class_name Kart
extends Node3D

var index: int
var follower: PathFollow3D
var path: Path3D

var power: Vector3 = Vector3.ZERO
var model_roll_angle: float = 0.0

const MODEL_ROLL_LIMIT_DEG: float = 60.0

const MODELS: Array[PackedScene] = [
	preload("res://assets/kart.glb"),
	preload("res://assets/kart.glb"),
	preload("res://assets/kart.glb"),
	preload("res://assets/kart.glb"),
	preload("res://assets/kart.glb"),
]

const CHARA_MODELS: Array[PackedScene] = [
	preload("res://assets/mario.glb"),
	preload("res://assets/bowser.glb"),
	preload("res://assets/goomba.glb"),

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
		power += push_dir * 0.3
		other.power -= push_dir * 0.3

func _init(index: int, path: Path3D):
	self.index = index
	self.path = path

	var model = MODELS[index % 5].instantiate()
	add_child(model)
	model.scale = Vector3(12, 12, 12)
	model.rotation_degrees.y = 180
	var mesh_instance = model.get_child(1) as MeshInstance3D
	var original_mat = mesh_instance.mesh.surface_get_material(0)
	var unique_mat = original_mat.duplicate() as StandardMaterial3D
	unique_mat.albedo_color = Color.from_hsv(index / 9.0, 0.9, 0.8)
	mesh_instance.set_surface_override_material(0, unique_mat)
	# add_child(create_box_mesh(Color.from_hsv(index / 8.0, 0.4, 0.9)))

	var chara_model = null

	if index == 0:
		chara_model = CHARA_MODELS[0].instantiate()
		chara_model.scale = Vector3(2, 2, 2)
	elif index == 1:
		chara_model = CHARA_MODELS[1].instantiate()
		chara_model.scale = Vector3(0.05, 0.05, 0.05)
		chara_model.position = Vector3(0, 0.5, 0.18)
	else:
		chara_model = CHARA_MODELS[2].instantiate()
		chara_model.scale = Vector3(0.03, 0.03, 0.03)
		chara_model.position = Vector3(0, 0.2, 0.0)

	set_shading_per_vertex(chara_model)

	model.add_child(chara_model)

	if index == 0:
		return
	follower = PathFollow3D.new()
	path.add_child(follower)
	follower.loop = true
	follower.h_offset = randf_range(-64.0 * 0.9, 64.0 * 0.9)
	follower.progress_ratio = 0.0
	self.position = follower.position
	follower.progress_ratio = 0.03


func set_shading_per_vertex(node: Node) -> void:
	if node is MeshInstance3D:
		for i in node.get_surface_override_material_count():
			var mat = node.get_active_material(i)
			if mat is BaseMaterial3D:
				# 共通マテリアルに影響を出さないよう duplicate() する
				var new_mat = mat.duplicate() as BaseMaterial3D
				new_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				# new_mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX

				# スペキュラ（ツヤ）もカット
				new_mat.roughness = 1.0
				new_mat.metallic_specular = 0.0

				node.set_surface_override_material(i, new_mat)

	for child in node.get_children():
		set_shading_per_vertex(child)

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
