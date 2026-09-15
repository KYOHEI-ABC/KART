class_name Bot

var kart: Kart
var follower: PathFollow3D
var target_distance: float

func _init(kart: Kart):
	self.kart = kart

	follower = PathFollow3D.new()
	kart.path.add_child(follower)
	follower.loop = true
	follower.h_offset = randf_range(-3, 3)
	follower.progress_ratio = 0.03
	kart.position = follower.position
	# follower.progress_ratio = 0.03

	target_distance = randf_range(0.03, 0.1)

func process(karts: Array[Kart]) -> void:
	follower.progress = kart.path.curve.get_closest_offset(kart.position) + kart.path.curve.get_baked_length() * target_distance
	var target_direction = follower.position - kart.position
	if (-kart.transform.basis.z).signed_angle_to(target_direction.normalized(), Vector3.UP) > 0.1:
		kart.turn(0.75)
	elif (-kart.transform.basis.z).signed_angle_to(target_direction.normalized(), Vector3.UP) < -0.1:
		kart.turn(-0.75)

	adjust_speed(karts[0])


func adjust_speed(target: Kart) -> void:
	var length = kart.path.curve.get_baked_length()
	var diff = kart.path.curve.get_closest_offset(target.position) / length - kart.path.curve.get_closest_offset(kart.position) / length

	if diff > 0.5:
		diff -= 1.0
	elif diff < -0.5:
		diff += 1.0

	if diff > 0.01:
		follower.progress_ratio = kart.path.curve.get_closest_offset(target.position) / length - 0.01
		kart.position = follower.position
		# kart.velocity *= 1.05
	elif diff < -0.03:
		kart.velocity *= 0.99
	else:
		kart.velocity *= 1.005