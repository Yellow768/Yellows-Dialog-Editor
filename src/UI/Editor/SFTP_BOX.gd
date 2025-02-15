extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	if CurrentEnvironment.sftp_client:
		$SftpConnection.self_modulate = Color(1,1,1,1)
		$SftpDirectory.self_modulate = Color(1,1,1,1)
		$SFTPLabel.self_modulate = Color(1,1,1,1)
		$SftpConnection.text = CurrentEnvironment.sftp_client.ConnectionInfoDict["username"]+"@"+CurrentEnvironment.sftp_client.ConnectionInfoDict["hostname"]
		$SftpDirectory.text = CurrentEnvironment.sftp_directory


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
