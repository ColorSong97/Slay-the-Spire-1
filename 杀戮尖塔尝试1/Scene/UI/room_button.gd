extends Control
class_name RoomButton


signal room_pressed

@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect

@export var room_type: MapRoomNode.RoomType
@export var is_activated: bool = false


func set_room_type(new: MapRoomNode.RoomType) -> void:
	match new:
		MapRoomNode.RoomType.COMBAT_NORMAL:
			label.text = "敌人"
		MapRoomNode.RoomType.COMBAT_ELITE:
			label.text = "干部"
		MapRoomNode.RoomType.COMBAT_BOSS:
			label.text = "头领"
		MapRoomNode.RoomType.EVENT:
			label.text = "?"
		MapRoomNode.RoomType.CHEST:
			label.text = "宝箱"
		MapRoomNode.RoomType.CAMPFIRE:
			label.text = "火堆"
		MapRoomNode.RoomType.SHOP:
			label.text = "$"
		_:
			label.text = "FIFA"

func activate() -> void:
	if not is_activated:
		is_activated = true
		texture_rect.visible = true

func deactivate() -> void:
	if is_activated:
		is_activated = false
		texture_rect.visible = false

func _on_button_pressed() -> void:
	room_pressed.emit()
