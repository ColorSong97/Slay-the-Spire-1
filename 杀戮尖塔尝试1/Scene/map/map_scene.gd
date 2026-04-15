extends Control
class_name MapScene


@onready var rooms: Array[RoomButton] = []

const ROOM_BUTTON_NODE = preload("res://Scene/UI/room_button.tscn")
const ROOM_PATH = "PanelContainer/ScrollContainer/VBoxContainer/"

var map_pos: Dictionary = {}
var lines: Dictionary = {}

#region mouse input



func _input(event: InputEvent) -> void:
	pass

#endregion

func create_map(map_data: MapData) -> void:
	#print_debug("[MapScene] On creating map")
	
	# 清空房间
	#print_debug("[MapScene] clear old things")
	map_pos.clear()
	lines.clear()
	for depth in range(1, MapData.MAX_DEPTH + 1):
		var layer_node = get_node(ROOM_PATH + str(depth))
		for node in layer_node.get_children():
			node.queue_free()
	
	# 绘制房间
	#print_debug("[MapScene] depth:", MapData.MAX_DEPTH)
	for depth in range(1, MapData.MAX_DEPTH + 1):
		var layer_node = get_node(ROOM_PATH + str(depth))
		#print_debug("[MapScene] at depth ", depth, ", get layer node:", layer_node)
		for room in map_data.rooms[depth]:
			print("[MapScene] On creating room: ", room.serialize())
			
			var room_button_node = ROOM_BUTTON_NODE.instantiate()
			#await room_button_node.ready
			if not room_button_node:
				push_error("[MapScene] Error on creating room UI")
				return
			layer_node.add_child(room_button_node)
			room_button_node.name = str(room.index)
			room_button_node.set_room_type(room.type)
			room_button_node.deactivate()
			room_button_node = null
	
	for depth in range(1, MapData.MAX_DEPTH + 1):
		var layer_node = get_node(ROOM_PATH + str(depth))
		var index = 0		# 记录序号
		for room in layer_node.get_children():
			# 记录房间位置
			map_pos[str(depth) + "_" + str(index)] = room.global_position
			index += 1
	#print_debug(map_pos)
	
	var lines_index = 0		# 记录序号
	for depth in range(1, MapData.MAX_DEPTH):
		var layer_node = get_node(ROOM_PATH + str(depth))
		for room in map_data.rooms[depth]:
			for next in room.next_rooms:
				var line: Dictionary = {}
				line["from"] = map_pos[str(room.depth) + "_" + str(room.index)]
				line["to"] = map_pos[str(room.depth+1) + "_" + str(next)]
				lines[lines_index] = line
				lines_index += 1

func _draw() -> void:
	# 绘制路径
	for line in lines:
		var from_pos = line["from"]
		var to_pos = line["to"]
		draw_line(from_pos, to_pos, Color.BLACK, 500)
	pass
