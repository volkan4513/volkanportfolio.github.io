extends Button

func _ready() -> void:
	connect("pressed", Callable(self, "_on_button_pressed"))
	
	var appPlugin := Engine.get_singleton("AppPlugin")
	if appPlugin:
		print("App plugin is available")

		# Signal fired from the app logic to update the gltf model being shown
		appPlugin.connect("reset_scene", _reset_scene_function)
	else:
		print("App plugin is not available")

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()

func _reset_scene_function() -> void:
	_on_button_pressed()
