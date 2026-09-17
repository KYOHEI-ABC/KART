class_name Rank
extends Node

var karts: Array[Kart]
var label: Label
var kart_laps: Array[int] = []
var previous_kart_offsets: Array[float] = []
const LAPS_TO_FINISH := 1

func _init(race_karts: Array[Kart]):
	karts = race_karts
	for kart in karts:
		kart_laps.append(0)
		previous_kart_offsets.append(kart.path.curve.get_closest_offset(kart.position))

	label = Label.new()
	add_child(label)
	label.position = Vector2(Main.WINDOW.x - 130, Main.WINDOW.y - 60)
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color.from_hsv(50 / 360.0, 1, 1))

func process() -> bool:
	var course_length = karts[0].path.curve.get_baked_length()

	for kart in karts:
		var current_offset = kart.path.curve.get_closest_offset(kart.position)
		var previous_offset = previous_kart_offsets[kart.index]
		if previous_offset > course_length * 0.75 and current_offset < course_length * 0.25:
			kart_laps[kart.index] += 1
		previous_kart_offsets[kart.index] = current_offset

	var ranked_karts = karts.duplicate()
	ranked_karts.sort_custom(func(a: Kart, b: Kart):
		return _kart_progress(a) > _kart_progress(b)
	)

	for i in range(ranked_karts.size()):
		if ranked_karts[i].index == 0:
			label.text = "Rank: %d" % (i + 1)
			break

	return kart_laps[0] >= LAPS_TO_FINISH

func _kart_progress(kart: Kart) -> float:
	var course_length = karts[0].path.curve.get_baked_length()
	return kart_laps[kart.index] * kart.path.curve.get_baked_length() + kart.path.curve.get_closest_offset(kart.position)
