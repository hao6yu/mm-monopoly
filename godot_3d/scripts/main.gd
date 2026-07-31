extends Node3D

const CityThemesCatalog = preload("res://scripts/city_themes.gd")

const BOARD_SIZE := 22.8
const CORNER := 9.55
const EDGE_STEP := 1.91
const BOARD_TOP := 1.34
const BOARD_WORLD_SCALE := 1.0
const TABLE_PLAYER_SCALE := 3.0
const TABLE_WIDTH := 37.0
const TABLE_DEPTH := 40.0
const BOARD_SPOT_COUNT := 52
const CAMERA_MIN_DISTANCE := 19.0
const CAMERA_MAX_DISTANCE := 68.0
const CAMERA_WHEEL_STEP := 2.4
const PINCH_ZOOM_SENSITIVITY := 0.035
# Retained only as dormant source for a possible later RPG prototype.
const RPG_ENTER_DISTANCE := 22.0
const RPG_WALK_SPEED := 7.5

const NAVY := Color("#111a33")
const INK := Color("#142033")
const CREAM := Color("#f6efd9")
const FELT := Color("#155b4b")
const GOLD := Color("#e4b64e")
const GOLD_LIGHT := Color("#ffe29a")
const TEAL := Color("#32d1b3")
const RED := Color("#ef5261")
const SKY_BLUE := Color("#4ba7e8")
const SKY_HORIZON := Color("#d9f4ff")
const HARBOR_BLUE := Color("#1596b6")
const PARK_GREEN := Color("#4f9f61")

const PLAYER_NAMES := ["MIA", "NOAH", "LUNA", "MAX"]
const PLAYER_COLORS := [
	Color("#ff4f5e"),
	Color("#49a8ff"),
	Color("#ffcc47"),
	Color("#51dc90"),
]
const PLAYER_SKIN_COLORS := [
	Color("#f0bd91"),
	Color("#8f5d45"),
	Color("#f5c99f"),
	Color("#b97454"),
]
const PLAYER_HAIR_COLORS := [
	Color("#4a241b"),
	Color("#17171d"),
	Color("#d5a13a"),
	Color("#30201b"),
]
const PLAYER_START_TILES := [19, 32, 45, 6]

const TILE_NAMES := [
	"START", "Battery Park", "Wall Street", "LIBERTY", "SoHo",
	"CITY TAX", "Canal Street", "Greenwich", "Washington Sq.", "Chelsea",
	"High Line", "Hudson Yards", "TIMES SQUARE", "Broadway", "Madison Sq.",
	"Flatiron", "Union Square", "CENTRAL PARK", "Columbus Circle", "Lincoln Center",
	"Museum Mile", "Fifth Avenue", "HARLEM", "Apollo Theater", "Riverside",
	"LUCK", "Columbia", "East Harlem", "Yankee Line", "GRAND CENTRAL",
	"Chrysler Tower", "Bryant Park", "Water Works", "Rockefeller", "Radio City",
	"GO TO JAIL", "East Village", "Lower East Side", "SKY CARD", "Chinatown",
	"BROOKLYN BRIDGE", "DUMBO", "Seaport", "Ferry Terminal", "LUXURY TAX",
	"Governors Isle", "One World", "Tribeca", "Little Italy", "City Hall",
	"CHANCE", "Financial Dist.",
]

const MANHATTAN_ROUTE_2D := [
	Vector2(0.0, -17.5),
	Vector2(-1.3, -17.1),
	Vector2(-2.2, -15.8),
	Vector2(-2.8, -14.1),
	Vector2(-4.0, -12.3),
	Vector2(-5.0, -10.3),
	Vector2(-5.7, -8.2),
	Vector2(-6.0, -6.0),
	Vector2(-6.1, -3.8),
	Vector2(-5.9, -1.6),
	Vector2(-5.5, 0.5),
	Vector2(-5.2, 2.6),
	Vector2(-4.9, 4.7),
	Vector2(-4.6, 6.8),
	Vector2(-4.2, 8.8),
	Vector2(-3.6, 10.7),
	Vector2(-2.4, 12.2),
	Vector2(-0.8, 13.2),
	Vector2(1.0, 13.2),
	Vector2(2.8, 12.4),
	Vector2(4.0, 11.1),
	Vector2(4.7, 9.3),
	Vector2(5.0, 7.3),
	Vector2(5.1, 5.2),
	Vector2(5.2, 3.1),
	Vector2(4.6, 1.2),
	Vector2(3.2, 0.2),
	Vector2(2.0, -0.8),
	Vector2(2.1, -2.7),
	Vector2(3.6, -3.8),
	Vector2(5.0, -5.0),
	Vector2(5.4, -7.0),
	Vector2(5.2, -9.0),
	Vector2(4.5, -10.9),
	Vector2(3.4, -12.3),
	Vector2(2.2, -13.8),
	Vector2(2.5, -15.2),
	Vector2(2.0, -16.5),
	Vector2(1.1, -17.3),
	Vector2(0.45, -17.7),
]

const PROPERTY_COLORS := {
	1: Color("#8b5a3c"), 2: Color("#8b5a3c"),
	4: Color("#54cbe8"),
	6: Color("#54cbe8"), 7: Color("#54cbe8"),
	9: Color("#f277b7"),
	11: Color("#f277b7"), 13: Color("#f277b7"), 14: Color("#f277b7"),
	16: Color("#f29b38"), 17: Color("#f29b38"), 19: Color("#f29b38"),
	21: Color("#e85151"), 23: Color("#e85151"), 24: Color("#e85151"),
	26: Color("#f2cf44"), 27: Color("#f2cf44"),
	29: Color("#f2cf44"), 31: Color("#4bb66a"), 32: Color("#4bb66a"),
	34: Color("#4bb66a"), 37: Color("#496bd6"), 39: Color("#496bd6"),
	40: Color("#8b5a3c"), 41: Color("#8b5a3c"),
	42: Color("#54cbe8"), 43: Color("#54cbe8"),
	45: Color("#f277b7"), 46: Color("#f277b7"),
	47: Color("#f29b38"), 48: Color("#f29b38"),
	49: Color("#e85151"), 51: Color("#496bd6"),
}

const MODEL_PATHS := [
	"res://assets/models/kenney_city/building-a.glb",
	"res://assets/models/kenney_city/building-c.glb",
	"res://assets/models/kenney_city/building-f.glb",
	"res://assets/models/kenney_city/building-i.glb",
	"res://assets/models/kenney_city/building-skyscraper-a.glb",
	"res://assets/models/kenney_city/building-skyscraper-b.glb",
	"res://assets/models/kenney_city/building-skyscraper-d.glb",
]

@export_range(2, 4, 1) var active_player_count: int = 4

var board_root: Node3D
var table_root: Node3D
var rpg_root: Node3D
var rpg_character: Node3D
var camera: Camera3D
var camera_target := Vector3(0.0, 1.4, -1.0)
var camera_azimuth := deg_to_rad(43.0)
var camera_elevation := deg_to_rad(58.0)
var camera_distance := 36.0
var orbiting := false
var touch_points: Dictionary = {}
var pinch_distance := 0.0
var rpg_mode := false
var mode_transitioning := false
var rpg_camera_yaw := 0.0
var rpg_camera_pitch := deg_to_rad(20.0)
var rpg_camera_distance := 8.5
var rpg_roll_active := false
var rpg_path_direction := -1.0

var tile_positions: Array[Vector3] = []
var player_tokens: Array[Node3D] = []
var table_players: Array[Node3D] = []
var dice_nodes: Array[Node3D] = []
var player_tiles: Array[int] = [19, 32, 45, 6]
var current_player_index := 0
var active_reach_player := -1
var dice_value_label: Label
var turn_label: Label
var roll_button: Button
var action_panel: PanelContainer
var hint_label: Label
var transition_overlay: ColorRect
var active_tween: Tween
var flutter_bridge: Object
var swift_host_messages: Array[Dictionary] = []
var embedded_mode := false
var player_names: Array[String] = ["MIA", "NOAH", "LUNA", "MAX"]
var cloud_nodes: Array[Node3D] = []
var cloud_speeds: Array[float] = []
var boat_routes: Array[Dictionary] = []
var current_board_id := "usa_new_york"
var city_theme: Dictionary = {}
var active_tile_names: Array[String] = []
var latest_logical_tile_names: Array[String] = []
var latest_logical_tiles: Array[Dictionary] = []
var active_visual_tile_data: Dictionary = {}
var board_tap_targets: Array[Dictionary] = []
var player_ids: Array[String] = ["", "", "", ""]
var brand_title_label: Label
var brand_subtitle_label: Label
var movement_preview_root: Node3D
var movement_markers: Array[MeshInstance3D] = []
var destination_beacon: Node3D
var camera_tween: Tween
var cinematic_camera_active := false
var saved_camera_target := Vector3.ZERO
var saved_camera_azimuth := 0.0
var saved_camera_elevation := 0.0
var saved_camera_distance := 36.0


func _ready() -> void:
	randomize()
	city_theme = CityThemesCatalog.get_theme(current_board_id)
	active_tile_names.assign(TILE_NAMES)
	board_root = Node3D.new()
	board_root.name = "ScaledBoard"
	board_root.scale = Vector3.ONE * BOARD_WORLD_SCALE
	add_child(board_root)
	_create_environment()
	_create_board()
	_create_center_city()
	_create_theme_park_world()
	_create_tokens()
	_create_dice()
	_create_camera()
	_create_ui()
	_set_active_player(0)
	_connect_flutter_bridge()
	_capture_initial_preview()


func _process(delta: float) -> void:
	_update_theme_park_world(delta)
	if cinematic_camera_active:
		_update_camera()
	if is_instance_valid(destination_beacon):
		var beacon_pulse := 1.0 + sin(Time.get_ticks_msec() * 0.006) * 0.12
		destination_beacon.scale = Vector3.ONE * beacon_pulse
		destination_beacon.rotation.y += delta * 0.75
	if player_tokens.is_empty():
		return
	if active_reach_player >= 0:
		_update_reach_arm(active_reach_player)
	var token := player_tokens[current_player_index]
	if active_reach_player < 0 and (active_tween == null or not active_tween.is_running()):
		token.position.y = sin(Time.get_ticks_msec() * 0.003) * 0.06


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			orbiting = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			camera_distance = maxf(
				CAMERA_MIN_DISTANCE,
				camera_distance - CAMERA_WHEEL_STEP
			)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			camera_distance = minf(
				CAMERA_MAX_DISTANCE,
				camera_distance + CAMERA_WHEEL_STEP
			)
			_update_camera()
	elif event is InputEventMouseMotion and orbiting:
		camera_azimuth -= event.relative.x * 0.007
		camera_elevation = clampf(
			camera_elevation - event.relative.y * 0.005,
			deg_to_rad(27.0),
			deg_to_rad(72.0)
		)
		_update_camera()
	elif event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
		else:
			touch_points.erase(event.index)
		orbiting = touch_points.size() == 1
		pinch_distance = (
			_current_touch_distance()
			if touch_points.size() == 2
			else 0.0
		)
	elif event is InputEventScreenDrag:
		touch_points[event.index] = event.position
		if touch_points.size() == 2:
			var next_pinch_distance := _current_touch_distance()
			if pinch_distance > 0.0:
				camera_distance = clampf(
					camera_distance - (
						next_pinch_distance - pinch_distance
					) * PINCH_ZOOM_SENSITIVITY,
					CAMERA_MIN_DISTANCE,
					CAMERA_MAX_DISTANCE
				)
				_update_camera()
			pinch_distance = next_pinch_distance
			orbiting = false
		elif touch_points.size() == 1:
			orbiting = true
			camera_azimuth -= event.relative.x * 0.007
			camera_elevation = clampf(
				camera_elevation - event.relative.y * 0.005,
				deg_to_rad(27.0),
				deg_to_rad(72.0)
			)
			_update_camera()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE:
				if not embedded_mode:
					_roll_dice()
			KEY_R:
				_reset_camera()
			KEY_F12:
				_save_preview()


func _current_touch_distance() -> float:
	var positions := touch_points.values()
	if positions.size() < 2:
		return 0.0
	var first_position := positions[0] as Vector2
	var second_position := positions[1] as Vector2
	return first_position.distance_to(second_position)


func _create_environment() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.58
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.tonemap_exposure = 0.84
	environment.fog_enabled = false

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = _theme_color("sky_top", "#2f86c9")
	sky_material.sky_horizon_color = _theme_color("sky_horizon", "#bfeaff")
	sky_material.ground_bottom_color = _theme_color("water", "#3196bc")
	sky_material.ground_horizon_color = _theme_color("sky_horizon", "#8fd5eb")
	sky_material.sun_angle_max = 12.0
	sky_material.sun_curve = 0.12
	sky_material.energy_multiplier = 1.0
	sky.sky_material = sky_material
	environment.sky = sky
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.name = "KeyLight"
	sun.light_color = Color("#fff7df")
	sun.light_energy = 1.18
	sun.rotation_degrees = Vector3(-52.0, -38.0, 0.0)
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)

	var fill := OmniLight3D.new()
	fill.name = "WarmFill"
	fill.position = Vector3(-9.0, 12.0, 8.0)
	fill.light_color = Color("#ffd49e")
	fill.light_energy = 0.72
	fill.omni_range = 24.0
	fill.shadow_enabled = true
	add_child(fill)

	var rim := OmniLight3D.new()
	rim.name = "CoolRim"
	rim.position = Vector3(11.0, 9.0, -9.0)
	rim.light_color = Color("#8fd8ff")
	rim.light_energy = 0.95
	rim.omni_range = 22.0
	add_child(rim)


func _create_table() -> void:
	_add_box(
		self,
		Vector3(TABLE_WIDTH, 0.7, TABLE_DEPTH),
		Vector3(0.0, -0.85, 0.0),
		_material(Color("#1e1410"), 0.0, 0.3)
	)
	_add_box(
		self,
		Vector3(TABLE_WIDTH - 0.8, 0.12, TABLE_DEPTH - 0.8),
		Vector3(0.0, -0.44, 0.0),
		_material(Color("#4b2d1d"), 0.0, 0.25)
	)
	_add_box(
		self,
		Vector3(46.0, 0.35, 48.0),
		Vector3(0.0, -1.35, 0.0),
		_material(Color("#080b15"), 0.05, 0.82)
	)


func _create_board() -> void:
	if current_board_id != "usa_new_york":
		_create_city_theme_board()
		return

	var brass_base := _add_cylinder(
		board_root,
		13.8,
		13.8,
		0.7,
		Vector3(0.0, 0.32, -1.1),
		_material(GOLD, 0.68, 0.2)
	)
	brass_base.scale.z = 1.38
	var water := _add_cylinder(
		board_root,
		13.35,
		13.35,
		0.48,
		Vector3(0.0, 0.74, -1.1),
		_water_material()
	)
	water.scale.z = 1.36
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var island_outline: Array[Vector2] = [
		Vector2(-3.4, -14.5),
		Vector2(-6.5, -10.4),
		Vector2(-7.0, -4.0),
		Vector2(-6.2, 4.5),
		Vector2(-4.5, 10.5),
		Vector2(-2.3, 13.4),
		Vector2(1.0, 14.0),
		Vector2(4.2, 11.7),
		Vector2(6.0, 6.5),
		Vector2(6.2, -2.8),
		Vector2(5.5, -9.5),
		Vector2(2.8, -13.8),
	]
	var island_trim: Array[Vector2] = []
	for point in island_outline:
		island_trim.append(point * 1.055)
	_add_polygon_platform(
		board_root,
		island_trim,
		1.04,
		0.32,
		_material(GOLD_LIGHT, 0.55, 0.26)
	)
	_add_polygon_platform(
		board_root,
		island_outline,
		1.18,
		0.32,
		_material(Color("#7f9674"), 0.0, 0.82)
	)

	# Liberty Island and its board-game connection to Lower Manhattan.
	var liberty_trim := _add_cylinder(
		board_root,
		2.25,
		2.25,
		0.3,
		Vector3(0.0, 1.04, -17.45),
		_material(GOLD_LIGHT, 0.5, 0.25)
	)
	liberty_trim.scale.z = 0.72
	var liberty_land := _add_cylinder(
		board_root,
		2.02,
		2.02,
		0.32,
		Vector3(0.0, 1.2, -17.45),
		_material(Color("#6c9a67"), 0.0, 0.82)
	)
	liberty_land.scale.z = 0.68
	var liberty_bridge := _add_box(
		board_root,
		Vector3(2.4, 0.18, 4.0),
		Vector3(-1.45, 1.16, -15.05),
		_material(Color("#6d747d"), 0.18, 0.46)
	)
	liberty_bridge.rotation_degrees.y = -23.0

	tile_positions = _sample_manhattan_route(BOARD_SPOT_COUNT)

	var route_material := _material(Color("#9e4440"), 0.04, 0.56)
	for index in BOARD_SPOT_COUNT:
		var start := tile_positions[index]
		var finish := tile_positions[(index + 1) % BOARD_SPOT_COUNT]
		var direction := finish - start
		var route_segment := _add_box(
			board_root,
			Vector3(direction.length() + 0.35, 0.08, 0.68),
			start.lerp(finish, 0.5) - Vector3(0.0, 0.09, 0.0),
			route_material
		)
		route_segment.rotation.y = atan2(-direction.z, direction.x)

	for index in BOARD_SPOT_COUNT:
		var position := tile_positions[index]
		_create_tile(index, position)


func _create_tile(index: int, position: Vector3) -> void:
	var payload := _visual_tile_payload(index)
	var tile_type := str(payload.get("type", ""))
	var is_corner := (
		tile_type in ["start", "jail", "freeParking", "goToJail"]
		or (payload.is_empty() and index % 13 == 0)
	)
	var tile_size := (
		Vector3(1.34, 0.2, 1.1)
		if is_corner
		else Vector3(1.06, 0.2, 0.88)
	)

	var tile_color := _tile_surface_color(index)

	var tile := Node3D.new()
	tile.name = "Tile%02d" % index
	tile.position = position
	tile.rotation_degrees.y = _tile_label_rotation(index)
	tile.set_meta("logical_index", int(payload.get("logicalIndex", -1)))
	board_root.add_child(tile)
	var base := _add_box(
		tile,
		tile_size,
		Vector3.ZERO,
		_material(tile_color, 0.0, 0.5)
	)
	base.name = "TileBase"

	var accent := _tile_accent_color(index)
	var accent_mesh := _add_box(
		tile,
		Vector3(tile_size.x - 0.08, 0.055, 0.27),
		Vector3(0.0, 0.13, 0.34),
		_material(accent if accent.a > 0.0 else Color.WHITE, 0.05, 0.33)
	)
	accent_mesh.name = "TileAccent"
	accent_mesh.visible = accent.a > 0.0
	if accent.a > 0.0:
		accent_mesh.material_override = _material(accent, 0.05, 0.33)

	var label := Label3D.new()
	label.name = "TileLabel"
	label.text = _tile_label_text(index)
	label.font_size = 34 if is_corner else 27
	label.pixel_size = 0.0066 if is_corner else 0.0056
	label.modulate = Color("#172238") if tile_color.get_luminance() > 0.5 else Color.WHITE
	label.outline_modulate = Color(1.0, 1.0, 1.0, 0.18) if tile_color.get_luminance() < 0.5 else Color.TRANSPARENT
	label.outline_size = 5
	label.position = Vector3(0.0, 0.17, -0.12)
	label.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	label.width = 125.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tile.add_child(label)

	var icon := Label3D.new()
	icon.name = "TileIcon"
	icon.text = _tile_icon_text(tile_type)
	icon.font_size = 52 if is_corner else 46
	icon.pixel_size = 0.0064 if is_corner else 0.0056
	icon.position = Vector3(0.0, 0.18, 0.27)
	icon.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	icon.modulate = Color.WHITE if tile_color.get_luminance() < 0.55 else INK
	icon.outline_modulate = Color("#07101e")
	icon.outline_size = 5
	icon.visible = not icon.text.is_empty()
	tile.add_child(icon)
	_refresh_tile_development(tile, index)


func _visual_tile_payload(index: int) -> Dictionary:
	var value = active_visual_tile_data.get(index, {})
	return value as Dictionary if typeof(value) == TYPE_DICTIONARY else {}


func _tile_surface_color(index: int) -> Color:
	var tile_type := str(_visual_tile_payload(index).get("type", ""))
	match tile_type:
		"chance":
			return Color("#df8b24")
		"communityChest":
			return Color("#248fc9")
		"tax":
			return Color("#8a54a2")
		"railroad":
			return Color("#444b59")
		"utility":
			return Color("#e4b64e")
		"start":
			return Color("#27a982")
		"jail":
			return Color("#d98632")
		"freeParking":
			return Color("#9157c8")
		"goToJail":
			return RED
		_:
			return CREAM


func _tile_accent_color(index: int) -> Color:
	var payload := _visual_tile_payload(index)
	if str(payload.get("type", "")) == "property":
		return _color_from_argb(
			int(payload.get("colorArgb", 0)),
			PROPERTY_COLORS.get(index, Color.TRANSPARENT) as Color
		)
	if payload.is_empty():
		return PROPERTY_COLORS.get(index, Color.TRANSPARENT) as Color
	return Color.TRANSPARENT


func _tile_icon_text(tile_type: String) -> String:
	match tile_type:
		"start":
			return "GO"
		"jail":
			return "LOCK"
		"freeParking":
			return "SPIN"
		"goToJail":
			return "JAIL"
		"chance":
			return "?"
		"communityChest":
			return "BOX"
		"tax":
			return "$"
		"railroad":
			return "R"
		"utility":
			return "⚡"
		_:
			return ""


func _tile_label_text(index: int) -> String:
	var name := (
		active_tile_names[index]
		if index < active_tile_names.size()
		else "CITY STOP"
	)
	var price := int(_visual_tile_payload(index).get("price", 0))
	return "%s\n$%d" % [name, price] if price > 0 else name


func _color_from_argb(value: int, fallback: Color) -> Color:
	if value == 0:
		return fallback
	var alpha := float((value >> 24) & 0xff) / 255.0
	var red := float((value >> 16) & 0xff) / 255.0
	var green := float((value >> 8) & 0xff) / 255.0
	var blue := float(value & 0xff) / 255.0
	return Color(red, green, blue, alpha)


func _create_center_city() -> void:
	if current_board_id != "usa_new_york":
		_create_city_theme_center()
		return

	var landmarks := Node3D.new()
	landmarks.name = "ManhattanLandmarks"
	board_root.add_child(landmarks)

	# Central Park anchors the upper half of the island.
	_add_box(
		landmarks,
		Vector3(5.3, 0.16, 7.4),
		Vector3(0.0, 1.34, 6.5),
		_material(Color("#356f48"), 0.0, 0.9)
	)
	_add_box(
		landmarks,
		Vector3(4.85, 0.035, 6.95),
		Vector3(0.0, 1.44, 6.5),
		_material(Color("#4b9a5d"), 0.0, 0.86)
	)
	for park_path in [
		[Vector3(0.34, 0.025, 6.6), Vector3(-0.7, 1.47, 6.5), -12.0],
		[Vector3(4.4, 0.025, 0.28), Vector3(0.0, 1.47, 5.2), 0.0],
		[Vector3(3.8, 0.025, 0.25), Vector3(0.25, 1.47, 8.3), 18.0],
	]:
		var path := _add_box(
			landmarks,
			park_path[0],
			park_path[1],
			_material(Color("#d9c69b"), 0.0, 0.78)
		)
		path.rotation_degrees.y = park_path[2]
	var park_lake := _add_cylinder(
		landmarks,
		1.05,
		1.05,
		0.045,
		Vector3(0.65, 1.49, 6.55),
		_material(Color("#55b5c8"), 0.16, 0.22)
	)
	park_lake.scale.z = 0.48

	var trunk_material := _material(Color("#59402d"), 0.0, 0.85)
	var leaf_material := _material(Color("#2f8252"), 0.0, 0.82)
	for tree_position in [
		Vector3(-1.8, 1.47, 4.1),
		Vector3(-0.5, 1.47, 4.5),
		Vector3(1.7, 1.47, 4.2),
		Vector3(-1.7, 1.47, 6.0),
		Vector3(1.9, 1.47, 7.0),
		Vector3(-1.4, 1.47, 8.1),
		Vector3(0.2, 1.47, 9.0),
		Vector3(1.7, 1.47, 9.2),
	]:
		_add_cylinder(
			landmarks,
			0.07,
			0.09,
			0.7,
			tree_position + Vector3.UP * 0.35,
			trunk_material
		)
		_add_sphere(
			landmarks,
			0.34,
			tree_position + Vector3.UP * 0.88,
			leaf_material,
			16,
			8
		)

	# Midtown and downtown use the existing CC0 city kit at landmark scale.
	var placements := [
		[MODEL_PATHS[4], Vector3(-1.35, 1.36, -8.8), 0.82, -8.0],
		[MODEL_PATHS[5], Vector3(0.2, 1.36, -9.3), 0.78, 6.0],
		[MODEL_PATHS[6], Vector3(1.45, 1.36, -8.2), 0.76, 13.0],
		[MODEL_PATHS[0], Vector3(-2.0, 1.36, -6.4), 0.82, -10.0],
		[MODEL_PATHS[1], Vector3(1.85, 1.36, -5.9), 0.82, 9.0],
		[MODEL_PATHS[2], Vector3(-1.7, 1.36, 0.3), 0.74, -6.0],
		[MODEL_PATHS[3], Vector3(1.45, 1.36, 1.25), 0.72, 10.0],
	]
	for placement in placements:
		var packed := load(placement[0]) as PackedScene
		if packed == null:
			continue
		var model := packed.instantiate() as Node3D
		model.position = placement[1]
		model.scale = Vector3.ONE * placement[2]
		model.rotation_degrees.y = placement[3]
		landmarks.add_child(model)
		_enable_model_shadows(model)

	# An art-deco tower reads as the Empire State Building from the board camera.
	var stone := _material(Color("#c6bda8"), 0.15, 0.38)
	_add_box(landmarks, Vector3(1.5, 2.2, 1.35), Vector3(0.0, 2.45, -2.55), stone)
	_add_box(landmarks, Vector3(1.15, 1.5, 1.05), Vector3(0.0, 4.25, -2.55), stone)
	_add_box(landmarks, Vector3(0.78, 1.15, 0.72), Vector3(0.0, 5.55, -2.55), stone)
	_add_cylinder(
		landmarks,
		0.08,
		0.14,
		1.8,
		Vector3(0.0, 7.0, -2.55),
		_material(GOLD_LIGHT, 0.55, 0.22, GOLD_LIGHT, 1.1)
	)

	# Statue of Liberty on its own playable island.
	var statue_stone := _material(Color("#b9aa8f"), 0.05, 0.6)
	var statue_green := _material(Color("#55a693"), 0.14, 0.42)
	_add_box(
		landmarks,
		Vector3(0.72, 0.8, 0.72),
		Vector3(0.0, 1.72, -17.45),
		statue_stone
	)
	_add_capsule(
		landmarks,
		0.22,
		1.05,
		Vector3(0.0, 2.62, -17.45),
		statue_green,
		20,
		10
	)
	_add_sphere(
		landmarks,
		0.22,
		Vector3(0.0, 3.23, -17.45),
		statue_green,
		20,
		10
	)
	var torch_arm := _add_capsule(
		landmarks,
		0.075,
		0.9,
		Vector3.ZERO,
		statue_green,
		14,
		8
	)
	_orient_capsule_between(
		torch_arm,
		Vector3(0.12, 2.9, -17.45),
		Vector3(0.42, 3.65, -17.45),
		0.075
	)
	_add_sphere(
		landmarks,
		0.14,
		Vector3(0.44, 3.78, -17.45),
		_material(Color("#ff9e3d"), 0.0, 0.22, Color("#ff9e3d"), 4.0),
		16,
		8
	)

	# Brooklyn Bridge extends into the harbor and makes the map silhouette asymmetric.
	var bridge_material := _material(Color("#a88e72"), 0.08, 0.52)
	_add_box(
		landmarks,
		Vector3(6.4, 0.18, 1.0),
		Vector3(8.55, 1.52, -6.3),
		bridge_material
	)
	for tower_x in [6.5, 10.6]:
		for tower_z in [-6.7, -5.9]:
			_add_box(
				landmarks,
				Vector3(0.28, 2.0, 0.28),
				Vector3(tower_x, 2.45, tower_z),
				bridge_material
			)
		_add_box(
			landmarks,
			Vector3(0.32, 0.24, 1.35),
			Vector3(tower_x, 3.25, -6.3),
			bridge_material
		)

	_add_landmark_label(landmarks, "CENTRAL PARK", Vector3(0.0, 2.4, 6.6), TEAL)
	_add_landmark_label(landmarks, "MIDTOWN", Vector3(0.0, 7.8, -2.55), GOLD_LIGHT)
	_add_landmark_label(landmarks, "LIBERTY ISLAND", Vector3(0.0, 4.25, -17.45), Color.WHITE)
	_add_landmark_label(landmarks, "BROOKLYN BRIDGE", Vector3(8.6, 4.0, -6.3), GOLD_LIGHT)


func _create_theme_park_world() -> void:
	if current_board_id != "usa_new_york":
		_create_city_theme_world()
		return

	var world := Node3D.new()
	world.name = "ThemeParkManhattan"
	board_root.add_child(world)
	_create_harbor_details(world)
	_create_harbor_traffic(world)
	_create_cloud_layer(world)

	var landmarks := board_root.get_node_or_null("ManhattanLandmarks") as Node3D
	if landmarks != null:
		_create_signature_landmarks(landmarks)
		_create_neighborhood_blocks(landmarks)


func _create_city_theme_board() -> void:
	var accent := _theme_color("accent", "#f0c75b")
	var water_color := _theme_color("water", "#168fab")
	var brass_base := _add_cylinder(
		board_root,
		13.8,
		13.8,
		0.7,
		Vector3(0.0, 0.32, -1.1),
		_material(accent, 0.62, 0.22)
	)
	brass_base.scale.z = 1.38
	var water := _add_cylinder(
		board_root,
		13.35,
		13.35,
		0.48,
		Vector3(0.0, 0.74, -1.1),
		_water_material(water_color)
	)
	water.scale.z = 1.36
	water.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var shape := str(city_theme.get("shape", "basin_city"))
	var island_outline := _city_outline(shape)
	var island_trim: Array[Vector2] = []
	for point in island_outline:
		island_trim.append(point * 1.045)
	_add_polygon_platform(
		board_root,
		island_trim,
		1.03,
		0.3,
		_material(accent.lightened(0.18), 0.48, 0.28)
	)
	_add_polygon_platform(
		board_root,
		island_outline,
		1.18,
		0.34,
		_material(_theme_color("land", "#78966c"), 0.0, 0.84)
	)

	var route_points := _city_route(shape)
	tile_positions = _sample_closed_route(route_points, BOARD_SPOT_COUNT)
	var route_material := _material(
		_theme_color("route", "#a34e48"),
		0.05,
		0.55
	)
	for index in BOARD_SPOT_COUNT:
		var start := tile_positions[index]
		var finish := tile_positions[(index + 1) % BOARD_SPOT_COUNT]
		var direction := finish - start
		var route_segment := _add_box(
			board_root,
			Vector3(direction.length() + 0.35, 0.08, 0.68),
			start.lerp(finish, 0.5) - Vector3(0.0, 0.09, 0.0),
			route_material
		)
		route_segment.rotation.y = atan2(-direction.z, direction.x)

	for index in BOARD_SPOT_COUNT:
		_create_tile(index, tile_positions[index])


func _create_city_theme_center() -> void:
	var landmarks := Node3D.new()
	landmarks.name = "CityLandmarks"
	board_root.add_child(landmarks)

	var shape := str(city_theme.get("shape", "basin_city"))
	var street_material := _material(Color("#76828a"), 0.03, 0.72)
	var sidewalk_material := _material(Color("#d7ccb3"), 0.0, 0.78)
	for street_z in [-7.2, -3.6, 0.0, 3.6, 7.2]:
		_add_box(
			landmarks,
			Vector3(6.4, 0.035, 0.16),
			Vector3(0.0, 1.38, street_z),
			street_material
		)
	for avenue_x in [-3.15, 0.0, 3.15]:
		_add_box(
			landmarks,
			Vector3(0.16, 0.035, 17.0),
			Vector3(avenue_x, 1.38, 0.0),
			street_material
		)

	# River cities receive a dedicated recessed water corridor. Crossings are
	# raised bridges, so no traffic is ever rendered as driving through water.
	if shape in ["river_city", "canal_city", "confluence"]:
		_add_box(
			landmarks,
			Vector3(1.05, 0.09, 18.2),
			Vector3(0.0, 1.43, 0.0),
			_material(_theme_color("water", "#3f879e"), 0.16, 0.24)
		)
		for bridge_z in [-6.0, -1.8, 2.5, 6.5]:
			_add_box(
				landmarks,
				Vector3(2.1, 0.16, 0.52),
				Vector3(0.0, 1.58, bridge_z),
				sidewalk_material
			)

	if shape in ["barrier_island", "pacific_coast", "mediterranean_coast", "caribbean_coast"]:
		_add_box(
			landmarks,
			Vector3(0.48, 0.05, 18.0),
			Vector3(-4.45, 1.42, 0.0),
			_material(Color("#f1d49a"), 0.0, 0.9)
		)
		for palm_z in [-7.8, -4.6, -1.4, 1.8, 5.0, 8.2]:
			_create_tree(landmarks, Vector3(-3.95, 1.4, palm_z), true)
	else:
		for tree_position in [
			Vector3(-4.0, 1.4, -8.0),
			Vector3(4.0, 1.4, -6.0),
			Vector3(-4.0, 1.4, 5.4),
			Vector3(4.0, 1.4, 8.0),
		]:
			_create_tree(landmarks, tree_position)

	_create_city_building_blocks(landmarks)
	var landmark_values = city_theme.get("landmarks", [])
	if typeof(landmark_values) == TYPE_ARRAY:
		for landmark_value in landmark_values:
			if typeof(landmark_value) == TYPE_DICTIONARY:
				_create_city_landmark(landmarks, landmark_value as Dictionary)


func _create_city_theme_world() -> void:
	var world := Node3D.new()
	world.name = "ThemePark%s" % str(city_theme.get("city", "City")).replace(" ", "")
	board_root.add_child(world)
	_create_cloud_layer(world)
	if str(city_theme.get("transport", "none")) == "coast":
		_create_city_coast_traffic(world)

	var accent := _theme_color("accent", "#f0c75b")
	for marker_position in [
		Vector3(-10.8, 1.15, -11.0),
		Vector3(-11.2, 1.15, 4.5),
		Vector3(11.0, 1.15, -9.0),
		Vector3(11.4, 1.15, 10.0),
	]:
		_add_sphere(
			world,
			0.12,
			marker_position,
			_material(accent, 0.1, 0.3, accent, 0.55),
			12,
			7
		)


func _create_city_building_blocks(parent: Node3D) -> void:
	var placements := [
		Vector3(-2.35, 1.4, -8.3),
		Vector3(2.25, 1.4, -8.0),
		Vector3(-2.5, 1.4, -5.0),
		Vector3(2.45, 1.4, -4.7),
		Vector3(-2.45, 1.4, 1.8),
		Vector3(2.35, 1.4, 1.9),
		Vector3(-2.35, 1.4, 5.2),
		Vector3(2.45, 1.4, 5.3),
		Vector3(-1.4, 1.4, 8.4),
		Vector3(1.5, 1.4, 8.3),
	]
	var landmark_values = city_theme.get("landmarks", [])
	for index in placements.size():
		var position := placements[index] as Vector3
		var occupied := false
		if typeof(landmark_values) == TYPE_ARRAY:
			for landmark_value in landmark_values:
				if typeof(landmark_value) != TYPE_DICTIONARY:
					continue
				var descriptor := landmark_value as Dictionary
				var landmark_position := Vector2(
					float(descriptor.get("x", 0.0)),
					float(descriptor.get("z", 0.0))
				)
				if landmark_position.distance_to(Vector2(position.x, position.z)) < 2.0:
					occupied = true
					break
		if occupied:
			continue
		var packed := load(MODEL_PATHS[index % MODEL_PATHS.size()]) as PackedScene
		if packed == null:
			continue
		var model := packed.instantiate() as Node3D
		model.position = position
		model.scale = Vector3.ONE * (0.42 + float(index % 3) * 0.055)
		model.rotation_degrees.y = float((index * 23) % 37) - 18.0
		parent.add_child(model)
		_enable_model_shadows(model)


func _create_city_landmark(parent: Node3D, descriptor: Dictionary) -> void:
	var landmark := Node3D.new()
	var label_text := str(descriptor.get("label", "LANDMARK"))
	landmark.name = "%sLandmark" % label_text.replace(" ", "")
	landmark.position = Vector3(
		float(descriptor.get("x", 0.0)),
		1.42,
		float(descriptor.get("z", 0.0))
	)
	var scale_value := float(descriptor.get("scale", 1.0))
	landmark.scale = Vector3.ONE * scale_value
	parent.add_child(landmark)

	var stone := _material(_theme_color("architecture", "#d2bea0"), 0.08, 0.46)
	var accent_color := _theme_color("accent", "#f0c75b")
	var accent := _material(accent_color, 0.28, 0.3, accent_color, 0.34)
	var dark := _material(Color("#273747"), 0.28, 0.26)
	var green := _material(Color("#4f8c61"), 0.0, 0.82)
	var kind := str(descriptor.get("kind", "monument"))

	match kind:
		"tower", "modern_tower":
			_add_box(landmark, Vector3(1.15, 2.8, 1.05), Vector3(0.0, 1.4, 0.0), dark if kind == "modern_tower" else stone)
			_add_box(landmark, Vector3(0.78, 1.5, 0.72), Vector3(0.0, 3.55, 0.0), dark if kind == "modern_tower" else accent)
			_add_cylinder(landmark, 0.05, 0.09, 1.7, Vector3(0.0, 5.15, 0.0), accent)
		"clock_tower":
			_add_box(landmark, Vector3(1.15, 3.8, 1.15), Vector3(0.0, 1.9, 0.0), stone)
			_add_sphere(landmark, 0.36, Vector3(0.0, 2.45, -0.59), accent, 20, 10)
			_add_cylinder(landmark, 0.06, 0.48, 1.45, Vector3(0.0, 4.5, 0.0), dark)
		"eiffel":
			for leg_x in [-0.65, 0.65]:
				var leg := _add_capsule(landmark, 0.11, 4.2, Vector3.ZERO, dark, 18, 8)
				_orient_capsule_between(
					leg,
					Vector3(leg_x, 0.0, 0.0),
					Vector3(leg_x * 0.18, 4.0, 0.0),
					0.11
				)
			_add_box(landmark, Vector3(1.6, 0.14, 0.7), Vector3(0.0, 1.25, 0.0), dark)
			_add_box(landmark, Vector3(0.9, 0.12, 0.55), Vector3(0.0, 2.65, 0.0), dark)
			_add_cylinder(landmark, 0.04, 0.08, 1.2, Vector3(0.0, 4.55, 0.0), accent)
		"wheel":
			var torus_mesh := TorusMesh.new()
			torus_mesh.inner_radius = 1.15
			torus_mesh.outer_radius = 1.28
			torus_mesh.rings = 40
			torus_mesh.ring_segments = 14
			var wheel := MeshInstance3D.new()
			wheel.mesh = torus_mesh
			wheel.position = Vector3(0.0, 2.0, 0.0)
			wheel.rotation_degrees.x = 90.0
			wheel.material_override = accent
			landmark.add_child(wheel)
			_add_cylinder(landmark, 0.12, 0.12, 3.8, Vector3(0.0, 1.9, 0.0), dark)
			for spoke_angle in range(0, 360, 45):
				var spoke := _add_box(landmark, Vector3(0.08, 2.2, 0.08), Vector3(0.0, 2.0, 0.0), dark)
				spoke.rotation_degrees.z = float(spoke_angle)
		"bridge", "wall":
			_add_box(landmark, Vector3(4.0, 0.22, 0.75), Vector3(0.0, 1.1, 0.0), stone)
			for tower_x in [-1.55, 1.55]:
				_add_box(landmark, Vector3(0.45, 2.5, 0.65), Vector3(tower_x, 2.0, 0.0), stone)
				_add_cylinder(landmark, 0.08, 0.34, 0.65, Vector3(tower_x, 3.55, 0.0), accent)
		"temple":
			_add_box(landmark, Vector3(2.7, 0.7, 1.8), Vector3(0.0, 0.35, 0.0), stone)
			var roof := _add_triangular_prism(landmark, Vector3(3.25, 0.75, 2.25), Vector3(0.0, 1.05, 0.0), accent)
			roof.rotation_degrees.y = 180.0
			_add_box(landmark, Vector3(2.0, 0.6, 1.25), Vector3(0.0, 1.65, 0.0), stone)
			_add_triangular_prism(landmark, Vector3(2.5, 0.62, 1.7), Vector3(0.0, 2.25, 0.0), accent)
		"palace", "castle", "cathedral":
			_add_box(landmark, Vector3(3.0, 1.45, 1.9), Vector3(0.0, 0.72, 0.0), stone)
			for tower_x in [-1.2, 1.2]:
				_add_box(landmark, Vector3(0.62, 2.5, 0.62), Vector3(tower_x, 1.25, 0.0), stone)
				_add_cylinder(landmark, 0.05, 0.42, 0.75, Vector3(tower_x, 2.88, 0.0), accent)
			if kind == "cathedral":
				_add_cylinder(landmark, 0.08, 0.75, 1.0, Vector3(0.0, 2.0, 0.0), accent)
		"stadium":
			var stadium := _add_cylinder(landmark, 1.65, 1.65, 0.72, Vector3(0.0, 0.36, 0.0), stone)
			stadium.scale.z = 0.68
			var field := _add_cylinder(landmark, 1.18, 1.18, 0.1, Vector3(0.0, 0.77, 0.0), green)
			field.scale.z = 0.6
		"sign":
			_add_box(landmark, Vector3(3.0, 1.2, 0.18), Vector3(0.0, 2.0, 0.0), accent)
			for support_x in [-1.1, 1.1]:
				_add_box(landmark, Vector3(0.13, 2.8, 0.13), Vector3(support_x, 0.6, 0.0), dark)
		"pyramid":
			_add_box(landmark, Vector3(3.0, 0.55, 2.8), Vector3(0.0, 0.28, 0.0), stone)
			_add_box(landmark, Vector3(2.35, 0.55, 2.15), Vector3(0.0, 0.82, 0.0), stone)
			_add_box(landmark, Vector3(1.65, 0.55, 1.45), Vector3(0.0, 1.36, 0.0), stone)
			_add_box(landmark, Vector3(0.9, 0.55, 0.75), Vector3(0.0, 1.9, 0.0), accent)
		"dome":
			_add_box(landmark, Vector3(2.8, 1.0, 1.9), Vector3(0.0, 0.5, 0.0), stone)
			var dome := _add_sphere(landmark, 1.0, Vector3(0.0, 1.65, 0.0), accent, 28, 14)
			dome.scale.y = 0.62
			_add_cylinder(landmark, 0.07, 0.12, 0.9, Vector3(0.0, 2.6, 0.0), dark)
		"lighthouse":
			_add_cylinder(landmark, 0.35, 0.55, 3.4, Vector3(0.0, 1.7, 0.0), stone)
			_add_cylinder(landmark, 0.5, 0.5, 0.36, Vector3(0.0, 3.5, 0.0), accent)
			_add_sphere(landmark, 0.3, Vector3(0.0, 3.82, 0.0), accent, 18, 9)
		"mountain":
			var mountain := _add_triangular_prism(landmark, Vector3(3.8, 3.4, 3.0), Vector3(0.0, 1.7, 0.0), green)
			mountain.rotation_degrees.y = 24.0
			_add_triangular_prism(landmark, Vector3(1.8, 1.25, 1.6), Vector3(0.0, 3.0, 0.0), stone)
		"park":
			_add_box(landmark, Vector3(3.5, 0.16, 2.4), Vector3(0.0, 0.08, 0.0), green)
			for tree_position in [
				Vector3(-1.1, 0.1, -0.6),
				Vector3(0.0, 0.1, 0.55),
				Vector3(1.05, 0.1, -0.25),
			]:
				_create_tree(landmark, tree_position)
		_:
			_add_box(landmark, Vector3(1.1, 1.2, 1.1), Vector3(0.0, 0.6, 0.0), stone)
			_add_cylinder(landmark, 0.12, 0.3, 2.5, Vector3(0.0, 2.25, 0.0), accent)

	var label_height := 5.1
	match kind:
		"tower", "modern_tower", "clock_tower", "eiffel", "lighthouse":
			label_height = 6.55
		"stadium", "park", "dome", "pyramid":
			label_height = 3.65
	_add_landmark_label(
		landmark,
		label_text,
		Vector3(0.0, label_height, 0.0),
		accent_color.lightened(0.25)
	)


func _create_tree(parent: Node, position: Vector3, palm: bool = false) -> void:
	var trunk := _material(Color("#68472c"), 0.0, 0.86)
	var leaves := _material(Color("#2f8252"), 0.0, 0.82)
	_add_cylinder(parent, 0.07, 0.1, 0.72, position + Vector3.UP * 0.36, trunk)
	if palm:
		for angle in range(0, 360, 60):
			var leaf := _add_box(
				parent,
				Vector3(0.12, 0.05, 0.95),
				position + Vector3(0.0, 0.85, 0.0),
				leaves
			)
			leaf.rotation_degrees.y = float(angle)
			leaf.rotation_degrees.x = 18.0
	else:
		_add_sphere(parent, 0.34, position + Vector3.UP * 0.88, leaves, 16, 8)


func _create_city_coast_traffic(parent: Node3D) -> void:
	# All animated craft use this verified ocean lane west of the land mass.
	# It is intentionally separated from the property route and dice platform.
	var ocean_lane := [
		Vector3(-10.4, 1.2, -13.6),
		Vector3(-11.25, 1.2, -8.0),
		Vector3(-11.45, 1.2, -1.5),
		Vector3(-11.3, 1.2, 5.5),
		Vector3(-10.2, 1.2, 12.8),
	]
	var specs := [
		["ferry", _theme_color("accent", "#f0c75b"), 0, 0.12, 0.82, 1],
		["sailboat", Color("#f4f1e7"), 3, 0.45, 0.58, -1],
	]
	for spec in specs:
		var boat := _make_harbor_boat(str(spec[0]), spec[1] as Color)
		parent.add_child(boat)
		boat_routes.append({
			"node": boat,
			"path": ocean_lane,
			"segment": int(spec[2]),
			"progress": float(spec[3]),
			"speed": float(spec[4]),
			"direction": int(spec[5]),
			"surface": "water",
		})


func _city_outline(shape: String) -> Array[Vector2]:
	match shape:
		"barrier_island":
			return [
				Vector2(-5.4, -14.0), Vector2(-7.1, -8.0), Vector2(-6.8, 0.0),
				Vector2(-5.8, 8.2), Vector2(-3.0, 13.5), Vector2(2.5, 13.0),
				Vector2(5.3, 7.8), Vector2(6.2, -0.5), Vector2(5.2, -9.2),
				Vector2(2.2, -14.0),
			]
		"pacific_coast", "mediterranean_coast", "caribbean_coast":
			return [
				Vector2(-6.5, -13.4), Vector2(-7.2, -6.0), Vector2(-6.3, 2.0),
				Vector2(-5.2, 10.5), Vector2(-1.4, 13.8), Vector2(3.8, 12.0),
				Vector2(6.4, 6.0), Vector2(6.2, -2.0), Vector2(5.0, -10.5),
				Vector2(1.0, -14.0),
			]
		"river_city", "canal_city", "confluence":
			return [
				Vector2(-7.4, -11.7), Vector2(-8.0, -4.0), Vector2(-7.4, 4.0),
				Vector2(-5.0, 11.5), Vector2(0.0, 13.4), Vector2(5.2, 11.0),
				Vector2(7.6, 4.0), Vector2(7.7, -4.5), Vector2(5.2, -11.5),
				Vector2(0.0, -13.5),
			]
		"bay_city", "harbor_islands":
			return [
				Vector2(-6.8, -12.8), Vector2(-7.6, -5.0), Vector2(-5.4, 1.0),
				Vector2(-7.0, 7.5), Vector2(-3.0, 12.8), Vector2(1.0, 11.3),
				Vector2(4.8, 13.0), Vector2(7.2, 6.5), Vector2(5.7, 0.0),
				Vector2(7.2, -7.2), Vector2(3.8, -13.2),
			]
		_:
			return [
				Vector2(-5.8, -13.0), Vector2(-7.5, -7.0), Vector2(-7.2, 1.0),
				Vector2(-5.8, 8.8), Vector2(-1.5, 13.2), Vector2(3.5, 12.0),
				Vector2(6.8, 7.0), Vector2(7.2, -1.0), Vector2(5.8, -9.0),
				Vector2(1.8, -13.5),
			]


func _city_route(shape: String) -> Array[Vector2]:
	var outline := _city_outline(shape)
	var route: Array[Vector2] = []
	var inset := 0.84
	if shape in ["river_city", "canal_city", "confluence"]:
		inset = 0.82
	elif shape in ["bay_city", "harbor_islands"]:
		inset = 0.8
	for point in outline:
		route.append(point * inset)
	return route


func _sample_closed_route(points: Array[Vector2], spot_count: int) -> Array[Vector3]:
	var segment_lengths: Array[float] = []
	var total_length := 0.0
	for index in points.size():
		var next_index := (index + 1) % points.size()
		var segment_length := points[index].distance_to(points[next_index])
		segment_lengths.append(segment_length)
		total_length += segment_length

	var result: Array[Vector3] = []
	for spot_index in spot_count:
		var target_distance := total_length * float(spot_index) / float(spot_count)
		var traversed := 0.0
		for segment_index in segment_lengths.size():
			var segment_length := segment_lengths[segment_index]
			if traversed + segment_length >= target_distance:
				var next_index := (segment_index + 1) % points.size()
				var progress := (target_distance - traversed) / maxf(segment_length, 0.001)
				var point := points[segment_index].lerp(points[next_index], progress)
				result.append(Vector3(point.x, BOARD_TOP, point.y))
				break
			traversed += segment_length
	return result


func _create_harbor_details(parent: Node3D) -> void:
	var pier_material := _material(Color("#b58c61"), 0.02, 0.72)
	var pier_edge := _material(Color("#f1d49a"), 0.08, 0.5)
	for pier_data in [
		[Vector3(-8.05, 1.18, -7.7), Vector3(3.0, 0.16, 0.62)],
		[Vector3(-8.3, 1.18, -5.6), Vector3(3.2, 0.16, 0.58)],
		[Vector3(8.1, 1.18, -9.6), Vector3(3.0, 0.16, 0.62)],
		[Vector3(8.45, 1.18, -3.8), Vector3(3.4, 0.16, 0.58)],
	]:
		_add_box(parent, pier_data[1], pier_data[0], pier_material)
		_add_box(
			parent,
			Vector3(pier_data[1].x + 0.12, 0.035, 0.08),
			pier_data[0] + Vector3(0.0, 0.1, -pier_data[1].z * 0.42),
			pier_edge
		)

	var buoy_red := _material(Color("#f2554d"), 0.08, 0.34, Color("#f2554d"), 0.45)
	var buoy_white := _material(Color("#fff4d8"), 0.05, 0.4)
	for buoy_position in [
		Vector3(-10.8, 1.16, -12.0),
		Vector3(10.6, 1.16, -11.0),
		Vector3(-11.3, 1.16, 4.0),
		Vector3(11.2, 1.16, 6.1),
		Vector3(-7.8, 1.16, 14.0),
	]:
		_add_cylinder(
			parent,
			0.11,
			0.16,
			0.3,
			buoy_position + Vector3.UP * 0.1,
			buoy_white
		)
		_add_sphere(
			parent,
			0.13,
			buoy_position + Vector3.UP * 0.34,
			buoy_red,
			12,
			7
		)


func _create_harbor_traffic(parent: Node3D) -> void:
	# These are explicit, water-only navigation lanes. Traffic never uses the
	# decorative board route, and every point stays outside land, piers and dice.
	var hudson_lane := [
		Vector3(-8.5, 1.2, -13.6),
		Vector3(-10.4, 1.2, -10.5),
		Vector3(-11.3, 1.2, -5.0),
		Vector3(-11.5, 1.2, 1.0),
		Vector3(-10.7, 1.2, 7.0),
		Vector3(-7.8, 1.2, 13.0),
	]
	var east_river_lane := [
		Vector3(6.0, 1.2, -14.0),
		Vector3(10.0, 1.2, -11.0),
		Vector3(12.4, 1.2, -7.5),
		Vector3(12.4, 1.2, -3.0),
		Vector3(12.1, 1.2, 4.0),
		Vector3(11.8, 1.2, 6.5),
		Vector3(10.2, 1.2, 8.0),
		Vector3(7.3, 1.2, 12.5),
	]
	var liberty_ferry_lane := [
		Vector3(-8.5, 1.2, -12.8),
		Vector3(-7.0, 1.2, -15.0),
		Vector3(-4.8, 1.2, -16.7),
		Vector3(-2.8, 1.2, -17.7),
	]
	var south_harbor_lane := [
		Vector3(3.0, 1.2, -17.6),
		Vector3(5.2, 1.2, -16.1),
		Vector3(7.5, 1.2, -13.7),
		Vector3(9.5, 1.2, -10.5),
	]
	var boat_specs := [
		["ferry", Color("#f4c84b"), hudson_lane, 1, 0.25, 1.15, 1],
		["ferry", Color("#ef6a55"), east_river_lane, 4, 0.5, 1.0, -1],
		["sailboat", Color("#f4f1e7"), liberty_ferry_lane, 0, 0.4, 0.7, 1],
		["tug", Color("#43a7d7"), south_harbor_lane, 2, 0.2, 0.82, -1],
	]
	for spec in boat_specs:
		var boat := _make_harbor_boat(str(spec[0]), spec[1] as Color)
		parent.add_child(boat)
		boat_routes.append({
			"node": boat,
			"path": spec[2],
			"segment": int(spec[3]),
			"progress": float(spec[4]),
			"speed": float(spec[5]),
			"direction": int(spec[6]),
		})


func _make_harbor_boat(kind: String, accent: Color) -> Node3D:
	var boat := Node3D.new()
	boat.name = "%sBoat" % kind.capitalize()
	var hull := _material(Color("#f3f0e5"), 0.08, 0.38)
	var hull_dark := _material(Color("#1d4054"), 0.18, 0.26)
	var accent_material := _material(accent, 0.08, 0.34)
	var glass := _material(Color("#76d4eb"), 0.2, 0.16, Color("#76d4eb"), 0.22)
	# A pointed plan-view hull and visible wake make these read as boats even
	# from the board's high camera, instead of road vehicles on blue terrain.
	var lower_hull := _add_triangular_prism(
		boat,
		Vector3(1.18, 0.3, 2.35),
		Vector3(0.0, 0.2, -0.08),
		hull_dark
	)
	lower_hull.rotation_degrees.y = 180.0
	var upper_hull := _add_triangular_prism(
		boat,
		Vector3(1.02, 0.18, 2.0),
		Vector3(0.0, 0.4, -0.12),
		hull
	)
	upper_hull.rotation_degrees.y = 180.0
	var wake_material := _material(Color(1.0, 1.0, 1.0, 0.48), 0.0, 0.82)
	wake_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for wake_x in [-0.34, 0.34]:
		var wake := _add_box(
			boat,
			Vector3(0.13, 0.025, 1.35),
			Vector3(wake_x, 0.04, 1.25),
			wake_material
		)
		wake.rotation_degrees.y = -10.0 if wake_x < 0.0 else 10.0

	if kind == "sailboat":
		_add_cylinder(
			boat,
			0.025,
			0.035,
			1.55,
			Vector3(0.0, 1.12, 0.06),
			hull_dark
		)
		var sail := _add_box(
			boat,
			Vector3(0.055, 0.95, 0.72),
			Vector3(0.04, 1.17, 0.1),
			accent_material
		)
		sail.rotation_degrees.x = -9.0
	else:
		_add_box(boat, Vector3(0.76, 0.38, 0.92), Vector3(0.0, 0.66, 0.02), hull)
		_add_box(boat, Vector3(0.78, 0.16, 0.48), Vector3(0.0, 0.7, -0.38), glass)
		_add_box(boat, Vector3(0.86, 0.08, 0.98), Vector3(0.0, 0.9, 0.02), accent_material)
		if kind == "ferry":
			_add_box(
				boat,
				Vector3(0.58, 0.2, 0.62),
				Vector3(0.0, 1.04, 0.08),
				hull
			)
			var ferry_label := Label3D.new()
			ferry_label.text = "FERRY"
			ferry_label.font_size = 28
			ferry_label.pixel_size = 0.006
			ferry_label.position = Vector3(0.0, 0.73, -0.5)
			ferry_label.modulate = Color("#122e41")
			ferry_label.outline_modulate = Color.WHITE
			ferry_label.outline_size = 3
			boat.add_child(ferry_label)
	return boat


func _create_cloud_layer(parent: Node3D) -> void:
	var cloud_material := _material(Color(1.0, 1.0, 1.0, 0.76), 0.0, 0.92)
	cloud_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var cloud_specs := [
		[Vector3(-10.8, 6.5, -12.8), 0.58, 0.08],
		[Vector3(10.8, 7.4, -6.8), 0.48, 0.06],
		[Vector3(-10.2, 8.2, 8.0), 0.52, 0.05],
	]
	for spec in cloud_specs:
		var cloud := Node3D.new()
		cloud.name = "Cloud%02d" % cloud_nodes.size()
		cloud.position = spec[0]
		cloud.scale = Vector3.ONE * float(spec[1])
		parent.add_child(cloud)
		for puff in [
			[Vector3(-1.2, 0.0, 0.0), 0.72],
			[Vector3(-0.45, 0.28, 0.0), 0.92],
			[Vector3(0.45, 0.18, 0.0), 1.05],
			[Vector3(1.35, -0.03, 0.0), 0.65],
			[Vector3(0.15, -0.16, 0.28), 0.78],
		]:
			var sphere := _add_sphere(
				cloud,
				float(puff[1]),
				puff[0],
				cloud_material,
				16,
				8
			)
			sphere.scale.z = 0.66
			sphere.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cloud_nodes.append(cloud)
		cloud_speeds.append(float(spec[2]))


func _create_signature_landmarks(landmarks: Node3D) -> void:
	var limestone := _material(Color("#d7d0bc"), 0.12, 0.38)
	var pale_stone := _material(Color("#ece4cf"), 0.05, 0.55)
	var dark_glass := _material(Color("#4b7897"), 0.48, 0.15)
	var steel := _material(Color("#8998a2"), 0.72, 0.18)
	var billboard_blue := _material(Color("#42b8e9"), 0.08, 0.28, Color("#42b8e9"), 1.5)
	var billboard_pink := _material(Color("#f15c9a"), 0.05, 0.3, Color("#f15c9a"), 1.35)

	# One World Trade Center anchors Lower Manhattan.
	_add_box(landmarks, Vector3(1.25, 3.0, 1.18), Vector3(-0.65, 2.86, -10.75), dark_glass)
	_add_box(landmarks, Vector3(0.98, 1.55, 0.92), Vector3(-0.65, 5.08, -10.75), dark_glass)
	_add_box(landmarks, Vector3(0.7, 0.72, 0.65), Vector3(-0.65, 6.21, -10.75), steel)
	_add_cylinder(
		landmarks,
		0.045,
		0.09,
		2.05,
		Vector3(-0.65, 7.55, -10.75),
		steel
	)

	# Chrysler Building and Grand Central sit on the east side of Midtown.
	_add_box(landmarks, Vector3(0.88, 2.5, 0.82), Vector3(1.72, 2.62, -2.05), limestone)
	_add_box(landmarks, Vector3(0.65, 1.0, 0.6), Vector3(1.72, 4.36, -2.05), steel)
	for crown_y in [5.02, 5.31, 5.56]:
		_add_cylinder(
			landmarks,
			0.1 + (5.7 - crown_y) * 0.22,
			0.15 + (5.7 - crown_y) * 0.25,
			0.3,
			Vector3(1.72, crown_y, -2.05),
			steel
		)
	_add_cylinder(landmarks, 0.03, 0.055, 1.05, Vector3(1.72, 6.18, -2.05), steel)

	_add_box(landmarks, Vector3(2.15, 0.75, 1.2), Vector3(2.0, 1.83, -0.25), pale_stone)
	_add_box(landmarks, Vector3(1.8, 0.22, 1.35), Vector3(2.0, 2.31, -0.25), limestone)
	for column_x in [-0.72, -0.36, 0.0, 0.36, 0.72]:
		_add_cylinder(
			landmarks,
			0.055,
			0.07,
			0.66,
			Vector3(2.0 + column_x, 2.18, -0.87),
			limestone
		)

	# Times Square is deliberately bright and toy-like.
	for billboard in [
		[Vector3(-2.45, 2.38, 0.72), Vector3(0.78, 1.12, 0.12), billboard_blue, -14.0],
		[Vector3(-1.72, 2.65, 1.22), Vector3(0.68, 1.38, 0.12), billboard_pink, 10.0],
	]:
		var sign := _add_box(landmarks, billboard[1], billboard[0], billboard[2])
		sign.rotation_degrees.y = float(billboard[3])

	# The Flatiron Building gives Madison Square its unmistakable wedge.
	_add_triangular_prism(
		landmarks,
		Vector3(1.1, 2.45, 1.5),
		Vector3(-1.82, 2.58, -1.15),
		limestone
	)

	# Harlem receives two clear northern anchors.
	var stadium := _add_cylinder(
		landmarks,
		1.15,
		1.15,
		0.48,
		Vector3(1.35, 1.74, 11.25),
		pale_stone
	)
	stadium.scale.z = 0.72
	var stadium_field := _add_cylinder(
		landmarks,
		0.78,
		0.78,
		0.08,
		Vector3(1.35, 2.03, 11.25),
		_material(Color("#55a868"), 0.0, 0.82)
	)
	stadium_field.scale.z = 0.65
	_add_box(
		landmarks,
		Vector3(1.7, 0.7, 0.9),
		Vector3(-1.4, 1.72, 11.15),
		_material(Color("#7c4538"), 0.05, 0.58)
	)
	_add_box(
		landmarks,
		Vector3(1.35, 0.28, 0.08),
		Vector3(-1.4, 1.86, 10.68),
		_material(RED, 0.04, 0.34, RED, 0.8)
	)

	# A tiny Central Park carousel sells the theme-park scale.
	_add_cylinder(
		landmarks,
		0.52,
		0.66,
		0.28,
		Vector3(-1.15, 1.73, 7.45),
		_material(Color("#ef6b56"), 0.05, 0.42)
	)
	_add_cylinder(
		landmarks,
		0.06,
		0.08,
		1.0,
		Vector3(-1.15, 2.3, 7.45),
		_material(GOLD, 0.5, 0.22)
	)
	_add_cylinder(
		landmarks,
		0.06,
		0.7,
		0.48,
		Vector3(-1.15, 2.55, 7.45),
		_material(Color("#fff4d5"), 0.02, 0.54)
	)

	_add_landmark_label(landmarks, "ONE WORLD", Vector3(-0.65, 8.8, -10.75), Color.WHITE)
	_add_landmark_label(landmarks, "TIMES SQUARE", Vector3(-2.1, 4.0, 0.95), Color("#ff8bc0"))
	_add_landmark_label(landmarks, "GRAND CENTRAL", Vector3(2.0, 3.05, -0.25), GOLD_LIGHT)
	_add_landmark_label(landmarks, "HARLEM", Vector3(0.0, 3.4, 11.25), Color("#a8f0ba"))


func _create_neighborhood_blocks(landmarks: Node3D) -> void:
	var street_material := _material(Color("#7a8790"), 0.04, 0.72)
	for street_z in [-9.6, -7.8, -6.0, -4.2, -2.4, -0.6, 1.2]:
		_add_box(
			landmarks,
			Vector3(5.9, 0.035, 0.13),
			Vector3(0.0, 1.36, street_z),
			street_material
		)
	for avenue_x in [-2.15, -0.72, 0.72, 2.15]:
		_add_box(
			landmarks,
			Vector3(0.13, 0.035, 11.4),
			Vector3(avenue_x, 1.36, -4.2),
			street_material
		)

	var neighborhood_placements := [
		[MODEL_PATHS[0], Vector3(-2.75, 1.36, -9.0), 0.48, -8.0],
		[MODEL_PATHS[1], Vector3(2.55, 1.36, -8.5), 0.5, 12.0],
		[MODEL_PATHS[2], Vector3(-3.0, 1.36, -6.9), 0.52, -5.0],
		[MODEL_PATHS[3], Vector3(2.75, 1.36, -6.3), 0.48, 9.0],
		[MODEL_PATHS[0], Vector3(-3.05, 1.36, -4.7), 0.46, -8.0],
		[MODEL_PATHS[1], Vector3(3.0, 1.36, -4.2), 0.5, 8.0],
		[MODEL_PATHS[2], Vector3(-3.2, 1.36, -2.5), 0.48, -6.0],
		[MODEL_PATHS[3], Vector3(3.15, 1.36, -1.9), 0.46, 7.0],
		[MODEL_PATHS[0], Vector3(-3.25, 1.36, 2.7), 0.44, -4.0],
		[MODEL_PATHS[1], Vector3(3.2, 1.36, 2.8), 0.46, 6.0],
		[MODEL_PATHS[2], Vector3(-3.35, 1.36, 5.2), 0.44, -3.0],
		[MODEL_PATHS[3], Vector3(3.3, 1.36, 5.4), 0.44, 5.0],
		[MODEL_PATHS[0], Vector3(-3.0, 1.36, 8.0), 0.42, -2.0],
		[MODEL_PATHS[1], Vector3(3.0, 1.36, 8.5), 0.43, 4.0],
	]
	for placement in neighborhood_placements:
		var packed := load(placement[0]) as PackedScene
		if packed == null:
			continue
		var model := packed.instantiate() as Node3D
		model.position = placement[1]
		model.scale = Vector3.ONE * float(placement[2])
		model.rotation_degrees.y = float(placement[3])
		landmarks.add_child(model)
		_enable_model_shadows(model)


func _update_theme_park_world(delta: float) -> void:
	for index in cloud_nodes.size():
		var cloud := cloud_nodes[index]
		if not is_instance_valid(cloud):
			continue
		cloud.position.x += cloud_speeds[index] * delta
		if cloud.position.x > 32.0:
			cloud.position.x = -32.0

	for route in boat_routes:
		var boat := route.get("node") as Node3D
		if not is_instance_valid(boat):
			continue
		var path := route.get("path") as Array
		if path == null or path.size() < 2:
			continue
		var segment := clampi(int(route.get("segment", 0)), 0, path.size() - 1)
		var direction := int(route.get("direction", 1))
		var target_index := segment + direction
		if target_index < 0 or target_index >= path.size():
			direction *= -1
			target_index = segment + direction
		var start := path[segment] as Vector3
		var finish := path[target_index] as Vector3
		var segment_length := maxf(start.distance_to(finish), 0.01)
		var progress := (
			float(route.get("progress", 0.0))
			+ float(route.get("speed", 1.0)) * delta / segment_length
		)
		while progress >= 1.0:
			progress -= 1.0
			segment = target_index
			if segment == 0 or segment == path.size() - 1:
				direction *= -1
			target_index = segment + direction
			start = path[segment] as Vector3
			finish = path[target_index] as Vector3
		boat.position = start.lerp(finish, progress)
		boat.look_at(finish, Vector3.UP)
		route["segment"] = segment
		route["progress"] = progress
		route["direction"] = direction


func _add_landmark_label(
	parent: Node,
	text: String,
	position: Vector3,
	color: Color
) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = 36
	label.pixel_size = 0.0054
	label.position = position
	label.modulate = color
	label.outline_modulate = Color("#07101e")
	label.outline_size = 12
	label.width = 410.0
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(label)
	board_tap_targets.append({
		"node": label,
		"kind": "landmark",
		"title": text,
	})


func _create_rpg_district() -> void:
	rpg_root = Node3D.new()
	rpg_root.name = "VictoryParkStreetLevel"
	rpg_root.visible = false
	add_child(rpg_root)

	var grass_material := _material(Color("#173f35"), 0.02, 0.9)
	var asphalt_material := _material(Color("#1b2330"), 0.04, 0.78)
	var sidewalk_material := _material(Color("#687483"), 0.03, 0.7)
	var curb_material := _material(Color("#d6d0bd"), 0.02, 0.62)
	var lane_material := _material(GOLD_LIGHT, 0.05, 0.48, GOLD_LIGHT, 0.3)

	_add_box(
		rpg_root,
		Vector3(42.0, 0.5, 56.0),
		Vector3(0.0, -0.3, 0.0),
		grass_material
	)
	_add_box(
		rpg_root,
		Vector3(10.5, 0.12, 56.0),
		Vector3(0.0, 0.02, 0.0),
		asphalt_material
	)
	for sidewalk_x in [-7.5, 7.5]:
		_add_box(
			rpg_root,
			Vector3(4.2, 0.3, 56.0),
			Vector3(sidewalk_x, 0.13, 0.0),
			sidewalk_material
		)
		_add_box(
			rpg_root,
			Vector3(0.26, 0.42, 56.0),
			Vector3(sidewalk_x - signf(sidewalk_x) * 2.22, 0.18, 0.0),
			curb_material
		)

	for lane_z in range(-24, 25, 6):
		_add_box(
			rpg_root,
			Vector3(0.18, 0.04, 2.8),
			Vector3(0.0, 0.1, float(lane_z)),
			lane_material
		)

	for stripe_x in range(-4, 5, 2):
		_add_box(
			rpg_root,
			Vector3(1.1, 0.045, 0.55),
			Vector3(float(stripe_x), 0.105, -3.5),
			_material(Color("#f3f1e7"), 0.02, 0.55)
		)

	var building_placements := [
		[MODEL_PATHS[4], Vector3(-14.0, 0.1, -19.0), 2.5, 90.0],
		[MODEL_PATHS[0], Vector3(-14.0, 0.1, -7.0), 2.7, 90.0],
		[MODEL_PATHS[2], Vector3(-14.0, 0.1, 7.0), 2.6, 90.0],
		[MODEL_PATHS[5], Vector3(-14.0, 0.1, 20.0), 2.45, 90.0],
		[MODEL_PATHS[6], Vector3(14.0, 0.1, -20.0), 2.4, -90.0],
		[MODEL_PATHS[1], Vector3(14.0, 0.1, -7.0), 2.7, -90.0],
		[MODEL_PATHS[3], Vector3(14.0, 0.1, 7.0), 2.65, -90.0],
		[MODEL_PATHS[4], Vector3(14.0, 0.1, 20.0), 2.35, -90.0],
	]
	for placement in building_placements:
		var packed := load(placement[0]) as PackedScene
		if packed == null:
			continue
		var model := packed.instantiate() as Node3D
		model.position = placement[1]
		model.scale = Vector3.ONE * placement[2]
		model.rotation_degrees.y = placement[3]
		rpg_root.add_child(model)
		_enable_model_shadows(model)

	var lamp_material := _material(Color("#233047"), 0.38, 0.24)
	var lamp_glow := _material(GOLD_LIGHT, 0.1, 0.2, GOLD_LIGHT, 4.0)
	for lamp_z in [-18.0, -7.0, 6.0, 18.0]:
		for lamp_x in [-9.7, 9.7]:
			_add_cylinder(
				rpg_root,
				0.09,
				0.12,
				4.7,
				Vector3(lamp_x, 2.45, lamp_z),
				lamp_material
			)
			_add_sphere(
				rpg_root,
				0.24,
				Vector3(lamp_x, 4.75, lamp_z),
				lamp_glow,
				18,
				10
			)

	var tree_trunk := _material(Color("#5e3a25"), 0.0, 0.85)
	var tree_leaf := _material(Color("#2d8b62"), 0.02, 0.78)
	for tree_position in [
		Vector3(-10.8, 0.0, -12.0),
		Vector3(10.8, 0.0, -13.0),
		Vector3(-10.8, 0.0, 13.5),
		Vector3(10.8, 0.0, 12.5),
	]:
		_add_cylinder(
			rpg_root,
			0.19,
			0.25,
			2.6,
			tree_position + Vector3(0.0, 1.35, 0.0),
			tree_trunk
		)
		_add_sphere(
			rpg_root,
			1.25,
			tree_position + Vector3(0.0, 3.2, 0.0),
			tree_leaf,
			24,
			12
		)

	var district_title := Label3D.new()
	district_title.text = "VICTORY PARK  •  STREET LEVEL"
	district_title.font_size = 72
	district_title.pixel_size = 0.012
	district_title.position = Vector3(0.0, 7.5, -22.0)
	district_title.modulate = GOLD_LIGHT
	district_title.outline_modulate = Color("#09101f")
	district_title.outline_size = 12
	district_title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rpg_root.add_child(district_title)

	_set_rpg_character(current_player_index)


func _set_rpg_character(player_index: int) -> void:
	if rpg_character != null:
		rpg_character.queue_free()

	var temporary_player := _make_table_player(
		PLAYER_NAMES[player_index],
		PLAYER_COLORS[player_index],
		PLAYER_SKIN_COLORS[player_index],
		PLAYER_HAIR_COLORS[player_index],
		false
	)
	rpg_character = temporary_player.get_node("CharacterBody") as Node3D
	temporary_player.remove_child(rpg_character)
	temporary_player.free()
	rpg_character.name = "%sStreetCharacter" % PLAYER_NAMES[player_index]
	rpg_character.position = Vector3(0.0, 0.18, 8.0)
	rpg_root.add_child(rpg_character)

	var player_label := Label3D.new()
	player_label.text = PLAYER_NAMES[player_index]
	player_label.font_size = 42
	player_label.pixel_size = 0.006
	player_label.position = Vector3(0.0, 4.2, 0.0)
	player_label.modulate = PLAYER_COLORS[player_index]
	player_label.outline_modulate = Color("#08101e")
	player_label.outline_size = 8
	player_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rpg_character.add_child(player_label)


func _create_tokens() -> void:
	for index in active_player_count:
		var token := _make_character_piece(
			PLAYER_COLORS[index],
			PLAYER_SKIN_COLORS[index],
			PLAYER_HAIR_COLORS[index],
			index == 0
		)
		token.name = "%sCharacterPiece" % PLAYER_NAMES[index]
		token.position = tile_positions[PLAYER_START_TILES[index]]
		token.position.y = 0.0
		board_root.add_child(token)
		token.look_at(board_root.to_global(Vector3.ZERO), Vector3.UP)
		player_tokens.append(token)


func _make_character_piece(
	shirt_color: Color,
	skin_color: Color,
	hair_color: Color,
	active: bool
) -> Node3D:
	var character := Node3D.new()
	var shirt_material := _material(shirt_color, 0.3, 0.22)
	var skin_material := _material(skin_color, 0.08, 0.42)
	var hair_material := _material(hair_color, 0.18, 0.3)
	var pants_material := _material(Color("#25324c"), 0.12, 0.38)
	var shoe_material := _material(Color("#10131c"), 0.24, 0.25)

	# A colored plinth keeps each miniature readable against busy property tiles.
	_add_cylinder(
		character,
		0.42,
		0.47,
		0.12,
		Vector3(0.0, 1.16, 0.0),
		shirt_material
	)

	for leg_x in [-0.13, 0.13]:
		_add_capsule(
			character,
			0.105,
			0.48,
			Vector3(leg_x, 1.46, 0.0),
			pants_material,
			16,
			8
		)
		var shoe := _add_sphere(
			character,
			0.13,
			Vector3(leg_x, 1.24, -0.07),
			shoe_material,
			16,
			8
		)
		shoe.scale = Vector3(0.88, 0.58, 1.3)

	var torso := _add_capsule(
		character,
		0.31,
		0.82,
		Vector3(0.0, 1.92, 0.0),
		shirt_material,
		20,
		10
	)
	torso.scale = Vector3(1.0, 1.0, 0.72)

	for arm_x in [-0.37, 0.37]:
		var arm := _add_capsule(
			character,
			0.09,
			0.58,
			Vector3(arm_x, 1.9, -0.01),
			shirt_material,
			16,
			8
		)
		arm.rotation_degrees.z = -14.0 if arm_x < 0.0 else 14.0
		_add_sphere(
			character,
			0.105,
			Vector3(arm_x * 1.12, 1.65, -0.03),
			skin_material,
			16,
			8
		)

	_add_cylinder(
		character,
		0.12,
		0.14,
		0.16,
		Vector3(0.0, 2.38, 0.0),
		skin_material
	)
	_add_sphere(character, 0.29, Vector3(0.0, 2.62, 0.0), skin_material, 24, 12)
	var hair := _add_sphere(
		character,
		0.3,
		Vector3(0.0, 2.78, 0.035),
		hair_material,
		24,
		12
	)
	hair.scale = Vector3(1.02, 0.56, 1.02)

	var face_material := _material(Color("#11131b"), 0.04, 0.24)
	_add_sphere(character, 0.035, Vector3(-0.09, 2.65, -0.27), face_material, 10, 6)
	_add_sphere(character, 0.035, Vector3(0.09, 2.65, -0.27), face_material, 10, 6)

	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 0.47
	ring_mesh.outer_radius = 0.55
	ring_mesh.rings = 32
	ring_mesh.ring_segments = 12
	var ring := MeshInstance3D.new()
	ring.name = "ActiveRing"
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 1.08, 0.0)
	ring.material_override = _material(TEAL, 0.25, 0.16, TEAL, 2.6)
	ring.visible = active
	character.add_child(ring)
	return character


func _create_table_players() -> void:
	var placements: Array[Vector3]
	match active_player_count:
		2:
			placements = [
				Vector3(-11.5, -0.3, 0.0),
				Vector3(11.5, -0.3, 0.0),
			]
		3:
			placements = [
				Vector3(-11.5, -0.3, 0.0),
				Vector3(0.0, -0.3, -9.0),
				Vector3(11.5, -0.3, 0.0),
			]
		_:
			placements = [
				Vector3(-11.5, -0.3, 0.0),
				Vector3(0.0, -0.3, -9.0),
				Vector3(11.5, -0.3, 0.0),
				Vector3(0.0, -0.3, 9.0),
			]
	var skin_tones := [
		Color("#d9986f"),
		Color("#8f5d45"),
		Color("#f0bd91"),
		Color("#b97454"),
	]
	var hair_colors := [
		Color("#4a241b"),
		Color("#17171d"),
		Color("#d5a13a"),
		Color("#30201b"),
	]

	for index in active_player_count:
		var player := _make_table_player(
			PLAYER_NAMES[index],
			PLAYER_COLORS[index],
			skin_tones[index],
			hair_colors[index],
			index == current_player_index
		)
		player.name = "%sTablePlayer" % PLAYER_NAMES[index]
		player.position = placements[index]
		player.scale = Vector3.ONE * TABLE_PLAYER_SCALE
		add_child(player)
		player.look_at(Vector3(0.0, player.position.y, 0.0), Vector3.UP)
		table_players.append(player)


func _make_table_player(
	player_name: String,
	player_color: Color,
	skin_color: Color,
	hair_color: Color,
	active: bool
) -> Node3D:
	var player := Node3D.new()
	var chair_material := _material(Color("#19223a"), 0.12, 0.32)
	var shirt_material := _material(player_color, 0.18, 0.28)
	var skin_material := _material(skin_color, 0.0, 0.52)
	var hair_material := _material(hair_color, 0.05, 0.4)

	# The chair stays fixed while CharacterBody leans toward the board.
	_add_box(player, Vector3(2.0, 0.28, 1.8), Vector3(0.0, 0.22, 0.35), chair_material)
	_add_box(player, Vector3(2.05, 2.25, 0.28), Vector3(0.0, 1.25, 1.08), chair_material)
	for leg_position in [
		Vector3(-0.78, -0.62, -0.22),
		Vector3(0.78, -0.62, -0.22),
		Vector3(-0.78, -0.62, 0.86),
		Vector3(0.78, -0.62, 0.86),
	]:
		_add_box(
			player,
			Vector3(0.16, 1.55, 0.16),
			leg_position,
			_material(Color("#101522"), 0.28, 0.25)
		)

	var body := Node3D.new()
	body.name = "CharacterBody"
	player.add_child(body)

	var torso := _add_capsule(
		body,
		0.7,
		2.05,
		Vector3(0.0, 1.42, 0.08),
		shirt_material
	)
	torso.scale = Vector3(1.08, 1.0, 0.74)

	var pants_material := _material(Color("#25324c"), 0.08, 0.42)
	var shoe_material := _material(Color("#10131c"), 0.22, 0.28)
	for leg_x in [-0.34, 0.34]:
		_add_capsule(
			body,
			0.23,
			0.95,
			Vector3(leg_x, 0.39, 0.2),
			pants_material,
			20,
			10
		)
		var shoe := _add_sphere(
			body,
			0.25,
			Vector3(leg_x, -0.01, -0.04),
			shoe_material,
			20,
			10
		)
		shoe.scale = Vector3(1.0, 0.58, 1.35)

	var left_arm := _add_capsule(
		body,
		0.22,
		1.35,
		Vector3(-0.82, 1.28, -0.1),
		shirt_material,
		20,
		10
	)
	left_arm.name = "StaticLeftArm"
	left_arm.rotation_degrees = Vector3(13.0, 0.0, -19.0)
	var right_arm := _add_capsule(
		body,
		0.22,
		1.35,
		Vector3(0.82, 1.28, -0.1),
		shirt_material,
		20,
		10
	)
	right_arm.name = "StaticRightArm"
	right_arm.rotation_degrees = Vector3(13.0, 0.0, 19.0)
	var left_hand := _add_sphere(
		body,
		0.25,
		Vector3(-1.0, 0.72, -0.33),
		skin_material,
		20,
		10
	)
	left_hand.name = "StaticLeftHand"
	var right_hand := _add_sphere(
		body,
		0.25,
		Vector3(1.0, 0.72, -0.33),
		skin_material,
		20,
		10
	)
	right_hand.name = "StaticRightHand"

	_add_cylinder(
		body,
		0.26,
		0.28,
		0.35,
		Vector3(0.0, 2.35, 0.0),
		skin_material
	)
	_add_sphere(body, 0.61, Vector3(0.0, 2.92, 0.0), skin_material, 36, 20)
	var hair := _add_sphere(
		body,
		0.64,
		Vector3(0.0, 3.25, 0.08),
		hair_material,
		36,
		20
	)
	hair.scale = Vector3(1.03, 0.58, 1.02)

	var eye_material := _material(Color("#101522"), 0.0, 0.24)
	_add_sphere(body, 0.075, Vector3(-0.19, 3.01, -0.565), eye_material, 12, 8)
	_add_sphere(body, 0.075, Vector3(0.19, 3.01, -0.565), eye_material, 12, 8)
	var smile := _add_sphere(body, 0.09, Vector3(0.0, 2.78, -0.59), eye_material, 12, 8)
	smile.scale = Vector3(1.65, 0.32, 0.35)

	# Articulated arm used only during the pick-up/carry/release animation.
	var reach_rig := Node3D.new()
	reach_rig.name = "ReachRig"
	reach_rig.visible = false
	player.add_child(reach_rig)
	var reach_upper := _add_capsule(
		reach_rig,
		0.23,
		1.0,
		Vector3.ZERO,
		shirt_material,
		24,
		10
	)
	reach_upper.name = "UpperArm"
	var reach_forearm := _add_capsule(
		reach_rig,
		0.19,
		1.0,
		Vector3.ZERO,
		skin_material,
		24,
		10
	)
	reach_forearm.name = "Forearm"

	var reach_hand := Node3D.new()
	reach_hand.name = "Hand"
	reach_rig.add_child(reach_hand)
	_add_sphere(reach_hand, 0.32, Vector3.ZERO, skin_material, 24, 12)
	for finger_x in [-0.17, 0.0, 0.17]:
		var finger := _add_capsule(
			reach_hand,
			0.065,
			0.58,
			Vector3(finger_x, -0.28, 0.0),
			skin_material,
			14,
			8
		)
		finger.name = "Finger"
	var thumb := _add_capsule(
		reach_hand,
		0.075,
		0.44,
		Vector3(0.31, -0.08, 0.0),
		skin_material,
		14,
		8
	)
	thumb.rotation_degrees.z = -52.0

	var highlight_mesh := TorusMesh.new()
	highlight_mesh.inner_radius = 0.48
	highlight_mesh.outer_radius = 0.56
	highlight_mesh.rings = 48
	highlight_mesh.ring_segments = 12
	var highlight := MeshInstance3D.new()
	highlight.name = "ActiveRing"
	highlight.mesh = highlight_mesh
	highlight.position = Vector3(0.0, -0.46, 0.18)
	highlight.material_override = _material(player_color, 0.25, 0.18, player_color, 3.2)
	highlight.visible = active
	player.add_child(highlight)

	var name_label := Label3D.new()
	name_label.name = "NameLabel"
	name_label.text = "%s  •  $1,500" % player_name
	name_label.font_size = 42
	name_label.pixel_size = 0.0042
	name_label.position = Vector3(0.0, 3.96, 0.0)
	name_label.modulate = Color.WHITE
	name_label.outline_modulate = Color("#0b1020")
	name_label.outline_size = 10
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	player.add_child(name_label)

	var active_label := Label3D.new()
	active_label.name = "ActiveLabel"
	active_label.text = "●  ACTIVE PLAYER"
	active_label.font_size = 30
	active_label.pixel_size = 0.0035
	active_label.position = Vector3(0.0, 4.42, 0.0)
	active_label.modulate = player_color
	active_label.outline_modulate = Color("#080d18")
	active_label.outline_size = 8
	active_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	active_label.visible = active
	player.add_child(active_label)
	return player


func _create_dice() -> void:
	var platform_center := _dice_platform_center()
	_add_box(
		board_root,
		Vector3(3.6, 0.16, 2.05),
		platform_center,
		_material(Color("#172642"), 0.22, 0.3)
	)
	for index in 2:
		var die := _make_die()
		die.name = "Die%d" % (index + 1)
		die.position = Vector3(
			platform_center.x - 0.75 + index * 1.5,
			1.9,
			platform_center.z
		)
		die.rotation_degrees = Vector3(-8.0, -16.0 + index * 31.0, 5.0)
		board_root.add_child(die)
		dice_nodes.append(die)


func _dice_platform_center() -> Vector3:
	if current_board_id == "usa_new_york":
		return Vector3(9.0, 1.22, 4.8)
	return Vector3(10.2, 1.22, 0.5)


func _make_die() -> Node3D:
	var die := Node3D.new()
	_add_box(
		die,
		Vector3(1.08, 1.08, 1.08),
		Vector3.ZERO,
		_material(Color("#fffaf0"), 0.12, 0.18)
	)
	var pip_material := _material(INK, 0.08, 0.26)
	_add_die_face_pips(die, Vector3.UP, 1, pip_material)
	_add_die_face_pips(die, Vector3.DOWN, 6, pip_material)
	_add_die_face_pips(die, Vector3.FORWARD, 2, pip_material)
	_add_die_face_pips(die, Vector3.BACK, 5, pip_material)
	_add_die_face_pips(die, Vector3.RIGHT, 3, pip_material)
	_add_die_face_pips(die, Vector3.LEFT, 4, pip_material)
	return die


func _add_die_face_pips(
	die: Node3D,
	normal: Vector3,
	value: int,
	pip_material: Material
) -> void:
	var pip_offsets := {
		1: [Vector2.ZERO],
		2: [Vector2(-0.27, -0.27), Vector2(0.27, 0.27)],
		3: [Vector2(-0.27, -0.27), Vector2.ZERO, Vector2(0.27, 0.27)],
		4: [
			Vector2(-0.27, -0.27),
			Vector2(0.27, -0.27),
			Vector2(-0.27, 0.27),
			Vector2(0.27, 0.27),
		],
		5: [
			Vector2(-0.27, -0.27),
			Vector2(0.27, -0.27),
			Vector2.ZERO,
			Vector2(-0.27, 0.27),
			Vector2(0.27, 0.27),
		],
		6: [
			Vector2(-0.27, -0.29),
			Vector2(-0.27, 0.0),
			Vector2(-0.27, 0.29),
			Vector2(0.27, -0.29),
			Vector2(0.27, 0.0),
			Vector2(0.27, 0.29),
		],
	}
	for offset in pip_offsets[value]:
		var pip_position: Vector3
		if absf(normal.y) > 0.5:
			pip_position = Vector3(offset.x, normal.y * 0.555, offset.y)
		elif absf(normal.z) > 0.5:
			pip_position = Vector3(offset.x, offset.y, normal.z * 0.555)
		else:
			pip_position = Vector3(normal.x * 0.555, offset.y, offset.x)
		_add_sphere(die, 0.072, pip_position, pip_material, 10, 6)


func _die_face_rotation(value: int) -> Vector3:
	match clampi(value, 1, 6):
		2:
			return Vector3(PI * 0.5, 0.0, 0.0)
		3:
			return Vector3(0.0, 0.0, PI * 0.5)
		4:
			return Vector3(0.0, 0.0, -PI * 0.5)
		5:
			return Vector3(-PI * 0.5, 0.0, 0.0)
		6:
			return Vector3(PI, 0.0, 0.0)
		_:
			return Vector3.ZERO


func _animate_3d_dice(die_one: int, die_two: int) -> void:
	var values := [die_one, die_two]
	var platform_center := _dice_platform_center()
	for index in dice_nodes.size():
		var die := dice_nodes[index]
		var die_value := int(values[index])
		die.visible = die_value > 0
		if not die.visible:
			continue
		var settle_rotation := _die_face_rotation(die_value)
		var target_rotation := settle_rotation + Vector3(
			TAU * float(2 + index),
			TAU * float(3 - index),
			TAU * 2.0
		)
		var target_position := Vector3(
			platform_center.x - 0.78 + index * 1.53,
			1.9,
			platform_center.z - 0.16 + index * 0.3
		)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(die, "rotation", target_rotation, 0.92)
		tween.tween_property(die, "position:x", target_position.x, 0.92)
		tween.tween_property(die, "position:z", target_position.z, 0.92)
		tween.tween_property(die, "position:y", 3.65, 0.3)
		tween.chain().tween_property(die, "position:y", 1.9, 0.42)
		tween.chain().tween_property(die, "position:y", 2.22, 0.12)
		tween.chain().tween_property(die, "position:y", 1.9, 0.14)


func _create_camera() -> void:
	camera = Camera3D.new()
	camera.name = "BoardCamera"
	camera.fov = 46.0
	camera.near = 0.1
	camera.far = 120.0
	add_child(camera)
	camera.current = true
	_update_camera()


func _create_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "GameHUD"
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	canvas.add_child(root)

	var brand_panel := PanelContainer.new()
	brand_panel.position = Vector2(28.0, 24.0)
	brand_panel.size = Vector2(430.0, 92.0)
	brand_panel.add_theme_stylebox_override("panel", _ui_panel(NAVY, 0.94, 18, GOLD, 2))
	root.add_child(brand_panel)
	var brand_margin := MarginContainer.new()
	brand_margin.add_theme_constant_override("margin_left", 22)
	brand_margin.add_theme_constant_override("margin_right", 22)
	brand_margin.add_theme_constant_override("margin_top", 13)
	brand_margin.add_theme_constant_override("margin_bottom", 11)
	brand_panel.add_child(brand_margin)
	var brand_box := VBoxContainer.new()
	brand_box.add_theme_constant_override("separation", 0)
	brand_margin.add_child(brand_box)
	brand_title_label = Label.new()
	brand_title_label.text = "PROPERTY TYCOON  •  %s" % str(city_theme.get("city", "MANHATTAN"))
	brand_title_label.add_theme_font_size_override("font_size", 23)
	brand_title_label.add_theme_color_override("font_color", GOLD_LIGHT)
	brand_box.add_child(brand_title_label)
	brand_subtitle_label = Label.new()
	brand_subtitle_label.text = str(city_theme.get("subtitle", "CITY THEME PARK"))
	brand_subtitle_label.add_theme_font_size_override("font_size", 13)
	brand_subtitle_label.add_theme_color_override("font_color", Color("#8fe9da"))
	brand_box.add_child(brand_subtitle_label)

	var turn_panel := PanelContainer.new()
	turn_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	turn_panel.position = Vector2(-370.0, 24.0)
	turn_panel.size = Vector2(342.0, 92.0)
	turn_panel.add_theme_stylebox_override("panel", _ui_panel(NAVY, 0.94, 18, TEAL, 2))
	root.add_child(turn_panel)
	var turn_margin := MarginContainer.new()
	turn_margin.add_theme_constant_override("margin_left", 20)
	turn_margin.add_theme_constant_override("margin_right", 20)
	turn_margin.add_theme_constant_override("margin_top", 12)
	turn_margin.add_theme_constant_override("margin_bottom", 10)
	turn_panel.add_child(turn_margin)
	var turn_box := VBoxContainer.new()
	turn_margin.add_child(turn_box)
	var overline := Label.new()
	overline.text = "CURRENT TURN"
	overline.add_theme_font_size_override("font_size", 12)
	overline.add_theme_color_override("font_color", Color("#88a0c7"))
	turn_box.add_child(overline)
	turn_label = Label.new()
	turn_label.text = "MIA  •  Rose Avenue"
	turn_label.add_theme_font_size_override("font_size", 23)
	turn_label.add_theme_color_override("font_color", Color.WHITE)
	turn_box.add_child(turn_label)

	var stats_panel := PanelContainer.new()
	stats_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	stats_panel.position = Vector2(28.0, -128.0)
	stats_panel.size = Vector2(385.0, 96.0)
	stats_panel.add_theme_stylebox_override("panel", _ui_panel(NAVY, 0.92, 18))
	root.add_child(stats_panel)
	var stats_margin := MarginContainer.new()
	stats_margin.add_theme_constant_override("margin_left", 20)
	stats_margin.add_theme_constant_override("margin_right", 20)
	stats_margin.add_theme_constant_override("margin_top", 12)
	stats_margin.add_theme_constant_override("margin_bottom", 12)
	stats_panel.add_child(stats_margin)
	var stats := HBoxContainer.new()
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 34)
	stats_margin.add_child(stats)
	for item in [["BALANCE", "$1,500"], ["PROPERTIES", "0"], ["ROUND", "1"]]:
		var box := VBoxContainer.new()
		var value := Label.new()
		value.text = item[1]
		value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		value.add_theme_font_size_override("font_size", 22)
		value.add_theme_color_override("font_color", Color.WHITE)
		box.add_child(value)
		var caption := Label.new()
		caption.text = item[0]
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.add_theme_font_size_override("font_size", 11)
		caption.add_theme_color_override("font_color", Color("#8da0c0"))
		box.add_child(caption)
		stats.add_child(box)

	action_panel = PanelContainer.new()
	action_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	action_panel.position = Vector2(-475.0, -128.0)
	action_panel.size = Vector2(447.0, 96.0)
	action_panel.add_theme_stylebox_override("panel", _ui_panel(NAVY, 0.94, 18))
	root.add_child(action_panel)
	var action_margin := MarginContainer.new()
	action_margin.add_theme_constant_override("margin_left", 14)
	action_margin.add_theme_constant_override("margin_right", 14)
	action_margin.add_theme_constant_override("margin_top", 12)
	action_margin.add_theme_constant_override("margin_bottom", 12)
	action_panel.add_child(action_margin)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	action_margin.add_child(actions)
	dice_value_label = Label.new()
	dice_value_label.text = "DICE\n3 + 4"
	dice_value_label.custom_minimum_size = Vector2(96.0, 66.0)
	dice_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dice_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dice_value_label.add_theme_font_size_override("font_size", 17)
	dice_value_label.add_theme_color_override("font_color", GOLD_LIGHT)
	actions.add_child(dice_value_label)

	roll_button = Button.new()
	roll_button.text = "ROLL FOR MIA"
	roll_button.custom_minimum_size = Vector2(200.0, 66.0)
	roll_button.add_theme_font_size_override("font_size", 21)
	roll_button.add_theme_color_override("font_color", INK)
	roll_button.add_theme_color_override("font_hover_color", INK)
	roll_button.add_theme_stylebox_override("normal", _ui_panel(GOLD, 1.0, 16))
	roll_button.add_theme_stylebox_override("hover", _ui_panel(GOLD_LIGHT, 1.0, 16))
	roll_button.add_theme_stylebox_override("pressed", _ui_panel(Color("#c9922f"), 1.0, 16))
	roll_button.pressed.connect(_roll_dice)
	actions.add_child(roll_button)

	var reset_button := Button.new()
	reset_button.text = "RESET\nVIEW"
	reset_button.custom_minimum_size = Vector2(94.0, 66.0)
	reset_button.add_theme_font_size_override("font_size", 14)
	reset_button.add_theme_color_override("font_color", Color.WHITE)
	reset_button.add_theme_stylebox_override("normal", _ui_panel(Color("#24304d"), 1.0, 16))
	reset_button.add_theme_stylebox_override("hover", _ui_panel(Color("#344466"), 1.0, 16))
	reset_button.pressed.connect(_reset_camera)
	actions.add_child(reset_button)

	hint_label = Label.new()
	hint_label.text = "Right-drag to orbit   •   Wheel to zoom   •   Space to roll"
	hint_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	hint_label.position = Vector2(-245.0, 30.0)
	hint_label.size = Vector2(490.0, 30.0)
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 13)
	hint_label.add_theme_color_override("font_color", Color(0.82, 0.88, 1.0, 0.72))
	root.add_child(hint_label)


func _theme_color(key: String, fallback: String) -> Color:
	return Color(str(city_theme.get(key, fallback)))


func _rebuild_city_board(
	board_id: String,
	logical_tile_names: Array[String],
	logical_tiles: Array[Dictionary]
) -> void:
	if not CityThemesCatalog.has_theme(board_id):
		push_warning("No 3D city theme registered for %s." % board_id)
		return
	if active_tween != null and active_tween.is_running():
		active_tween.kill()
	if camera_tween != null and camera_tween.is_running():
		camera_tween.kill()
	cinematic_camera_active = false
	active_reach_player = -1

	for child in board_root.get_children():
		board_root.remove_child(child)
		child.queue_free()
	tile_positions.clear()
	player_tokens.clear()
	dice_nodes.clear()
	cloud_nodes.clear()
	cloud_speeds.clear()
	boat_routes.clear()
	board_tap_targets.clear()
	movement_markers.clear()
	movement_preview_root = null
	destination_beacon = null
	player_tiles = [19, 32, 45, 6]

	current_board_id = board_id
	city_theme = CityThemesCatalog.get_theme(current_board_id)
	latest_logical_tile_names.assign(logical_tile_names)
	latest_logical_tiles.assign(logical_tiles)
	_apply_visual_tile_data(logical_tiles)
	active_tile_names = _visual_tile_names(logical_tile_names)
	_apply_city_environment()
	_create_board()
	_create_center_city()
	_create_theme_park_world()
	_create_tokens()
	_create_dice()
	_update_city_brand()


func _visual_tile_names(logical_tile_names: Array[String]) -> Array[String]:
	var result: Array[String] = []
	var scenic_values = city_theme.get("scenic", [])
	var scenic: Array = scenic_values if typeof(scenic_values) == TYPE_ARRAY else []
	for index in BOARD_SPOT_COUNT:
		var scenic_name := "SCENIC STOP"
		if not scenic.is_empty():
			scenic_name = str(scenic[index % scenic.size()])
		result.append(scenic_name)

	if logical_tile_names.is_empty():
		if current_board_id == "usa_new_york":
			result.assign(TILE_NAMES)
		return result

	for logical_index in logical_tile_names.size():
		var visual_index := (
			roundi(float(logical_index) * float(BOARD_SPOT_COUNT) / float(logical_tile_names.size()))
			% BOARD_SPOT_COUNT
		)
		result[visual_index] = logical_tile_names[logical_index]
	return result


func _apply_visual_tile_data(logical_tiles: Array[Dictionary]) -> void:
	active_visual_tile_data.clear()
	for tile_value in logical_tiles:
		var visual_position := posmod(
			int(tile_value.get("visualPosition", 0)),
			BOARD_SPOT_COUNT
		)
		active_visual_tile_data[visual_position] = tile_value.duplicate(true)


func _refresh_visual_tiles(
	logical_tile_names: Array[String],
	logical_tiles: Array[Dictionary]
) -> void:
	latest_logical_tile_names.assign(logical_tile_names)
	latest_logical_tiles.assign(logical_tiles)
	var previous_visual_tile_data := active_visual_tile_data.duplicate(true)
	_apply_visual_tile_data(logical_tiles)
	active_tile_names = _visual_tile_names(logical_tile_names)
	for index in BOARD_SPOT_COUNT:
		var tile := board_root.get_node_or_null("Tile%02d" % index) as Node3D
		if tile == null:
			continue
		var label := tile.get_node_or_null("TileLabel") as Label3D
		if label != null:
			label.text = _tile_label_text(index)
		var previous_payload_value = previous_visual_tile_data.get(index, {})
		var previous_payload := (
			previous_payload_value as Dictionary
			if typeof(previous_payload_value) == TYPE_DICTIONARY
			else {}
		)
		_refresh_tile_style(tile, index, previous_payload)


func _refresh_tile_style(
	tile: Node3D,
	index: int,
	previous_payload: Dictionary = {}
) -> void:
	var payload := _visual_tile_payload(index)
	var tile_type := str(payload.get("type", ""))
	var tile_color := _tile_surface_color(index)
	tile.set_meta("logical_index", int(payload.get("logicalIndex", -1)))

	var base := tile.get_node_or_null("TileBase") as MeshInstance3D
	if base != null:
		base.material_override = _material(tile_color, 0.0, 0.5)

	var accent_color := _tile_accent_color(index)
	var accent := tile.get_node_or_null("TileAccent") as MeshInstance3D
	if accent != null:
		accent.visible = accent_color.a > 0.0
		if accent.visible:
			accent.material_override = _material(accent_color, 0.05, 0.33)

	var label := tile.get_node_or_null("TileLabel") as Label3D
	if label != null:
		label.modulate = (
			Color("#172238")
			if tile_color.get_luminance() > 0.5
			else Color.WHITE
		)

	var icon := tile.get_node_or_null("TileIcon") as Label3D
	if icon != null:
		icon.text = _tile_icon_text(tile_type)
		icon.visible = not icon.text.is_empty()
		icon.modulate = (
			Color.WHITE
			if tile_color.get_luminance() < 0.55
			else INK
		)
	_refresh_tile_development(tile, index, previous_payload)


func _refresh_tile_development(
	tile: Node3D,
	index: int,
	previous_payload: Dictionary = {}
) -> void:
	var payload := _visual_tile_payload(index)
	var previous := tile.get_node_or_null("DevelopmentMarkers")
	if (
		previous != null
		and not previous_payload.is_empty()
		and not _development_payload_changed(payload, previous_payload)
	):
		return
	if previous != null:
		previous.name = "RetiringDevelopmentMarkers"
		tile.remove_child(previous)
		previous.queue_free()

	var owner_color := _color_from_argb(
		int(payload.get("ownerColorArgb", 0)),
		Color.TRANSPARENT
	)
	var upgrade_level := int(payload.get("upgradeLevel", 0))
	var is_mortgaged := bool(payload.get("isMortgaged", false))
	var has_complete_group := bool(payload.get("hasCompleteColorGroup", false))
	if owner_color.a <= 0.0 and upgrade_level <= 0 and not is_mortgaged:
		return

	var markers := Node3D.new()
	markers.name = "DevelopmentMarkers"
	tile.add_child(markers)
	if owner_color.a > 0.0:
		_create_owner_flag(markers, owner_color)
	if has_complete_group and owner_color.a > 0.0:
		_create_complete_group_trim(markers, owner_color)

	if upgrade_level > 0:
		if (
			current_board_id == "usa_new_york"
			and str(payload.get("type", "")) == "property"
		):
			_create_nyc_property_development(
				markers,
				payload,
				upgrade_level,
				owner_color
			)
		elif upgrade_level >= 5:
			_create_mini_hotel(markers, owner_color)
		else:
			for house_index in mini(upgrade_level, 4):
				_create_mini_house(markers, house_index, owner_color)

	if is_mortgaged:
		_create_mortgage_shutter(markers)

	if previous_payload.is_empty():
		return
	var previous_owner := int(previous_payload.get("ownerColorArgb", 0))
	var previous_upgrade := int(previous_payload.get("upgradeLevel", 0))
	var previous_mortgage := bool(previous_payload.get("isMortgaged", false))
	var previous_complete := bool(
		previous_payload.get("hasCompleteColorGroup", false)
	)
	var change_label := ""
	var change_color := owner_color if owner_color.a > 0.0 else GOLD_LIGHT
	if previous_owner == 0 and owner_color.a > 0.0:
		change_label = "SOLD"
	elif upgrade_level > previous_upgrade:
		change_label = "HOTEL OPEN" if upgrade_level >= 5 else "BUILDING"
	elif not previous_complete and has_complete_group:
		change_label = "DISTRICT COMPLETE"
	elif not previous_mortgage and is_mortgaged:
		change_label = "MORTGAGED"
		change_color = RED
	elif previous_mortgage and not is_mortgaged:
		change_label = "REOPENED"
	if not change_label.is_empty():
		_animate_property_change(markers, change_label, change_color)


func _development_payload_changed(
	payload: Dictionary,
	previous_payload: Dictionary
) -> bool:
	return (
		str(payload.get("type", "")) != str(previous_payload.get("type", ""))
		or int(payload.get("logicalIndex", -1))
			!= int(previous_payload.get("logicalIndex", -1))
		or int(payload.get("ownerColorArgb", 0))
			!= int(previous_payload.get("ownerColorArgb", 0))
		or int(payload.get("upgradeLevel", 0))
			!= int(previous_payload.get("upgradeLevel", 0))
		or bool(payload.get("isMortgaged", false))
			!= bool(previous_payload.get("isMortgaged", false))
		or bool(payload.get("hasCompleteColorGroup", false))
			!= bool(previous_payload.get("hasCompleteColorGroup", false))
	)


func _create_owner_flag(markers: Node3D, owner_color: Color) -> void:
	var pole_material := _material(Color("#c9d4df"), 0.72, 0.24)
	var pole := _add_box(
		markers,
		Vector3(0.025, 0.44, 0.025),
		Vector3(-0.4, 0.39, 0.25),
		pole_material
	)
	pole.name = "OwnerFlagPole"
	var flag := _add_box(
		markers,
		Vector3(0.24, 0.13, 0.035),
		Vector3(-0.29, 0.54, 0.25),
		_material(owner_color, 0.18, 0.3, owner_color, 0.7)
	)
	flag.name = "OwnerFlag"


func _create_complete_group_trim(
	markers: Node3D,
	owner_color: Color
) -> void:
	var glow_material := _material(
		owner_color.lightened(0.18),
		0.24,
		0.18,
		owner_color,
		2.2
	)
	var trim_index := 0
	for edge_z in [-0.44, 0.44]:
		var horizontal_trim := _add_box(
			markers,
			Vector3(1.02, 0.04, 0.035),
			Vector3(0.0, 0.15, edge_z),
			glow_material
		)
		horizontal_trim.name = "CompleteGroupTrim%d" % trim_index
		trim_index += 1
	for edge_x in [-0.52, 0.52]:
		var vertical_trim := _add_box(
			markers,
			Vector3(0.035, 0.04, 0.85),
			Vector3(edge_x, 0.15, 0.0),
			glow_material
		)
		vertical_trim.name = "CompleteGroupTrim%d" % trim_index
		trim_index += 1


func _create_mini_house(
	markers: Node3D,
	house_index: int,
	owner_color: Color
) -> void:
	var x := -0.19 + float(house_index) * 0.145
	var body_color := owner_color.lerp(CREAM, 0.7)
	var house := _add_box(
		markers,
		Vector3(0.12, 0.2, 0.15),
		Vector3(x, 0.27, -0.29),
		_material(body_color, 0.03, 0.62)
	)
	house.name = "House%d" % (house_index + 1)
	_add_box(
		markers,
		Vector3(0.145, 0.07, 0.175),
		Vector3(x, 0.405, -0.29),
		_material(owner_color, 0.08, 0.48)
	)
	_add_box(
		markers,
		Vector3(0.035, 0.045, 0.012),
		Vector3(x, 0.29, -0.371),
		_material(GOLD_LIGHT, 0.08, 0.25, GOLD_LIGHT, 1.0)
	)


func _create_mini_hotel(markers: Node3D, owner_color: Color) -> void:
	var body_color := owner_color.lerp(Color("#dbe7eb"), 0.74)
	var hotel := _add_box(
		markers,
		Vector3(0.32, 0.52, 0.26),
		Vector3(0.1, 0.43, -0.28),
		_material(body_color, 0.16, 0.38)
	)
	hotel.name = "Hotel"
	for floor_index in 3:
		_add_box(
			markers,
			Vector3(0.2, 0.035, 0.018),
			Vector3(
				0.1,
				0.27 + float(floor_index) * 0.13,
				-0.421
			),
			_material(GOLD_LIGHT, 0.05, 0.24, GOLD_LIGHT, 1.2)
		)
	_add_box(
		markers,
		Vector3(0.38, 0.08, 0.3),
		Vector3(0.1, 0.73, -0.28),
		_material(owner_color, 0.22, 0.3, owner_color, 0.8)
	)


func _create_nyc_property_development(
	markers: Node3D,
	payload: Dictionary,
	upgrade_level: int,
	owner_color: Color
) -> void:
	var logical_index := int(payload.get("logicalIndex", -1))
	var family := _nyc_development_family(logical_index)
	var model := Node3D.new()
	model.name = "NYC%sDevelopment" % (
		family.capitalize().replace(" ", "").replace("_", "")
	)
	# Keep the architecture on the color-strip side of the card so the
	# location name and price remain readable from the normal board camera.
	model.position = Vector3(0.04, 0.16, 0.28)
	model.set_meta("logical_index", logical_index)
	model.set_meta("development_family", family)
	model.set_meta("upgrade_level", upgrade_level)
	markers.add_child(model)

	match family:
		"chinatown":
			_create_nyc_chinatown_model(model, upgrade_level, owner_color)
		"loft":
			_create_nyc_loft_model(model, upgrade_level, owner_color)
		"neon":
			_create_nyc_neon_model(model, upgrade_level, owner_color)
		"luxury":
			_create_nyc_luxury_model(model, upgrade_level, owner_color)
		"arts":
			_create_nyc_arts_model(model, upgrade_level, owner_color)
		"finance":
			_create_nyc_finance_model(model, upgrade_level, owner_color)
		"bridge":
			_create_nyc_bridge_model(model, upgrade_level, owner_color)
		"park":
			_create_nyc_park_model(model, upgrade_level, owner_color)
		"waterfront":
			_create_nyc_waterfront_model(model, upgrade_level, owner_color)
		"flatiron":
			_create_nyc_flatiron_model(model, upgrade_level, owner_color)
		"modern":
			_create_nyc_modern_model(model, upgrade_level, owner_color)
		"art_deco":
			_create_nyc_art_deco_model(model, upgrade_level, owner_color)
		"liberty":
			_create_nyc_liberty_model(model, upgrade_level, owner_color)
		_:
			_create_nyc_brownstone_model(model, upgrade_level, owner_color)
	_create_nyc_development_badges(model, upgrade_level, owner_color)


func _nyc_development_family(logical_index: int) -> String:
	match logical_index:
		1:
			return "chinatown"
		3, 11, 23:
			return "brownstone"
		6, 8, 9, 31:
			return "loft"
		13:
			return "neon"
		14, 24, 26:
			return "luxury"
		16:
			return "arts"
		18:
			return "finance"
		19:
			return "bridge"
		21:
			return "park"
		27, 29:
			return "waterfront"
		32:
			return "flatiron"
		34:
			return "modern"
		37:
			return "art_deco"
		39:
			return "liberty"
		_:
			return "brownstone"


func _create_nyc_development_badges(
	parent: Node3D,
	upgrade_level: int,
	owner_color: Color
) -> void:
	var badge_material := _material(
		owner_color.lightened(0.18),
		0.22,
		0.25,
		owner_color,
		1.35
	)
	if upgrade_level >= 5:
		var hotel_badge := _add_box(
			parent,
			Vector3(0.28, 0.035, 0.055),
			Vector3(0.0, 0.035, -0.26),
			badge_material
		)
		hotel_badge.name = "HotelBadge"
		return
	var badge_count := mini(upgrade_level, 4)
	for badge_index in badge_count:
		var badge_x := (
			(float(badge_index) - float(badge_count - 1) * 0.5) * 0.09
		)
		var badge := _add_box(
			parent,
			Vector3(0.06, 0.035, 0.055),
			Vector3(badge_x, 0.035, -0.26),
			badge_material
		)
		badge.name = "HouseBadge%d" % (badge_index + 1)


func _create_nyc_brownstone_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var count := 1 if level <= 1 else 2 if level <= 3 else 3
	var body := _material(
		owner_color.lerp(Color("#9b5c47"), 0.72),
		0.02,
		0.68
	)
	var trim := _material(Color("#ead9bf"), 0.03, 0.55)
	var window := _material(
		GOLD_LIGHT,
		0.05,
		0.24,
		GOLD_LIGHT,
		0.9
	)
	for building_index in count:
		var width := 0.42 / float(count)
		var x := (
			-0.21 + width * 0.5 + float(building_index) * width
		)
		var height := (
			0.32 + 0.055 * float(level)
			if level < 5
			else 0.68
		)
		_add_box(
			parent,
			Vector3(width - 0.018, height, 0.25),
			Vector3(x, height * 0.5, 0.0),
			body
		)
		_add_box(
			parent,
			Vector3(width - 0.035, 0.035, 0.275),
			Vector3(x, height + 0.018, 0.0),
			_material(owner_color, 0.08, 0.42)
		)
		for floor_index in mini(level + 1, 4):
			_add_box(
				parent,
				Vector3(width * 0.42, 0.035, 0.014),
				Vector3(
					x,
					0.15 + float(floor_index) * 0.11,
					-0.132
				),
				window
			)
		_add_box(
			parent,
			Vector3(width * 0.28, 0.12, 0.018),
			Vector3(x, 0.07, -0.134),
			trim
		)


func _create_nyc_chinatown_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var brick := _material(
		owner_color.lerp(Color("#b44b3f"), 0.72),
		0.03,
		0.62
	)
	var jade := _material(
		Color("#2aa987"),
		0.16,
		0.34,
		Color("#2aa987"),
		0.45
	)
	var lantern := _material(
		Color("#ff5548"),
		0.04,
		0.25,
		Color("#ff5548"),
		1.6
	)
	var height := 0.28 + 0.075 * float(level)
	_add_box(
		parent,
		Vector3(0.43, height, 0.26),
		Vector3(0.0, height * 0.5, 0.0),
		brick
	)
	var roof_layers := 2 if level >= 3 else 1
	for roof_index in roof_layers:
		var roof_width := 0.49 - float(roof_index) * 0.11
		_add_box(
			parent,
			Vector3(roof_width, 0.055, 0.32),
			Vector3(
				0.0,
				height + 0.04 + float(roof_index) * 0.11,
				0.0
			),
			jade
		)
	for lantern_x in [-0.15, 0.15]:
		_add_sphere(
			parent,
			0.045,
			Vector3(lantern_x, 0.19, -0.16),
			lantern,
			10,
			6
		)
	if level >= 5:
		_add_cylinder(
			parent,
			0.025,
			0.04,
			0.28,
			Vector3(0.0, height + 0.3, 0.0),
			_material(GOLD, 0.55, 0.24)
		)


func _create_nyc_loft_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var brick := _material(
		owner_color.lerp(Color("#8a5546"), 0.82),
		0.02,
		0.7
	)
	var iron := _material(Color("#263642"), 0.42, 0.24)
	var glass := _material(
		Color("#7ad2df"),
		0.18,
		0.22,
		Color("#7ad2df"),
		0.45
	)
	var height := 0.3 + 0.085 * float(level)
	_add_box(
		parent,
		Vector3(0.44, height, 0.27),
		Vector3(0.0, height * 0.5, 0.0),
		brick
	)
	for floor_index in mini(level + 1, 5):
		_add_box(
			parent,
			Vector3(0.32, 0.038, 0.016),
			Vector3(
				0.0,
				0.13 + float(floor_index) * 0.105,
				-0.144
			),
			glass
		)
		_add_box(
			parent,
			Vector3(0.38, 0.018, 0.03),
			Vector3(
				0.0,
				0.095 + float(floor_index) * 0.105,
				-0.153
			),
			iron
		)
	if level >= 3:
		_add_cylinder(
			parent,
			0.075,
			0.075,
			0.11,
			Vector3(0.12, height + 0.09, 0.0),
			iron
		)
		_add_box(
			parent,
			Vector3(0.12, 0.018, 0.12),
			Vector3(0.12, height + 0.16, 0.0),
			_material(owner_color, 0.2, 0.35)
		)


func _create_nyc_neon_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var tower := _material(Color("#202b42"), 0.35, 0.22)
	var height := 0.34 + 0.095 * float(level)
	_add_box(
		parent,
		Vector3(0.36, height, 0.24),
		Vector3(0.0, height * 0.5, 0.0),
		tower
	)
	var sign_colors := [
		Color("#36c5f0"),
		Color("#ff4f9a"),
		GOLD_LIGHT,
		owner_color.lightened(0.12),
	]
	var sign_count := mini(level + 1, 4)
	for sign_index in sign_count:
		var sign_color: Color = sign_colors[sign_index]
		var sign_material := _material(
			sign_color,
			0.08,
			0.24,
			sign_color,
			2.2
		)
		for sign_side in [-1.0, 1.0]:
			var sign := _add_box(
				parent,
				Vector3(
					0.16 + float(sign_index % 2) * 0.07,
					0.105,
					0.016
				),
				Vector3(
					-0.08 + float(sign_index % 2) * 0.16,
					0.2 + float(sign_index) * 0.13,
					float(sign_side) * 0.132
				),
				sign_material
			)
			sign.rotation_degrees.z = -5.0 + float(sign_index) * 3.5
	if level >= 5:
		_add_cylinder(
			parent,
			0.025,
			0.04,
			0.32,
			Vector3(0.0, height + 0.16, 0.0),
			_material(GOLD_LIGHT, 0.5, 0.2, GOLD_LIGHT, 1.6)
		)


func _create_nyc_luxury_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var stone := _material(
		owner_color.lerp(Color("#e8dfce"), 0.84),
		0.12,
		0.42
	)
	var glass := _material(
		Color("#8fd8e5"),
		0.35,
		0.18,
		Color("#8fd8e5"),
		0.38
	)
	var height := 0.34 + 0.105 * float(level)
	_add_box(
		parent,
		Vector3(0.34, height, 0.25),
		Vector3(0.0, height * 0.5, 0.0),
		stone
	)
	for floor_index in mini(level + 2, 6):
		_add_box(
			parent,
			Vector3(0.25, 0.026, 0.016),
			Vector3(
				0.0,
				0.11 + float(floor_index) * 0.1,
				-0.134
			),
			glass
		)
		if floor_index % 2 == 1:
			_add_box(
				parent,
				Vector3(0.42, 0.018, 0.31),
				Vector3(
					0.0,
					0.14 + float(floor_index) * 0.1,
					0.0
				),
				_material(owner_color, 0.2, 0.36)
			)
	if level >= 5:
		_add_box(
			parent,
			Vector3(0.2, 0.11, 0.18),
			Vector3(0.0, height + 0.055, 0.0),
			glass
		)


func _create_nyc_arts_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var theater := _material(Color("#3b2538"), 0.08, 0.5)
	var marquee := _material(
		owner_color.lightened(0.18),
		0.12,
		0.24,
		owner_color,
		1.8
	)
	var height := 0.3 + 0.075 * float(level)
	_add_box(
		parent,
		Vector3(0.44, height, 0.26),
		Vector3(0.0, height * 0.5, 0.0),
		theater
	)
	_add_box(
		parent,
		Vector3(0.4, 0.12, 0.055),
		Vector3(0.0, 0.2, -0.155),
		marquee
	)
	_add_box(
		parent,
		Vector3(0.26, 0.055, 0.17),
		Vector3(0.0, 0.11, -0.1),
		_material(GOLD_LIGHT, 0.24, 0.3, GOLD_LIGHT, 0.7)
	)
	for light_index in mini(level + 2, 6):
		var light_x := -0.17 + float(light_index) * 0.068
		_add_sphere(
			parent,
			0.018,
			Vector3(light_x, 0.255, -0.189),
			_material(
				GOLD_LIGHT,
				0.02,
				0.2,
				GOLD_LIGHT,
				2.4
			),
			8,
			5
		)
	if level >= 5:
		_add_box(
			parent,
			Vector3(0.3, 0.16, 0.025),
			Vector3(0.0, height + 0.09, 0.0),
			marquee
		)


func _create_nyc_finance_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var stone := _material(Color("#d9d0bd"), 0.12, 0.4)
	var dark := _material(
		owner_color.lerp(Color("#243746"), 0.7),
		0.42,
		0.22
	)
	var height := 0.28 + 0.085 * float(level)
	_add_box(
		parent,
		Vector3(0.46, height, 0.26),
		Vector3(0.0, height * 0.5, 0.0),
		stone
	)
	for column_x in [-0.14, -0.047, 0.047, 0.14]:
		_add_cylinder(
			parent,
			0.018,
			0.024,
			height * 0.72,
			Vector3(column_x, height * 0.42, -0.145),
			dark
		)
	_add_triangular_prism(
		parent,
		Vector3(0.5, 0.12, 0.3),
		Vector3(0.0, height + 0.06, 0.0),
		stone
	)
	if level >= 4:
		_add_box(
			parent,
			Vector3(0.22, 0.24, 0.18),
			Vector3(0.0, height + 0.2, 0.0),
			dark
		)
	if level >= 5:
		_add_cylinder(
			parent,
			0.02,
			0.04,
			0.3,
			Vector3(0.0, height + 0.47, 0.0),
			_material(GOLD_LIGHT, 0.55, 0.2, GOLD_LIGHT, 1.0)
		)


func _create_nyc_bridge_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var stone := _material(
		owner_color.lerp(Color("#bca487"), 0.8),
		0.08,
		0.5
	)
	var cable := _material(Color("#e8dbc6"), 0.48, 0.22)
	var tower_height := 0.32 + 0.055 * float(level)
	_add_box(
		parent,
		Vector3(0.48, 0.045, 0.16),
		Vector3(0.0, 0.13, 0.0),
		stone
	)
	for tower_x in [-0.17, 0.17]:
		for tower_offset in [-0.035, 0.035]:
			_add_box(
				parent,
				Vector3(0.035, tower_height, 0.035),
				Vector3(
					tower_x + tower_offset,
					0.13 + tower_height * 0.5,
					0.0
				),
				stone
			)
		_add_box(
			parent,
			Vector3(0.12, 0.035, 0.08),
			Vector3(tower_x, 0.13 + tower_height, 0.0),
			cable
		)
	_add_box(
		parent,
		Vector3(0.42, 0.018, 0.03),
		Vector3(0.0, 0.13 + tower_height * 0.72, -0.055),
		cable
	)
	if level >= 5:
		for lamp_x in [-0.12, 0.0, 0.12]:
			_add_sphere(
				parent,
				0.024,
				Vector3(lamp_x, 0.2, -0.1),
				_material(
					GOLD_LIGHT,
					0.05,
					0.2,
					GOLD_LIGHT,
					2.0
				),
				8,
				5
			)


func _create_nyc_park_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var lawn := _material(Color("#48a663"), 0.0, 0.82)
	var path := _material(Color("#ead7aa"), 0.0, 0.72)
	_add_box(
		parent,
		Vector3(0.48, 0.035, 0.27),
		Vector3(0.0, 0.02, 0.0),
		lawn
	)
	_add_box(
		parent,
		Vector3(0.42, 0.018, 0.045),
		Vector3(0.0, 0.045, 0.0),
		path
	)
	var tree_positions := [
		Vector3(-0.16, 0.05, -0.075),
		Vector3(0.0, 0.05, 0.07),
		Vector3(0.16, 0.05, -0.05),
		Vector3(-0.08, 0.05, 0.08),
	]
	for tree_index in mini(level, 4):
		var tree_position: Vector3 = tree_positions[tree_index]
		_add_cylinder(
			parent,
			0.018,
			0.025,
			0.15,
			tree_position + Vector3.UP * 0.075,
			_material(Color("#66452d"), 0.0, 0.85)
		)
		_add_sphere(
			parent,
			0.075,
			tree_position + Vector3.UP * 0.19,
			_material(
				owner_color.lerp(Color("#2f8252"), 0.72),
				0.0,
				0.78
			),
			12,
			7
		)
	if level >= 5:
		_add_cylinder(
			parent,
			0.09,
			0.12,
			0.13,
			Vector3(0.0, 0.13, 0.0),
			_material(Color("#f0d6b0"), 0.04, 0.52)
		)
		_add_cylinder(
			parent,
			0.025,
			0.13,
			0.12,
			Vector3(0.0, 0.255, 0.0),
			_material(owner_color, 0.12, 0.38)
		)


func _create_nyc_waterfront_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var warehouse := _material(
		owner_color.lerp(Color("#a86148"), 0.78),
		0.03,
		0.68
	)
	var steel := _material(Color("#354b59"), 0.45, 0.24)
	var glass := _material(
		Color("#84d2df"),
		0.26,
		0.2,
		Color("#84d2df"),
		0.32
	)
	var height := 0.27 + 0.07 * float(level)
	_add_box(
		parent,
		Vector3(0.44, height, 0.27),
		Vector3(0.0, height * 0.5, 0.0),
		warehouse
	)
	for window_x in [-0.13, 0.0, 0.13]:
		for floor_index in mini(level + 1, 4):
			_add_box(
				parent,
				Vector3(0.07, 0.035, 0.015),
				Vector3(
					window_x,
					0.14 + float(floor_index) * 0.1,
					-0.145
				),
				glass
			)
	if level >= 3:
		_add_cylinder(
			parent,
			0.075,
			0.075,
			0.12,
			Vector3(0.11, height + 0.08, 0.0),
			steel
		)
		_add_box(
			parent,
			Vector3(0.13, 0.025, 0.13),
			Vector3(0.11, height + 0.155, 0.0),
			_material(owner_color, 0.18, 0.36)
		)
	if level >= 5:
		_add_box(
			parent,
			Vector3(0.5, 0.035, 0.31),
			Vector3(0.0, height + 0.018, 0.0),
			steel
		)


func _create_nyc_flatiron_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var limestone := _material(
		owner_color.lerp(Color("#d9cdb7"), 0.86),
		0.1,
		0.44
	)
	var height := 0.34 + 0.09 * float(level)
	var wedge := _add_triangular_prism(
		parent,
		Vector3(0.46, height, 0.3),
		Vector3(0.0, height * 0.5, 0.0),
		limestone
	)
	wedge.rotation_degrees.y = 180.0
	for floor_index in mini(level + 2, 6):
		_add_box(
			parent,
			Vector3(0.3, 0.025, 0.014),
			Vector3(
				0.0,
				0.11 + float(floor_index) * 0.1,
				-0.158
			),
			_material(
				GOLD_LIGHT,
				0.05,
				0.25,
				GOLD_LIGHT,
				0.55
			)
		)
	if level >= 5:
		_add_box(
			parent,
			Vector3(0.25, 0.07, 0.17),
			Vector3(0.0, height + 0.035, -0.025),
			_material(owner_color, 0.2, 0.32)
		)


func _create_nyc_modern_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var glass := _material(
		owner_color.lerp(Color("#70cce1"), 0.72),
		0.52,
		0.14,
		Color("#70cce1"),
		0.25
	)
	var steel := _material(Color("#d6e1e5"), 0.64, 0.18)
	var height := 0.36 + 0.1 * float(level)
	_add_box(
		parent,
		Vector3(0.25, height, 0.25),
		Vector3(-0.08, height * 0.5, 0.0),
		glass
	)
	if level >= 2:
		_add_box(
			parent,
			Vector3(0.2, height * 0.78, 0.2),
			Vector3(0.13, height * 0.39, 0.025),
			glass
		)
	for floor_index in mini(level + 2, 6):
		_add_box(
			parent,
			Vector3(0.42, 0.018, 0.012),
			Vector3(
				0.0,
				0.12 + float(floor_index) * 0.1,
				-0.135
			),
			steel
		)
	if level >= 5:
		_add_box(
			parent,
			Vector3(0.44, 0.055, 0.3),
			Vector3(0.0, height + 0.03, 0.0),
			_material(owner_color, 0.3, 0.24, owner_color, 0.7)
		)


func _create_nyc_art_deco_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var stone := _material(
		owner_color.lerp(Color("#c9c0ad"), 0.88),
		0.16,
		0.36
	)
	var steel := _material(Color("#8298a4"), 0.62, 0.18)
	var base_height := 0.27 + 0.045 * float(level)
	_add_box(
		parent,
		Vector3(0.4, base_height, 0.27),
		Vector3(0.0, base_height * 0.5, 0.0),
		stone
	)
	_add_box(
		parent,
		Vector3(0.29, 0.22 + 0.025 * float(level), 0.21),
		Vector3(
			0.0,
			base_height + 0.11 + 0.0125 * float(level),
			0.0
		),
		stone
	)
	if level >= 3:
		_add_box(
			parent,
			Vector3(0.18, 0.2, 0.15),
			Vector3(0.0, base_height + 0.38, 0.0),
			steel
		)
	if level >= 5:
		_add_cylinder(
			parent,
			0.018,
			0.04,
			0.38,
			Vector3(0.0, base_height + 0.67, 0.0),
			_material(
				GOLD_LIGHT,
				0.6,
				0.16,
				GOLD_LIGHT,
				1.5
			)
		)


func _create_nyc_liberty_model(
	parent: Node3D,
	level: int,
	owner_color: Color
) -> void:
	var pedestal := _material(Color("#cfc3a8"), 0.06, 0.55)
	var copper := _material(
		owner_color.lerp(Color("#55a693"), 0.82),
		0.18,
		0.42
	)
	var pedestal_height := 0.17 + 0.035 * float(level)
	_add_box(
		parent,
		Vector3(0.27, pedestal_height, 0.25),
		Vector3(0.0, pedestal_height * 0.5, 0.0),
		pedestal
	)
	_add_capsule(
		parent,
		0.06,
		0.28 + 0.035 * float(level),
		Vector3(0.0, pedestal_height + 0.18, 0.0),
		copper,
		12,
		7
	)
	_add_sphere(
		parent,
		0.065,
		Vector3(0.0, pedestal_height + 0.39, 0.0),
		copper,
		12,
		7
	)
	var torch_arm := _add_capsule(
		parent,
		0.022,
		0.27,
		Vector3.ZERO,
		copper,
		10,
		6
	)
	_orient_capsule_between(
		torch_arm,
		Vector3(0.035, pedestal_height + 0.3, 0.0),
		Vector3(0.12, pedestal_height + 0.52, 0.0),
		0.022
	)
	_add_sphere(
		parent,
		0.042,
		Vector3(0.125, pedestal_height + 0.57, 0.0),
		_material(
			GOLD_LIGHT,
			0.04,
			0.18,
			GOLD_LIGHT,
			2.5
		),
		10,
		6
	)
	if level >= 5:
		var crown := _add_cylinder(
			parent,
			0.02,
			0.11,
			0.055,
			Vector3(0.0, pedestal_height + 0.46, 0.0),
			_material(owner_color, 0.2, 0.36)
		)
		crown.rotation_degrees.z = 180.0


func _create_mortgage_shutter(markers: Node3D) -> void:
	var shutter := _add_box(
		markers,
		Vector3(0.9, 0.045, 0.66),
		Vector3(0.0, 0.18, 0.0),
		_material(Color("#1b202b"), 0.08, 0.8)
	)
	shutter.name = "MortgageShutter"
	for stripe_index in 5:
		_add_box(
			markers,
			Vector3(0.8, 0.018, 0.025),
			Vector3(
				0.0,
				0.21,
				-0.24 + float(stripe_index) * 0.12
			),
			_material(Color("#3b4351"), 0.1, 0.62)
		)
	var mortgage_label := Label3D.new()
	mortgage_label.name = "MortgageLabel"
	mortgage_label.text = "CLOSED"
	mortgage_label.font_size = 38
	mortgage_label.pixel_size = 0.0054
	mortgage_label.position = Vector3(0.0, 0.235, 0.0)
	mortgage_label.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	mortgage_label.modulate = RED
	mortgage_label.outline_modulate = Color("#070b12")
	mortgage_label.outline_size = 7
	markers.add_child(mortgage_label)


func _animate_property_change(
	markers: Node3D,
	label_text: String,
	change_color: Color
) -> void:
	markers.scale = Vector3.ONE * 0.08
	markers.position = Vector3(0.0, -0.16, 0.0)
	var construction_tween := create_tween()
	construction_tween.set_parallel(true)
	construction_tween.set_trans(Tween.TRANS_BACK)
	construction_tween.set_ease(Tween.EASE_OUT)
	construction_tween.tween_property(markers, "scale", Vector3.ONE, 0.48)
	construction_tween.tween_property(
		markers,
		"position",
		Vector3.ZERO,
		0.48
	)

	var status_label := Label3D.new()
	status_label.name = "PropertyChangeLabel"
	status_label.text = label_text
	status_label.font_size = 38
	status_label.pixel_size = 0.006
	status_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	status_label.position = Vector3(0.0, 1.0, 0.0)
	status_label.modulate = change_color
	status_label.outline_modulate = INK
	status_label.outline_size = 8
	markers.add_child(status_label)
	var label_tween := create_tween()
	label_tween.set_trans(Tween.TRANS_QUAD)
	label_tween.set_ease(Tween.EASE_OUT)
	label_tween.tween_property(
		status_label,
		"position:y",
		1.38,
		0.65
	)
	label_tween.tween_interval(0.35)
	label_tween.tween_property(
		status_label,
		"modulate:a",
		0.0,
		0.32
	)


func _apply_city_environment() -> void:
	var world_environment := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment == null or world_environment.environment == null:
		return
	var sky := world_environment.environment.sky
	if sky == null:
		return
	var sky_material := sky.sky_material as ProceduralSkyMaterial
	if sky_material == null:
		return
	sky_material.sky_top_color = _theme_color("sky_top", "#2f86c9")
	sky_material.sky_horizon_color = _theme_color("sky_horizon", "#bfeaff")
	sky_material.ground_bottom_color = _theme_color("water", "#3196bc")
	sky_material.ground_horizon_color = _theme_color("sky_horizon", "#8fd5eb")


func _update_city_brand() -> void:
	if brand_title_label != null:
		brand_title_label.text = "PROPERTY TYCOON  •  %s" % str(city_theme.get("city", "CITY"))
	if brand_subtitle_label != null:
		brand_subtitle_label.text = str(city_theme.get("subtitle", "CITY THEME PARK"))


func _connect_flutter_bridge() -> void:
	flutter_bridge = (
		Engine.get_singleton("PropertyTycoonBridge")
		if Engine.has_singleton("PropertyTycoonBridge")
		else null
	)
	if flutter_bridge != null:
		_enable_embedded_mode()
		flutter_bridge.connect("sync_state", _apply_flutter_state_json)
		flutter_bridge.connect("animate_roll", _animate_flutter_roll_json)
		flutter_bridge.connect("camera_gesture", _apply_camera_gesture_json)
		flutter_bridge.connect("board_tap", _pick_board_object_json)
		flutter_bridge.ready()
		return

	if OS.get_name() == "iOS":
		_enable_embedded_mode()
		_emit_swift_host_event("boardReady", {})


func _enable_embedded_mode() -> void:
	embedded_mode = true
	var hud := get_node_or_null("GameHUD") as CanvasLayer
	if hud != null:
		hud.visible = false


func host_receive_message(message: Dictionary) -> void:
	var action := str(message.get("action", ""))
	var json := str(message.get("json", ""))
	match action:
		"sync_state":
			_apply_flutter_state_json(json)
		"animate_roll":
			_animate_flutter_roll_json(json)
		"camera_gesture":
			_apply_camera_gesture_json(json)
		"board_tap":
			_pick_board_object_json(json)


func _apply_camera_gesture_json(json: String) -> void:
	var value = JSON.parse_string(json)
	if typeof(value) != TYPE_DICTIONARY:
		return
	var gesture := value as Dictionary
	if bool(gesture.get("reset", false)):
		_reset_camera()
		return
	var orbit_delta_x := float(gesture.get("orbitDeltaX", 0.0))
	var orbit_delta_y := float(gesture.get("orbitDeltaY", 0.0))
	var zoom_scale := float(gesture.get("zoomScale", 1.0))
	if (
		orbit_delta_x != 0.0
		or orbit_delta_y != 0.0
		or (zoom_scale > 0.0 and not is_equal_approx(zoom_scale, 1.0))
	):
		_cancel_camera_cinematic()

	if orbit_delta_x != 0.0 or orbit_delta_y != 0.0:
		camera_azimuth -= orbit_delta_x * 0.007
		camera_elevation = clampf(
			camera_elevation - orbit_delta_y * 0.005,
			deg_to_rad(27.0),
			deg_to_rad(72.0)
		)
	if zoom_scale > 0.0 and not is_equal_approx(zoom_scale, 1.0):
		camera_distance = clampf(
			camera_distance / zoom_scale,
			CAMERA_MIN_DISTANCE,
			CAMERA_MAX_DISTANCE
		)
	_update_camera()


func _pick_board_object_json(json: String) -> void:
	var value = JSON.parse_string(json)
	if typeof(value) != TYPE_DICTIONARY or camera == null:
		return
	var pick := value as Dictionary
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var screen_position := Vector2(
		clampf(float(pick.get("normalizedX", 0.5)), 0.0, 1.0) * viewport_size.x,
		clampf(float(pick.get("normalizedY", 0.5)), 0.0, 1.0) * viewport_size.y
	)
	_emit_board_selection(_selection_at_screen(screen_position, viewport_size))


func _selection_at_screen(
	screen_position: Vector2,
	viewport_size: Vector2
) -> Dictionary:
	var selection := {
		"kind": "city",
		"logicalIndex": -1,
		"visualIndex": -1,
		"playerIndex": -1,
		"playerId": "",
		"title": str(city_theme.get("city", "CITY")),
	}
	var best_score := INF
	var base_radius := clampf(minf(viewport_size.x, viewport_size.y) * 0.06, 44.0, 86.0)

	for player_index in player_tokens.size():
		var token := player_tokens[player_index]
		if not token.visible:
			continue
		var player_position := token.global_position + Vector3.UP * 2.1
		var player_score := _screen_pick_score(
			player_position,
			screen_position,
			base_radius * 1.25
		) - 0.18
		if player_score < best_score:
			best_score = player_score
			selection = {
				"kind": "player",
				"logicalIndex": -1,
				"visualIndex": player_tiles[player_index],
				"playerIndex": player_index,
				"playerId": player_ids[player_index],
				"title": player_names[player_index],
			}

	for die_index in dice_nodes.size():
		var die := dice_nodes[die_index]
		var die_score := _screen_pick_score(
			die.global_position,
			screen_position,
			base_radius * 1.12
		) - 0.12
		if die_score < best_score:
			best_score = die_score
			selection = {
				"kind": "dice",
				"logicalIndex": -1,
				"visualIndex": -1,
				"playerIndex": -1,
				"playerId": "",
				"title": "DICE",
			}

	for target in board_tap_targets:
		var target_node = target.get("node")
		if not is_instance_valid(target_node) or not target_node is Node3D:
			continue
		var landmark_score := _screen_pick_score(
			(target_node as Node3D).global_position,
			screen_position,
			base_radius * 1.6
		) - 0.06
		if landmark_score < best_score:
			best_score = landmark_score
			selection = {
				"kind": str(target.get("kind", "landmark")),
				"logicalIndex": -1,
				"visualIndex": -1,
				"playerIndex": -1,
				"playerId": "",
				"title": str(target.get("title", "LANDMARK")),
			}

	for visual_index in tile_positions.size():
		var tile_position := board_root.to_global(
			tile_positions[visual_index] + Vector3.UP * 0.3
		)
		var tile_score := _screen_pick_score(
			tile_position,
			screen_position,
			base_radius
		)
		if tile_score >= best_score:
			continue
		best_score = tile_score
		var payload := _visual_tile_payload(visual_index)
		if payload.is_empty():
			selection = {
				"kind": "scenic",
				"logicalIndex": -1,
				"visualIndex": visual_index,
				"playerIndex": -1,
				"playerId": "",
				"title": active_tile_names[visual_index],
			}
		else:
			selection = {
				"kind": "tile",
				"logicalIndex": int(payload.get("logicalIndex", -1)),
				"visualIndex": visual_index,
				"playerIndex": -1,
				"playerId": "",
				"title": str(payload.get("name", active_tile_names[visual_index])),
			}
	return selection


func _screen_pick_score(
	world_position: Vector3,
	screen_position: Vector2,
	radius: float
) -> float:
	if camera.is_position_behind(world_position):
		return INF
	var projected := camera.unproject_position(world_position)
	var distance := projected.distance_to(screen_position)
	return distance / radius if distance <= radius else INF


func _emit_board_selection(selection: Dictionary) -> void:
	if flutter_bridge != null:
		flutter_bridge.boardObjectTapped(
			str(selection.get("kind", "city")),
			int(selection.get("logicalIndex", -1)),
			int(selection.get("visualIndex", -1)),
			int(selection.get("playerIndex", -1)),
			str(selection.get("playerId", "")),
			str(selection.get("title", ""))
		)
	else:
		_emit_swift_host_event("boardObjectTapped", selection)


func _emit_swift_host_event(method: String, arguments: Dictionary) -> void:
	var payload := {
		"method": method,
		"arguments": JSON.stringify(arguments),
	}
	swift_host_messages.append(payload)


func host_poll_message() -> Dictionary:
	if swift_host_messages.is_empty():
		return {}
	return swift_host_messages.pop_front()


func _apply_flutter_state_json(json: String) -> void:
	var payload = JSON.parse_string(json)
	if typeof(payload) != TYPE_DICTIONARY:
		push_warning("Flutter board state was not a JSON object.")
		return

	var players_value = payload.get("players", [])
	if typeof(players_value) != TYPE_ARRAY:
		return
	var players: Array = players_value
	var requested_board_id := str(payload.get("boardId", current_board_id))
	var logical_tile_names: Array[String] = []
	var tile_names_value = payload.get("tileNames", [])
	if typeof(tile_names_value) == TYPE_ARRAY:
		for tile_name in tile_names_value:
			logical_tile_names.append(str(tile_name))
	var logical_tiles: Array[Dictionary] = []
	var tiles_value = payload.get("tiles", [])
	if typeof(tiles_value) == TYPE_ARRAY:
		for tile_value in tiles_value:
			if typeof(tile_value) == TYPE_DICTIONARY:
				logical_tiles.append((tile_value as Dictionary).duplicate(true))

	var requested_player_count := clampi(players.size(), 0, PLAYER_NAMES.size())
	if requested_board_id != current_board_id:
		active_player_count = requested_player_count
		_rebuild_city_board(requested_board_id, logical_tile_names, logical_tiles)
	elif (
		logical_tile_names != latest_logical_tile_names
		or logical_tiles != latest_logical_tiles
	):
		_refresh_visual_tiles(logical_tile_names, logical_tiles)

	active_player_count = clampi(players.size(), 0, player_tokens.size())
	current_player_index = clampi(
		int(payload.get("currentPlayerIndex", 0)),
		0,
		maxi(0, active_player_count - 1)
	)

	for index in player_tokens.size():
		var token := player_tokens[index]
		if index >= players.size():
			token.visible = false
			continue
		var player_value = players[index]
		if typeof(player_value) != TYPE_DICTIONARY:
			token.visible = false
			continue
		var player: Dictionary = player_value
		token.visible = bool(player.get("isActive", true))
		player_names[index] = str(player.get("name", player_names[index]))
		player_ids[index] = str(player.get("id", ""))
		token.name = "%sCharacterPiece" % player_names[index]
		var visual_position := posmod(
			int(player.get("visualPosition", 0)),
			BOARD_SPOT_COUNT
		)
		player_tiles[index] = visual_position
		var target := tile_positions[visual_position] + _token_offset_for_tile(
			visual_position,
			index
		)
		token.position = Vector3(target.x, 0.0, target.z)

	if active_player_count > 0:
		_set_active_player(current_player_index)
	var synced_die_one := int(payload.get("die1", 0))
	var synced_die_two := int(payload.get("die2", 0))
	if dice_nodes.size() > 1:
		dice_nodes[1].visible = synced_die_two > 0
	dice_value_label.text = (
		"DICE\n%d" % synced_die_one
		if synced_die_two <= 0
		else "DICE\n%d + %d" % [synced_die_one, synced_die_two]
	)


func _animate_flutter_roll_json(json: String) -> void:
	var payload = JSON.parse_string(json)
	if typeof(payload) != TYPE_DICTIONARY:
		return
	var command: Dictionary = payload
	var player_index := int(command.get("playerIndex", -1))
	if player_index < 0 or player_index >= player_tokens.size():
		return
	if active_tween != null and active_tween.is_running():
		get_tree().create_timer(0.05).timeout.connect(
			_animate_flutter_roll_json.bind(json),
			CONNECT_ONE_SHOT
		)
		return

	var die_one := int(command.get("die1", 0))
	var die_two := int(command.get("die2", 0))
	current_player_index = player_index
	_set_active_player(player_index)
	turn_label.text = "%s IS ROLLING…" % player_names[player_index]
	_show_movement_preview(command)
	_begin_roll_camera_cinematic()
	_animate_3d_dice(die_one, die_two)

	get_tree().create_timer(1.04).timeout.connect(
		_begin_flutter_token_path.bind(command),
		CONNECT_ONE_SHOT
	)


func _begin_flutter_token_path(command: Dictionary) -> void:
	var player_index := int(command.get("playerIndex", -1))
	if player_index < 0 or player_index >= player_tokens.size():
		return
	var die_one := int(command.get("die1", 0))
	var die_two := int(command.get("die2", 0))
	var spaces := int(command.get("spaces", die_one + die_two))
	dice_value_label.text = "DICE\n%d + %d" % [die_one, die_two]
	turn_label.text = "%s MOVES %d SPACES…" % [
		player_names[player_index],
		spaces,
	]
	_focus_camera_on_route(command)

	var visual_path_value = command.get("visualPath", [])
	if typeof(visual_path_value) == TYPE_ARRAY:
		_animate_flutter_path_step(command, visual_path_value, 0)
	else:
		_finish_flutter_roll(command)


func _animate_flutter_path_step(
	command: Dictionary,
	visual_path: Array,
	path_index: int
) -> void:
	if path_index >= visual_path.size():
		_finish_flutter_roll(command)
		return

	var player_index := int(command.get("playerIndex", -1))
	if player_index < 0 or player_index >= player_tokens.size():
		return
	var target_tile := posmod(int(visual_path[path_index]), BOARD_SPOT_COUNT)
	_advance_movement_preview(path_index)
	player_tiles[player_index] = target_tile
	var token := player_tokens[player_index]
	var target_local := tile_positions[target_tile] + _token_offset_for_tile(
		target_tile,
		player_index
	)
	var move_direction := Vector3(
		target_local.x - token.position.x,
		0.0,
		target_local.z - token.position.z
	)
	if move_direction.length_squared() > 0.001:
		token.rotation.y = atan2(-move_direction.x, -move_direction.z)

	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(token, "position:x", target_local.x, 0.22)
	active_tween.tween_property(token, "position:z", target_local.z, 0.22)
	active_tween.finished.connect(
		_animate_flutter_path_step.bind(
			command,
			visual_path,
			path_index + 1
		),
		CONNECT_ONE_SHOT
	)

	var hop_tween := create_tween()
	hop_tween.set_trans(Tween.TRANS_QUAD)
	hop_tween.set_ease(Tween.EASE_OUT)
	hop_tween.tween_property(token, "position:y", 0.68, 0.11)
	hop_tween.set_ease(Tween.EASE_IN)
	hop_tween.tween_property(token, "position:y", 0.0, 0.11)


func _finish_flutter_roll(command: Dictionary) -> void:
	var player_index := int(command.get("playerIndex", -1))
	if player_index < 0 or player_index >= player_tokens.size():
		return

	var final_visual := player_tiles[player_index]
	var to_logical := int(command.get("toLogicalPosition", 0))
	turn_label.text = "%s  •  %s" % [
		player_names[player_index],
		active_tile_names[final_visual],
	]
	_finish_movement_preview(final_visual)
	_play_landing_reaction(player_index)
	_focus_camera_on_landing(final_visual)
	get_tree().create_timer(1.25).timeout.connect(
		_restore_camera_after_roll,
		CONNECT_ONE_SHOT
	)
	get_tree().create_timer(1.35).timeout.connect(
		_clear_movement_preview,
		CONNECT_ONE_SHOT
	)
	var command_id := str(command.get("commandId", ""))
	var player_id := str(command.get("playerId", ""))
	if flutter_bridge != null:
		flutter_bridge.movementComplete(
			command_id,
			player_id,
			to_logical,
			final_visual
		)
	else:
		_emit_swift_host_event("movementComplete", {
			"commandId": command_id,
			"playerId": player_id,
			"logicalPosition": to_logical,
			"visualPosition": final_visual,
		})


func _show_movement_preview(command: Dictionary) -> void:
	_clear_movement_preview()
	movement_preview_root = Node3D.new()
	movement_preview_root.name = "MovementPreview"
	board_root.add_child(movement_preview_root)

	var visual_path_value = command.get("visualPath", [])
	if typeof(visual_path_value) != TYPE_ARRAY:
		return
	var visual_path: Array = visual_path_value
	for path_index in visual_path.size():
		var visual_index := posmod(
			int(visual_path[path_index]),
			BOARD_SPOT_COUNT
		)
		var marker_material := _material(
			Color(0.16, 0.82, 0.76, 0.5),
			0.16,
			0.24,
			TEAL,
			1.5
		)
		marker_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		var marker := _add_cylinder(
			movement_preview_root,
			0.31,
			0.31,
			0.045,
			tile_positions[visual_index] + Vector3.UP * 0.27,
			marker_material
		)
		marker.name = "RouteMarker%02d" % path_index
		marker.scale = Vector3.ONE * 0.05
		movement_markers.append(marker)
		var marker_tween := create_tween()
		marker_tween.tween_interval(path_index * 0.035)
		marker_tween.set_trans(Tween.TRANS_BACK)
		marker_tween.set_ease(Tween.EASE_OUT)
		marker_tween.tween_property(marker, "scale", Vector3.ONE, 0.18)

	if visual_path.is_empty():
		return
	var destination_visual := posmod(
		int(visual_path[visual_path.size() - 1]),
		BOARD_SPOT_COUNT
	)
	destination_beacon = Node3D.new()
	destination_beacon.name = "DestinationBeacon"
	destination_beacon.position = tile_positions[destination_visual]
	movement_preview_root.add_child(destination_beacon)
	var beacon_material := _material(
		Color(1.0, 0.75, 0.22, 0.48),
		0.3,
		0.2,
		GOLD_LIGHT,
		2.4
	)
	beacon_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_add_cylinder(
		destination_beacon,
		0.72,
		0.72,
		0.055,
		Vector3.UP * 0.31,
		beacon_material
	)
	var destination_label := Label3D.new()
	destination_label.name = "DestinationLabel"
	destination_label.text = "LANDING"
	destination_label.font_size = 34
	destination_label.pixel_size = 0.006
	destination_label.modulate = GOLD_LIGHT
	destination_label.outline_modulate = INK
	destination_label.outline_size = 8
	destination_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	destination_label.position = Vector3(0.0, 1.28, 0.0)
	destination_beacon.add_child(destination_label)


func _advance_movement_preview(path_index: int) -> void:
	for marker_index in movement_markers.size():
		var marker := movement_markers[marker_index]
		if not is_instance_valid(marker):
			continue
		if marker_index < path_index:
			marker.scale = Vector3.ONE * 0.58
		elif marker_index == path_index:
			marker.scale = Vector3.ONE * 1.35
			marker.material_override = _material(
				GOLD_LIGHT,
				0.25,
				0.18,
				GOLD_LIGHT,
				2.4
			)
		else:
			marker.scale = Vector3.ONE


func _finish_movement_preview(final_visual: int) -> void:
	if not is_instance_valid(destination_beacon):
		return
	destination_beacon.position = tile_positions[final_visual]
	var label := destination_beacon.get_node_or_null("DestinationLabel") as Label3D
	if label != null:
		label.text = active_tile_names[final_visual].to_upper()
	var finish_tween := create_tween()
	finish_tween.set_trans(Tween.TRANS_BACK)
	finish_tween.set_ease(Tween.EASE_OUT)
	finish_tween.tween_property(
		destination_beacon,
		"scale",
		Vector3.ONE * 1.65,
		0.24
	)


func _clear_movement_preview() -> void:
	movement_markers.clear()
	destination_beacon = null
	if is_instance_valid(movement_preview_root):
		movement_preview_root.queue_free()
	movement_preview_root = null


func _play_landing_reaction(player_index: int) -> void:
	if player_index < 0 or player_index >= player_tokens.size():
		return
	var token := player_tokens[player_index]
	var landing_tween := create_tween()
	landing_tween.set_parallel(true)
	landing_tween.set_trans(Tween.TRANS_BACK)
	landing_tween.set_ease(Tween.EASE_OUT)
	landing_tween.tween_property(token, "scale", Vector3.ONE * 1.18, 0.16)
	landing_tween.tween_property(token, "position:y", 0.34, 0.16)
	landing_tween.chain().set_parallel(true)
	landing_tween.set_trans(Tween.TRANS_QUAD)
	landing_tween.set_ease(Tween.EASE_IN_OUT)
	landing_tween.tween_property(token, "scale", Vector3.ONE, 0.18)
	landing_tween.tween_property(token, "position:y", 0.0, 0.18)


func _begin_roll_camera_cinematic() -> void:
	if camera == null or dice_nodes.is_empty():
		return
	_cancel_camera_cinematic()
	saved_camera_target = camera_target
	saved_camera_azimuth = camera_azimuth
	saved_camera_elevation = camera_elevation
	saved_camera_distance = camera_distance
	cinematic_camera_active = true

	var dice_focus := Vector3.ZERO
	var visible_dice := 0
	for die in dice_nodes:
		if die.visible:
			dice_focus += die.global_position
			visible_dice += 1
	if visible_dice > 0:
		dice_focus /= float(visible_dice)
	dice_focus.y = 1.25
	camera_tween = create_tween()
	camera_tween.set_parallel(true)
	camera_tween.set_trans(Tween.TRANS_CUBIC)
	camera_tween.set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(self, "camera_target", dice_focus, 0.48)
	camera_tween.tween_property(self, "camera_distance", 27.0, 0.48)
	camera_tween.tween_property(
		self,
		"camera_elevation",
		deg_to_rad(52.0),
		0.48
	)


func _focus_camera_on_route(command: Dictionary) -> void:
	if not cinematic_camera_active:
		return
	var visual_path_value = command.get("visualPath", [])
	if typeof(visual_path_value) != TYPE_ARRAY:
		return
	var visual_path: Array = visual_path_value
	if visual_path.is_empty():
		return
	var destination_visual := posmod(
		int(visual_path[visual_path.size() - 1]),
		BOARD_SPOT_COUNT
	)
	var player_index := int(command.get("playerIndex", 0))
	var start_visual := player_tiles[clampi(
		player_index,
		0,
		maxi(0, player_tiles.size() - 1)
	)]
	var route_focus := tile_positions[start_visual].lerp(
		tile_positions[destination_visual],
		0.58
	)
	route_focus.y = 1.15
	if camera_tween != null and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween()
	camera_tween.set_parallel(true)
	camera_tween.set_trans(Tween.TRANS_CUBIC)
	camera_tween.set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(self, "camera_target", route_focus, 0.55)
	camera_tween.tween_property(self, "camera_distance", 28.5, 0.55)
	camera_tween.tween_property(
		self,
		"camera_elevation",
		deg_to_rad(55.0),
		0.55
	)


func _focus_camera_on_landing(visual_index: int) -> void:
	if not cinematic_camera_active or visual_index >= tile_positions.size():
		return
	var landing_position := tile_positions[visual_index]
	var landing_focus := landing_position
	landing_focus.y = 0.72
	var payload := _visual_tile_payload(visual_index)
	var is_developed := (
		int(payload.get("ownerColorArgb", 0)) != 0
		or int(payload.get("upgradeLevel", 0)) > 0
	)
	var outward_azimuth := atan2(landing_position.x, landing_position.z + 1.0)
	if camera_tween != null and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween()
	camera_tween.set_parallel(true)
	camera_tween.set_trans(Tween.TRANS_CUBIC)
	camera_tween.set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(self, "camera_target", landing_focus, 0.48)
	camera_tween.tween_property(self, "camera_azimuth", outward_azimuth, 0.48)
	camera_tween.tween_property(
		self,
		"camera_elevation",
		deg_to_rad(49.0),
		0.48
	)
	camera_tween.tween_property(
		self,
		"camera_distance",
		21.5 if is_developed else 24.0,
		0.48
	)


func _restore_camera_after_roll() -> void:
	if not cinematic_camera_active:
		return
	if camera_tween != null and camera_tween.is_running():
		camera_tween.kill()
	camera_tween = create_tween()
	camera_tween.set_parallel(true)
	camera_tween.set_trans(Tween.TRANS_CUBIC)
	camera_tween.set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(self, "camera_target", saved_camera_target, 0.72)
	camera_tween.tween_property(self, "camera_azimuth", saved_camera_azimuth, 0.72)
	camera_tween.tween_property(
		self,
		"camera_elevation",
		saved_camera_elevation,
		0.72
	)
	camera_tween.tween_property(
		self,
		"camera_distance",
		saved_camera_distance,
		0.72
	)
	camera_tween.finished.connect(
		_complete_camera_restore,
		CONNECT_ONE_SHOT
	)


func _complete_camera_restore() -> void:
	cinematic_camera_active = false
	_update_camera()


func _cancel_camera_cinematic() -> void:
	if camera_tween != null and camera_tween.is_running():
		camera_tween.kill()
	cinematic_camera_active = false


func _move_player_token_to_visual(player_index: int, target_value: int) -> void:
	var target_tile := posmod(target_value, BOARD_SPOT_COUNT)
	player_tiles[player_index] = target_tile
	var token := player_tokens[player_index]
	var target_local := tile_positions[target_tile] + _token_offset_for_tile(
		target_tile,
		player_index
	)
	var move_direction := Vector3(
		target_local.x - token.position.x,
		0.0,
		target_local.z - token.position.z
	)
	if move_direction.length_squared() > 0.001:
		token.rotation.y = atan2(-move_direction.x, -move_direction.z)
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(token, "position:x", target_local.x, 0.22)
	active_tween.tween_property(token, "position:z", target_local.z, 0.22)

	var hop_tween := create_tween()
	hop_tween.set_trans(Tween.TRANS_QUAD)
	hop_tween.set_ease(Tween.EASE_OUT)
	hop_tween.tween_property(token, "position:y", 0.68, 0.11)
	hop_tween.set_ease(Tween.EASE_IN)
	hop_tween.tween_property(token, "position:y", 0.0, 0.11)
	await active_tween.finished
	await hop_tween.finished


func _on_roll_pressed() -> void:
	if rpg_mode:
		_roll_rpg_dice()
	else:
		_roll_dice()


func _roll_rpg_dice() -> void:
	if not rpg_mode or mode_transitioning or rpg_roll_active:
		return
	rpg_roll_active = true
	roll_button.disabled = true
	var rolling_player := current_player_index
	var die_one := randi_range(1, 6)
	var die_two := randi_range(1, 6)
	var total := die_one + die_two
	turn_label.text = "%s ROLLS AT STREET LEVEL…" % PLAYER_NAMES[rolling_player]

	for preview_roll in 6:
		dice_value_label.text = "ROLLING\n%d + %d" % [
			randi_range(1, 6),
			randi_range(1, 6),
		]
		await get_tree().create_timer(0.08 + preview_roll * 0.012).timeout

	dice_value_label.text = "RPG DICE\n%d + %d" % [die_one, die_two]
	turn_label.text = "%s MOVES %d STREET STEPS…" % [
		PLAYER_NAMES[rolling_player],
		total,
	]

	for _step in total:
		var next_z := rpg_character.position.z + rpg_path_direction * 1.35
		if next_z < -22.0 or next_z > 22.0:
			rpg_path_direction *= -1.0
			next_z = rpg_character.position.z + rpg_path_direction * 1.35
		rpg_character.rotation.y = 0.0 if rpg_path_direction < 0.0 else PI

		var street_tween := create_tween()
		street_tween.set_parallel(true)
		street_tween.set_trans(Tween.TRANS_QUAD)
		street_tween.set_ease(Tween.EASE_IN_OUT)
		street_tween.tween_property(rpg_character, "position:z", next_z, 0.26)
		street_tween.tween_property(rpg_character, "position:x", 0.0, 0.26)

		var hop_tween := create_tween()
		hop_tween.set_trans(Tween.TRANS_QUAD)
		hop_tween.set_ease(Tween.EASE_OUT)
		hop_tween.tween_property(rpg_character, "position:y", 0.42, 0.13)
		hop_tween.set_ease(Tween.EASE_IN)
		hop_tween.tween_property(rpg_character, "position:y", 0.18, 0.13)

		_advance_hidden_board_token(rolling_player)
		await street_tween.finished
		await hop_tween.finished

	turn_label.text = "%s REACHED %s" % [
		PLAYER_NAMES[rolling_player],
		active_tile_names[player_tiles[rolling_player]],
	]
	await get_tree().create_timer(0.65).timeout

	var handoff_position := rpg_character.position
	current_player_index = (rolling_player + 1) % active_player_count
	_set_active_player(current_player_index)
	_set_rpg_character(current_player_index)
	rpg_character.position = Vector3(
		handoff_position.x,
		0.18,
		handoff_position.z + rpg_path_direction * 1.1
	)
	turn_label.text = "%s  •  YOUR STREET TURN" % PLAYER_NAMES[current_player_index]
	dice_value_label.text = "RPG DICE\nREADY"
	roll_button.text = "ROLL & MOVE %s" % PLAYER_NAMES[current_player_index]
	roll_button.disabled = false
	rpg_roll_active = false


func _advance_hidden_board_token(player_index: int) -> void:
	player_tiles[player_index] = (player_tiles[player_index] + 1) % BOARD_SPOT_COUNT
	var target_tile := player_tiles[player_index]
	var target_local := tile_positions[target_tile] + _token_offset_for_tile(
		target_tile,
		player_index
	)
	var token := player_tokens[player_index]
	var direction := Vector3(
		target_local.x - token.position.x,
		0.0,
		target_local.z - token.position.z
	)
	if direction.length_squared() > 0.001:
		token.rotation.y = atan2(-direction.x, -direction.z)
	token.position = Vector3(target_local.x, 0.0, target_local.z)


func _roll_dice() -> void:
	if active_tween != null and active_tween.is_running():
		return
	var rolling_player := current_player_index
	var die_one := randi_range(1, 6)
	var die_two := randi_range(1, 6)
	var total := die_one + die_two
	dice_value_label.text = "ROLLING…"
	turn_label.text = "%s IS ROLLING…" % PLAYER_NAMES[rolling_player]
	roll_button.disabled = true
	_animate_3d_dice(die_one, die_two)

	await get_tree().create_timer(1.04).timeout
	dice_value_label.text = "DICE\n%d + %d" % [die_one, die_two]
	await _move_player_token(rolling_player, total)
	turn_label.text = "%s  •  %s" % [
		PLAYER_NAMES[rolling_player],
		active_tile_names[player_tiles[rolling_player]],
	]
	await get_tree().create_timer(0.7).timeout
	current_player_index = (rolling_player + 1) % active_player_count
	_set_active_player(current_player_index)
	roll_button.disabled = false


func _move_player_token(player_index: int, spaces: int) -> void:
	var token := player_tokens[player_index]
	token.position.y = 0.0
	turn_label.text = "%s MOVES %d SPACES…" % [
		PLAYER_NAMES[player_index],
		spaces,
	]

	for _step in spaces:
		player_tiles[player_index] = (
			player_tiles[player_index] + 1
		) % BOARD_SPOT_COUNT
		var target_tile := player_tiles[player_index]
		var target_local := tile_positions[target_tile] + _token_offset_for_tile(
			target_tile,
			player_index
		)
		var move_direction := Vector3(
			target_local.x - token.position.x,
			0.0,
			target_local.z - token.position.z
		)
		if move_direction.length_squared() > 0.001:
			token.rotation.y = atan2(-move_direction.x, -move_direction.z)
		active_tween = create_tween()
		active_tween.set_trans(Tween.TRANS_QUAD)
		active_tween.set_ease(Tween.EASE_IN_OUT)
		active_tween.set_parallel(true)
		active_tween.tween_property(token, "position:x", target_local.x, 0.28)
		active_tween.tween_property(token, "position:z", target_local.z, 0.28)

		var hop_tween := create_tween()
		hop_tween.set_trans(Tween.TRANS_QUAD)
		hop_tween.set_ease(Tween.EASE_OUT)
		hop_tween.tween_property(token, "position:y", 0.68, 0.14)
		hop_tween.set_ease(Tween.EASE_IN)
		hop_tween.tween_property(token, "position:y", 0.0, 0.14)
		await active_tween.finished
		await hop_tween.finished


func _begin_hand_pickup(player_index: int) -> void:
	active_reach_player = player_index
	var player := table_players[player_index]
	var body := player.get_node("CharacterBody") as Node3D
	var static_arm := body.get_node("StaticRightArm") as MeshInstance3D
	var static_hand := body.get_node("StaticRightHand") as MeshInstance3D
	var reach_rig := player.get_node("ReachRig") as Node3D
	var hand := reach_rig.get_node("Hand") as Node3D
	var token := player_tokens[player_index]

	token.position.y = 0.0
	turn_label.text = "%s REACHES FOR THE PAWN…" % PLAYER_NAMES[player_index]

	static_arm.visible = false
	static_hand.visible = false
	reach_rig.visible = true
	hand.scale = Vector3.ONE
	hand.global_position = body.to_global(Vector3(0.72, 2.0, -0.18))
	var token_grip := token.global_position + Vector3(0.0, 2.0, 0.0)
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(body, "position", Vector3(0.0, 0.04, -0.34), 0.52)
	active_tween.tween_property(body, "rotation_degrees:x", -8.0, 0.52)
	active_tween.tween_property(hand, "global_position", token_grip, 0.52)
	await active_tween.finished

	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_OUT)
	active_tween.tween_property(hand, "scale", Vector3(0.78, 1.0, 0.78), 0.2)
	active_tween.tween_property(hand, "global_position:y", token_grip.y - 0.08, 0.2)
	await active_tween.finished

	# Lift the pawn once the fingers close around it.
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_OUT)
	active_tween.tween_property(token, "position:y", 0.8, 0.22)
	active_tween.tween_property(hand, "global_position:y", token_grip.y + 0.3, 0.22)
	await active_tween.finished
	await _save_named_preview("hand_pickup.png")


func _end_hand_move(player_index: int) -> void:
	var player := table_players[player_index]
	var body := player.get_node("CharacterBody") as Node3D
	var static_arm := body.get_node("StaticRightArm") as MeshInstance3D
	var static_hand := body.get_node("StaticRightHand") as MeshInstance3D
	var reach_rig := player.get_node("ReachRig") as Node3D
	var hand := reach_rig.get_node("Hand") as Node3D
	var token := player_tokens[player_index]

	turn_label.text = "%s PLACES THE PAWN…" % PLAYER_NAMES[player_index]
	var release_position := token.global_position + Vector3(0.0, 2.0, 0.0)
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(token, "position:y", 0.0, 0.24)
	active_tween.tween_property(hand, "global_position", release_position, 0.24)
	await active_tween.finished

	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(hand, "scale", Vector3.ONE, 0.16)
	active_tween.tween_property(
		hand,
		"global_position",
		body.to_global(Vector3(0.72, 2.0, -0.18)),
		0.48
	)
	await active_tween.finished

	reach_rig.visible = false
	static_arm.visible = true
	static_hand.visible = true
	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_QUAD)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(body, "position", Vector3.ZERO, 0.36)
	active_tween.tween_property(body, "rotation", Vector3.ZERO, 0.36)
	await active_tween.finished
	active_reach_player = -1


func _update_reach_arm(player_index: int) -> void:
	if player_index < 0 or player_index >= table_players.size():
		return
	var player := table_players[player_index]
	var body := player.get_node("CharacterBody") as Node3D
	var reach_rig := player.get_node("ReachRig") as Node3D
	if not reach_rig.visible:
		return
	var upper_arm := reach_rig.get_node("UpperArm") as MeshInstance3D
	var forearm := reach_rig.get_node("Forearm") as MeshInstance3D
	var hand := reach_rig.get_node("Hand") as Node3D
	var shoulder := body.to_global(Vector3(0.72, 2.0, -0.18))
	var reach_length := shoulder.distance_to(hand.global_position)
	var bend_direction := body.global_basis.x.normalized()
	var elbow := shoulder.lerp(hand.global_position, 0.46)
	elbow += bend_direction * minf(1.8, reach_length * 0.14)
	elbow += Vector3.UP * minf(1.25, reach_length * 0.1)
	_orient_capsule_between(upper_arm, shoulder, elbow, 0.58)
	_orient_capsule_between(forearm, elbow, hand.global_position, 0.46)


func _set_active_player(player_index: int) -> void:
	for index in player_tokens.size():
		var token_ring := player_tokens[index].get_node_or_null("ActiveRing") as MeshInstance3D
		if token_ring != null:
			token_ring.visible = index == player_index
		if index != player_index:
			player_tokens[index].position.y = 0.0

	for index in table_players.size():
		var table_ring := table_players[index].get_node_or_null("ActiveRing") as MeshInstance3D
		var active_label := table_players[index].get_node_or_null("ActiveLabel") as Label3D
		if table_ring != null:
			table_ring.visible = index == player_index
		if active_label != null:
			active_label.visible = index == player_index

	turn_label.text = "%s  •  YOUR TURN" % player_names[player_index]
	roll_button.text = "ROLL FOR %s" % player_names[player_index]


func _enter_rpg_mode() -> void:
	if rpg_mode or mode_transitioning:
		return
	if active_tween != null and active_tween.is_running():
		camera_distance = RPG_ENTER_DISTANCE + 1.8
		return

	mode_transitioning = true
	roll_button.disabled = true
	turn_label.text = "DIVING INTO VICTORY PARK…"
	var focus := player_tokens[current_player_index].global_position + Vector3.UP * 1.7
	camera.look_at(focus, Vector3.UP)

	transition_overlay.visible = true
	var dive_tween := create_tween()
	dive_tween.set_parallel(true)
	dive_tween.set_trans(Tween.TRANS_QUAD)
	dive_tween.set_ease(Tween.EASE_IN)
	dive_tween.tween_property(
		camera,
		"global_position",
		focus + Vector3(0.0, 3.2, 4.8),
		0.85
	)
	dive_tween.tween_property(camera, "fov", 64.0, 0.85)
	var fade_in := create_tween()
	fade_in.set_trans(Tween.TRANS_QUAD)
	fade_in.set_ease(Tween.EASE_IN)
	fade_in.tween_property(transition_overlay, "modulate:a", 1.0, 0.85)
	await dive_tween.finished
	await fade_in.finished

	_set_rpg_character(current_player_index)
	table_root.visible = false
	board_root.visible = false
	rpg_root.visible = true
	rpg_mode = true
	rpg_camera_yaw = 0.0
	rpg_camera_pitch = deg_to_rad(20.0)
	rpg_camera_distance = 8.5
	rpg_path_direction = -1.0
	camera.fov = 58.0
	_update_rpg_camera()

	action_panel.visible = true
	hint_label.text = "WASD / arrows to walk   •   Right-drag to look   •   Wheel down, E, or Esc to return"
	turn_label.text = "%s  •  VICTORY PARK STREET LEVEL" % PLAYER_NAMES[current_player_index]
	dice_value_label.text = "RPG DICE\nREADY"
	roll_button.text = "ROLL & MOVE %s" % PLAYER_NAMES[current_player_index]
	roll_button.disabled = false

	var fade_out := create_tween()
	fade_out.set_trans(Tween.TRANS_QUAD)
	fade_out.set_ease(Tween.EASE_OUT)
	fade_out.tween_property(transition_overlay, "modulate:a", 0.0, 0.7)
	await fade_out.finished
	transition_overlay.visible = false
	mode_transitioning = false
	await get_tree().create_timer(0.25).timeout
	_save_named_preview("rpg_street_view.png")


func _exit_rpg_mode() -> void:
	if not rpg_mode or mode_transitioning or rpg_roll_active:
		return
	mode_transitioning = true
	transition_overlay.visible = true

	var fade_in := create_tween()
	fade_in.set_trans(Tween.TRANS_QUAD)
	fade_in.set_ease(Tween.EASE_IN)
	fade_in.tween_property(transition_overlay, "modulate:a", 1.0, 0.55)
	await fade_in.finished

	rpg_mode = false
	rpg_root.visible = false
	table_root.visible = true
	board_root.visible = true
	camera.fov = 46.0
	camera_distance = 28.0
	_update_camera()
	action_panel.visible = true
	hint_label.text = "Right-drag to orbit   •   Wheel to zoom   •   Zoom closer or press E to enter"
	_set_active_player(current_player_index)
	roll_button.disabled = false

	var fade_out := create_tween()
	fade_out.set_trans(Tween.TRANS_QUAD)
	fade_out.set_ease(Tween.EASE_OUT)
	fade_out.tween_property(transition_overlay, "modulate:a", 0.0, 0.65)
	await fade_out.finished
	transition_overlay.visible = false
	mode_transitioning = false


func _update_rpg_character(delta: float) -> void:
	if rpg_character == null:
		return
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y += 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y -= 1.0

	if input_vector.length_squared() > 0.0:
		input_vector = input_vector.normalized()
		var forward := Vector3(-sin(rpg_camera_yaw), 0.0, -cos(rpg_camera_yaw))
		var right := Vector3(cos(rpg_camera_yaw), 0.0, -sin(rpg_camera_yaw))
		var direction := (right * input_vector.x + forward * input_vector.y).normalized()
		var next_position := rpg_character.position + direction * RPG_WALK_SPEED * delta
		next_position.x = clampf(next_position.x, -10.2, 10.2)
		next_position.z = clampf(next_position.z, -24.0, 24.0)
		next_position.y = 0.18 + absf(sin(Time.get_ticks_msec() * 0.012)) * 0.08
		rpg_character.position = next_position
		rpg_character.rotation.y = atan2(-direction.x, -direction.z)
	else:
		rpg_character.position.y = lerpf(rpg_character.position.y, 0.18, delta * 8.0)


func _update_rpg_camera() -> void:
	if camera == null or rpg_character == null:
		return
	var focus := rpg_character.global_position + Vector3.UP * 2.0
	var horizontal := cos(rpg_camera_pitch) * rpg_camera_distance
	camera.global_position = focus + Vector3(
		sin(rpg_camera_yaw) * horizontal,
		sin(rpg_camera_pitch) * rpg_camera_distance,
		cos(rpg_camera_yaw) * horizontal
	)
	camera.look_at(focus, Vector3.UP)


func _reset_rpg_view() -> void:
	if rpg_character == null:
		return
	rpg_character.position = Vector3(0.0, 0.18, 8.0)
	rpg_camera_yaw = 0.0
	rpg_camera_pitch = deg_to_rad(20.0)
	rpg_camera_distance = 8.5
	_update_rpg_camera()


func _reset_camera() -> void:
	_cancel_camera_cinematic()
	camera_target = Vector3(0.0, 1.4, -1.0)
	camera_azimuth = deg_to_rad(43.0)
	camera_elevation = deg_to_rad(58.0)
	camera_distance = 36.0
	_update_camera()


func _update_camera() -> void:
	if camera == null:
		return
	var horizontal := cos(camera_elevation) * camera_distance
	camera.position = camera_target + Vector3(
		sin(camera_azimuth) * horizontal,
		sin(camera_elevation) * camera_distance,
		cos(camera_azimuth) * horizontal
	)
	camera.look_at(camera_target, Vector3.UP)


func _sample_manhattan_route(spot_count: int) -> Array[Vector3]:
	var segment_lengths: Array[float] = []
	var total_length := 0.0
	for index in MANHATTAN_ROUTE_2D.size():
		var next_index := (index + 1) % MANHATTAN_ROUTE_2D.size()
		var segment_length: float = MANHATTAN_ROUTE_2D[index].distance_to(
			MANHATTAN_ROUTE_2D[next_index]
		)
		segment_lengths.append(segment_length)
		total_length += segment_length

	var result: Array[Vector3] = []
	for spot_index in spot_count:
		var target_distance := total_length * float(spot_index) / float(spot_count)
		var traversed := 0.0
		for segment_index in segment_lengths.size():
			var segment_length := segment_lengths[segment_index]
			if traversed + segment_length >= target_distance:
				var next_index := (segment_index + 1) % MANHATTAN_ROUTE_2D.size()
				var progress := (
					(target_distance - traversed) / maxf(segment_length, 0.001)
				)
				var point: Vector2 = MANHATTAN_ROUTE_2D[segment_index].lerp(
					MANHATTAN_ROUTE_2D[next_index],
					progress
				)
				result.append(Vector3(point.x, BOARD_TOP, point.y))
				break
			traversed += segment_length
	return result


func _tile_position(index: int) -> Vector3:
	return tile_positions[index]


func _tile_label_rotation(index: int) -> float:
	var previous := tile_positions[
		(index + BOARD_SPOT_COUNT - 1) % BOARD_SPOT_COUNT
	]
	var following := tile_positions[(index + 1) % BOARD_SPOT_COUNT]
	var tangent := following - previous
	return rad_to_deg(atan2(-tangent.z, tangent.x))


func _token_offset_for_tile(index: int, player_index: int = 0) -> Vector3:
	var previous := tile_positions[
		(index + BOARD_SPOT_COUNT - 1) % BOARD_SPOT_COUNT
	]
	var following := tile_positions[(index + 1) % BOARD_SPOT_COUNT]
	var tangent := (following - previous).normalized()
	var normal := Vector3(tangent.z, 0.0, -tangent.x)
	var slot := player_index % 4
	var lateral := -0.24 if slot % 2 == 0 else 0.24
	var longitudinal := -0.18 if slot < 2 else 0.18
	return normal * lateral + tangent * longitudinal


func _material(
	color: Color,
	metallic: float = 0.0,
	roughness: float = 0.5,
	emission_color: Color = Color.BLACK,
	emission_energy: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission_color
		material.emission_energy_multiplier = emission_energy
	return material


func _water_material(base_color: Color = HARBOR_BLUE) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 deep_color : source_color = vec4(0.025, 0.30, 0.34, 1.0);
uniform vec4 shallow_color : source_color = vec4(0.05, 0.48, 0.52, 1.0);

void vertex() {
	float wave_a = sin(VERTEX.x * 1.35 + TIME * 0.8);
	float wave_b = cos(VERTEX.z * 1.1 - TIME * 0.62);
	VERTEX.y += (wave_a + wave_b) * 0.018;
}

void fragment() {
	float ripple = sin(VERTEX.x * 2.1 + VERTEX.z * 1.7 + TIME * 0.75) * 0.5 + 0.5;
	ALBEDO = mix(deep_color.rgb, shallow_color.rgb, ripple * 0.22);
	METALLIC = 0.14;
	ROUGHNESS = 0.22;
	SPECULAR = 0.64;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("deep_color", base_color.darkened(0.38))
	material.set_shader_parameter("shallow_color", base_color.lightened(0.16))
	return material


func _add_triangular_prism(
	parent: Node,
	size: Vector3,
	position: Vector3,
	material: Material
) -> MeshInstance3D:
	var half_width := size.x * 0.5
	var half_height := size.y * 0.5
	var half_depth := size.z * 0.5
	var bottom := [
		Vector3(-half_width, -half_height, -half_depth),
		Vector3(half_width, -half_height, -half_depth),
		Vector3(0.0, -half_height, half_depth),
	]
	var top := [
		Vector3(-half_width, half_height, -half_depth),
		Vector3(half_width, half_height, -half_depth),
		Vector3(0.0, half_height, half_depth),
	]
	var triangles := [
		[bottom[0], bottom[1], bottom[2]],
		[top[0], top[2], top[1]],
		[bottom[0], top[0], top[1]],
		[bottom[0], top[1], bottom[1]],
		[bottom[1], top[1], top[2]],
		[bottom[1], top[2], bottom[2]],
		[bottom[2], top[2], top[0]],
		[bottom[2], top[0], bottom[0]],
	]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for triangle in triangles:
		for vertex in triangle:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var instance := MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.position = position
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _add_polygon_platform(
	parent: Node,
	points: Array[Vector2],
	top_y: float,
	height: float,
	material: Material
) -> MeshInstance3D:
	var center := Vector2.ZERO
	for point in points:
		center += point
	center /= float(points.size())
	var bottom_y := top_y - height
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)

	for index in points.size():
		var next_index := (index + 1) % points.size()
		surface.add_vertex(Vector3(center.x, top_y, center.y))
		surface.add_vertex(Vector3(points[next_index].x, top_y, points[next_index].y))
		surface.add_vertex(Vector3(points[index].x, top_y, points[index].y))

		surface.add_vertex(Vector3(points[index].x, top_y, points[index].y))
		surface.add_vertex(Vector3(points[index].x, bottom_y, points[index].y))
		surface.add_vertex(Vector3(points[next_index].x, bottom_y, points[next_index].y))
		surface.add_vertex(Vector3(points[index].x, top_y, points[index].y))
		surface.add_vertex(Vector3(points[next_index].x, bottom_y, points[next_index].y))
		surface.add_vertex(Vector3(points[next_index].x, top_y, points[next_index].y))

	surface.generate_normals()
	var instance := MeshInstance3D.new()
	instance.mesh = surface.commit()
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _add_box(
	parent: Node,
	size: Vector3,
	position: Vector3,
	material: Material
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _add_cylinder(
	parent: Node,
	top_radius: float,
	bottom_radius: float,
	height: float,
	position: Vector3,
	material: Material
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = 48
	mesh.rings = 2
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _add_capsule(
	parent: Node,
	radius: float,
	height: float,
	position: Vector3,
	material: Material,
	radial_segments: int = 32,
	rings: int = 12
) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = radial_segments
	mesh.rings = rings
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _orient_capsule_between(
	capsule: MeshInstance3D,
	start: Vector3,
	finish: Vector3,
	radius: float
) -> void:
	var direction := finish - start
	var length := direction.length()
	if length < 0.001:
		return
	var y_axis := direction / length
	var reference := Vector3.FORWARD
	if absf(y_axis.dot(reference)) > 0.94:
		reference = Vector3.RIGHT
	var x_axis := reference.cross(y_axis).normalized()
	var z_axis := x_axis.cross(y_axis).normalized()
	var mesh := capsule.mesh as CapsuleMesh
	mesh.radius = radius
	mesh.height = maxf(length, radius * 2.05)
	capsule.global_transform = Transform3D(
		Basis(x_axis, y_axis, z_axis),
		start.lerp(finish, 0.5)
	)


func _add_sphere(
	parent: Node,
	radius: float,
	position: Vector3,
	material: Material,
	radial_segments: int = 32,
	rings: int = 16
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = radial_segments
	mesh.rings = rings
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = position
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func _enable_model_shadows(node: Node) -> void:
	if node is GeometryInstance3D:
		(node as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for child in node.get_children():
		_enable_model_shadows(child)


func _ui_panel(
	color: Color,
	alpha: float,
	radius: int,
	border_color: Color = Color.TRANSPARENT,
	border_width: int = 0
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, alpha)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	if border_width > 0:
		style.border_width_left = border_width
		style.border_width_top = border_width
		style.border_width_right = border_width
		style.border_width_bottom = border_width
		style.border_color = border_color
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.32)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0.0, 4.0)
	return style


func _capture_initial_preview() -> void:
	await get_tree().create_timer(2.0).timeout
	_save_preview()


func _save_preview() -> void:
	await _save_named_preview("initial_build.png")


func _save_named_preview(file_name: String) -> void:
	DirAccess.make_dir_absolute(ProjectSettings.globalize_path("res://preview"))
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png("res://preview/%s" % file_name)
	if result == OK:
		print("Saved preview to res://preview/%s" % file_name)
	else:
		push_warning("Could not save preview image: %s" % result)
