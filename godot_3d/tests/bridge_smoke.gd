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
		"sessionId": "bridge-smoke-session",
		"stateGeneration": 1,
		"boardId": "usa",
		"currentPlayerIndex": 0,
		"die1": 0,
		"die2": 0,
		"tileNames": logical_names,
		"tiles": logical_tiles,
		"players": [
			{
				"id": "player-one",
				"name": "Player 1",
				"colorArgb": 0xff5b8def,
				"visualPosition": 0,
				"isActive": true,
			},
			{
				"id": "player-two",
				"name": "Player 2",
				"colorArgb": 0xffef765b,
				"visualPosition": 0,
				"isActive": true,
			},
		],
	}
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify(state),
	})
	_test_state_applied_handshake(scene, state)
	_test_mobile_render_budget(scene)
	_test_unrolled_dice_state(scene)
	_test_token_grounding_and_occupancy(scene)
	_test_distance_scaled_token_motion(scene)
	await _test_roll_cancellation_on_state_sync(scene, state)
	_test_native_one_finger_pan(scene)
	_test_pinch_zoom(scene)
	_test_host_camera_gesture(scene)
	_test_host_camera_pan(scene)
	_test_mobile_camera_framing(scene)
	_test_die_face_rotations(scene)
	_test_boat_lanes(scene)
	_test_embedded_cloud_policy(scene)
	await _test_city_catalog(scene, state)
	# The development/picking fixtures below assert New York-specific model
	# families. Restore that city after exercising the complete catalog.
	state["boardId"] = "usa_new_york"
	_test_special_tile_metadata(scene)
	_test_property_development_metadata(scene)
	await _test_nyc_development_families(scene, state)
	await _test_unchanged_property_visuals_are_reused(scene, state)
	await _test_property_state_transition(scene, state)
	_test_board_object_picking(scene)

	var roll_camera_snapshot := _camera_snapshot(scene)
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
	if not _camera_matches_snapshot(scene, roll_camera_snapshot):
		push_error("Starting a dice roll moved the player-controlled camera.")
		quit(1)
		return
	var expected_marker_position: Vector3 = (
		scene._token_anchor_for_tile(1, 0) + Vector3.UP * 0.17
	)
	if not scene.movement_markers[0].position.is_equal_approx(
		expected_marker_position
	):
		push_error("3D route marker is not aligned with the pawn's route anchor.")
		quit(1)
		return
	print("ROLL_PRESENTATION_OK")

	for _attempt in 160:
		await create_timer(0.05).timeout
		var message: Dictionary = scene.host_poll_message()
		if message.is_empty():
			continue
		if message.get("method", "") == "movementComplete":
			var token_visual := scene._token_visual(scene.player_tokens[0]) as Node3D
			if (
				scene.active_tween != null
				or token_visual == null
				or not is_zero_approx(token_visual.position.y)
			):
				push_error("movementComplete was emitted before the pawn landed.")
				quit(1)
				return
			if not _dice_values_face_up(scene, [2, 3]):
				push_error("3D dice did not settle on the Flutter roll values.")
				quit(1)
				return
			if not _camera_matches_snapshot(scene, roll_camera_snapshot):
				push_error("A completed roll did not preserve the chosen camera view.")
				quit(1)
				return
			print("BRIDGE_SMOKE_OK ", message)
			quit(0)
			return

	push_error("Timed out waiting for movementComplete.")
	quit(1)


func _test_state_applied_handshake(scene: Node, state: Dictionary) -> void:
	var message: Dictionary = scene.host_poll_message()
	var arguments_value = JSON.parse_string(str(message.get("arguments", "{}")))
	var arguments: Dictionary = (
		arguments_value as Dictionary
		if typeof(arguments_value) == TYPE_DICTIONARY
		else {}
	)
	if (
		str(message.get("method", "")) != "stateApplied"
		or str(arguments.get("sessionId", "")) != str(state["sessionId"])
		or int(arguments.get("stateGeneration", -1))
		!= int(state["stateGeneration"])
		or str(arguments.get("boardId", "")) != str(state["boardId"])
	):
		push_error("Godot acknowledged readiness before applying the requested state token.")
		quit(1)
		return
	print("STATE_APPLIED_HANDSHAKE_OK ", arguments)


func _camera_snapshot(scene: Node) -> Dictionary:
	return {
		"target": scene.camera_target,
		"azimuth": scene.camera_azimuth,
		"elevation": scene.camera_elevation,
		"distance": scene.camera_distance,
	}


func _camera_matches_snapshot(scene: Node, snapshot: Dictionary) -> bool:
	var expected_target: Vector3 = snapshot["target"]
	return (
		scene.camera_target.is_equal_approx(expected_target)
		and is_equal_approx(scene.camera_azimuth, float(snapshot["azimuth"]))
		and is_equal_approx(scene.camera_elevation, float(snapshot["elevation"]))
		and is_equal_approx(scene.camera_distance, float(snapshot["distance"]))
	)


func _test_mobile_render_budget(scene: Node) -> void:
	var msaa_3d := int(ProjectSettings.get_setting(
		"rendering/anti_aliasing/quality/msaa_3d",
		-1
	))
	var directional_shadow_size := int(ProjectSettings.get_setting(
		"rendering/lights_and_shadows/directional_shadow/size",
		-1
	))
	var positional_shadow_size := int(ProjectSettings.get_setting(
		"rendering/lights_and_shadows/positional_shadow/atlas_size",
		-1
	))
	var key_light := scene.get_node_or_null("KeyLight") as DirectionalLight3D
	var fill_light := scene.get_node_or_null("WarmFill") as OmniLight3D
	var probe_root := Node3D.new()
	scene.add_child(probe_root)
	var probe_material := StandardMaterial3D.new()
	var first_pip: MeshInstance3D = scene._add_sphere(
		probe_root,
		0.072,
		Vector3.ZERO,
		probe_material,
		10,
		6
	)
	var second_pip: MeshInstance3D = scene._add_sphere(
		probe_root,
		0.072,
		Vector3.RIGHT,
		probe_material,
		10,
		6
	)
	var first_box: MeshInstance3D = scene._add_box(
		probe_root,
		Vector3.ONE,
		Vector3.ZERO,
		probe_material
	)
	var second_box: MeshInstance3D = scene._add_box(
		probe_root,
		Vector3.ONE,
		Vector3.RIGHT,
		probe_material
	)
	if (
		msaa_3d != Viewport.MSAA_2X
		or directional_shadow_size > 2048
		or positional_shadow_size > 1024
		or key_light == null
		or not key_light.shadow_enabled
		or fill_light == null
		or fill_light.shadow_enabled
		or scene.MOBILE_CYLINDER_RADIAL_SEGMENTS > 24
		or first_pip.mesh != second_pip.mesh
		or first_box.mesh != second_box.mesh
		or first_pip.cast_shadow
		!= GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	):
		push_error("The embedded board exceeded its mobile GPU render budget.")
		quit(1)
		return
	probe_root.queue_free()
	print(
		"MOBILE_RENDER_BUDGET_OK msaa=",
		msaa_3d,
		" directional_shadow=",
		directional_shadow_size,
		" positional_shadow=",
		positional_shadow_size
	)


func _test_unrolled_dice_state(scene: Node) -> void:
	if (
		scene.dice_value_label.text != "DICE\n—"
		or scene.dice_nodes.size() < 2
		or scene.dice_nodes[1].visible
	):
		push_error("A new game presents an unset die as a settled roll value.")
		quit(1)
		return
	print("UNROLLED_DICE_STATE_OK")


func _test_token_grounding_and_occupancy(scene: Node) -> void:
	var tile_anchor: Vector3 = scene._tile_ground_anchor(0)
	var first_token := scene.player_tokens[0] as Node3D
	var second_token := scene.player_tokens[1] as Node3D
	if (
		not is_equal_approx(first_token.position.y, tile_anchor.y)
		or not is_equal_approx(second_token.position.y, tile_anchor.y)
	):
		push_error("Pawn roots are not anchored to the tile surface.")
		quit(1)
		return
	var first_visual := scene._token_visual(first_token) as Node3D
	if first_visual == null:
		push_error("Pawn visual hierarchy does not preserve a ground contact origin.")
		quit(1)
		return
	var first_idle := first_visual.get_node_or_null("TokenIdle") as Node3D
	var first_model := (
		first_idle.get_node_or_null("TokenModel") as Node3D
		if first_idle != null
		else null
	)
	if first_model == null or not is_equal_approx(first_model.position.y, -1.1):
		push_error("Pawn visual hierarchy does not preserve a ground contact origin.")
		quit(1)
		return
	var midpoint := first_token.position.lerp(second_token.position, 0.5)
	if not midpoint.is_equal_approx(tile_anchor):
		push_error("Shared-tile pawn slots are not centered around the road anchor.")
		quit(1)
		return
	var effective_base_diameter := 1.1 * first_visual.scale.x
	if first_token.position.distance_to(second_token.position) < effective_base_diameter:
		push_error("Shared-tile pawn slots overlap after occupancy scaling.")
		quit(1)
		return
	for occupant_count in range(1, 5):
		var offsets: Array[Vector3] = []
		var centroid := Vector3.ZERO
		for slot_index in occupant_count:
			var offset: Vector3 = scene._token_offset_for_occupancy(
				0,
				slot_index,
				occupant_count
			)
			offsets.append(offset)
			centroid += offset
		centroid /= float(occupant_count)
		if not centroid.is_zero_approx():
			push_error("Occupancy slot pattern is not centered for %d pawns." % occupant_count)
			quit(1)
			return
		var scaled_diameter: float = (
			1.1 * scene._token_scale_for_occupancy(occupant_count).x
		)
		for first_index in offsets.size():
			for second_index in range(first_index + 1, offsets.size()):
				if offsets[first_index].distance_to(offsets[second_index]) < scaled_diameter:
					push_error(
						"Occupancy slot pattern overlaps for %d pawns." % occupant_count
					)
					quit(1)
					return
	var material_value = first_token.get_meta("player_color_material", null)
	if not material_value is StandardMaterial3D:
		push_error("Flutter player color was not applied to the 3D pawn.")
		quit(1)
		return
	var player_material := material_value as StandardMaterial3D
	if not player_material.albedo_color.is_equal_approx(Color("#5b8def")):
		push_error("Flutter player color was not applied to the 3D pawn.")
		quit(1)
		return
	print("TOKEN_GROUNDING_OCCUPANCY_COLOR_OK")


func _test_distance_scaled_token_motion(scene: Node) -> void:
	var base_duration: float = scene.TOKEN_STEP_DURATION
	var adjacent_duration: float = scene._token_step_duration(0, 1, base_duration)
	var skipped_duration: float = scene._token_step_duration(0, 2, base_duration)
	var adjacent_distance: float = scene.tile_positions[0].distance_to(
		scene.tile_positions[1]
	)
	var skipped_distance: float = scene.tile_positions[0].distance_to(
		scene.tile_positions[2]
	)
	var adjacent_speed := adjacent_distance / adjacent_duration
	var skipped_speed := skipped_distance / skipped_duration
	if skipped_duration <= adjacent_duration:
		push_error("A longer visual segment must not animate faster than one step.")
		quit(1)
		return
	if absf(adjacent_speed - skipped_speed) > adjacent_speed * 0.02:
		push_error("Pawn movement speed changes across different route distances.")
		quit(1)
		return
	print(
		"DISTANCE_SCALED_TOKEN_MOTION_OK ",
		adjacent_duration,
		" -> ",
		skipped_duration
	)


func _test_roll_cancellation_on_state_sync(
	scene: Node,
	state: Dictionary
) -> void:
	var expired_command := {
		"commandId": "1_player-one",
		"playerId": "player-one",
		"playerIndex": 0,
		"die1": 1,
		"die2": 1,
		"spaces": 2,
		"toLogicalPosition": 2,
		"visualPath": [1, 2],
	}
	scene.host_receive_message({
		"action": "animate_roll",
		"json": JSON.stringify(expired_command),
	})
	if not scene.active_roll_command_id.is_empty():
		push_error("Expired hosted roll was allowed to enter the movement queue.")
		quit(1)
		return
	var wrong_session_command := expired_command.duplicate(true)
	wrong_session_command["commandId"] = "wrong-session"
	wrong_session_command["sessionId"] = "retired-session"
	scene.host_receive_message({
		"action": "animate_roll",
		"json": JSON.stringify(wrong_session_command),
	})
	if not scene.active_roll_command_id.is_empty():
		push_error("A roll from a retired session entered the movement queue.")
		quit(1)
		return
	var cancelled_command := {
		"commandId": "cancel-on-sync",
		"playerId": "player-one",
		"playerIndex": 0,
		"die1": 1,
		"die2": 1,
		"spaces": 2,
		"toLogicalPosition": 2,
		"visualPath": [1, 2],
	}
	scene.host_receive_message({
		"action": "animate_roll",
		"json": JSON.stringify(cancelled_command),
	})
	if scene.active_roll_command_id != "cancel-on-sync":
		push_error("Hosted roll did not enter its scoped presentation state.")
		quit(1)
		return
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify(state),
	})
	await create_timer(1.15).timeout
	if (
		not scene.active_roll_command_id.is_empty()
		or scene.player_tiles[0] != 0
		or not scene.movement_markers.is_empty()
		or not scene.dice_tweens.is_empty()
	):
		push_error("State sync did not cancel the stale hosted roll presentation.")
		quit(1)
		return
	# Simulate a delayed native retry after the new authoritative generation.
	scene.host_receive_message({
		"action": "animate_roll",
		"json": JSON.stringify(cancelled_command),
	})
	if not scene.active_roll_command_id.is_empty():
		push_error("A cancelled roll retry escaped its original state generation.")
		quit(1)
		return
	var mid_move_command := cancelled_command.duplicate(true)
	mid_move_command["commandId"] = "cancel-mid-hop"
	scene.host_receive_message({
		"action": "animate_roll",
		"json": JSON.stringify(mid_move_command),
	})
	await create_timer(1.12).timeout
	if scene.active_tween == null or not scene.active_tween.is_running():
		push_error("Hosted roll did not enter its authoritative movement tween.")
		quit(1)
		return
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify(state),
	})
	await create_timer(0.35).timeout
	if (
		not scene.active_roll_command_id.is_empty()
		or scene.active_tween != null
		or scene.player_tiles[0] != 0
	):
		push_error("State sync did not cancel an in-flight pawn hop cleanly.")
		quit(1)
		return
	while true:
		var message: Dictionary = scene.host_poll_message()
		if message.is_empty():
			break
		if (
			message.get("method", "") == "movementComplete"
			and (
				str(message.get("arguments", "")).contains("cancel-on-sync")
				or str(message.get("arguments", "")).contains("cancel-mid-hop")
			)
		):
			push_error("Cancelled roll emitted a stale movementComplete event.")
			quit(1)
			return
	print("HOSTED_ROLL_CANCELLATION_OK")


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

	var spin_tile := scene.board_root.get_node("Tile26") as Node3D
	var spin_label := spin_tile.get_node("TileLabel") as Label3D
	var spin_icon := spin_tile.get_node("TileIcon") as Label3D
	scene.active_tile_names[26] = "LUCKY SPIN"
	spin_label.text = scene._tile_label_text(26)
	scene._refresh_tile_style(spin_tile, 26)
	if spin_icon.visible or not is_equal_approx(spin_label.position.z, 0.02):
		push_error("Special cards repeat words already present in their labels.")
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
		or markers.get_node_or_null("NYCChinatownDevelopment") == null
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


func _test_nyc_development_families(
	scene: Node,
	state: Dictionary
) -> void:
	var expected_families := {
		1: "Chinatown",
		3: "Brownstone",
		6: "Loft",
		13: "Neon",
		14: "Luxury",
		16: "Arts",
		18: "Finance",
		19: "Bridge",
		21: "Park",
		27: "Waterfront",
		32: "Flatiron",
		34: "Modern",
		37: "ArtDeco",
		39: "Liberty",
	}
	for logical_index in expected_families:
		var payload: Dictionary = state["tiles"][logical_index]
		payload["type"] = "property"
		payload["ownerColorArgb"] = 0xff29b6f6
		payload["upgradeLevel"] = 5 if logical_index % 2 == 1 else 3
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify(state),
	})
	for _frame in 3:
		await process_frame
	for logical_index in expected_families:
		var visual_position := (
			roundi(float(logical_index) * 52.0 / 40.0) % 52
		)
		var tile: Node3D = scene.board_root.get_node(
			"Tile%02d" % visual_position
		) as Node3D
		var markers := tile.get_node_or_null("DevelopmentMarkers")
		var model_name := "NYC%sDevelopment" % expected_families[logical_index]
		if (
			markers == null
			or markers.get_node_or_null(model_name) == null
		):
			push_error(
				"NYC development family %s is missing at logical tile %d."
				% [model_name, logical_index]
			)
			quit(1)
			return
	print("NYC_DEVELOPMENT_FAMILIES_OK ", expected_families.size())


func _test_unchanged_property_visuals_are_reused(
	scene: Node,
	state: Dictionary
) -> void:
	var visual_position := roundi(52.0 / 40.0) % 52
	var tile: Node3D = scene.board_root.get_node(
		"Tile%02d" % visual_position
	) as Node3D
	var before := tile.get_node_or_null("DevelopmentMarkers")
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify(state),
	})
	for _frame in 2:
		await process_frame
	var after := tile.get_node_or_null("DevelopmentMarkers")
	if before == null or after != before:
		push_error("Unchanged 3D property visuals were unnecessarily rebuilt.")
		quit(1)
		return
	print("PROPERTY_VISUAL_REUSE_OK")


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
		or markers.get_node_or_null("NYCBrownstoneDevelopment") == null
		or status == null
		or status.text != "SOLD"
		or status.visible
	):
		push_error("Embedded property transition is missing or has a floating label.")
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
	var message: Dictionary = {}
	for _attempt in 64:
		var candidate: Dictionary = scene.host_poll_message()
		if candidate.is_empty():
			break
		if candidate.get("method", "") == "boardObjectTapped":
			message = candidate
			break
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
	var initial_azimuth: float = scene.camera_azimuth
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
	if is_equal_approx(scene.camera_azimuth, initial_azimuth):
		push_error("Two-finger drag should rotate while pinch zoom remains active.")
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
		"TWO_FINGER_ORBIT_AND_PINCH_OK ",
		initial_distance,
		" -> ",
		zoomed_distance,
		" -> ",
		scene.camera_distance
	)
	var release_first := InputEventScreenTouch.new()
	release_first.index = 0
	release_first.position = Vector2(100.0, 100.0)
	release_first.pressed = false
	scene._unhandled_input(release_first)
	var release_second := InputEventScreenTouch.new()
	release_second.index = 1
	release_second.position = Vector2(150.0, 100.0)
	release_second.pressed = false
	scene._unhandled_input(release_second)
	scene._reset_camera()


func _test_native_one_finger_pan(scene: Node) -> void:
	var initial_target: Vector3 = scene.camera_target
	var touch := InputEventScreenTouch.new()
	touch.index = 0
	touch.position = Vector2(100.0, 100.0)
	touch.pressed = true
	scene._unhandled_input(touch)

	var drag := InputEventScreenDrag.new()
	drag.index = 0
	drag.position = Vector2(180.0, 55.0)
	drag.relative = Vector2(80.0, -45.0)
	scene._unhandled_input(drag)
	if scene.camera_target.is_equal_approx(initial_target):
		push_error("One-finger drag should move the camera across the board.")
		quit(1)
		return

	touch.position = drag.position
	touch.pressed = false
	scene._unhandled_input(touch)
	print("ONE_FINGER_CAMERA_PAN_OK ", initial_target, " -> ", scene.camera_target)
	scene._reset_camera()


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


func _test_host_camera_pan(scene: Node) -> void:
	var initial_target: Vector3 = scene.camera_target
	scene.host_receive_message({
		"action": "camera_gesture",
		"json": JSON.stringify({
			"panDeltaX": 80.0,
			"panDeltaY": -45.0,
			"zoomScale": 1.0,
		}),
	})
	if scene.camera_target.is_equal_approx(initial_target):
		push_error("Flutter camera bridge did not pan across the board.")
		quit(1)
		return

	scene.host_receive_message({
		"action": "camera_gesture",
		"json": JSON.stringify({
			"panDeltaX": 100000.0,
			"panDeltaY": 100000.0,
			"zoomScale": 1.0,
		}),
	})
	if (
		scene.camera_target.x < -11.01
		or scene.camera_target.x > 11.01
		or scene.camera_target.z < -20.01
		or scene.camera_target.z > 18.01
	):
		push_error("Camera panning escaped the board target bounds.")
		quit(1)
		return
	print("HOST_CAMERA_PAN_OK ", initial_target, " -> ", scene.camera_target)
	scene._reset_camera()


func _test_mobile_camera_framing(scene: Node) -> void:
	if ProjectSettings.get_setting("display/window/stretch/aspect") != "expand":
		push_error("The embedded board viewport must expand to fill portrait screens.")
		quit(1)
		return
	if scene.camera.keep_aspect != Camera3D.KEEP_WIDTH:
		push_error("The board camera must preserve its horizontal framing on phones.")
		quit(1)
		return
	scene.camera_uses_portrait_framing = true
	scene.camera_uses_tablet_landscape_framing = false
	if not is_equal_approx(scene._default_camera_distance(), 28.0):
		push_error("Portrait screens should start closer to the board.")
		quit(1)
		return
	if not is_equal_approx(scene._minimum_camera_distance(), 5.0):
		push_error("Portrait screens should allow a close label-reading zoom.")
		quit(1)
		return

	scene.host_receive_message({
		"action": "camera_gesture",
		"json": JSON.stringify({
			"orbitDeltaX": 0.0,
			"orbitDeltaY": 0.0,
			"zoomScale": 100.0,
		}),
	})
	if scene.camera_distance > 5.01:
		push_error(
			"The phone detail zoom limit is too far from the board: %s"
			% scene.camera_distance
		)
		quit(1)
		return
	print("MOBILE_CAMERA_FRAMING_OK close zoom ", scene.camera_distance)
	scene.camera_uses_portrait_framing = false
	scene.camera_uses_tablet_landscape_framing = true
	if not is_equal_approx(scene._default_camera_distance(), 31.5):
		push_error("Tablet landscape should use the closer release framing.")
		quit(1)
		return
	scene.camera_uses_tablet_landscape_framing = false
	if not is_equal_approx(scene._default_camera_distance(), 36.0):
		push_error("Wide landscape should retain the full-board framing.")
		quit(1)
		return
	scene._reset_camera()


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


func _test_embedded_cloud_policy(scene: Node) -> void:
	scene._enable_embedded_mode()
	if scene.cloud_nodes.is_empty():
		push_error("The ambient cloud visibility check has no scene fixtures.")
		quit(1)
		return
	for cloud in scene.cloud_nodes:
		if is_instance_valid(cloud) and cloud.visible:
			push_error("An embedded mobile cloud can still occlude the board.")
			quit(1)
			return
	print("EMBEDDED_CLOUD_OCCLUSION_POLICY_OK")


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
		if scene.player_tokens.size() < 2 or scene.dice_nodes.size() != 2:
			push_error(
				"%s did not rebuild its game pieces and dice (players=%d, dice=%d)."
				% [board_id, scene.player_tokens.size(), scene.dice_nodes.size()]
			)
			quit(1)
			return
		for token_index in range(2, scene.player_tokens.size()):
			if scene.player_tokens[token_index].visible:
				push_error("%s left a surplus bootstrap pawn visible." % board_id)
				quit(1)
				return
		for cloud in scene.cloud_nodes:
			if is_instance_valid(cloud) and cloud.visible:
				push_error("%s rebuilt an occluding mobile cloud layer." % board_id)
				quit(1)
				return
		if scene.active_tile_names[0] != "TILE 00":
			push_error("%s did not apply Flutter tile names." % board_id)
			quit(1)
			return
		_test_tile_card_spacing(scene, board_id)
		var property_visual := roundi(52.0 / 40.0) % 52
		var property_tile: Node3D = scene.board_root.get_node(
			"Tile%02d" % property_visual
		) as Node3D
		var property_markers := property_tile.get_node_or_null(
			"DevelopmentMarkers"
		)
		var expected_model := (
			"NYCChinatownDevelopment"
			if board_id == "usa_new_york"
			else "House1"
		)
		if (
			property_markers == null
			or property_markers.get_node_or_null(expected_model) == null
		):
			push_error(
				"%s did not build its expected %s property model."
				% [board_id, expected_model]
			)
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
	print("TILE_CARD_SPACING_OK")


func _test_tile_card_spacing(scene: Node, board_id: String) -> void:
	for index in 52:
		var next_index := (index + 1) % 52
		var tile: Node3D = scene.board_root.get_node("Tile%02d" % index) as Node3D
		var next_tile: Node3D = scene.board_root.get_node(
			"Tile%02d" % next_index
		) as Node3D
		var base := tile.get_node("TileBase") as MeshInstance3D
		var next_base := next_tile.get_node("TileBase") as MeshInstance3D
		var box := base.mesh as BoxMesh
		var next_box := next_base.mesh as BoxMesh
		var center_spacing: float = scene.tile_positions[index].distance_to(
			scene.tile_positions[next_index]
		)
		var occupied_length := (box.size.x + next_box.size.x) * 0.5
		if occupied_length > center_spacing * 0.9:
			push_error(
				"%s cards %d/%d overlap their route spacing: %.3f / %.3f."
				% [
					board_id,
					index,
					next_index,
					occupied_length,
					center_spacing,
				]
			)
			quit(1)
			return

		var label := tile.get_node("TileLabel") as Label3D
		if label.width * label.pixel_size > box.size.x * 0.87:
			push_error("%s card %d label exceeds its face." % [board_id, index])
			quit(1)
			return


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
