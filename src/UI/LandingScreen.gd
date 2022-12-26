extends Control
const prev_dirs_config_path = "user://prev_dirs.cfg"

var chosen_dir

func _ready():
	OS.low_processor_usage_mode = true
	OS.min_window_size = Vector2(1280,720)
	var config = ConfigFile.new()
	config.load(prev_dirs_config_path)
	for dir in config.get_sections():
		var quick_dir_button = Button.new()
		quick_dir_button.text = config.get_value(dir,"name")
		quick_dir_button.connect("pressed",self,"change_to_editor",[dir])
		$PrevDirsContainer.add_child(quick_dir_button)
	


func change_to_editor(directory):
	add_directory_to_config(directory)
	var editor = load("res://src/UI/Editor/MainEditor.tscn").instance()
	CurrentEnvironment.current_directory = directory
	get_parent().add_child(editor)
	queue_free()
	
func add_directory_to_config(directory : String):
	var config = ConfigFile.new()
	config.load(prev_dirs_config_path)
	for section in config.get_sections():
		config.set_value(section,"name",config.get_value(section,"name"))
	if config.get_value(directory,"name",null):
		return
	else:
		config.set_value(directory,"name",directory.get_base_dir())
		config.save(prev_dirs_config_path)


func find_valid_customnpcs_dir(dir : String):
	var directory = Directory.new()
	var dir_search = DirectorySearch.new()
	directory.open(dir)
	if dir.replace(dir.get_base_dir()+"/","") == "customnpcs":
		return dir
	print(dir_search.scan_directory_for_folders(dir))
	if dir_search.scan_directory_for_folders(dir).has("customnpcs"):
		if directory.dir_exists(dir+"/customnpcs/dialogs"):
			return dir+"/customnpcs"
	return ""

	
func _on_Open_Environment_pressed():
	$Panel/FileDialog.popup()


func _on_FileDialog_confirmed():
	print("FileDialog_confirmed")
	



func _on_FileDialog_dir_selected(path):
	var valid_path = find_valid_customnpcs_dir(path)
	if valid_path == "":
		chosen_dir = path
		$Panel/InvalidFolderWarning.popup()
	else:
		change_to_editor(valid_path)


		


func _on_Cancel_button_up():
	$Panel/FileDialog.popup()
	$Panel/InvalidFolderWarning.visible = false


func _on_Confirm_pressed():
	var dir = Directory.new()
	dir.open(chosen_dir)
	if chosen_dir.replace(chosen_dir.get_base_dir(),"") == "/customnpcs":
		dir.make_dir(chosen_dir+"/dialogs")
	else:
		dir.make_dir(chosen_dir+"/customnpcs")
		dir.make_dir(chosen_dir+"/customnpcs/dialogs")
	change_to_editor(chosen_dir+"/customnpcs")
