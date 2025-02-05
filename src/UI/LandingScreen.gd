extends Control
const user_settings_path := "user://user_settings.cfg"


@export var invalid_folder_path : NodePath
@export var prev_dir_tree_path : NodePath
@export var sftp_starter_path : NodePath


@onready var InvalidFolder : Popup = get_node(invalid_folder_path)
@onready var PrevDirTree : Tree = get_node(prev_dir_tree_path)
@onready var SftpStarter : PanelContainer = get_node(sftp_starter_path)

var chosen_dir : String

func _ready():
	get_tree().auto_accept_quit = true
	DisplayServer.window_set_title("Home | CNPC Dialog Editor")
	OS.low_processor_usage_mode = true
	get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED
	get_window().min_size = Vector2(1280,720)
	var config := ConfigFile.new()
	config.load(user_settings_path)
	var tree_root = PrevDirTree.create_item()
	PrevDirTree.hide_root = true
	for dir in JSON.parse_string(config.get_value("prev_dirs","dir_array","[]")):
		var new_file = PrevDirTree.create_item(tree_root)
		var text : String
		if dir is Dictionary:
			
			if dir.has("SSH"):
				text = dir["SSH"]["username"]+"@"+dir["SSH"]["hostname"]+":"+str(dir["SSH"]["port"]) +" || "+dir["SSH"]["directory"]
				new_file.set_metadata(0,dir["SSH"])
				new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/globe-earth-line.png"))
			else:
				text = dir["Path"]
				new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/folder-line.png"))
		else:
			text = dir
			new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/folder-line.png"))
		new_file.add_button(1,load("res://Assets/UI Textures/Icon Font/delete-bin-line.svg"),-1,false,"Remove")
		new_file.set_tooltip_text(0,text)
		if text.length() > 90:
			new_file.set_text(0,text.left(87)+"...")
		else:
			new_file.set_text(0,text)
		
	$Panel/FileDialog.current_dir = GlobalDeclarations.default_user_directory
	$Panel/FileDialog.set_ok_button_text(tr("FILE_SELECT_FOLDER"))
	print("Launched Succesfully")
	


func change_to_editor(directory : String) -> void:
	if DirAccess.dir_exists_absolute(directory):
		var editor = load("res://src/UI/Editor/MainEditor.tscn").instantiate()
		CurrentEnvironment.current_directory = directory
		CurrentEnvironment.load_faction_data()
		get_parent().add_child(editor)
		DisplayServer.window_set_title(directory+" | CNPC Dialog Editor")
		print("Loaded "+directory)
		queue_free()
	else:
		var tween := get_tree().create_tween()
		$InvalidDirectory.modulate = Color(1,1,1,1)
		tween.tween_property($InvalidDirectory,"modulate",Color(1,1,1,0),2).set_delay(1)
		printerr("Directory does not exist")
	
func add_directory_to_config(directory : String) -> void:
	var config = ConfigFile.new()
	config.load(user_settings_path)
	var dir_array = JSON.parse_string(config.get_value("prev_dirs","dir_array","[]"))
	dir_array.erase(directory)
	dir_array.erase({"Path":directory})
	dir_array.push_front({"Path":directory})
	config.set_value("prev_dirs","dir_array",JSON.new().stringify((dir_array)))
	config.save(user_settings_path)
	
func add_ssh_to_config(hostname : String,username: String, port : int,directory: String,local_path : String):
	var config = ConfigFile.new()
	config.load(user_settings_path)
	var dir_array = JSON.parse_string(config.get_value("prev_dirs","dir_array","[]"))
	for dir in dir_array:
		if dir["SSH"]["hostname"] == hostname && dir["SSH"]["username"] == username && dir["SSH"]["port"] == port && dir["SSH"]["directory"] == directory:
			dir_array.erase(dir)
	dir_array.push_front({"SSH":{"hostname":hostname,"username":username,"port":port,"directory":directory,"path":local_path}})
	config.set_value("prev_dirs","dir_array",JSON.new().stringify((dir_array)))
	config.save(user_settings_path)

func find_valid_customnpcs_dir(dir : String) -> String:
	var directory := DirAccess.open(dir)
	var dir_search := DirectorySearch.new()

	if dir.replace(dir.get_base_dir()+"/","") == "customnpcs":
		return dir
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
		InvalidFolder.popup_centered()
		InvalidFolder.connect("confirm_button_pressed",Callable(self,"_on_Confirm_pressed"))
		InvalidFolder.connect("cancel_button_pressed",Callable(self,"_on_Cancel_button_up"))
	else:
		add_directory_to_config(valid_path)
		change_to_editor(valid_path)


		


func _on_Cancel_button_up():
	$Panel/FileDialog.popup_centered()
	InvalidFolder.hide()
	InvalidFolder.disconnect("confirm_button_pressed",Callable(self,"_on_Confirm_pressed"))
	InvalidFolder.disconnect("cancel_button_pressed",Callable(self,"_on_Cancel_button_up"))


func _on_Confirm_pressed():
	var dir := DirAccess.open(chosen_dir)
	if chosen_dir.replace(chosen_dir.get_base_dir(),"") == "/customnpcs":
		dir.make_dir(chosen_dir+"/dialogs")
	else:
		dir.make_dir(chosen_dir+"/customnpcs")
		dir.make_dir(chosen_dir+"/customnpcs/dialogs")
	add_directory_to_config(chosen_dir+"/customnpcs")
	change_to_editor(chosen_dir+"/customnpcs")


func _on_file_dialog_visibility_changed():
	$Panel/FileDialog.set_ok_button_text(tr("FILE_SELECT_FOLDER"))


func _on_sftp_tester_sftp_directory_chosen(path):
	add_ssh_to_config(CurrentEnvironment.sftp_hostname,CurrentEnvironment.sftp_username,CurrentEnvironment.sftp_port,CurrentEnvironment.sftp_directory,path)
	change_to_editor(path)


func _on_prev_dirs_tree_item_activated():
	var selected = PrevDirTree.get_selected()
	if selected.get_metadata(0) == null:
		add_directory_to_config(PrevDirTree.get_selected().get_text(0))
		change_to_editor(PrevDirTree.get_selected().get_text(0))
	else:
		var ssh_data = selected.get_metadata(0)
		var PasswordEnter = load("res://src/UI/Util/TextEnterConfirmTemplate.tscn").instantiate()
		PasswordEnter.set_secret(true)
		PasswordEnter.title = "Enter Password for "+ssh_data["username"]+"@"+ssh_data["hostname"]
		PasswordEnter.set_placeholder_text("Password")
		get_parent().add_child(PasswordEnter)
		PasswordEnter.position = Vector2(DisplayServer.window_get_size().x/2,DisplayServer.window_get_size().y/2)
		PasswordEnter.connect("confirmed_send_text",Callable(SftpStarter,"connect_to_established_sftp").bind(ssh_data["username"],ssh_data["hostname"],ssh_data["port"],ssh_data["directory"],ssh_data["path"]))


func _on_prev_dirs_tree_button_clicked(item, column, id, mouse_button_index):
	var config = ConfigFile.new()
	config.load(user_settings_path)
	var dir_array = JSON.parse_string(config.get_value("prev_dirs","dir_array","[]"))
	for dir in dir_array:
		var ssh_info = item.get_metadata(0)
		if !dir is Dictionary || !dir.has("SSH") || ssh_info == null || !ssh_info.has("hostname"):
			continue
		if dir["SSH"]["hostname"] == ssh_info["hostname"] && dir["SSH"]["username"] == ssh_info["username"] && dir["SSH"]["port"] == ssh_info["port"]:
			dir_array.erase(dir)
	dir_array.erase(item.get_tooltip_text(0))
	dir_array.erase({"Path":item.get_tooltip_text(0)})
	config.set_value("prev_dirs","dir_array",JSON.new().stringify((dir_array)))
	config.save(user_settings_path)
	item.free()


