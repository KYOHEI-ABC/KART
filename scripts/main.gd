class_name Main
extends Node

static var WINDOW: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)


var camera: Camera3D

var karts: Array[Kart] = []
var zones: Array[Zone] = []
var minimap: MiniMap = null
var rank: Rank = null
var race_started: bool = false
var race_finished: bool = false
var countdown_label: Label

@export var ground_mesh: MeshInstance3D = null
@export var path3D: Path3D = null

func _ready() -> void:
	camera = Camera3D.new()
	add_child(camera)
	camera.position.y = 512
	camera.rotation_degrees.x = -90
	camera.fov = 30

	# var ground = Graphic.create_ground_mesh()
	# add_child(ground)
	# ground.position.y = -0.01

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

	if ground_mesh:
		ground_mesh.position.y = -0.1

	if path3D:
		for i in range(path3D.curve.point_count):
			var p = path3D.curve.get_point_position(i)
			p.y = 0
			path.curve.add_point(path3D.curve.get_point_position(i))
		path.curve.add_point(path3D.curve.get_point_position(0))

	else:
		for course_point in course_points:
			path.curve.add_point(course_point)
		path.curve.add_point(course_points[0])

		var p = 100
		set_point_in_out(path.curve, 1, Vector3(p, 0, p))
		set_point_in_out(path.curve, 2, Vector3(p, 0, -p))
		set_point_in_out(path.curve, 4, Vector3(-p, 0, -p))
		set_point_in_out(path.curve, 5, Vector3(-p, 0, p))

	path.curve.bake_interval = path.curve.get_baked_length() * 0.01
	add_child(Graphic.create_road_mesh(path.curve))

	for i in range(0, 8):
		karts.append(Kart.new(i, path))
		add_child(karts[-1])

	rank = Rank.new(karts)
	add_child(rank)

	minimap = MiniMap.new(path, karts)
	add_child(minimap)

	var retry_button = Button.new()
	retry_button.text = "Retry"
	retry_button.position = Vector2(8, 8)
	retry_button.size = Vector2(80, 40)
	retry_button.add_theme_font_size_override("font_size", 16)
	retry_button.pressed.connect(get_tree().reload_current_scene)
	add_child(retry_button)

	add_child(Graphic.setup_world_environment())

	add_child(Graphic.setup_directional_light())

	for i in range(3):
		zones.append(Zone.new(8, 1.1))
		add_child(zones[-1])
		zones[-1].position = get_random_points(path)

	for i in range(3):
		zones.append(Zone.new(8, 0.9))
		add_child(zones[-1])
		zones[-1].position = get_random_points(path)

	countdown_label = Label.new()
	countdown_label.position = Vector2(0, WINDOW.y * 0.35)
	countdown_label.size = Vector2(WINDOW.x, 100)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.add_theme_font_size_override("font_size", 72)
	countdown_label.add_theme_color_override("font_color", Color(1, 0.25, 0.25))
	# countdown_label.add_theme_color_override("font_outline_color", Color.BLACK)
	# countdown_label.add_theme_constant_override("outline_size", 12)
	add_child(countdown_label)
	start_countdown()

	rank.process()
	minimap.process(karts)


	camera.position = karts[0].position + karts[0].transform.basis.z * 32 + Vector3(0, 16, 0)
	camera.look_at(karts[0].position + Vector3(0, 8, 0), Vector3.UP)

func start_countdown() -> void:
	countdown_label.text = "READY"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "GO"
	await get_tree().create_timer(0.8).timeout
	countdown_label.hide()
	race_started = true

func _process(_delta: float) -> void:
	if not race_started:
		return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_viewport().get_mouse_position().x < WINDOW.x / 2.0:
			karts[0].turn(0.5)
		else:
			karts[0].turn(-0.5)
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_SHIFT):
		karts[0].turn(0.5)
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_ENTER):
		karts[0].turn(-0.5)

	for kart in karts:
		kart.process(karts)

	for zone in zones:
		zone.process(karts)

	if not race_finished and rank.process():
		race_finished = true
		countdown_label.text = "GOAL"
		countdown_label.show()

	minimap.process(karts)

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
	follow.h_offset = randf_range(-24.0, 24.0)
	follow.progress_ratio = randf_range(0, 1.0)
	var position = follow.position
	path.remove_child(follow)
	follow.queue_free()
	return position
