extends FileDialog
signal faction_json_selected


var json_path

func _ready():
	popup()
	print("help")


func _on_FactionJsonFile_file_selected(path):
	print("idfk")
	emit_signal("faction_json_selected",path)
	

func _on_FactionJsonFile_confirmed():
	emit_signal("faction_json_selected",json_path)


func _on_FactionJsonFile_dir_selected(dir):
	print("COME ONE")
