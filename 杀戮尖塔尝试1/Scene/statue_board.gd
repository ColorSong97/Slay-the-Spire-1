extends PanelContainer
class_name StatueBoard

signal pause_start
signal check_map_pressed
signal check_deck_pressed

signal potion_1_selected
signal potion_2_selected
signal potion_3_selected


@onready var character_icon: TextureRect = $VBoxContainer/MarginContainer2/HBoxContainer/MarginContainer/CharacterIcon
@onready var character_name: Label = $VBoxContainer/MarginContainer2/HBoxContainer/MarginContainer2/CenterContainer/CharacterName
@onready var hp_bar: ProgressBar = $VBoxContainer/MarginContainer2/HBoxContainer/MarginContainer3/VBoxContainer/MarginContainer2/HpBar
@onready var current_hp: Label = $VBoxContainer/MarginContainer2/HBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer2/HBoxContainer/CurrentHp
@onready var max_hp: Label = $VBoxContainer/MarginContainer2/HBoxContainer/MarginContainer3/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer2/HBoxContainer/MaxHp


func _on_menu_button_pressed() -> void:
	print_debug ("[StatueBoard] menu button pressed")
	pause_start.emit()


func _on_current_hp_changed(new_hp: int) -> void:
	if current_hp:
		current_hp.text = String.num(new_hp)
		print_debug("[StatueBoard] current hp changed to ", new_hp)
	else:
		push_error("[StatueBoard] CurrentHp Node not found")


func _on_max_hp_changed(new_hp: int) -> void:
	if max_hp:
		max_hp.text = String.num(new_hp)
		print_debug("[StatueBoard] max hp changed to ", new_hp)
	else:
		push_error("[StatueBoard] MaxHp Node not found")


func _change_character_icon(path: String) -> void:
	if ResourceLoader.exists(path):
		var texture = load(path) as Texture2D
		if texture:
			character_icon.texture = texture
			print_debug("[StatueBoard] 人物头像已加载")
		else:
			push_error("[StatueBoard] 无法加载纹理: ", path)
	else:
		# 也可以直接传入 Texture2D 对象，不判断路径
		push_error("[StatueBoard] 资源路径不存在: ", path)


func _change_character_name(name: String) -> void:
	if character_name:
		character_name.text = name
		print_debug("[StatueBoard] 人物名称已加载")
	else:
		push_error("character_name 节点未找到")
