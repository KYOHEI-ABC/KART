class_name Bot

var kart: Kart
var follower: PathFollow3D
var path: Path3D

func _init(kart: Kart, path: Path3D):
	self.kart = kart
	self.path = path

	follower = PathFollow3D.new()
	path.add_child(follower)
	follower.loop = true
	follower.h_offset = randf_range(-64.0 * 0.9, 64.0 * 0.9)
	follower.progress_ratio = 0.0
	kart.position = follower.position
	follower.progress_ratio = 0.03

func process(karts: Array[Kart]) -> void:
	follower.progress = path.curve.get_closest_offset(kart.position) + path.curve.get_baked_length() * 0.01
	var target_direction = follower.position - kart.position
	if (-kart.transform.basis.z).signed_angle_to(target_direction.normalized(), Vector3.UP) > 0.1:
		kart.turn(true)
	elif (-kart.transform.basis.z).signed_angle_to(target_direction.normalized(), Vector3.UP) < -0.1:
		kart.turn(false)

	adjust_speed(karts[0])


func adjust_speed(target: Kart) -> void:
	var length = path.curve.get_baked_length()
	var diff = path.curve.get_closest_offset(target.position) / length - path.curve.get_closest_offset(kart.position) / length

	if diff > 0.5:
		diff -= 1.0
	elif diff < -0.5:
		diff += 1.0

	if diff > 0.03:
		follower.progress_ratio = path.curve.get_closest_offset(target.position) / length - 0.03
		kart.position = follower.position
	elif diff < -0.1:
		kart.velocity *= 0.99
