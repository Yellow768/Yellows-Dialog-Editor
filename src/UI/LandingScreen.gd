extends Control
const prev_dirs_config_path = "user://prev_dirs.cfg"

var chosen_dir

func _ready():
	OS.low_processor_usage_mode = true
	get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED
	get_window().min_size = Vector2(1280,720)
	var config = ConfigFile.new()
	config.load(prev_dirs_config_path)
	for dir in config.get_sections():
		var quick_dir_button = Button.new()
		quick_dir_button.text = config.get_value(dir,"name")
		quick_dir_button.connect("pressed", Callable(self, "change_to_editor").bind(dir))
		$PrevDirsContainer.add_child(quick_dir_button)
		$PrevDirsContainer.move_child(quick_dir_button,1)
	


func change_to_editor(directory):
	add_directory_to_config(directory)
	if DirAccess.dir_exists_absolute(directory):
		var editor = load("res://src/UI/Editor/MainEditor.tscn").instantiate()
		CurrentEnvironment.current_directory = directory
		get_parent().add_child(editor)
		DisplayServer.window_set_title(directory+" | CNPC Dialog Editor")
		queue_free()
	else:
		var tween = get_tree().create_tween()
		$InvalidDirectory.modulate = Color(1,1,1,1)
		tween.tween_property($InvalidDirectory,"modulate",Color(1,1,1,0),2).set_delay(1)
		push_error("Directory does not exist")
	
func add_directory_to_config(directory : String):
	var config = ConfigFile.new()
	config.load(prev_dirs_config_path)
	if config.has_section(directory):
		config.erase_section(directory)
		config.save(prev_dirs_config_path)
	for section in config.get_sections():
		config.set_value(section,"name",config.get_value(section,"name"))
	if DirAccess.dir_exists_absolute(directory):
		if config.get_value(directory,"name",null):
			return
		else:
			config.set_value(directory,"name",directory.get_base_dir())
			config.save(prev_dirs_config_path)


func find_valid_customnpcs_dir(dir : String):
	var directory = DirAccess.open(dir)
	var dir_search = DirectorySearch.new()
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






func _on_FileDialog_dir_selected(path):
	var valid_path = find_valid_customnpcs_dir(path)
	if valid_path == "":
		chosen_dir = path
		$Panel/InvalidFolderWarning.popup_centered()
	else:
		change_to_editor(valid_path)


		


func _on_Cancel_button_up():
	$Panel/FileDialog.popup_centered()
	$Panel/InvalidFolderWarning.visible = false


func _on_Confirm_pressed():
	var dir = DirAccess.open(chosen_dir)
	if chosen_dir.replace(chosen_dir.get_base_dir(),"") == "/customnpcs":
		dir.make_dir(chosen_dir+"/dialogs")
	else:
		dir.make_dir(chosen_dir+"/customnpcs")
		dir.make_dir(chosen_dir+"/customnpcs/dialogs")
	change_to_editor(chosen_dir+"/customnpcs")
