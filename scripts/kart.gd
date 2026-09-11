class_name Kart
extends Node3D

static func create_box_mesh(color: Color) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(8, 8, 16)
	mesh_instance.mesh = box_mesh
	mesh_instance.material_override = StandardMaterial3D.new()
	mesh_instance.material_override.albedo_color = color
	return mesh_instance

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
