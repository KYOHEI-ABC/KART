class_name Main
extends Node

var camera: Camera3D

var karts: Array[Kart] = []

static func create_road_mesh(curve: Curve3D) -> MeshInstance3D:
	var mesh_instance_3d = MeshInstance3D.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	var road_width_3d: float = 128.0
	var half_w = road_width_3d * 0.5
	var baked_points = curve.get_baked_points()

	for i in range(baked_points.size()):
		var current = baked_points[i]
		var next_pt = baked_points[(i + 1) % baked_points.size()]
		var prev_pt = baked_points[(i - 1 + baked_points.size()) % baked_points.size()]
		var dir = (next_pt - prev_pt).normalized()
		var side = dir.cross(Vector3.UP).normalized()

		st.set_color(Color(0.2, 0.2, 0.2))
		st.add_vertex(current - side * half_w)
		st.add_vertex(current + side * half_w)

	var array_mesh = st.commit()
	mesh_instance_3d.mesh = array_mesh

	var road_mat = StandardMaterial3D.new()
	road_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	road_mat.vertex_color_use_as_albedo = true
	mesh_instance_3d.material_override = road_mat
	mesh_instance_3d.position.y = -0.01

	return mesh_instance_3d

func _ready() -> void:
	camera = Camera3D.new()
	add_child(camera)


	var path = Path3D.new()
	add_child(path)
	path.curve = Curve3D.new()

	var points: Array[Vector3] = [
		Vector3(100, 0, 0),
		Vector3(0, 0, -500),
		Vector3(-500, 0, -500),
		Vector3(-600, 0, 0),
		Vector3(-500, 0, 500),
		Vector3(0, 0, 500),
	]

	karts.append(Kart.new(0, path))
	add_child(karts[0])

	karts[0].position = points[0]

	for point in points:
		path.curve.add_point(point)
	path.curve.add_point(points[0])

	var c = 100
	set_point_in_out(path.curve, 1, Vector3(c, 0, c))
	set_point_in_out(path.curve, 2, Vector3(c, 0, -c))
	set_point_in_out(path.curve, 4, Vector3(-c, 0, -c))
	set_point_in_out(path.curve, 5, Vector3(-c, 0, c))

	for i in range(1, 8):
		karts.append(Kart.new(i, path))
		add_child(karts[-1])

	path.curve.bake_interval = 30
	var mesh_instance_3d = Main.create_road_mesh(path.curve)
	add_child(mesh_instance_3d)


func _process(delta: float) -> void:
	var screen_width = get_viewport().get_visible_rect().size.x

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var touch_position = get_viewport().get_mouse_position()

		# 画面の左半分を押している場合
		if touch_position.x < screen_width / 2.0:
			karts[0].rotate_left(1.0)
		# 画面の右半分を押している場合
		else:
			karts[0].rotate_right(1.0)

	# PCでのテスト用に A/D キーでも動くように残す場合
	if Input.is_key_pressed(KEY_A):
		karts[0].rotate_left(1.0)
	if Input.is_key_pressed(KEY_D):
		karts[0].rotate_right(1.0)

	karts[0].move_forward()

	for kart in karts:
		kart.check_course_out()

	for i in range(1, karts.size()):
		karts[i].bot()

	for kart in karts:
		kart.resolve_collision(karts)

	var target_position = karts[0].position + karts[0].transform.basis.z * 64 + Vector3(0, 64, 0)
	camera.position = camera.position.lerp(target_position, 10.0 * delta)
	camera.look_at(karts[0].position + Vector3(0, 1.0, 0), Vector3.UP)


func set_point_in_out(curve: Curve3D, index: int, point: Vector3):
	curve.set_point_in(index, point)
	curve.set_point_out(index, -point)
