class_name Zone

extends Node3D

var power: float
var radius: float

func _init(radius: float, power: float):
	self.radius = radius
	self.power = power

	add_child(Graphic.create_circle_mesh(radius, Color(1, 1, 0.2) if power > 1 else Color(0.2, 0.2, 0.2)))

func process(karts: Array[Kart]) -> void:
	for kart in karts:
		var dist_squared: float = position.distance_squared_to(kart.position)

		if dist_squared <= radius * radius:
			kart.velocity *= power
