class_name Graphic


const MODELS: Array[PackedScene] = [
	preload("res://assets/Mario/mario.glb"),
]

static func create_road_mesh(curve: Curve3D) -> MeshInstance3D:
	var mesh_instance_3d = MeshInstance3D.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)

	var road_width: float = 128.0

	var baked_points = curve.get_baked_points()

	for i in range(baked_points.size()):
		var next_pt = baked_points[(i + 1) % baked_points.size()]
		var prev_pt = baked_points[(i - 1 + baked_points.size()) % baked_points.size()]
		var dir = (next_pt - prev_pt).normalized()
		var side = dir.cross(Vector3.UP).normalized()

		st.set_color(Color(0.2, 0.2, 0.2))
		st.add_vertex(baked_points[i] - side * road_width * 0.5)

		st.set_color(Color(0.2, 0.2, 0.2))
		st.add_vertex(baked_points[i] + side * road_width * 0.5)

	mesh_instance_3d.mesh = st.commit()

	mesh_instance_3d.material_override = StandardMaterial3D.new()
	mesh_instance_3d.material_override.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance_3d.material_override.vertex_color_use_as_albedo = true
	mesh_instance_3d.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX

	return mesh_instance_3d


static func setup_world_environment() -> WorldEnvironment:
	var wE = WorldEnvironment.new()

	wE.environment = Environment.new()

	wE.environment.background_mode = Environment.BG_COLOR
	wE.environment.background_color = Color(0.4, 0.6, 0.9)

	wE.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	wE.environment.ambient_light_color = Color(0.65, 0.65, 0.65)
	wE.environment.ambient_light_energy = 0.8

	wE.environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	wE.environment.tonemap_exposure = 1.0

	wE.environment.fog_enabled = true
	wE.environment.fog_light_color = Color(0.5, 0.6, 0.7)
	wE.environment.fog_density = 0.0005

	return wE

static func setup_directional_light() -> DirectionalLight3D:
	var directionalLight = DirectionalLight3D.new()
	directionalLight.rotation_degrees = Vector3(-45, 45, 0)
	directionalLight.light_energy = 0.8
	return directionalLight

static func set_shading_mode(node: Node, mode: BaseMaterial3D.ShadingMode) -> void:
	if node is MeshInstance3D:
		for i in node.get_surface_override_material_count():
			if node.get_active_material(i) is BaseMaterial3D:
				var mat = node.get_active_material(i).duplicate() as BaseMaterial3D
				mat.shading_mode = mode
				mat.roughness = 1.0
				mat.metallic_specular = 0.0
				node.set_surface_override_material(i, mat)

	for child in node.get_children():
		set_shading_mode(child, mode)

static func set_albedo_color(mesh: MeshInstance3D, color: Color) -> void:
	var mat = mesh.mesh.surface_get_material(0).duplicate() as StandardMaterial3D
	mat.albedo_color = color
	mesh.set_surface_override_material(0, mat)

static func set_material_color(mesh: MeshInstance3D, v: float) -> void:
	var mat = mesh.material_override as StandardMaterial3D
	mat.albedo_color.v = v


static func create_ground_mesh() -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	mesh.mesh = PlaneMesh.new()
	mesh.mesh.size = Vector2(10000, 10000)
	mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mesh.material_override.albedo_color = Color(0, 0.3, 0)
	return mesh

static func create_box_mesh(color: Color) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	mesh.mesh.size = Vector3(8, 4, 8)
	mesh.material_override = StandardMaterial3D.new()
	mesh.material_override.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mesh.material_override.albedo_color = color
	return mesh
