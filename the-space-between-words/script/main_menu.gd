extends Control


func _on_new_game_pressed() -> void:
	GameManager.change_scene_and_save("res://Scene/MasukDesaScene.tscn")

func _on_load_game_pressed() -> void:
	GameManager.load_last_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
