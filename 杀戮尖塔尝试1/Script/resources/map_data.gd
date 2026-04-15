extends Resource
class_name MapData


const MAX_DEPTH := 20
const MAX_ROOMS_PER_LAYER := 5
const MIN_NEXT_ROOMS := 1
const MAX_NEXT_ROOMS := 3		# 每个房间最多连接的下层房间数（BOSS房除外）

@export_group("房间概率")
@export var room_posibility_combat_normal: float = 0.2
@export var room_posibility_combat_elite: float = 0.2
@export var room_posibility_event: float = 0.2
@export var room_posibility_campfire: float = 0.2
@export var room_posibility_shop: float = 0.2

var rooms: Array[Array] = []	# MapRoomNode[][]
var current_room: MapRoomNode = null

# 同类房间数组
var normal_rooms: Dictionary
var elite_rooms: Dictionary
var event_rooms: Dictionary
var campfire_rooms: Dictionary
var shop_rooms: Dictionary


func _init() -> void:
	rooms.resize(MAX_DEPTH + 1)
	for i in MAX_DEPTH + 1:
		rooms[i] = []

#region Save & Load

func serialize() -> Dictionary:
	var rooms_data = []
	for depth in range(1, MAX_DEPTH+1):
		var layer_data = []
		for room in rooms[depth]:
			layer_data.append(room.serialize())
		rooms_data.append(layer_data)
	return {
		"rooms": rooms_data,
		"current": [current_room.depth, current_room.index] if current_room else null
	}

func deserialize(save_data: Dictionary) -> void:
	# 先清空并重建二维数组
	for i in range(1, MAX_DEPTH+1):
		rooms[i].clear()
	
	# 创建所有房间
	for depth in range(1, MAX_DEPTH+1):
		var layer_data = save_data["rooms"][depth-1]  # 获取本层节点的注意索引偏移
		for room_dict in layer_data:
			var room := MapRoomNode.new()
			room.deserialize(room_dict)
			rooms[depth].append(room)
	
	# 恢复当前房间
	var curr_coord = save_data["current"]
	if curr_coord:
		current_room = rooms[curr_coord[0]][curr_coord[1]]
	else:
		current_room = rooms[1][0] if rooms[1].size() > 0 else null

#endregion

# ---------- 生成地图 ----------
func generate_map(seed: int, room_posibility: Dictionary) -> void:
	for i in MAX_DEPTH + 1:
		rooms[i].clear()
	
	for depth in range(1, MAX_DEPTH + 1):
		match depth:
			1:
				# 生成宝箱房，就是先古之民的房间
				pass
			11:
				# 生成正常宝箱房
				pass
			19:
				# 生成火堆
				pass
			20:
				# 生成BOSS房
				pass
			_:
				# 正常生成随机房间
				pass

# ---------- 测试地图 ----------
func test_generate_map() -> void:
	for i in MAX_DEPTH + 1:
		rooms[i].clear()
	
	# 这是测试用的，生成一条直路
	for depth in range(1, MAX_DEPTH + 1):
		var room := MapRoomNode.new()
		room.set_room(depth, 0, MapRoomNode.RoomType.CHEST)
		room.next_rooms.append(0)
		rooms[depth].append(room)
	
	rooms[1][0].set_room(1, 0, MapRoomNode.RoomType.COMBAT_NORMAL)
	rooms[19][0].set_room(19, 0, MapRoomNode.RoomType.CAMPFIRE)
	rooms[20][0].set_room(20, 0, MapRoomNode.RoomType.COMBAT_BOSS)

#region 接口

# 更换房间接口
func move_to_room(room: MapRoomNode) -> int:
	if room == null:
		return 1
	if current_room == null:
		return 1
	if room in current_room.next_rooms:
		current_room = room
		return 0
	return 1


#endregion

#region 调试 Debug

func test_print() -> void:
	#print("map test")
	for depth in range(1, MAX_DEPTH + 1):
		#print("depth:", depth)
		print("node num:", rooms[depth].size())
		for room in rooms[depth]:
			print("room:", room.serialize())
	pass

#endregion
