extends Node2D

@onready var continue_button: Button = $Buttons/VBoxContainer/ContinueButton
@onready var giveup_button: Button = $Buttons/VBoxContainer/GiveupButton
@onready var newgame_button: Button = $Buttons/VBoxContainer/NewgameButton
@onready var exit_button: Button = $Buttons/VBoxContainer/ExitButton

@onready var save_manager: Node = %SaveManager



func _ready() -> void:
	save_manager = get_node("/root/Game/SaveManager")
	await save_manager.ready
	continue_button.visible = save_manager.has_save_file()
	giveup_button.visible = save_manager.has_save_file()
	pass


#region Button Signals

func _on_continue_button_pressed() -> void:
	if save_manager.load_game():
		# 加载成功后切换到游戏场景，游戏场景会从 SaveManager.game_data 恢复状态
		get_tree().change_scene_to_file("res://scenes/in_game_scene.tscn")
	else:
		# 加载失败提示
		var err_dialog = AcceptDialog.new()
		err_dialog.dialog_text = "存档损坏，无法继续游戏。"
		add_child(err_dialog)
		err_dialog.popup_centered()
	print ("continue game")
	return


func _on_giveup_button_pressed() -> void:
	if save_manager.has_save_file():
		var confirm = ConfirmationDialog.new()
		confirm.title = "放弃"
		confirm.dialog_text = "已有存档，确定要放弃当前进度吗？"
		confirm.confirmed.connect(_clear_saving)
		add_child(confirm)
		confirm.popup_centered()
	pass


func _on_newgame_button_pressed() -> void:
	if save_manager.has_save_file():
		# 弹出确认对话框
		var confirm = ConfirmationDialog.new()
		confirm.title = "新游戏"
		confirm.dialog_text = "已有存档，确定要放弃当前进度吗？"
		confirm.confirmed.connect(_start_new_game)
		add_child(confirm)
		confirm.popup_centered()
	else:
		_start_new_game()
	pass

func _clear_saving():
	save_manager.delete_save()
	print ("saving deleted")

func _start_new_game():
	_clear_saving()          # 清空旧存档
	# 重置全局游戏数据（例如通过 Autoload 的 GameState）
	#GameState.reset_to_default()       # 稍后实现
	# 切换到游戏场景
	get_tree().change_scene_to_file("res://scenes/in_game_scene.tscn")


func _on_exit_button_pressed() -> void:
	var confirm = ConfirmationDialog.new()
	confirm.title = "退出"
	confirm.dialog_text = "确定要退出游戏吗？"
	confirm.confirmed.connect(_quit_game)
	add_child(confirm)
	confirm.popup_centered()
	pass

func _quit_game():
	get_tree().quit()

#endregion
