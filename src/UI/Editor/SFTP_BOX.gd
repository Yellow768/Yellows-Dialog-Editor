extends VBoxContainer
signal failed_to_reconnect
signal reconnected
signal resync_cache
signal sftp_done


@export var status_label_path : NodePath
@export var remote_dir_label_path : NodePath
@export var server_label_path : NodePath
@export var toggle_connection_path : NodePath
@export var resync_path : NodePath

@onready var StatusLabel : RichTextLabel = get_node(status_label_path)
@onready var RemoteDirLabel : Label = get_node(remote_dir_label_path)
@onready var ServerLabel : Label = get_node(server_label_path)
@onready var ToggleConnection : Button = get_node(toggle_connection_path)
@onready var Resync : Button = get_node(resync_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	if CurrentEnvironment.sftp_client:
		self.modulate = Color(1,1,1,1)
		ServerLabel.text = CurrentEnvironment.sftp_client.ConnectionInfoDict["username"]+"@"+CurrentEnvironment.sftp_client.ConnectionInfoDict["hostname"]
		ServerLabel.tooltip_text = CurrentEnvironment.sftp_client.ConnectionInfoDict["username"]+"@"+CurrentEnvironment.sftp_client.ConnectionInfoDict["hostname"]
		RemoteDirLabel.text = CurrentEnvironment.sftp_directory
		RemoteDirLabel.tooltip_text = CurrentEnvironment.sftp_directory
		CurrentEnvironment.sftp_client.connect("SftpNotConnected",Callable(self,"_on_sftp_disconnected"))


func _on_sftp_disconnected():
	update_connected_labels(false)

func update_connected_labels(is_connected):
	var text
	match is_connected:
		true:
			text = tr("SFTP_CONNECTED")+"[img]res://Assets/UI Textures/Icon Font/globe-earth-line.png[/img]"
			ToggleConnection.text = "Disconnect"
			Resync.disabled = false
		false:
			text = tr("SFTP_DISCONNECTED")+"[img]res://Assets/UI Textures/Icon Font/globe-grid-line.png[/img]"
			ToggleConnection.text = "Connect"
			Resync.disabled = true
	StatusLabel.text = text

func _on_button_pressed():
	if CurrentEnvironment.sftp_client.IsConnected():
		CurrentEnvironment.sftp_client.Disconnect()
		update_connected_labels(false)
	else:
		var attempt_to_connect_result = CurrentEnvironment.sftp_client.ConnectToSftpServer(CurrentEnvironment.sftp_client.ConnectionInfoDict)
		if attempt_to_connect_result == "OK":
			CurrentEnvironment.sftp_client.ChangeDirectory(CurrentEnvironment.sftp_client.remote_file_directory)
			update_connected_labels(true)
			emit_signal("reconnected")
		
		else:
			emit_signal("failed_to_reconnect")
			push_error(attempt_to_connect_result)
		
		


func _on_timer_timeout():
	if CurrentEnvironment.sftp_client:
		CurrentEnvironment.sftp_client.CheckConnection()


func delete_cached_dir(directory):
	var dir := DirAccess.open(directory)
	
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name : String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				delete_cached_dir(directory+"/"+file_name)
			dir.remove(file_name)
			file_name = dir.get_next()
	

	


func _on_resync_button_pressed():
	if !CurrentEnvironment.sftp_client.IsConnected():
		return
	var sftp_background_darkener
	sftp_background_darkener = ColorRect.new()
	sftp_background_darkener.color = Color(0,0,0,.5)
	
	
	delete_cached_dir(CurrentEnvironment.current_directory)
	var Progress = load("res://src/UI/Util/EditorProgressBar.tscn").instantiate()
	get_parent().get_parent().get_parent().add_child(Progress)
	
	get_parent().get_parent().add_child(sftp_background_darkener)
	sftp_background_darkener.size = Vector2(DisplayServer.window_get_size())
	sftp_background_darkener.set_anchors_preset(Control.PRESET_FULL_RECT)
	CurrentEnvironment.sftp_client.connect("ProgressMaxChanged",Callable(Progress,"set_max_progress"))
	CurrentEnvironment.sftp_client.connect("Progress",Callable(Progress,"set_progress"))
	CurrentEnvironment.sftp_client.connect("ProgressItemChanged",Callable(Progress,"set_current_item_text"))
	CurrentEnvironment.sftp_client.connect("ProgressDone",Callable(self,"emit_signal").bind("sftp_done"))	
	Progress.set_overall_task_name(tr("DOWNLOADING_DIALOGS"))
	CurrentEnvironment.sftp_client.DownloadDirectory(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/dialogs",CurrentEnvironment.current_dialog_directory,true,true)
	await self.sftp_done
	if CurrentEnvironment.sftp_client.Exists(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/quests"):
		Progress.set_overall_task_name(tr("DOWNLOADING_QUESTS"))
		DirAccess.make_dir_recursive_absolute(CurrentEnvironment.sftp_client.local_file_cache+"/quests")
		CurrentEnvironment.sftp_client.DownloadDirectory(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/quests",CurrentEnvironment.current_directory+"/quests",false,true)
		await self.sftp_done
	if CurrentEnvironment.sftp_client.Exists(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/factions.dat"):
		Progress.set_overall_task_name(tr("DOWNLOADING_FACTIONS"))
		CurrentEnvironment.sftp_client.DownloadFile(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/factions.dat",CurrentEnvironment.current_directory)
		await self.sftp_done
	CurrentEnvironment.sftp_client.disconnect("ProgressDone",Callable(self,"emit_signal"))
	Progress.queue_free()
	emit_signal("resync_cache")
	sftp_background_darkener.queue_free()
