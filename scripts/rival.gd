class_name Rival
extends Node3D

var follower: PathFollow3D

func setup(path: Path3D, color_hue: float) -> void:
	follower = PathFollow3D.new()
	follower.loop = true
	path.add_child(follower)
	follower.h_offset = randf_range(-64.0, 64.0)
	follower.progress_ratio = 0.0
	self.position = follower.position
	follower.progress_ratio = 0.03

	var rival_mesh_3d = MeshInstance3D.new()
	rival_mesh_3d.mesh = BoxMesh.new()
	rival_mesh_3d.mesh.size = Vector3(8, 8, 16)
	add_child(rival_mesh_3d)
	rival_mesh_3d.material_override = StandardMaterial3D.new()
	rival_mesh_3d.material_override.albedo_color = Color.from_hsv(color_hue, 1.0, 1.0)

func update_behavior() -> void:
	if follower == null:
		return

	var distance = self.position.distance_to(follower.position)
	if distance < 16.0:
		follower.progress_ratio += 0.01

	var current_direction = - self.transform.basis.z
	var target_direction = (follower.position - self.position).normalized()
	var angle_diff = current_direction.signed_angle_to(target_direction, Vector3.UP)

	if angle_diff > 0.1:
		self.rotation_degrees.y += 1
	elif angle_diff < -0.1:
		self.rotation_degrees.y -= 1

	var forward = - self.transform.basis.z
	self.position += forward * randf_range(0.8, 1.1)

func apply_player_collision(player: Node3D) -> void:
	var diff = player.position - self.position
	diff.y = 0.0

	if diff.length() < 8.0:
		var push_dir = diff.normalized()
		player.position += push_dir
		self.position -= push_dir

func apply_rival_collision(other: Rival) -> void:
	var diff = self.position - other.position
	diff.y = 0.0

	if diff.length() < 8.0:
		var push_dir = diff.normalized()
		self.position += push_dir
		other.position -= push_dir
