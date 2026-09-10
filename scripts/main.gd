class_name Main
extends Node

var path: Path2D
var path_follow: PathFollow2D
var player: Node2D

func _ready() -> void:
	var camera = Camera2D.new()
	add_child(camera)

	var points: Array[Vector2] = [
		Vector2(0, 0),
		Vector2(0, -200),
		Vector2(-200, -200),
		Vector2(-200, 200),
		Vector2(100, 200),
	]

	path = Path2D.new()
	path.curve = Curve2D.new()

	for point in points:
		path.curve.add_point(point)

	path.curve.add_point(points[0])

	add_child(path)

	var baked_points = path.curve.get_baked_points()
	var line_road = Line2D.new()
	line_road.width = 32
	line_road.default_color = Color(0.2, 0.2, 0.2)
	line_road.points = baked_points
	add_child(line_road)
	line_road.z_index = -1

	path_follow = PathFollow2D.new()
	path_follow.loop = true
	path_follow.rotates = true
	path.add_child(path_follow)

	var follower_mesh = MeshInstance2D.new()
	var box_mesh = QuadMesh.new()
	box_mesh.size = Vector2(12, 24)
	follower_mesh.mesh = box_mesh
	follower_mesh.modulate = Color(0.9, 0.2, 0.2)

	follower_mesh.rotation = PI / 2

	path_follow.add_child(follower_mesh)

	player = Node2D.new()
	var pl_mesh = MeshInstance2D.new()
	var pl_box_mesh = QuadMesh.new()
	pl_box_mesh.size = Vector2(12, 24)
	pl_mesh.mesh = pl_box_mesh
	pl_mesh.modulate = Color(0.2, 0.2, 0.9)
	player.add_child(pl_mesh)
	add_child(player)

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_A):
		player.rotation -= delta
	if Input.is_key_pressed(KEY_D):
		player.rotation += delta
	var direction = Vector2.UP.rotated(player.rotation)
	player.position += direction


	var closest_pt = path.curve.get_closest_point(player.position)
	if (player.position - closest_pt).length() > 16:
		player.modulate = Color(0.9, 0.2, 0.2)
	else:
		player.modulate = Color(0.2, 0.2, 0.9)


	if path_follow:
		path_follow.progress += 1