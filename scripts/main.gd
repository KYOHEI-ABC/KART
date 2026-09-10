class_name Main
extends Node

var path: Path2D

var player: Node2D
var rivals: Array[Node2D] = []
var rival_followers: Array[PathFollow2D] = []

func _ready() -> void:
	var camera = Camera2D.new()
	add_child(camera)

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


func set_point_in_out(curve: Curve2D, index: int, point: Vector2):
	curve.set_point_in(index, point)
	curve.set_point_out(index, -point)
