class_name Kart
extends Node3D

var index: int
var velocity: Vector3 = Vector3.ZERO

var path: Path3D
var bot: Bot = null


var model: Node3D
var model_roll_angle: float = 0.0

func _init(i: int, path: Path3D):
	self.index = i
	self.path = path

	position = path.curve.get_baked_points()[0]

	if not index == 0:
		bot = Bot.new(self)

	model = Graphic.create_box_mesh(Color.from_hsv(index / 8.0, 1, 0.5))
	add_child(model)

	var character_model = Graphic.MODELS[i].instantiate()
	match index:
		0:
			character_model.scale = Vector3(0.05, 0.05, 0.05)
			character_model.position.y = -2.4
			Graphic.set_material_color(model, Color.from_hsv(0, 1, 1))
		1:
			character_model.scale = Vector3(18, 18, 18)
			character_model.position.y = -2
			Graphic.set_material_color(model, Color.from_hsv(140 / 360.0, 1, 1))
		2:
			character_model.scale = Vector3(5, 5, 5)
			character_model.position.y = -3.5
			character_model.rotation_degrees = Vector3(90, 0, 0)
			Graphic.set_material_color(model, Color.from_hsv(330 / 360.0, 0.8, 1))
		3:
			character_model.scale = Vector3(5, 5, 5)
			character_model.position.y = -3.5
			character_model.rotation_degrees = Vector3(90, 0, 0)
			Graphic.set_material_color(model, Color.from_hsv(120 / 360.0, 1, 1))
		4:
			character_model.scale = Vector3(5, 5, 5)
			character_model.position.y = 0.5
			character_model.rotation_degrees = Vector3(90, 0, 0)
			Graphic.set_material_color(model, Color.from_hsv(240 / 360.0, 1, 1))
		5:
			character_model.scale = Vector3(2.5, 2.5, 2.5)
			character_model.position.y = -2.2
			Graphic.set_material_color(model, Color.from_hsv(60 / 360.0, 1, 1))

		_:
			pass


	model.add_child(character_model)
	model.position.y = 2
	model.rotation_degrees.y = 180

func process(karts: Array[Kart]) -> void:
	velocity += -transform.basis.z * 0.03
	position += velocity
	velocity *= 0.99

	if bot:
		bot.process(karts)

	collision(karts)

	check_course_out()

	model.rotation_degrees.z = model.rotation_degrees.z * 0.97

func turn(degree: float) -> void:
	self.rotation_degrees.y += degree
	velocity = velocity.lerp(Vector3.ZERO, 0.03)

	model.rotation_degrees.z += -1 if degree > 0 else 1


func collision(karts: Array[Kart]) -> void:
	for k in karts:
		if k == self:
			continue

		var diff = position - k.position
		diff.y = 0.0
		if diff.length() == 0.0 or diff.length() >= 8.0:
			continue

		# velocity += diff.normalized() * 0.08
		k.velocity -= diff.normalized() * 0.08

func check_course_out() -> void:
	var closest_pt = path.curve.get_closest_point(position)
	closest_pt.y = 0.0
	if (position - closest_pt).length() > 48.0:
		if index == 0:
			velocity = velocity.lerp(Vector3.ZERO, 0.1)
		else:
			velocity = velocity.lerp(Vector3.ZERO, 0.03)
		Graphic.set_material_color_v(model, 0.25)
	else:
		Graphic.set_material_color_v(model, 0.5)
