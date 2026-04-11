extends Node

@export var available: bool = true

func _ready() -> void:
	%SaveManager.game_save.connect(_on_game_save)
	%SaveManager.game_load.connect(_on_game_load)
	pass

func _on_game_save(data: Dictionary) -> void:
	if !available:
		return
	
	data["player"] = {
		"health": 100,
		"gold": 3
	}
	pass

func _on_game_load(data: Dictionary) -> void:
	if !available:
		return
	
	if data.has("player"):
		print (data["player"])
	pass

func _input(event: InputEvent) -> void:
	if !available:
		return
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_up"):
			%SaveManager.save_game()
		elif Input.is_action_just_pressed("ui_down"):
			%SaveManager.load_game()
