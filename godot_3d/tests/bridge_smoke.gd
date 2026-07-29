extends SceneTree

const CityThemesCatalog = preload("res://scripts/city_themes.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = load("res://main.tscn").instantiate()
	root.add_child(scene)
	for _frame in 5:
		await process_frame

	var logical_names: Array[String] = []
	var logical_tiles: Array[Dictionary] = []
	for index in 40:
		var tile_type := "property"
		match index:
			0:
				tile_type = "start"
			2, 17, 33:
				tile_type = "communityChest"
			7, 22, 36:
				tile_type = "chance"
			10:
				tile_type = "jail"
			20:
				tile_type = "freeParking"
			30:
				tile_type = "goToJail"
		var tile_name := "TILE %02d" % index
		logical_names.append(tile_name)
		var tile_payload := {
			"logicalIndex": index,
			"visualPosition": roundi(float(index) * 52.0 / 40.0) % 52,
			"name": tile_name,
			"type": tile_type,
			"colorArgb": 0xffd65c5c,
			"price": 120 if tile_type == "property" else 0,
			"ownerColorArgb": 0,
			"upgradeLevel": 0,
			"isMortgaged": false,
			"groupId": "group_%d" % (index / 3),
			"hasCompleteColorGroup": false,
		}
		if index == 1:
			tile_payload["ownerColorArgb"] = 0xffff4f5e
			tile_payload["upgradeLevel"] = 3
			tile_payload["isMortgaged"] = true
			tile_payload["hasCompleteColorGroup"] = true
		logical_tiles.append(tile_payload)

	var state := {
		"currentPlayerIndex": 0,
		"die1": 0,
		"die2": 0,
		"tileNames": logical_names,
		"tiles": logical_tiles,
		"players": [
			{
				"id": "player-one",
				"name": "Player 1",
				"visualPosition": 0,
				"isActive": true,
			},
			{
				"id": "player-two",
				"name": "Player 2",
				"visualPosition": 0,
				"isActive": true,
			},
		],
	}
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify(state),
	})
	_test_pinch_zoom(scene)
	_test_host_camera_gesture(scene)
	_test_die_face_rotations(scene)
	_test_boat_lanes(scene)
	await _test_city_catalog(scene, state)
	_test_special_tile_metadata(scene)
	_test_property_development_metadata(scene)
	await _test_property_state_transition(scene, state)
	_test_board_object_picking(scene)

	var command := {
		"commandId": "bridge-smoke",
		"playerId": "player-one",
		"playerIndex": 0,
		"die1": 2,
		"die2": 3,
		"spaces": 5,
		"toLogicalPosition": 5,
		"visualPath": [1, 2, 3, 4, 5],
	}
	scene.host_receive_message({
		"action": "animate_roll",
		"json": JSON.stringify(command),
	})
	await process_frame
	if scene.movement_markers.size() != 5:
		push_error("3D roll did not create the five-step route preview.")
		quit(1)
		return
	if not scene.cinematic_camera_active:
		push_error("3D roll did not start the camera cinematic.")
		quit(1)
		return
	print("ROLL_PRESENTATION_OK")

	for _attempt in 160:
		await create_timer(0.05).timeout
		var message: Dictionary = scene.host_poll_message()
		if message.is_empty():
			continue
		if message.get("method", "") == "movementComplete":
			if not _dice_values_face_up(scene, [2, 3]):
				push_error("3D dice did not settle on the Flutter roll values.")
				quit(1)
				return
			print("BRIDGE_SMOKE_OK ", message)
			quit(0)
			return

	push_error("Timed out waiting for movementComplete.")
	quit(1)


func _test_special_tile_metadata(scene: Node) -> void:
	var expected_types := {
		0: "start",
		3: "communityChest",
		9: "chance",
		13: "jail",
		26: "freeParking",
		39: "goToJail",
		43: "communityChest",
		47: "chance",
	}
	for visual_position in expected_types:
		var payload: Dictionary = scene._visual_tile_payload(visual_position)
		if str(payload.get("type", "")) != expected_types[visual_position]:
			push_error(
				"Special tile type missing at visual position %d." % visual_position
			)
			quit(1)
			return
		var tile: Node3D = scene.board_root.get_node(
			"Tile%02d" % visual_position
		) as Node3D
		var icon := tile.get_node("TileIcon") as Label3D
		if icon.text.is_empty():
			push_error(
				"Special tile icon missing at visual position %d." % visual_position
			)
			quit(1)
			return
	print("SPECIAL_TILE_METADATA_OK")


func _test_property_development_metadata(scene: Node) -> void:
	var visual_position := roundi(52.0 / 40.0) % 52
	var tile: Node3D = scene.board_root.get_node(
		"Tile%02d" % visual_position
	) as Node3D
	var markers := tile.get_node_or_null("DevelopmentMarkers")
	if (
		markers == null
		or markers.get_node_or_null("OwnerFlag") == null
		or markers.get_node_or_null("House1") == null
		or markers.get_node_or_null("CompleteGroupTrim0") == null
		or markers.get_node_or_null("MortgageShutter") == null
	):
		push_error("3D property ownership and development markers are missing.")
		quit(1)
		return
	var label := tile.get_node("TileLabel") as Label3D
	if not label.text.contains("$120"):
		push_error("3D property price is missing from its location label.")
		quit(1)
		return
	print("PROPERTY_DEVELOPMENT_METADATA_OK")


func _test_property_state_transition(scene: Node, state: Dictionary) -> void:
	var tile_payload: Dictionary = state["tiles"][4]
	tile_payload["ownerColorArgb"] = 0xff29b6f6
	tile_payload["upgradeLevel"] = 1
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify(state),
	})
	for _frame in 3:
		await process_frame
	var visual_position := roundi(4.0 * 52.0 / 40.0) % 52
	var tile: Node3D = scene.board_root.get_node(
		"Tile%02d" % visual_position
	) as Node3D
	var markers := tile.get_node_or_null("DevelopmentMarkers")
	var status := (
		markers.get_node_or_null("PropertyChangeLabel") as Label3D
		if markers != null
		else null
	)
	if (
		markers == null
		or markers.get_node_or_null("OwnerFlag") == null
		or markers.get_node_or_null("House1") == null
		or status == null
		or status.text != "SOLD"
	):
		push_error("3D property state transition did not animate.")
		quit(1)
		return
	print("PROPERTY_STATE_TRANSITION_OK")


func _test_board_object_picking(scene: Node) -> void:
	var logical_index := 7
	var visual_index := roundi(float(logical_index) * 52.0 / 40.0) % 52
	var viewport_size: Vector2 = scene.get_viewport().get_visible_rect().size
	var world_position: Vector3 = scene.board_root.to_global(
		scene.tile_positions[visual_index] + Vector3.UP * 0.3
	)
	var screen_position: Vector2 = scene.camera.unproject_position(world_position)
	scene.host_receive_message({
		"action": "board_tap",
		"json": JSON.stringify({
			"normalizedX": screen_position.x / viewport_size.x,
			"normalizedY": screen_position.y / viewport_size.y,
		}),
	})
	var message: Dictionary = scene.host_poll_message()
	if message.get("method", "") != "boardObjectTapped":
		push_error("3D board tap did not emit a Flutter selection.")
		quit(1)
		return
	var arguments = JSON.parse_string(str(message.get("arguments", "{}")))
	if (
		typeof(arguments) != TYPE_DICTIONARY
		or str(arguments.get("kind", "")) != "tile"
		or int(arguments.get("logicalIndex", -1)) != logical_index
	):
		push_error("3D board tap did not preserve the logical tile index.")
		quit(1)
		return
	print("BOARD_OBJECT_PICKING_OK")


func _test_pinch_zoom(scene: Node) -> void:
	var initial_distance: float = scene.camera_distance
	var first_touch := InputEventScreenTouch.new()
	first_touch.index = 0
	first_touch.position = Vector2(100.0, 100.0)
	first_touch.pressed = true
	scene._unhandled_input(first_touch)

	var second_touch := InputEventScreenTouch.new()
	second_touch.index = 1
	second_touch.position = Vector2(200.0, 100.0)
	second_touch.pressed = true
	scene._unhandled_input(second_touch)

	var spread_fingers := InputEventScreenDrag.new()
	spread_fingers.index = 1
	spread_fingers.position = Vector2(300.0, 100.0)
	spread_fingers.relative = Vector2(100.0, 0.0)
	scene._unhandled_input(spread_fingers)

	if scene.camera_distance >= initial_distance:
		push_error(
			"Pinch-out should zoom in: %s -> %s"
			% [initial_distance, scene.camera_distance]
		)
		quit(1)
		return

	var zoomed_distance: float = scene.camera_distance
	var close_fingers := InputEventScreenDrag.new()
	close_fingers.index = 1
	close_fingers.position = Vector2(150.0, 100.0)
	close_fingers.relative = Vector2(-150.0, 0.0)
	scene._unhandled_input(close_fingers)

	if scene.camera_distance <= zoomed_distance:
		push_error(
			"Pinch-in should zoom out: %s -> %s"
			% [zoomed_distance, scene.camera_distance]
		)
		quit(1)
		return

	print(
		"PINCH_ZOOM_OK ",
		initial_distance,
		" -> ",
		zoomed_distance,
		" -> ",
		scene.camera_distance
	)


func _test_host_camera_gesture(scene: Node) -> void:
	var initial_azimuth: float = scene.camera_azimuth
	var initial_distance: float = scene.camera_distance
	scene.host_receive_message({
		"action": "camera_gesture",
		"json": JSON.stringify({
			"orbitDeltaX": 24.0,
			"orbitDeltaY": -12.0,
			"zoomScale": 1.1,
		}),
	})

	if is_equal_approx(scene.camera_azimuth, initial_azimuth):
		push_error("Flutter camera bridge did not rotate the board.")
		quit(1)
		return
	if scene.camera_distance >= initial_distance:
		push_error("Flutter camera bridge did not zoom in.")
		quit(1)
		return

	print(
		"HOST_CAMERA_GESTURE_OK ",
		initial_distance,
		" -> ",
		scene.camera_distance
	)


func _test_die_face_rotations(scene: Node) -> void:
	var face_normals := {
		1: Vector3.UP,
		2: Vector3.FORWARD,
		3: Vector3.RIGHT,
		4: Vector3.LEFT,
		5: Vector3.BACK,
		6: Vector3.DOWN,
	}
	for value in range(1, 7):
		var rotation: Vector3 = scene._die_face_rotation(value)
		var rotated_normal: Vector3 = Basis.from_euler(rotation) * face_normals[value]
		if rotated_normal.dot(Vector3.UP) < 0.99:
			push_error("Die face %d does not settle upward." % value)
			quit(1)
			return
	print("DICE_FACE_ROTATIONS_OK")


func _dice_values_face_up(scene: Node, values: Array) -> bool:
	var face_normals := {
		1: Vector3.UP,
		2: Vector3.FORWARD,
		3: Vector3.RIGHT,
		4: Vector3.LEFT,
		5: Vector3.BACK,
		6: Vector3.DOWN,
	}
	for index in values.size():
		var die := scene.dice_nodes[index] as Node3D
		var rotated_normal: Vector3 = die.basis * face_normals[int(values[index])]
		if rotated_normal.dot(Vector3.UP) < 0.98:
			return false
	return true


func _test_boat_lanes(scene: Node) -> void:
	for route in scene.boat_routes:
		if str(route.get("surface", "water")) != "water":
			push_error("A boat route is not marked as a water surface.")
			quit(1)
			return
		var path := route.get("path") as Array
		for segment_index in path.size() - 1:
			var start := path[segment_index] as Vector3
			var finish := path[segment_index + 1] as Vector3
			for sample_index in 21:
				var point := start.lerp(finish, float(sample_index) / 20.0)
				for tile_position in scene.tile_positions:
					var flat_distance := Vector2(point.x, point.z).distance_to(
						Vector2(tile_position.x, tile_position.z)
					)
					if flat_distance < 1.25:
						push_error("Boat lane intersects the property route.")
						quit(1)
						return
				if (
					point.x > 6.8
					and point.x < 11.3
					and point.z > 3.5
					and point.z < 6.1
				):
					push_error("Boat lane intersects the dice platform.")
					quit(1)
					return
	print("BOAT_LANES_OK")


func _test_city_catalog(scene: Node, base_state: Dictionary) -> void:
	var logical_names: Array[String] = []
	for index in 40:
		logical_names.append("TILE %02d" % index)

	for board_id in CityThemesCatalog.all_board_ids():
		var state := base_state.duplicate(true)
		state["boardId"] = board_id
		state["tileNames"] = logical_names
		scene.host_receive_message({
			"action": "sync_state",
			"json": JSON.stringify(state),
		})
		await process_frame

		if scene.current_board_id != board_id:
			push_error("3D board did not switch to %s." % board_id)
			quit(1)
			return
		if scene.tile_positions.size() != 52:
			push_error("%s did not build 52 visual locations." % board_id)
			quit(1)
			return
		if scene.player_tokens.size() != 2 or scene.dice_nodes.size() != 2:
			push_error("%s did not rebuild its game pieces and dice." % board_id)
			quit(1)
			return
		if scene.active_tile_names[0] != "TILE 00":
			push_error("%s did not apply Flutter tile names." % board_id)
			quit(1)
			return

		var expected_landmarks := (
			scene.city_theme.get("landmarks", []) as Array
		).size()
		if expected_landmarks < 5:
			push_error("%s needs at least five signature landmarks." % board_id)
			quit(1)
			return
		if board_id != "usa_new_york":
			var landmark_root: Node = scene.board_root.get_node_or_null("CityLandmarks")
			if landmark_root == null:
				push_error("%s did not create its landmark district." % board_id)
				quit(1)
				return
			var landmark_count := 0
			for child in landmark_root.get_children():
				if str(child.name).ends_with("Landmark"):
					landmark_count += 1
			if landmark_count != expected_landmarks:
				push_error(
					"%s built %d/%d signature landmarks."
					% [board_id, landmark_count, expected_landmarks]
				)
				quit(1)
				return

		_test_active_boat_lanes(scene, board_id)

	var restore_state := base_state.duplicate(true)
	restore_state["boardId"] = "usa_new_york"
	restore_state["tileNames"] = logical_names
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify(restore_state),
	})
	await process_frame
	print("CITY_CATALOG_OK ", CityThemesCatalog.all_board_ids().size(), " boards")


func _test_active_boat_lanes(scene: Node, board_id: String) -> void:
	for route in scene.boat_routes:
		if str(route.get("surface", "water")) != "water":
			push_error("%s has a boat outside a water lane." % board_id)
			quit(1)
			return
		var path := route.get("path") as Array
		for segment_index in path.size() - 1:
			var start := path[segment_index] as Vector3
			var finish := path[segment_index + 1] as Vector3
			for sample_index in 21:
				var point := start.lerp(finish, float(sample_index) / 20.0)
				for tile_position in scene.tile_positions:
					var route_distance := Vector2(point.x, point.z).distance_to(
						Vector2(tile_position.x, tile_position.z)
					)
					if route_distance < 1.25:
						push_error("%s has a boat crossing the property road." % board_id)
						quit(1)
						return
				var dice_center: Vector3 = scene._dice_platform_center()
				if (
					absf(point.x - dice_center.x) < 2.2
					and absf(point.z - dice_center.z) < 1.5
				):
					push_error("%s has a boat crossing the dice platform." % board_id)
					quit(1)
					return
