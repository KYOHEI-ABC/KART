class_name MiniMap
extends CanvasLayer

var kart_markers: Array[Polygon2D] = []
var map_origin: Vector2 = Vector2(Main.WINDOW.x - 48, 48.0)
var map_scale: float = 0.08

func _init(path: Path3D, karts: Array[Kart]):
	var course_line := Line2D.new()
	course_line.width = 64 * map_scale
	add_child(course_line)

	var baked_points := path.curve.get_baked_points()
	var mapped_points := PackedVector2Array()
	mapped_points.resize(baked_points.size())
	for i in range(baked_points.size()):
		mapped_points[i] = _project_to_minimap(baked_points[i])
	course_line.points = mapped_points

	for kart in karts:
		var marker := _create_marker(kart.color)
		add_child(marker)
		kart_markers.append(marker)

func _project_to_minimap(point: Vector3) -> Vector2:
	return map_origin + Vector2(point.x, point.z) * map_scale

func _create_marker(color: Color) -> Polygon2D:
	var marker := Polygon2D.new()
	marker.color = color

	var points := PackedVector2Array()
	points.resize(8)
	for i in range(8):
		var angle := TAU * float(i) / float(8)
		points[i] = Vector2(cos(angle), sin(angle)) * 5
	marker.polygon = points
	return marker

func process(karts: Array[Kart]) -> void:
	for i in range(karts.size()):
		kart_markers[i].position = _project_to_minimap(karts[i].position)
