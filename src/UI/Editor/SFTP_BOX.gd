extends VBoxContainer
signal failed_to_reconnect
signal reconnected
signal resync_cache
signal sftp_done

# Called when the node enters the scene tree for the first time.
func _ready():
	if CurrentEnvironment.sftp_client:
		$SftpConnection.self_modulate = Color(1,1,1,1)
		$SftpDirectory.self_modulate = Color(1,1,1,1)
		$SFTPLabel.self_modulate = Color(1,1,1,1)
		$SftpConnection.text = "Server: "+CurrentEnvironment.sftp_client.ConnectionInfoDict["username"]+"@"+CurrentEnvironment.sftp_client.ConnectionInfoDict["hostname"]
		$SftpDirectory.text = "Dir: "+CurrentEnvironment.sftp_directory
		CurrentEnvironment.sftp_client.connect("SftpNotConnected",Callable(self,"_on_sftp_disconnected"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_sftp_disconnected():
	$SFTPLabel.text = "SFTP Status : Disconnected"
	$Button.text = "Connect"
	pass


func _on_button_pressed():
	if CurrentEnvironment.sftp_client.IsConnected():
		CurrentEnvironment.sftp_client.Disconnect()
		$SFTPLabel.text = "SFTP Status : Disconnected"
		$Button.text = "Connect"
	else:
		var attempt_to_connect_result = CurrentEnvironment.sftp_client.ConnectToSftpServer(CurrentEnvironment.sftp_client.ConnectionInfoDict)
		if attempt_to_connect_result == "OK":
			CurrentEnvironment.sftp_client.ChangeDirectory(CurrentEnvironment.sftp_client.remote_file_directory)
			$SFTPLabel.text = "SFTP Status : Connected"
			$Button.text = "Disconnect"
			emit_signal("reconnected")
		else:
			emit_signal("failed_to_reconnect")
			push_error(attempt_to_connect_result)
		
		


func _on_timer_timeout():
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
	delete_cached_dir(CurrentEnvironment.current_directory)
	var Progress = load("res://src/UI/Util/EditorProgressBar.tscn").instantiate()
	get_parent().get_parent().get_parent().add_child(Progress)
	CurrentEnvironment.sftp_client.connect("ProgressMaxChanged",Callable(Progress,"set_max_progress"))
	CurrentEnvironment.sftp_client.connect("Progress",Callable(Progress,"set_progress"))
	CurrentEnvironment.sftp_client.connect("ProgressItemChanged",Callable(Progress,"set_current_item_text"))
	CurrentEnvironment.sftp_client.connect("ProgressDone",Callable(self,"emit_signal").bind("sftp_done"))	
	Progress.set_overall_task_name("Downloading Dialog Categories")
	CurrentEnvironment.sftp_client.DownloadDirectory(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/dialogs",CurrentEnvironment.current_dialog_directory,true,true)
	await self.sftp_done
	if CurrentEnvironment.sftp_client.Exists(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/quests"):
		Progress.set_overall_task_name("Downloading Quests")
		DirAccess.make_dir_recursive_absolute(CurrentEnvironment.sftp_local_cache_directory+"/quests")
		CurrentEnvironment.sftp_client.DownloadDirectory(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/quests",CurrentEnvironment.current_directory+"/quests",false,true)
		await self.sftp_done
	if CurrentEnvironment.sftp_client.Exists(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/factions.dat"):
		Progress.set_overall_task_name("Downloading Factions")
		CurrentEnvironment.sftp_client.DownloadFile(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/factions.dat",CurrentEnvironment.current_directory)
		await self.sftp_done
	CurrentEnvironment.sftp_client.disconnect("ProgressDone",Callable(self,"emit_signal"))
	Progress.queue_free()
	emit_signal("resync_cache")
