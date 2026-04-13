extends Control

## 房间按钮的预制体（可以是 PackedScene 或直接创建 Button）
#var room_button_scene: PackedScene = preload("res://Scene/UI/RoomButton.tscn")

## 记录每个房间对应的 UI 按钮
var room_buttons: Dictionary = {}  # key: MapRoomNode, value: Button

## 记录每个房间的中心坐标（用于画线）
var room_positions: Dictionary = {}

## 容器节点（用于放置按钮和绘制线条）
@onready var map_container: Control = $MapContainer

func _ready():
	# 监听游戏地图变化（可自行添加信号）
	refresh_map()

## 刷新整个地图显示
func refresh_map():
	if not Game.map_data:
		return
	# 清除原有按钮
	for child in map_container.get_children():
		if child is Button:
			child.queue_free()
	room_buttons.clear()
	room_positions.clear()
	
	# 获取地图数据
	var map_data = Game.map_data
	var max_depth = MapData.MAX_DEPTH
	var max_rooms_per_layer = MapData.MAX_ROOMS_PER_LAYER
	
	# 计算布局参数
	var container_size = map_container.size
	var start_x = 100
	var start_y = 50
	var x_step = 150
	var y_step = 80
	
	# 遍历所有房间，创建按钮
	for depth in range(1, max_depth + 1):
		var layer_rooms = map_data.rooms[depth]
		var layer_size = layer_rooms.size()
		# 计算本层起始X坐标（居中）
		var layer_width = (layer_size - 1) * x_step
		var offset_x = (container_size.x - layer_width) / 2 if layer_size > 0 else 0
		
		for idx in range(layer_size):
			var room = layer_rooms[idx]
			var btn = room_button_scene.instantiate() if room_button_scene else Button.new()
			btn.text = _get_room_display_text(room)
			btn.size = Vector2(100, 50)
			# 设置位置
			var pos = Vector2(offset_x + idx * x_step, start_y + (depth-1) * y_step)
			map_container.add_child(btn)
			btn.position = pos
			btn.pressed.connect(_on_room_button_pressed.bind(room))
			room_buttons[room] = btn
			room_positions[room] = pos + btn.size / 2  # 中心点用于画线
	
	# 绘制连接线
	queue_redraw()

func _draw():
	if not Game.map_data:
		return
	# 绘制所有房间之间的连接线
	for room in room_positions.keys():
		var from_pos = room_positions[room]
		for next_room in room.next_rooms:
			if room_positions.has(next_room):
				var to_pos = room_positions[next_room]
				draw_line(from_pos, to_pos, Color.WHITE, 2.0)

## 房间按钮显示文本（根据类型）
func _get_room_display_text(room: MapRoomNode) -> String:
	match room.type:
		MapRoomNode.RoomType.COMBAT_NORMAL:
			return "战"
		MapRoomNode.RoomType.COMBAT_ELITE:
			return "精英"
		MapRoomNode.RoomType.COMBAT_BOSS:
			return "BOSS"
		MapRoomNode.RoomType.EVENT:
			return "事件"
		MapRoomNode.RoomType.CHEST:
			return "宝箱"
		MapRoomNode.RoomType.CAMPFIRE:
			return "火堆"
		MapRoomNode.RoomType.SHOP:
			return "商店"
		_:
			return "?"

## 点击房间按钮
func _on_room_button_pressed(room: MapRoomNode):
	if Game.move_to_room(room):
		refresh_map()  # 移动后刷新（高亮当前房间）
		# 可选：进入房间逻辑
		_enter_room(room)
	else:
		print("无法移动到该房间")

## 进入房间（根据房间类型触发不同界面）
func _enter_room(room: MapRoomNode):
	# 这里可以发出信号，或直接调用 Game 进入战斗/商店等
	print("进入房间: ", _get_room_display_text(room))

## 高亮当前房间（可在刷新时根据 current_room 设置按钮颜色）
func _refresh_highlight():
	var current = Game.map_data.current_room if Game.map_data else null
	for room in room_buttons.keys():
		var btn = room_buttons[room]
		if room == current:
			btn.modulate = Color.YELLOW
			# 也可禁用按钮或改变样式
		else:
			btn.modulate = Color.WHITE
		# 额外：可移动的房间高亮为绿色
		if current and room in current.next_rooms:
			btn.modulate = Color.GREEN
