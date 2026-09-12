class_name Main
extends Node

var camera: Camera3D

var karts: Array[Kart] = []
var dash_zones: Array[Node3D] = []
var obstacles: Array[Node3D] = []

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


	var light = DirectionalLight3D.new()
	light.position = Vector3(100, 160, -80)
	light.rotation_degrees = Vector3(-45, -45, 0)
	light.shadow_enabled = true
	add_child(light)

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

	spawn_dash_zones(path.curve, 4)
	spawn_obstacles(path.curve, 5)


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


	apply_obstacle_collision()
	apply_dash_boost()

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


static func create_dash_zone_mesh() -> MeshInstance3D:
	var zone_mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(36.0, 0.5, 56.0)
	zone_mesh.mesh = box_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.0, 1.0, 0.4, 0.85)
	zone_mesh.material_override = material
	return zone_mesh

static func create_obstacle_mesh() -> MeshInstance3D:
	var obstacle_mesh = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(22.0, 30.0, 22.0)
	obstacle_mesh.mesh = box_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.2, 0.2, 1.0)
	obstacle_mesh.material_override = material
	return obstacle_mesh

func spawn_dash_zones(curve: Curve3D, count: int = 4) -> void:
	var points = curve.get_baked_points()
	if points.is_empty():
		return

	for i in range(count):
		var idx = randi() % points.size()
		var point = points[idx]
		point.y = 0.0

		var prev_idx = (idx - 1 + points.size()) % points.size()
		var next_idx = (idx + 1) % points.size()
		var tangent = (points[next_idx] - points[prev_idx]).normalized()
		if tangent.length() == 0.0:
			tangent = Vector3.FORWARD

		var zone = Node3D.new()
		zone.position = point
		zone.look_at_from_position(point, point + tangent, Vector3.UP)
		var mesh = Main.create_dash_zone_mesh()
		mesh.position.y = 0.4
		zone.add_child(mesh)
		add_child(zone)
		dash_zones.append(zone)

func spawn_obstacles(curve: Curve3D, count: int = 3) -> void:
	var points = curve.get_baked_points()
	if points.is_empty():
		return

	for i in range(count):
		var idx = randi() % points.size()
		var point = points[idx]
		point.y = 0.0

		var obstacle = Node3D.new()
		obstacle.position = point
		var mesh = Main.create_obstacle_mesh()
		mesh.position.y = 15.0
		obstacle.add_child(mesh)
		add_child(obstacle)
		obstacles.append(obstacle)

func apply_obstacle_collision() -> void:
	for obstacle in obstacles:
		for kart in karts:
			var diff = kart.position - obstacle.position
			diff.y = 0.0
			var dist = diff.length()
			if dist < 22.0:
				# kart.stun_timer = 1
				kart.power *= 0.9

				# var push_dir = diff.normalized()
				# if push_dir.length() == 0.0:
				# 	push_dir = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()

				# # kart.position += push_dir * 30.0
				# kart.power += push_dir

func apply_dash_boost() -> void:
	for zone in dash_zones:
		for kart in karts:
			var dist = (zone.position - kart.position).length()
			if dist < 30.0:
				var forward = - kart.transform.basis.z
				kart.power += forward * 0.4

func set_point_in_out(curve: Curve3D, index: int, point: Vector3):
	curve.set_point_in(index, point)
	curve.set_point_out(index, -point)
