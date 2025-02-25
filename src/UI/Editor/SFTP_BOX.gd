extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	if CurrentEnvironment.sftp_client:
		$SftpConnection.self_modulate = Color(1,1,1,1)
		$SftpDirectory.self_modulate = Color(1,1,1,1)
		$SFTPLabel.self_modulate = Color(1,1,1,1)
		$SftpConnection.text = "Server: "+CurrentEnvironment.sftp_client.ConnectionInfoDict["username"]+"@"+CurrentEnvironment.sftp_client.ConnectionInfoDict["hostname"]
		$SftpDirectory.text = "Working SFTP Directory: "+CurrentEnvironment.sftp_directory
		CurrentEnvironment.sftp_client.connect("SftpNotConnected",Callable(self,"_on_sftp_disconnected"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_sftp_disconnected():
	$SftpConnection.text = "SFTP Status : Disconnected"
	$Button.visible = true
	pass


func _on_button_pressed():
	CurrentEnvironment.sftp_client.ConnectToSftpServer(CurrentEnvironment.sftp_client.ConnectionInfoDict)
	if CurrentEnvironment.sftp_client.Connected:
		CurrentEnvironment.sftp_client.ChangeDirectory(CurrentEnvironment.sftp_client.remote_file_directory)
		$SftpConnection.text = "SFTP Status : Connected"
		
