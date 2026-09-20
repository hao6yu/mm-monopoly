extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: Node = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	scene.dice_sides = 12
	scene._recreate_dice()
	for index in scene.dice_nodes.size():
		var die: Node3D = scene.dice_nodes[index]
		var normal: Vector3 = scene._d12_face_normal(1 + index * 5)
		if not (die.basis * normal).is_equal_approx(Vector3.UP):
			push_error("Fresh D12 must rest on a face; check radians/degrees.")
			quit(1)
			return
	for value in range(1, 13):
		var normal: Vector3 = scene._d12_face_normal(value)
		var rotation: Vector3 = scene._die_face_rotation(value)
		if not (Basis.from_euler(rotation) * normal).is_equal_approx(Vector3.UP):
			push_error("D12 settled face does not match value %d" % value)
			quit(1)
			return
		var face: Array = scene._dodecahedron_face_vertices(
			normal, scene._dodecahedron_vertices()
		)
		if face.size() != 5:
			push_error("D12 face must be a pentagon.")
			quit(1)
			return
	for degrees in range(0, 360, 15):
		scene.camera_azimuth = deg_to_rad(degrees)
		scene._update_camera()
		var first: Vector3 = scene._dice_rest_position(0)
		var second: Vector3 = scene._dice_rest_position(1)
		if first.distance_to(second) < 1.8:
			push_error("Dice slots overlap while orbiting.")
			quit(1)
			return
	print("D12_REGRESSION_OK: fresh orientation, all 12 faces, 24 orbit angles")
	scene.queue_free()
	await process_frame
	quit(0)
