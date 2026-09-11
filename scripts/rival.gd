class_name Rival
extends Kart

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
	add_child(Kart.create_box_mesh(color))

func update_behavior() -> void:
	var distance = self.position.distance_to(follower.position)
	if distance < 16.0:
		follower.progress_ratio += 0.01

	var target_direction = follower.position - self.position
	if target_direction.length() > 0.0:
		self.rotate_toward_direction(target_direction, 1.0)

	self.move_forward(randf_range(0.8, 1.1))
