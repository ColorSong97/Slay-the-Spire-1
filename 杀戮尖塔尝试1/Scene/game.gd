extends Node


var game_data: GameDataResource
@onready var save_manager: Node = %SaveManager


func _ready() -> void:
	game_data = GameDataResource.new()
	game_data.reset_to_default()
	game_data._map_data.test_generate_map()
	game_data.test_print()
	
	save_manager.game_save.connect(on_game_save)
	save_manager.game_load.connect(on_game_load)

func _process(delta: float) -> void:
	pass

#region Save & Load

func on_game_save(save_data: Dictionary) -> void:
	save_data["gameData"] = game_data.serialize()
	pass

func on_game_load(save_data: Dictionary) -> void:
	if save_data["gameData"]:
		game_data.deserialize(save_data["gameData"])
	pass

#endregion
