# game_data_resource.gd
extends Resource
class_name GameDataResource


#region  内部数据

var _health: int = 80
var _max_health: int = 80
var _gold: int = 0
var _deck: Array[CardResource] = []
var _current_room_id: String = ""
var _map_data: MapData

#endregion

#region  信号

signal health_changed(new_value: int)
signal max_health_changed(new_value: int)
signal gold_changed(new_value: int)
signal deck_changed()
signal map_changed()

#endregion

#region 公共接口

func reset_to_default() -> void:
	_health = 80
	_max_health = 80
	_gold = 0
	_deck.clear()
	_current_room_id = ""
	_map_data = MapData.new()
	# 可选：添加初始卡牌
	# _deck.append(load("res://cards/strike.tres"))

#endregion

func get_health() -> int:
	return _health

func set_health(value: int) -> void:
	_health = clamp(value, 0, _max_health)
	health_changed.emit(_health)


func get_max_health() -> int:
	return _max_health

func set_max_health(value: int) -> void:
	if _health > value:
		set_health(value)
	
	_max_health = max(1, value)
	max_health_changed.emit()


func get_gold() -> int:
	return _gold

func set_gold(value: int) -> void:
	_gold = max(0, value)
	gold_changed.emit(_gold)


func get_deck() -> Array[CardResource]:
	return _deck.duplicate()   # 返回副本，防止外部修改

func add_card(card: CardResource) -> void:
	_deck.append(card)
	deck_changed.emit()

func remove_card(card: CardResource) -> void:
	var idx = _deck.find(card)
	if idx != -1:
		_deck.remove_at(idx)
		deck_changed.emit()


func get_current_room_id() -> String:
	return _current_room_id

func set_current_room_id(room_id: String) -> void:
	_current_room_id = room_id

func get_map_data() -> MapData:
	return _map_data

func update_map_data(new_map: MapData) -> void:
	_map_data = new_map
	map_changed.emit()


#region 序列化（供 SaveManager 调用）

func serialize() -> Dictionary:
	return {
		"health": _health,
		"max_health": _max_health,
		"gold": _gold,
		"deck": _deck.map(func(c): return c.resource_path),   # 存卡牌路径
		"current_room_id": _current_room_id,
		# map_data 的序列化需要实现 MapData.serialize()
		"map_data": _map_data.serialize() if _map_data else {}
	}

func deserialize(data: Dictionary) -> void:
	_health = data.get("health", 80)
	_max_health = data.get("max_health", 80)
	_gold = data.get("gold", 0)
	# 从路径重新加载卡牌
	_deck.clear()
	for path in data.get("deck", []):
		var card = load(path)
		if card:
			_deck.append(card)
	_current_room_id = data.get("current_room_id", "")
	# 反序列化 map_data
	var map_dict = data.get("map_data", {})
	if map_dict:
		_map_data = MapData.new()
		_map_data.deserialize(map_dict)
	else:
		_map_data = null
	# 发出信号，通知 UI 刷新
	health_changed.emit(_health)
	gold_changed.emit(_gold)
	deck_changed.emit()


#region 调试 Debug

func test_print() -> void:
	#print("game data test")
	_map_data.test_print()
	pass

#endregion
