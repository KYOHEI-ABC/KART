class_name Kart
extends Node3D

var index: int
var follower: PathFollow3D
var path: Path3D

static func create_box_mesh(color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(8, 8, 16)
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = StandardMaterial3D.new()
	mesh_instance.material_override.albedo_color = color
	return mesh_instance

func check_course_out() -> void:
	var closest_pt = path.curve.get_closest_point(self.position)
	closest_pt.y = 0.0
	var mesh_3d = self.get_child(0) as MeshInstance3D
	var mat = mesh_3d.material_override as StandardMaterial3D
	if (self.position - closest_pt).length() > 64:
		mat.albedo_color = Color.from_hsv(index / 6.0, 1.0, 0.5)
	else:
		mat.albedo_color = Color.from_hsv(index / 6.0, 1.0, 1.0)

func resolve_collision(others: Array[Kart]) -> void:
	for other in others:
		if other == self:
			continue

		var diff = self.position - other.position
		diff.y = 0.0
		var dist = diff.length()
		if dist == 0.0 or dist >= 8.0:
			continue

		var push_dir = diff.normalized()
		var overlap = 8.0 - dist
		self.position += push_dir * overlap * 0.5
		other.position -= push_dir * overlap * 0.5

func _init(index: int, path: Path3D):
	self.index = index
	self.path = path
	add_child(create_box_mesh(Color.from_hsv(index / 6.0, 1.0, 1.0)))

	if index == 0:
		return
	follower = PathFollow3D.new()
	path.add_child(follower)
	follower.loop = true
	follower.h_offset = randf_range(-64.0, 64.0)
	follower.progress_ratio = 0.0
	self.position = follower.position
	follower.progress_ratio = 0.03


func bot() -> void:
	var distance = self.position.distance_to(follower.position)
	if distance < 16.0:
		follower.progress_ratio += 0.01

	var target_direction = follower.position - self.position
	if target_direction.length() > 0.0:
		self.rotate_toward_direction(target_direction, 1.0)

	self.move_forward(randf_range(0.8, 1.1))

func move_forward(speed: float = 1.0) -> void:
	var forward = - self.transform.basis.z
	self.position += forward * speed

func rotate_left(amount: float = 1.0) -> void:
	self.rotation_degrees.y += amount

func rotate_right(amount: float = 1.0) -> void:
	self.rotation_degrees.y -= amount

func rotate_toward_direction(target_direction: Vector3, step: float = 1.0) -> void:
	if target_direction.length() == 0.0:
		return

	var current_direction = - self.transform.basis.z
	var angle_diff = current_direction.signed_angle_to(target_direction.normalized(), Vector3.UP)

	if angle_diff > 0.1:
		self.rotate_left(step)
	elif angle_diff < -0.1:
		self.rotate_right(step)
