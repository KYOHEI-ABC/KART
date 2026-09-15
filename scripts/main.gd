class_name Main
extends Node

static var WINDOW: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)


var camera: Camera3D

var karts: Array[Kart] = []
var zones: Array[Zone] = []

func _ready() -> void:
	camera = Camera3D.new()
	add_child(camera)
	camera.position.y = 512
	camera.rotation_degrees.x = -90
	camera.fov = 45

	var ground = Graphic.create_ground_mesh()
	add_child(ground)
	ground.position.y = -0.01

	var path = Path3D.new()
	add_child(path)
	path.curve = Curve3D.new()

	var course_points: Array[Vector3] = [
		Vector3(100, 0, 0),
		Vector3(0, 0, -500),
		Vector3(-500, 0, -500),
		Vector3(-600, 0, 0),
		Vector3(-500, 0, 500),
		Vector3(0, 0, 500),
	]

	for course_point in course_points:
		path.curve.add_point(course_point)
	path.curve.add_point(course_points[0])

	var p = 100
	set_point_in_out(path.curve, 1, Vector3(p, 0, p))
	set_point_in_out(path.curve, 2, Vector3(p, 0, -p))
	set_point_in_out(path.curve, 4, Vector3(-p, 0, -p))
	set_point_in_out(path.curve, 5, Vector3(-p, 0, p))

	path.curve.bake_interval = path.curve.get_baked_length() * 0.03
	add_child(Graphic.create_road_mesh(path.curve))


	for i in range(0, 4):
		karts.append(Kart.new(i, path))
		add_child(karts[-1])

	add_child(Graphic.setup_world_environment())

	add_child(Graphic.setup_directional_light())

	for i in range(12):
		zones.append(Zone.new(12, 1.1))
		add_child(zones[-1])
		zones[-1].position = get_random_points(path)

	for i in range(12):
		zones.append(Zone.new(12, 0.9))
		add_child(zones[-1])
		zones[-1].position = get_random_points(path)

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_viewport().get_mouse_position().x < WINDOW.x / 2.0:
			karts[0].turn(true)
		else:
			karts[0].turn(false)
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_SHIFT):
		karts[0].turn(true)
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_ENTER):
		karts[0].turn(false)


	for kart in karts:
		kart.process(karts)

	for zone in zones:
		zone.process(karts)

	var camera_target_position = karts[0].position + karts[0].velocity.normalized() * -32 + Vector3(0, 16, 0)
	camera.position = camera.position.lerp(camera_target_position, 0.1)
	# camera.position = camera_target_position
	camera.look_at(karts[0].position + Vector3(0, 8, 0), Vector3.UP)


func set_point_in_out(curve: Curve3D, i: int, point: Vector3):
	curve.set_point_in(i, point)
	curve.set_point_out(i, -point)

func get_random_points(path: Path3D) -> Vector3:
	var follow = PathFollow3D.new()
	path.add_child(follow)
	follow.h_offset = randf_range(-64.0, 64.0)
	follow.progress_ratio = randf_range(0, 1.0)
	var position = follow.position
	path.remove_child(follow)
	follow.queue_free()
	return position