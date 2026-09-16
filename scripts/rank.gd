class_name Rank
extends Node

var karts: Array[Kart]
var rank_label: Label
var kart_laps: Array[int] = []
var previous_kart_offsets: Array[float] = []

func _init(race_karts: Array[Kart]):
	karts = race_karts
	for kart in karts:
		kart_laps.append(0)
		previous_kart_offsets.append(kart.path.curve.get_closest_offset(kart.position))

	var rank_panel = PanelContainer.new()
	rank_panel.position = Vector2(Main.WINDOW.x - 130, Main.WINDOW.y - 60)
	rank_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	rank_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var rank_container = VBoxContainer.new()
	rank_panel.add_child(rank_container)
	rank_label = Label.new()
	rank_label.add_theme_font_size_override("font_size", 32)
	rank_label.add_theme_color_override("font_color", Color.WHITE)
	rank_container.add_child(rank_label)
	var rank_layer = CanvasLayer.new()
	rank_layer.add_child(rank_panel)
	add_child(rank_layer)

func process() -> void:
	_update_lap_progress()
	_update_rank_display()

func _update_rank_display() -> void:
	var ranked_karts = karts.duplicate()
	ranked_karts.sort_custom(func(a: Kart, b: Kart):
		return _kart_progress(a) > _kart_progress(b)
	)

	for i in range(ranked_karts.size()):
		if ranked_karts[i].index == 0:
			rank_label.text = "Rank: %d" % (i + 1)
			return

func _kart_progress(kart: Kart) -> float:
	return kart_laps[kart.index] * kart.path.curve.get_baked_length() + kart.path.curve.get_closest_offset(kart.position)

func _update_lap_progress() -> void:
	var course_length = karts[0].path.curve.get_baked_length()
	for kart in karts:
		var current_offset = kart.path.curve.get_closest_offset(kart.position)
		var previous_offset = previous_kart_offsets[kart.index]
		if previous_offset > course_length * 0.75 and current_offset < course_length * 0.25:
			kart_laps[kart.index] += 1
		previous_kart_offsets[kart.index] = current_offset