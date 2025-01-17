extends PanelContainer
@export var username_textbox_path : NodePath
@export var hostname_textbox_path : NodePath
@export var port_spinbox_path : NodePath
@export var password_textbox_path : NodePath
@export var connect_button_path : NodePath
@export var tree_path : NodePath
@export var invalid_directory_path : NodePath

@onready var UsernameTextEdit : LineEdit = get_node(username_textbox_path)
@onready var HostnameTextEdit : LineEdit = get_node(hostname_textbox_path)
@onready var PortSpinBox : SpinBox = get_node(port_spinbox_path)
@onready var PasswordTextEdit : LineEdit = get_node(password_textbox_path)
@onready var ConnectButton : Button = get_node(connect_button_path)
@onready var FileTree : Tree = get_node(tree_path)
@onready var InvalidDirectory : Popup = get_node(invalid_directory_path)

var tree_root
var forward_dir = []

signal sftp_directory_chosen

# Called when the node enters the scene tree for the first time.
func _ready():
	tree_root = FileTree.create_item()
	FileTree.hide_root = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


var files_in_sftp_directory : Dictionary

func _on_button_pressed():
	CurrentEnvironment.create_sftpclient()
	CurrentEnvironment.sftp_client.ConnectToSftpServer(UsernameTextEdit.text,HostnameTextEdit.text,PortSpinBox.value,PasswordTextEdit.text)
	CurrentEnvironment.sftp_hostname = HostnameTextEdit.text
	CurrentEnvironment.sftp_username = UsernameTextEdit.text
	files_in_sftp_directory = CurrentEnvironment.sftp_client.ListDirectory(CurrentEnvironment.sftp_client.GetCurrentDirectory())
	for file in files_in_sftp_directory:
		if (file == "." || file == ".."):
			continue
		var new_file = FileTree.create_item(tree_root)
		new_file.set_text(0,file)
		if files_in_sftp_directory[file]:
			new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/folder-line.svg"))
		else:
			new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/file-line.svg"))
		
		
	


func change_tree_directory(text):
		CurrentEnvironment.sftp_client.ChangeDirectory(text)
		FileTree.deselect_all()
		var item = tree_root.get_first_child()
		var item_to_delete = tree_root.get_first_child()
		for tree_item in tree_root.get_children():
			tree_item.free()
		files_in_sftp_directory = CurrentEnvironment.sftp_client.ListDirectory(CurrentEnvironment.sftp_client.GetCurrentDirectory())
		for file in files_in_sftp_directory:
			if (file == "." || file == ".."):
				continue
			var new_file = FileTree.create_item(tree_root)
			new_file.set_text(0,file)
			if files_in_sftp_directory[file]:
				new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/folder-line.svg"))
			else:
				new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/file-line.svg"))

func sftp_find_customnpcs_dir():
	if FileTree.get_selected().get_text(0) == "customnpcs":
		if CurrentEnvironment.sftp_client.Exists(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/customnpcs/dialogs"):
			return  CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/customnpcs"		
	if CurrentEnvironment.sftp_client.Exists(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/"+FileTree.get_selected().get_text(0)+"/customnpcs"):
		if CurrentEnvironment.sftp_client.Exists(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/"+FileTree.get_selected().get_text(0)+"/customnpcs/dialogs"):
			return CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/"+FileTree.get_selected().get_text(0)+"/customnpcs"
	return ""


func _on_select_folder_pressed():
	var remote_path_to_download_from = sftp_find_customnpcs_dir()
	if remote_path_to_download_from == "":
		remote_path_to_download_from = CurrentEnvironment.sftp_client.GetCurrentDirectory()
		InvalidDirectory.popup_centered()
		InvalidDirectory.connect("confirm_button_clicked",Callable(self,"make_local_cache_and_download_sftp"),remote_path_to_download_from)
		InvalidDirectory.connect("cancel_button_clicked",Callable(self,"disconnect_invalid_directory"))
	else:
		make_local_cache_and_download_sftp(remote_path_to_download_from)	

	
	
func make_local_cache_and_download_sftp(remote_path_to_download_from):
	var local_cache_directory_path = OS.get_user_data_dir()+"/sftp_cache/"+CurrentEnvironment.sftp_username+"@"+CurrentEnvironment.sftp_hostname
	DirAccess.make_dir_recursive_absolute(local_cache_directory_path)
	if CurrentEnvironment.sftp_client.Exists(remote_path_to_download_from+"/dialogs"):
		DirAccess.make_dir_recursive_absolute(local_cache_directory_path+"/customnpcs/dialogs")
		CurrentEnvironment.sftp_client.DownloadDirectory(remote_path_to_download_from+"/dialogs",local_cache_directory_path+"/customnpcs/dialogs")
	if CurrentEnvironment.sftp_client.Exists(remote_path_to_download_from+"/quests"):
		DirAccess.make_dir_recursive_absolute(local_cache_directory_path+"/customnpcs/dialogs")
		CurrentEnvironment.sftp_client.DownloadDirectory(remote_path_to_download_from+"/quests",local_cache_directory_path+"/customnpcs/quests")
	if CurrentEnvironment.sftp_client.Exists(remote_path_to_download_from+"/factions.dat"):
		CurrentEnvironment.sftp_client.DownloadFile(remote_path_to_download_from+"/factions.dat",local_cache_directory_path+"/customnpcs/")
	CurrentEnvironment.sftp_client.ChangeDirectory(remote_path_to_download_from)
	sftp_directory_chosen.emit(local_cache_directory_path+"/customnpcs")
	
func disconnect_invalid_directory():
	InvalidDirectory.disconect("confirm_button_clicked",Callable(self,"make_local_cache_and_download_sftp"))
	InvalidDirectory.disconect("cancel_button_clicked",Callable(self,"disconnect_invalid_directory"))
	InvalidDirectory.hide()


func _on_back_pressed():
	forward_dir.append(CurrentEnvironment.sftp_client.GetCurrentDirectory())
	change_tree_directory("..")


func _on_tree_item_activated():
	change_tree_directory(FileTree.get_selected().get_text(0))


func _on_forward_pressed():
	change_tree_directory(forward_dir.pop_front())
	


func _on_connect_to_sftp_server_pressed():
	visible = true


func _on_close_button_pressed():
	visible = false
