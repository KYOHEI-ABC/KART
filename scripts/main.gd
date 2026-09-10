class_name Main
extends Node

var path_follow: PathFollow2D

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

	var path = Path2D.new()
	path.curve = Curve2D.new()

	for point in points:
		path.curve.add_point(point)

	path.curve.add_point(points[0])

	add_child(path)


	var baked_points = path.curve.get_baked_points()
	var line_road = Line2D.new()
	line_road.width = 16
	line_road.default_color = Color(0.2, 0.2, 0.2) # ダークグレー
	line_road.points = baked_points
	add_child(line_road)
	path_follow = PathFollow2D.new()
	path_follow.loop = true
	path_follow.rotates = true
	path.add_child(path_follow)
	line_road.z_index = -1


	var follower_mesh = MeshInstance2D.new()
	var box_mesh = QuadMesh.new()
	box_mesh.size = Vector2(24, 12)
	follower_mesh.mesh = box_mesh
	follower_mesh.modulate = Color(0.9, 0.2, 0.2)
	path_follow.add_child(follower_mesh)


func _process(delta: float) -> void:
	if path_follow:
		path_follow.progress += 1
