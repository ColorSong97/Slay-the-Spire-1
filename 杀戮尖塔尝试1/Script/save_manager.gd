extends Node

#region signals

## 信号：请求保存数据。其他模块应连接此信号，并将自己的数据填充到 data 字典中
signal game_save(data: Dictionary)
## 信号：请求加载数据。其他模块应连接此信号，从 data 字典中读取自己的数据并恢复状态
signal game_load(data: Dictionary)
## 信号：保存完成后发出
signal game_saved
## 信号：加载完成后发出
signal game_loaded

#endregion

## 存档文件路径
const SAVE_PATH := "res://savegame1.json"

var game_data: Dictionary

## 检查存档文件是否存在
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## 保存游戏（由外部调用，例如切换房间、战斗结束时）
func save_game() -> void:
	# 清空旧数据，准备重新收集
	game_data.clear()
	
	# 发出保存请求，让其他模块填充数据
	game_save.emit(game_data)
	
	# 将字典写入 JSON 文件
	var json_str = JSON.stringify(game_data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		game_saved.emit()
		print("游戏已保存至 ", SAVE_PATH)
	else:
		push_error("无法写入存档文件: ", SAVE_PATH)
	
	game_saved.emit()
	pass

## 加载游戏（由继续游戏时调用）
func load_game() -> int:
	if not has_save_file():
		push_warning("没有找到存档文件")
		return 1
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("无法打开存档文件: ", SAVE_PATH)
		return 1
	
	var json_str = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_str)
	if error != OK:
		push_error("JSON 解析失败: ", json.get_error_message())
		return 1
	
	game_data = json.data
	
	# 发出加载信号，让其他模块恢复状态
	game_load.emit(game_data)
	
	game_loaded.emit()
	print("游戏加载完成")
	return 0

## 删除存档（新游戏覆盖时调用）
func delete_save() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_PATH)
		game_data.clear()
		print("存档已删除")

#func _ready() -> void:
	#var data_to_send = ["a", "b", "c", [1, 2, 3]]
	#var json_string = JSON.stringify(data_to_send, "\t")
	## 保存数据
	## ...
	## 检索数据
	#var json = JSON.new()
	#var error = json.parse(json_string)
	#if error == OK:
		#var data_received = json.data
		#if typeof(data_received) == TYPE_ARRAY:
			#print(data_received) # 输出 array
		#else:
			#print("Unexpected data")
	#else:
		#print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
