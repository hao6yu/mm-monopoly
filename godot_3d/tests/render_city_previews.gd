extends SceneTree

const CityThemesCatalog = preload("res://scripts/city_themes.gd")
const OUTPUT_DIRECTORY := "/tmp/property_tycoon_city_previews"


func _initialize() -> void:
	call_deferred("_render_all")


func _render_all() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIRECTORY)
	var scene: Node = load("res://main.tscn").instantiate()
	root.add_child(scene)
	for _frame in 8:
		await process_frame
	scene._enable_embedded_mode()

	var logical_names: Array[String] = []
	var logical_tiles: Array[Dictionary] = []
	for index in 40:
		var name := "LOCATION %02d" % (index + 1)
		var tile_type := "property"
		match index:
			0:
				name = "GO"
				tile_type = "start"
			2, 17, 33:
				name = "COMMUNITY CHEST"
				tile_type = "communityChest"
			7, 22, 36:
				name = "CHANCE"
				tile_type = "chance"
			10:
				name = "JAIL"
				tile_type = "jail"
			20:
				name = "LUCKY SPIN"
				tile_type = "freeParking"
			30:
				name = "GO TO JAIL"
				tile_type = "goToJail"
		logical_names.append(name)
		logical_tiles.append({
			"logicalIndex": index,
			"visualPosition": roundi(float(index) * 52.0 / 40.0) % 52,
			"name": name,
			"type": tile_type,
			"colorArgb": 0xffd45b63,
			"price": 120 + index * 10 if tile_type == "property" else 0,
			"ownerColorArgb": 0xffff4f5e if index == 1 else 0,
			"upgradeLevel": 3 if index == 1 else 0,
			"isMortgaged": false,
		})

	for board_id in CityThemesCatalog.all_board_ids():
		scene.host_receive_message({
			"action": "sync_state",
			"json": JSON.stringify({
				"boardId": board_id,
				"tileNames": logical_names,
				"tiles": logical_tiles,
				"currentPlayerIndex": 0,
				"die1": 4,
				"die2": 3,
				"players": [
					{
						"id": "preview-one",
						"name": "Mia",
						"visualPosition": 0,
						"isActive": true,
					},
					{
						"id": "preview-two",
						"name": "Noah",
						"visualPosition": 13,
						"isActive": true,
					},
					{
						"id": "preview-three",
						"name": "Luna",
						"visualPosition": 26,
						"isActive": true,
					},
					{
						"id": "preview-four",
						"name": "Max",
						"visualPosition": 39,
						"isActive": true,
					},
				],
			}),
		})
		scene._reset_camera()
		for _frame in 8:
			await process_frame
		var image := root.get_texture().get_image()
		var output_path := "%s/%s.png" % [OUTPUT_DIRECTORY, board_id]
		var result := image.save_png(output_path)
		if result != OK:
			push_error("Could not save %s." % output_path)
			quit(1)
			return
		print("CITY_PREVIEW ", output_path)

	print("CITY_PREVIEWS_OK ", CityThemesCatalog.all_board_ids().size())
	quit(0)
