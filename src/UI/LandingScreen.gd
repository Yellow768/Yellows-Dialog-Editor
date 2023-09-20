extends Control
const user_settings_path := "user://user_settings.cfg"

var chosen_dir : String

func _ready():
	get_tree().auto_accept_quit = true
	DisplayServer.window_set_title("Home | CNPC Dialog Editor")
	OS.low_processor_usage_mode = true
	get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED
	get_window().min_size = Vector2(1280,720)
	var config := ConfigFile.new()
	config.load(user_settings_path)
	for dir in JSON.parse_string(config.get_value("prev_dirs","dir_array","[]")):
		print(dir)
		var quick_dir_button := Button.new()
		quick_dir_button.text = dir
		quick_dir_button.connect("pressed", Callable(self, "change_to_editor").bind(dir))
		$PrevDirsContainer.add_child(quick_dir_button)
	


func change_to_editor(directory : String) -> void:
	add_directory_to_config(directory)
	if DirAccess.dir_exists_absolute(directory):
		var editor = load("res://src/UI/Editor/MainEditor.tscn").instantiate()
		CurrentEnvironment.current_directory = directory
		get_parent().add_child(editor)
		DisplayServer.window_set_title(directory+" | CNPC Dialog Editor")
		queue_free()
	else:
		var tween := get_tree().create_tween()
		$InvalidDirectory.modulate = Color(1,1,1,1)
		tween.tween_property($InvalidDirectory,"modulate",Color(1,1,1,0),2).set_delay(1)
		push_error("Directory does not exist")
	
func add_directory_to_config(directory : String) -> void:
	var config = ConfigFile.new()
	config.load(user_settings_path)
	var dir_array = JSON.parse_string(config.get_value("prev_dirs","dir_array","[]"))
	dir_array.erase(directory)
	dir_array.push_front(directory)
	config.set_value("prev_dirs","dir_array",JSON.new().stringify((dir_array)))
	config.save(user_settings_path)
	


func find_valid_customnpcs_dir(dir : String) -> String:
	var directory := DirAccess.open(dir)
	var dir_search := DirectorySearch.new()
	print(dir)
	if dir.replace(dir.get_base_dir()+"/","") == "customnpcs":
		return dir
	print(dir_search.scan_directory_for_folders(dir))
	if dir_search.scan_directory_for_folders(dir).has("customnpcs"):
		if directory.dir_exists(dir+"/customnpcs/dialogs"):
			return dir+"/customnpcs"
	directory.change_dir("..")
	dir = directory.get_current_dir(true)
	if dir_search.scan_directory_for_folders(dir).has("customnpcs"):
		if directory.dir_exists(dir+"/customnpcs/dialogs"):
			return dir+"/customnpcs"
	return ""

	
func _on_Open_Environment_pressed():
	$Panel/FileDialog.popup_centered()






func _on_FileDialog_dir_selected(path : String):
	var valid_path := find_valid_customnpcs_dir(path)
	if valid_path == "":
		chosen_dir = path
		$Panel/InvalidFolderWarning.popup_centered()
	else:
		change_to_editor(valid_path)


		


func _on_Cancel_button_up():
	$Panel/FileDialog.popup_centered()
	$Panel/InvalidFolderWarning.visible = false


func _on_Confirm_pressed():
	var dir := DirAccess.open(chosen_dir)
	if chosen_dir.replace(chosen_dir.get_base_dir(),"") == "/customnpcs":
		dir.make_dir(chosen_dir+"/dialogs")
	else:
		dir.make_dir(chosen_dir+"/customnpcs")
		dir.make_dir(chosen_dir+"/customnpcs/dialogs")
	change_to_editor(chosen_dir+"/customnpcs")
