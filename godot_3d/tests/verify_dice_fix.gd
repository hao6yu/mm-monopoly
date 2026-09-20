extends SceneTree

## Verifies (a) camera-relative dice slots fix the overlap and (b) the d12
## dodecahedron rendering and settle orientations for several values.

const OUTPUT_DIRECTORY := "/tmp/mm/godot_verify"


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

	# (a) Overlap fix: settled 4+3 viewed from the azimuth that used to stack
	# the dice one behind the other.
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify({
			"boardId": "usa",
			"tileNames": logical_names,
			"tiles": logical_tiles,
			"currentPlayerIndex": 0,
			"die1": 4,
			"die2": 3,
			"diceSides": 6,
			"players": players,
		}),
	})
	for _frame in 8:
		await process_frame
	scene.camera_azimuth = deg_to_rad(-99.0)
	scene.camera_elevation = deg_to_rad(30.0)
	scene.camera_distance = 9.0
	scene.camera_target = Vector3(9.7, 1.6, 0.5)
	scene._update_camera()
	scene._settle_dice_at_slots()
	for _frame in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/d6_fixed_slots.png" % OUTPUT_DIRECTORY)
	print("SAVED d6_fixed_slots")

	# (b) d12 shape via sync, close-up on the platform.
	scene.host_receive_message({
		"action": "sync_state",
		"json": JSON.stringify({
			"boardId": "usa",
			"tileNames": logical_names,
			"tiles": logical_tiles,
			"currentPlayerIndex": 0,
			"die1": 8,
			"die2": 12,
			"diceSides": 12,
			"players": players,
		}),
	})
	for _frame in 10:
		await process_frame
	_dump_dice(scene, "d12")
	scene.camera_distance = 6.5
	scene.camera_target = Vector3(9.7, 1.7, 0.5)
	scene.camera_elevation = deg_to_rad(52.0)
	scene.camera_azimuth = deg_to_rad(43.0)
	scene._update_camera()
	for _frame in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("%s/d12_closeup.png" % OUTPUT_DIRECTORY)
	print("SAVED d12_closeup")

	# (c) d12 settle orientations: sweep die1 through 1..6 then 7..12 pairs.
	for pair in [[1, 7], [2, 8], [3, 9], [4, 10], [5, 11], [6, 12]]:
		scene.host_receive_message({
			"action": "sync_state",
			"json": JSON.stringify({
				"boardId": "usa",
				"tileNames": logical_names,
				"tiles": logical_tiles,
				"currentPlayerIndex": 0,
				"die1": pair[0],
				"die2": pair[1],
				"diceSides": 12,
				"players": players,
			}),
		})
		for _frame in 6:
			await process_frame
		# Force the settled orientation exactly as a roll would.
		for index in scene.dice_nodes.size():
			var die: Node3D = scene.dice_nodes[index]
			die.rotation = Vector3(scene._die_face_rotation(pair[index]))
		scene._settle_dice_at_slots()
		for _frame in 4:
			await process_frame
		await RenderingServer.frame_post_draw
		var file_name := "d12_faces_%d_%d.png" % [pair[0], pair[1]]
		root.get_texture().get_image().save_png("%s/%s" % [OUTPUT_DIRECTORY, file_name])
		print("SAVED ", file_name)

	print("VERIFY_OK")
	quit(0)


func _dump_dice(scene: Node, label: String) -> void:
	var dice: Array = scene.dice_nodes
	for index in dice.size():
		var die: Node3D = dice[index]
		print("DUMP[%s] die%d visible=%s pos=%s" % [
			label, index, die.visible, die.position,
		])
