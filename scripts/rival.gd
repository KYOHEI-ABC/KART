class_name Rival
extends Node3D

var follower: PathFollow3D


func _init(index: int, path: Path3D):
	follower = PathFollow3D.new()
	path.add_child(follower)
	follower.loop = true
	follower.h_offset = randf_range(-64.0, 64.0)
	follower.progress_ratio = 0.0
	self.position = follower.position
	follower.progress_ratio = 0.03

	var color = Color.from_hsv(index / 6.0, 1.0, 1.0)
	add_child(Main.create_box_mesh(color))

func update_behavior() -> void:
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
