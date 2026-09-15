class_name Kart
extends Node3D

var index: int
var velocity: Vector3 = Vector3.ZERO
var bot: Bot = null

var model: Node3D
var model_roll_angle: float = 0.0

func _init(i: int, path: Path3D):
	self.index = i

	position = path.curve.get_baked_points()[0]

	if not index == 0:
		bot = Bot.new(self, path)

	model = Graphic.create_box_mesh(Color.from_hsv(index / 8.0, 1, 0.5))
	add_child(model)

	var character_model = Graphic.MODELS[0].instantiate()
	model.add_child(character_model)
	character_model.scale = Vector3(0.05, 0.05, 0.05)
	character_model.position.y = -2.4

	model.position.y = 2
	model.rotation_degrees.y = 180

func process(karts: Array[Kart]) -> void:
	velocity += -transform.basis.z * 0.03
	position += velocity
	velocity *= 0.99

	if bot:
		bot.process(karts)

	collision(karts)

	model.rotation_degrees.z = model.rotation_degrees.z * 0.97

func turn(left: bool) -> void:
	var degree = 0.5
	if not left:
		degree *= -1
	self.rotation_degrees.y += degree
	velocity = velocity.lerp(Vector3.ZERO, 0.03)

	model.rotation_degrees.z += -1 if left else 1


func collision(karts: Array[Kart]) -> void:
	for k in karts:
		if k == self:
			continue

		var diff = position - k.position
		diff.y = 0.0
		if diff.length() == 0.0 or diff.length() >= 8.0:
			continue

		velocity += diff.normalized() * 0.3
		k.velocity -= diff.normalized() * 0.3