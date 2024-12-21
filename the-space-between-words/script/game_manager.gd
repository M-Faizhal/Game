extends Node

# SimpleGameManager.gd
const SAVE_FILE = "user://last_scene.save"

func change_scene_and_save(scene_path: String) -> Error:
	# Save the scene we're changing to
	var save_file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	save_file.store_line(scene_path)
	
	# Change to the scene
	return get_tree().change_scene_to_file(scene_path)

func load_last_scene() -> bool:
	if not FileAccess.file_exists(SAVE_FILE):
		print("No saved scene found")
		return false
		
	var save_file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	var last_scene = save_file.get_line()
	get_tree().change_scene_to_file(last_scene)
	return true
