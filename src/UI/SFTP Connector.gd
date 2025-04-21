extends PanelContainer
@export var username_textbox_path : NodePath
@export var hostname_textbox_path : NodePath
@export var port_spinbox_path : NodePath
@export var password_textbox_path : NodePath
@export var key_file_line_edit_path : NodePath
@export var key_file_hbox_path : NodePath
@export var key_passphrase_path : NodePath
@export var private_key_vbox_path : NodePath


@export var connect_button_path : NodePath
@export var tree_path : NodePath
@export var invalid_directory_path : NodePath
@export var select_button_path : NodePath
@export var path_line_edit_path : NodePath


@onready var UsernameTextEdit : LineEdit = get_node(username_textbox_path)
@onready var HostnameTextEdit : LineEdit = get_node(hostname_textbox_path)
@onready var PortSpinBox : SpinBox = get_node(port_spinbox_path)
@onready var PasswordTextEdit : LineEdit = get_node(password_textbox_path)
@onready var KeyFileLineEdit : LineEdit = get_node(key_file_line_edit_path)
@onready var KeyFileHbox : HBoxContainer = get_node(key_file_hbox_path)
@onready var KeyPassPhrase : LineEdit = get_node(key_passphrase_path)
@onready var PrivateKeyVbox : VBoxContainer = get_node(private_key_vbox_path)


@onready var ConnectButton : Button = get_node(connect_button_path)
@onready var FileTree : Tree = get_node(tree_path)
@onready var SelectButton : Button = get_node(select_button_path)
@onready var PathLineEdit : LineEdit = get_node(path_line_edit_path)

var tree_root
var forward_dirs = []
var previous_dirs = []
var connection_info = {}


enum CHOSEN_AUTH_METHOD{PASSWORD,KEY,KEY_AND_PASSPHRASE}

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
	var connecting_popup = AcceptDialog.new()
	connecting_popup.get_ok_button().set_visible(false)
	connecting_popup.add_theme_icon_override("close",Texture2D.new())
	connecting_popup.dialog_text = "\n"+tr("CONNECTING_TO_SFTP_SERVER")
	connecting_popup.title = ""
	get_parent().add_child(connecting_popup)
	connecting_popup.popup_centered()
	await get_tree().create_timer(1.0).timeout
	connection_info = {
		"username" : UsernameTextEdit.text,
		"hostname" : HostnameTextEdit.text, 
		"port":PortSpinBox.value
	}
	if PasswordTextEdit.text != "":
		connection_info["password"] = PasswordTextEdit.text
	if KeyFileLineEdit.text != "":
		connection_info["private_key_file"] = KeyFileLineEdit.text
	if KeyPassPhrase.text != "":
		connection_info["private_key_passphrase"] = KeyPassPhrase.text
	var connection_result = CurrentEnvironment.sftp_client.ConnectToSftpServer(connection_info)
	connecting_popup.queue_free()
	if connection_result != "OK":
		var failure_alert := AcceptDialog.new()
		get_parent().add_child(failure_alert)
		failure_alert.dialog_text = connection_result
		failure_alert.title = "SFTP Failed To Connect"
		failure_alert.popup_centered()
		return
	change_tree_directory(CurrentEnvironment.sftp_client.GetCurrentDirectory())
		
		
	


func change_tree_directory(text):
		SelectButton.disabled =true
		CurrentEnvironment.sftp_client.ChangeDirectory(text)
		PathLineEdit.text = CurrentEnvironment.sftp_client.GetCurrentDirectory()
		FileTree.deselect_all()
		for tree_item in tree_root.get_children():
			tree_item.free()
		files_in_sftp_directory = CurrentEnvironment.sftp_client.ListDirectory(CurrentEnvironment.sftp_client.GetCurrentDirectory())
		var sorted_file_names = files_in_sftp_directory.keys()
		sorted_file_names.sort()
		for file in sorted_file_names:
			if (file == "." || file == ".." || !files_in_sftp_directory[file]):
				continue
			var new_file = FileTree.create_item(tree_root)
			new_file.set_text(0,file)
			new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/folder-line.svg"))

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
		var InvalidPathConfirmDialog = ConfirmationDialog.new()
		InvalidPathConfirmDialog.get_label().text = tr("INVALID_CUSTOMNPCS_DIR")
		InvalidPathConfirmDialog.get_ok_button().text = tr("INVALID_CUSTOMNPCS_DIR_ACCEPT")
		InvalidPathConfirmDialog.connect("confirmed",Callable(self,"make_local_cache_and_download_sftp").bind(remote_path_to_download_from))
		add_child(InvalidPathConfirmDialog)
		InvalidPathConfirmDialog.popup_centered()
	else:
		
		make_local_cache_and_download_sftp(remote_path_to_download_from)	

	
	
func make_local_cache_and_download_sftp(remote_path_to_download_from):
	CurrentEnvironment.sftp_client.ChangeDirectory(remote_path_to_download_from)
	CurrentEnvironment.sftp_local_cache_directory = OS.get_user_data_dir()+"/sftp_cache/"+connection_info["username"]+"@"+connection_info["hostname"]+remote_path_to_download_from
	CurrentEnvironment.sftp_client.local_file_cache = OS.get_user_data_dir()+"/sftp_cache/"+connection_info["username"]+"@"+connection_info["hostname"]+remote_path_to_download_from		
	CurrentEnvironment.sftp_directory = remote_path_to_download_from
	DirAccess.make_dir_recursive_absolute(CurrentEnvironment.sftp_local_cache_directory)
	DirAccess.make_dir_recursive_absolute(CurrentEnvironment.sftp_local_cache_directory+"/dialogs")
	var Progress = load("res://src/UI/Util/EditorProgressBar.tscn").instantiate()
	get_parent().add_child(Progress)
	CurrentEnvironment.sftp_client.connect("ProgressMaxChanged",Callable(Progress,"set_max_progress"))
	CurrentEnvironment.sftp_client.connect("Progress",Callable(Progress,"set_progress"))
	CurrentEnvironment.sftp_client.connect("ProgressItemChanged",Callable(Progress,"set_current_item_text"))
	if CurrentEnvironment.sftp_client.Exists(remote_path_to_download_from+"/dialogs"):
		Progress.set_overall_task_name(tr("DOWNLOADING_DIALOGS"))
		CurrentEnvironment.sftp_client.DownloadDirectory(remote_path_to_download_from+"/dialogs",CurrentEnvironment.sftp_local_cache_directory+"/dialogs",true,true)
		await CurrentEnvironment.sftp_client.ProgressDone
	if CurrentEnvironment.sftp_client.Exists(remote_path_to_download_from+"/quests"):
		Progress.set_overall_task_name(tr("DOWNLOADING_QUESTS"))
		DirAccess.make_dir_recursive_absolute(CurrentEnvironment.sftp_local_cache_directory+"/quests")
		CurrentEnvironment.sftp_client.DownloadDirectory(remote_path_to_download_from+"/quests",CurrentEnvironment.sftp_local_cache_directory+"/quests",false,true)
		await CurrentEnvironment.sftp_client.ProgressDone
	if CurrentEnvironment.sftp_client.Exists(remote_path_to_download_from+"/factions.dat"):
		Progress.set_overall_task_name(tr("DOWNLOADING_FACTIONS"))
		CurrentEnvironment.sftp_client.DownloadFile(remote_path_to_download_from+"/factions.dat",CurrentEnvironment.sftp_local_cache_directory)
		await CurrentEnvironment.sftp_client.ProgressDone
	CurrentEnvironment.sftp_client.ChangeDirectory(remote_path_to_download_from)
	CurrentEnvironment.sftp_client.remote_file_directory = remote_path_to_download_from
	sftp_directory_chosen.emit(CurrentEnvironment.sftp_local_cache_directory,connection_info)
	
	
func connect_to_established_sftp(auth_data,remote_dir,local_dir):
	CurrentEnvironment.create_sftpclient()
	connection_info = auth_data.call()
	var connection_result = CurrentEnvironment.sftp_client.ConnectToSftpServer(connection_info)
	if connection_result == "OK":
		CurrentEnvironment.sftp_directory = remote_dir
		CurrentEnvironment.sftp_client.ChangeDirectory(remote_dir)
		CurrentEnvironment.sftp_local_cache_directory = OS.get_user_data_dir()+"/sftp_cache/"+connection_info["username"]+"@"+connection_info["hostname"]+remote_dir
		CurrentEnvironment.sftp_client.local_file_cache = OS.get_user_data_dir()+"/sftp_cache/"+connection_info["username"]+"@"+connection_info["hostname"]+remote_dir
		CurrentEnvironment.sftp_client.remote_file_directory = remote_dir
		if DirAccess.dir_exists_absolute(local_dir):
			sftp_directory_chosen.emit(local_dir,connection_info)
		else:
			make_local_cache_and_download_sftp(remote_dir)
	else:
		var failure_alert := AcceptDialog.new()
		get_parent().add_child(failure_alert)
		failure_alert.dialog_text = connection_result
		failure_alert.title = "SFTP Failed To Connect"
		failure_alert.popup_centered()
		

func _on_back_pressed():
	if previous_dirs.size() != 0:
		forward_dirs.append(CurrentEnvironment.sftp_client.GetCurrentDirectory())
		change_tree_directory(previous_dirs.pop_back())


func _on_tree_item_activated():
	previous_dirs.append(CurrentEnvironment.sftp_client.GetCurrentDirectory())
	forward_dirs.clear()
	change_tree_directory(FileTree.get_selected().get_text(0))


func _on_forward_pressed():
	if forward_dirs.size() != 0:
		previous_dirs.append(CurrentEnvironment.sftp_client.GetCurrentDirectory())
		change_tree_directory(forward_dirs.pop_back())
	
var sftp_background_darkener

func _on_connect_to_sftp_server_pressed():
	sftp_background_darkener = ColorRect.new()
	sftp_background_darkener.color = Color(0,0,0,.3)
	
	get_parent().add_child(sftp_background_darkener)
	get_parent().move_child(sftp_background_darkener,get_index()-1)
	sftp_background_darkener.size = Vector2(DisplayServer.window_get_size())
	sftp_background_darkener.set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = true


func _on_close_button_pressed():
	visible = false
	sftp_background_darkener.queue_free()
	for child in tree_root.get_children():
		child.free()
	PathLineEdit.text = ""
	HostnameTextEdit.text = ""
	PasswordTextEdit.text = ""
	UsernameTextEdit.text = ""
	PortSpinBox.value = 22
	if CurrentEnvironment.sftp_client:
		CurrentEnvironment.sftp_client.Disconnect()
		CurrentEnvironment.sftp_client.queue_free()
		CurrentEnvironment.sftp_client = null


func _on_tree_nothing_selected():
	SelectButton.disabled = true
	if FileTree.get_selected():
		FileTree.get_selected().deselect(0)


func _on_tree_item_selected():
	SelectButton.disabled = false


func _on_line_edit_text_submitted(new_text):
	if !CurrentEnvironment.sftp_client:
		PathLineEdit.text = ""
		return
	if CurrentEnvironment.sftp_client.Exists(new_text):
		previous_dirs.append(CurrentEnvironment.sftp_client.GetCurrentDirectory())
		change_tree_directory(new_text)
		forward_dirs.clear()
	else:
		PathLineEdit.text = CurrentEnvironment.sftp_client.GetCurrentDirectory()


func _on_auth_type_button_item_selected(index):
	match index:
		CHOSEN_AUTH_METHOD.PASSWORD:
			PasswordTextEdit.visible = true
			KeyFileHbox.visible = false
			KeyPassPhrase.visible = false
		CHOSEN_AUTH_METHOD.KEY:
			PasswordTextEdit.visible = false
			KeyFileHbox.visible = true
			KeyPassPhrase.visible = false
		CHOSEN_AUTH_METHOD.KEY_AND_PASSPHRASE:
			PasswordTextEdit.visible = false
			KeyFileHbox.visible = true
			KeyPassPhrase.visible = true


func _on_select_key_file_button_pressed():
	var key_file_dialog = FileDialog.new()
	key_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	key_file_dialog.title = "Select Private Key File"
	key_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	var ssh_dir
	if OS.has_feature("windows"):
		ssh_dir = OS.get_environment("USERPROFILE")+"/.ssh"
	else:
		ssh_dir = OS.get_environment("HOME")+"/.ssh"
	key_file_dialog.current_dir = ssh_dir
	key_file_dialog.connect("file_selected",Callable(self,"update_key_file_line_edit"))
	key_file_dialog.min_size = Vector2(DisplayServer.window_get_size())/2
	key_file_dialog.popup_centered()
	get_parent().add_child(key_file_dialog)
	key_file_dialog.popup_centered()

func update_key_file_line_edit(text):
	KeyFileLineEdit.text = text

func _on_key_file_button_toggled(button_pressed):
	PrivateKeyVbox.visible = button_pressed
