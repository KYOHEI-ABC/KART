class_name Kart
extends Node3D

var index: int
var follower: PathFollow3D
var path: Path3D

var power: Vector3 = Vector3.ZERO
var model_roll_angle: float = 0.0

const MODEL_ROLL_LIMIT_DEG: float = 60.0

const MODELS: Array[PackedScene] = [
	preload("res://assets/kart-oobi.glb"),
	preload("res://assets/kart-oodi.glb"),
	preload("res://assets/kart-ooli.glb"),
	preload("res://assets/kart-oopi.glb"),
	preload("res://assets/kart-oozi.glb"),
]

static func create_box_mesh(color: Color) -> MeshInstance3D:
	return
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(8, 8, 16)
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = StandardMaterial3D.new()
	mesh_instance.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override.albedo_color = color
	return mesh_instance

func check_course_out() -> void:
	var closest_pt = path.curve.get_closest_point(position)
	closest_pt.y = 0.0
	# var mat = (get_child(0) as MeshInstance3D).material_override as StandardMaterial3D
	# print(get_child(0))
	if (position - closest_pt).length() > 64:
	# 	mat.albedo_color.v = 0.45
		if index == 0:
			power = power.lerp(Vector3.ZERO, 0.1)
		else:
			power = power.lerp(Vector3.ZERO, 0.03)
	# else:
	# 	mat.albedo_color.v = 0.9

func resolve_collision(others: Array[Kart]) -> void:
	for other in others:
		if other == self:
			continue

		var diff = position - other.position
		diff.y = 0.0
		if diff.length() == 0.0 or diff.length() >= 8.0:
			continue

		var push_dir = diff.normalized()
		power += push_dir * 0.1
		other.power -= push_dir * 0.1

func _init(index: int, path: Path3D):
	self.index = index
	self.path = path

	add_child(MODELS[index % 5].instantiate())
	get_child(0).scale = Vector3(8, 8, 8)
	get_child(0).rotation_degrees.y = 180

	# add_child(create_box_mesh(Color.from_hsv(index / 8.0, 0.4, 0.9)))


	if index == 0:
		return
	follower = PathFollow3D.new()
	path.add_child(follower)
	follower.loop = true
	follower.h_offset = randf_range(-64.0 * 0.9, 64.0 * 0.9)
	follower.progress_ratio = 0.0
	self.position = follower.position
	follower.progress_ratio = 0.03


func bot() -> void:
	follower.progress = path.curve.get_closest_offset(position) + path.curve.get_baked_length() * 0.01

	var target_direction = follower.position - position
	if target_direction.length() > 0.0:
		rotate_toward_direction(target_direction, 1.0)

	move_forward()

func move_forward() -> void:
	power += -transform.basis.z * 0.05
	position += power
	power *= 0.99

	model_roll_angle = lerp(model_roll_angle, 0.0, 0.03)
	get_child(0).rotation_degrees.z = model_roll_angle


func rotate_left(amount: float = 1.0) -> void:
	self.rotation_degrees.y += amount
	power = power.lerp(Vector3.ZERO, 0.03)
	model_roll_angle = lerp(model_roll_angle, -MODEL_ROLL_LIMIT_DEG, 0.035)


func rotate_right(amount: float = 1.0) -> void:
	self.rotation_degrees.y -= amount
	power = power.lerp(Vector3.ZERO, 0.03)
	model_roll_angle = lerp(model_roll_angle, MODEL_ROLL_LIMIT_DEG, 0.035)

func rotate_toward_direction(target_direction: Vector3, step: float = 1.0) -> void:
	if target_direction.length() == 0.0:
		return

	var current_direction = - self.transform.basis.z
	var angle_diff = current_direction.signed_angle_to(target_direction.normalized(), Vector3.UP)

	if angle_diff > 0.1:
		self.rotate_left(step)
	elif angle_diff < -0.1:
		self.rotate_right(step)

func adjust_speed(others: Array[Kart]) -> void:
	var total_length = path.curve.get_baked_length()
	var diff = path.curve.get_closest_offset(others[0].position) / total_length - path.curve.get_closest_offset(position) / total_length

	if diff > 0.5:
		diff -= 1.0
	elif diff < -0.5:
		diff += 1.0

	if diff > 0.03:
		# ライバルが遅れている
		follower.progress_ratio = path.curve.get_closest_offset(others[0].position) / total_length - 0.03
		position = follower.position
	elif diff < -0.3:
		# ライバルが先行
		power *= 0.99
