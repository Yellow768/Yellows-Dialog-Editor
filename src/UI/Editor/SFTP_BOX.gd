extends VBoxContainer
signal failed_to_reconnect
signal reconnected

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
