class_name Main
extends Node


var path: Path3D

var camera: Camera3D
var player: Node3D
var rivals: Array = []


func _ready() -> void:
	camera = Camera3D.new()
	add_child(camera)

	player = Node3D.new()
	add_child(player)
	var player_mesh_3d = MeshInstance3D.new()
	player_mesh_3d.mesh = BoxMesh.new()
	player_mesh_3d.mesh.size = Vector3(8, 8, 16)
	player.add_child(player_mesh_3d)
	player_mesh_3d.material_override = StandardMaterial3D.new()
	player_mesh_3d.material_override.albedo_color = Color.from_hsv(0.0, 1.0, 1.0)

	path = Path3D.new()
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

	player.position = points[0]


	for point in points:
		path.curve.add_point(point)
	path.curve.add_point(points[0])

	var c = 100
	set_point_in_out(path.curve, 1, Vector3(c, 0, c))
	set_point_in_out(path.curve, 2, Vector3(c, 0, -c))
	set_point_in_out(path.curve, 4, Vector3(-c, 0, -c))
	set_point_in_out(path.curve, 5, Vector3(-c, 0, c))


	for i in range(5):
		var rival = Rival.new()
		add_child(rival)
		rival.setup(path, i / 6.0)
		rivals.append(rival)


	path.curve.bake_interval = 30
	var baked_points = path.curve.get_baked_points()


	var mesh_instance_3d = MeshInstance3D.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	var road_width_3d: float = 128.0
	var half_w = road_width_3d * 0.5

	for i in range(baked_points.size()):
		var current = baked_points[i]

		var next_pt = baked_points[(i + 1) % baked_points.size()]
		var prev_pt = baked_points[(i - 1 + baked_points.size()) % baked_points.size()]
		var dir = (next_pt - prev_pt).normalized()

		var side = dir.cross(Vector3.UP).normalized()

		# 左右の頂点を追加
		st.set_color(Color(0.2, 0.2, 0.2)) # 2Dと同じ道路色
		st.add_vertex(current - side * half_w)
		st.add_vertex(current + side * half_w)

	var array_mesh = st.commit()
	mesh_instance_3d.mesh = array_mesh

	# 両面描画用のマテリアルを設定（地面に埋もれないよう少しYを下げて配置）
	var road_mat = StandardMaterial3D.new()
	road_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	road_mat.vertex_color_use_as_albedo = true
	mesh_instance_3d.material_override = road_mat
	mesh_instance_3d.position.y = -0.01

	add_child(mesh_instance_3d)

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_A):
		player.rotation_degrees.y += 1
	if Input.is_key_pressed(KEY_D):
		player.rotation_degrees.y -= 1

	player.position += -player.transform.basis.z

	var closest_pt = path.curve.get_closest_point(player.position)
	closest_pt.y = 0
	var mesh_3d = player.get_child(0) as MeshInstance3D
	var mat = mesh_3d.material_override as StandardMaterial3D
	if (player.position - closest_pt).length() > 64:
		mat.albedo_color = Color.from_hsv(0.5, 1.0, 1.0)
	else:
		mat.albedo_color = Color.from_hsv(0.0, 1.0, 1.0)

	for rival in rivals:
		rival.update_behavior()

	for rival in rivals:
		rival.apply_player_collision(player)

	for i in range(rivals.size()):
		for j in range(i + 1, rivals.size()):
			var rival1 = rivals[i]
			var rival2 = rivals[j]
			rival1.apply_rival_collision(rival2)


	var target_position = player.position + player.transform.basis.z * 64 + Vector3(0, 64, 0)
	camera.position = camera.position.lerp(target_position, 10.0 * delta)
	camera.look_at(player.position + Vector3(0, 1.0, 0), Vector3.UP)


func set_point_in_out(curve: Curve3D, index: int, point: Vector3):
	curve.set_point_in(index, point)
	curve.set_point_out(index, -point)
