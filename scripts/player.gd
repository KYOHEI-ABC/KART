class_name Player
extends Kart

func _init():
	add_child(Kart.create_box_mesh(Color.from_hsv(0.0, 1.0, 1.0)))
