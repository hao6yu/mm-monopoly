extends SceneTree

## Verifies the settled dice stay on the widened dock from the default
## island-centered portrait camera and from an along-axis orbit.

const OUTPUT_DIRECTORY := "/tmp/mm/godot_verify2"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIRECTORY)
	var scene: Node = load("res://main.tscn").instantiate()
	root.add_child(scene)
	for _frame in 8:
		await process_frame
	scene._enable_embedded_mode()

	var logical_names: Array[String] = []
	var logical_tiles: Array[Dictionary] = []
	for index in 40:
		logical_names.append("LOCATION %02d" % (index + 1))
		logical_tiles.append({
			"logicalIndex": index,
			"visualPosition": roundi(float(index) * 52.0 / 40.0) % 52,
			"name": "LOCATION %02d" % (index + 1),
			"type": "property",
			"colorArgb": 0xffd45b63,
			"price": 100,
			"ownerColorArgb": 0,
			"upgradeLevel": 0,
			"isMortgaged": false,
			"groupId": "",
			"hasCompleteColorGroup": false,
		})
	var players := [
		{"id": "p1", "name": "Player 1", "visualPosition": 0, "isActive": true},
		{"id": "p2", "name": "Player 2", "visualPosition": 13, "isActive": true},
	]

	# Fresh d12 game, untouched default camera (as on a just-started phone).
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify({
			"boardId": "usa",
			"tileNames": logical_names,
			"tiles": logical_tiles,
			"currentPlayerIndex": 0,
			"die1": 0,
			"die2": 0,
			"diceSides": 12,
			"players": players,
		}),
	})
	scene._reset_camera()
	for _frame in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/d12_default_camera.png" % OUTPUT_DIRECTORY)
	print("SAVED d12_default_camera")

	# Settled 7 + 1 from the default camera (the phone QA state).
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify({
			"boardId": "usa",
			"tileNames": logical_names,
			"tiles": logical_tiles,
			"currentPlayerIndex": 0,
			"die1": 7,
			"die2": 1,
			"diceSides": 12,
			"players": players,
		}),
	})
	for _frame in 8:
		await process_frame
	for index in scene.dice_nodes.size():
		var die: Node3D = scene.dice_nodes[index]
		die.rotation = Vector3(scene._die_face_rotation([7, 1][index]))
	scene._settle_dice_at_slots()
	for _frame in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/d12_settled_default.png" % OUTPUT_DIRECTORY)
	print("SAVED d12_settled_default")

	# Worst case: camera orbit so the lanes run along the dock's short axis.
	scene.camera_azimuth = deg_to_rad(-99.0)
	scene.camera_elevation = deg_to_rad(30.0)
	scene.camera_distance = 9.0
	scene.camera_target = Vector3(9.55, 1.6, 0.42)
	scene._update_camera()
	scene._settle_dice_at_slots()
	for _frame in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/d12_short_axis_orbit.png" % OUTPUT_DIRECTORY)
	print("SAVED d12_short_axis_orbit")

	# New York board dock sanity.
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify({
			"boardId": "usa_new_york",
			"tileNames": logical_names,
			"tiles": logical_tiles,
			"currentPlayerIndex": 0,
			"die1": 3,
			"die2": 5,
			"diceSides": 12,
			"players": players,
		}),
	})
	scene._reset_camera()
	for _frame in 12:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/d12_new_york.png" % OUTPUT_DIRECTORY)
	print("SAVED d12_new_york")

	print("VERIFY2_OK")
	quit(0)
