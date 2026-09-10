class_name Main
extends Node

var path: Path2D
var path_follow: PathFollow2D

var player: Node2D
var rival: Node2D

func _ready() -> void:
	var camera = Camera2D.new()
	add_child(camera)

	path = Path2D.new()
	add_child(path)
	path.curve = Curve2D.new()

	var points: Array[Vector2] = [
		Vector2(0, 0),
		Vector2(0, -200),
		Vector2(-200, -200),
		Vector2(-200, 200),
		Vector2(100, 200),
	]

	for point in points:
		path.curve.add_point(point)
	path.curve.add_point(points[0])

	path_follow = PathFollow2D.new()
	path_follow.loop = true
	path.add_child(path_follow)

	player = Node2D.new()
	add_child(player)
	var pl_mesh = MeshInstance2D.new()
	player.add_child(pl_mesh)
	pl_mesh.mesh = QuadMesh.new()
	pl_mesh.mesh.size = Vector2(12, 24)
	pl_mesh.modulate = Color(0.2, 0.2, 0.9)

	rival = Node2D.new()
	add_child(rival)
	var rival_mesh = MeshInstance2D.new()
	rival.add_child(rival_mesh)
	rival_mesh.mesh = QuadMesh.new()
	rival_mesh.mesh.size = Vector2(12, 24)
	rival_mesh.modulate = Color(0.9, 0.2, 0.2)


	var baked_points = path.curve.get_baked_points()
	var line_road = Line2D.new()
	line_road.width = 32
	line_road.default_color = Color(0.2, 0.2, 0.2)
	line_road.points = baked_points
	add_child(line_road)
	line_road.z_index = -1


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_A):
		player.rotation -= 0.1
	if Input.is_key_pressed(KEY_D):
		player.rotation += 0.1
	var direction = Vector2.UP.rotated(player.rotation)
	player.position += direction


	var closest_pt = path.curve.get_closest_point(player.position)
	if (player.position - closest_pt).length() > 16:
		player.modulate = Color(0.9, 0.2, 0.2)
	else:
		player.modulate = Color(0.2, 0.2, 0.9)


	if path_follow:
		path_follow.progress += 1

	var rival_direction = path_follow.position - rival.position
	rival.position = path_follow.position
	rival.rotation = rival_direction.angle() + PI / 2
