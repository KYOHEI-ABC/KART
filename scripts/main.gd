class_name Main
extends Node

var path: Path2D

var player: Node2D
var rivals: Array[Node2D] = []
var rival_followers: Array[PathFollow2D] = []

var camera_3D: Camera3D
var player_3D: Node3D
var rivals_3D: Array[Node3D] = []

func _ready() -> void:
	# var camera = Camera2D.new()
	# add_child(camera)
	path = Path2D.new()
	add_child(path)
	path.curve = Curve2D.new()

	var points: Array[Vector2] = [
		Vector2(55, 0),
		Vector2(0, -200),
		Vector2(-200, -200),
		Vector2(-255, -0),
		Vector2(-200, 200),
		Vector2(0, 200),
	]

	for point in points:
		path.curve.add_point(point)
	path.curve.add_point(points[0])

	var c = 55
	set_point_in_out(path.curve, 1, Vector2(c, c))
	set_point_in_out(path.curve, 2, Vector2(c, -c))
	set_point_in_out(path.curve, 4, Vector2(-c, -c))
	set_point_in_out(path.curve, 5, Vector2(-c, c))


	player = Node2D.new()
	add_child(player)
	var pl_mesh = MeshInstance2D.new()
	player.add_child(pl_mesh)
	pl_mesh.mesh = QuadMesh.new()
	pl_mesh.mesh.size = Vector2(12, 24)
	player.z_index = 128


	for i in range(5):
		var rival_follower = PathFollow2D.new()
		rival_follower.loop = true
		path.add_child(rival_follower)
		rival_followers.append(rival_follower)
		rival_follower.v_offset = randf_range(-32.0, 32.0)

		var rival = Node2D.new()
		add_child(rival)
		rivals.append(rival)

		var rival_mesh = MeshInstance2D.new()
		rival.add_child(rival_mesh)
		rival_mesh.mesh = QuadMesh.new()
		rival_mesh.mesh.size = Vector2(12, 24)
		rival_mesh.modulate = Color.from_hsv(i / 6.0, 0.8, 0.7)

		rival_follower.progress_ratio = 0
		rival.position = rival_follower.position
		rival_follower.progress_ratio = 0.03

		var follower_mesh = MeshInstance2D.new()
		rival_follower.add_child(follower_mesh)
		follower_mesh.mesh = QuadMesh.new()
		follower_mesh.mesh.size = Vector2(12, 12)
		follower_mesh.modulate = Color.from_hsv(i / 6.0, 0.6, 0.5)
		follower_mesh.z_index = 64


	var baked_points = path.curve.get_baked_points()
	var line_road = Line2D.new()
	line_road.width = 64
	line_road.default_color = Color(0.2, 0.2, 0.2)
	line_road.points = baked_points
	add_child(line_road)
	line_road.z_index = -1

	player.position = rivals[0].position

	player_3D = Node3D.new()
	add_child(player_3D)
	var player_mesh_3d = MeshInstance3D.new()
	player_mesh_3d.mesh = BoxMesh.new()
	player_mesh_3d.mesh.size = Vector3(1, 1, 2)
	player_3D.add_child(player_mesh_3d)

	camera_3D = Camera3D.new()
	add_child(camera_3D)
	camera_3D.position = Vector3(0, 8, 8)
	camera_3D.look_at(player_3D.position, Vector3.UP)

	var light = DirectionalLight3D.new()
	add_child(light)

	for i in range(5):
		var rival_3D = Node3D.new()
		add_child(rival_3D)
		rivals_3D.append(rival_3D)

		var rival_mesh_3D = MeshInstance3D.new()
		rival_mesh_3D.mesh = BoxMesh.new()
		rival_mesh_3D.mesh.size = Vector3(1, 1, 2)
		rival_3D.add_child(rival_mesh_3D)


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_A):
		player.rotation -= 0.05
	if Input.is_key_pressed(KEY_D):
		player.rotation += 0.05
	var direction = Vector2.UP.rotated(player.rotation)
	player.position += direction

	var closest_pt = path.curve.get_closest_point(player.position)
	if (player.position - closest_pt).length() > 32:
		player.modulate = Color.from_hsv(0.9, 1.0, 0.5)
	else:
		player.modulate = Color.from_hsv(0.9, 1.0, 1.0)

	for i in range(rival_followers.size()):
		var follower = rival_followers[i]
		var rival = rivals[i]

		var distance = (rival.position - follower.position).length()

		if distance < 16:
			follower.progress_ratio += 0.01
		else:
			pass

		var current_direction = Vector2.UP.rotated(rival.rotation)
		var target_direction = (follower.position - rival.position).normalized()
		var angle_diff = current_direction.angle_to(target_direction)
		if angle_diff > 0.1:
			rival.rotation += 0.05
		elif angle_diff < -0.1:
			rival.rotation -= 0.05
		rival.position += Vector2.UP.rotated(rival.rotation) * randf_range(0.8, 1.1)

	for rival in rivals:
		var diff = player.position - rival.position
		if diff.length() < 16:
			player.position += diff.normalized()
			rival.position -= diff.normalized()

	for rival in rivals:
		for rival2 in rivals:
			if rival == rival2:
				continue
			var diff = rival.position - rival2.position
			if diff.length() < 16:
				rival.position += diff.normalized()
				rival2.position -= diff.normalized()

	player_3D.position = Vector3(player.position.x, 0, player.position.y)
	player_3D.rotation = Vector3(0, -player.rotation, 0)


	var distance = 8.0
	var height = 3.0
	var target_position = player_3D.position + player_3D.transform.basis.z * distance + Vector3(0, height, 0)
	camera_3D.position = camera_3D.position.lerp(target_position, 10.0 * delta)
	camera_3D.look_at(player_3D.position + Vector3(0, 1.0, 0), Vector3.UP)


	for i in range(rivals.size()):
		rivals_3D[i].position = Vector3(rivals[i].position.x, 0, rivals[i].position.y)
		rivals_3D[i].rotation = Vector3(0, -rivals[i].rotation, 0)


func set_point_in_out(curve: Curve2D, index: int, point: Vector2):
	curve.set_point_in(index, point)
	curve.set_point_out(index, -point)
