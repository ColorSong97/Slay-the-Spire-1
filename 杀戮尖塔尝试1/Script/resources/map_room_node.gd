extends Resource
class_name MapRoomNode


enum RoomType {
	COMBAT_NORMAL,	# 普通战斗
	COMBAT_ELITE,	# 精英战斗
	COMBAT_BOSS,	# BOSS战斗
	EVENT,			# 事件
	CHEST,			# 宝箱
	CAMPFIRE,		# 火堆（休息点）
	SHOP			# 商店
}

@export var depth: int				# 深度（层数，1~20）
@export var index: int				# 在当前层的序号（0~4）
@export var type: RoomType
@export var next_rooms: Array[int]	# 指向的下层房间index列表
@export var prev_rooms: Array[int]	# 指向的上层房间index列表


func _init() -> void:
	depth = 0
	index = 0
	type = 0
	next_rooms = []
	prev_rooms = []

func set_room(_depth: int, _index: int, _type: MapRoomNode.RoomType) -> void:
	depth = _depth
	index = _index
	type = _type
	next_rooms = []
	prev_rooms = []

func serialize() -> Dictionary:
	return {
		"depth": depth,
		"index": index,
		"type": type,
		"next_rooms": next_rooms,
		"prev_rooms": prev_rooms
	}

func deserialize(d: Dictionary) -> void:
	set_room(d["depth"], d["index"], d["type"])
	next_rooms.clear()
	prev_rooms.clear()
	for i in d["next_rooms"]:
		next_rooms.append(int(d["next_rooms"][i]))
	for i in d["prev_rooms"]:
		prev_rooms.append(int(d["prev_rooms"][i]))
