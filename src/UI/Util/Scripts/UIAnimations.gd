extends Node

@export var InformationPanel: NodePath
@export var CategoryPanel: NodePath

func _ready():
	if CurrentEnvironment.sftp_client:
		CurrentEnvironment.sftp_client.connect("SftpError",Callable(self,"_on_sftp_error"))
		CurrentEnvironment.sftp_client.connect("SftpNotConnected",Callable(self,"_on_sftp_not_connected"))
		CurrentEnvironment.sftp_client.connect("SftpDisconnected",Callable(self,"_on_sftp_disconnected"))
		CurrentEnvironment.sftp_client.connect("SftpConnected",Callable(self,"_on_sftp_conneceted"))

func tween(node,property,to,speed,type):
	var tweener = get_tree().create_tween()
	tweener.tween_property(node,property,to,speed).set_trans(type)

func add_notification(text,color = Color(1,1,1)):
	var new_notif = GlobalDeclarations.NOTIFICATION.instantiate()
	new_notif.set_notification_text(text,color)
	$NotificationCenter.add_child(new_notif)
	$NotificationCenter.move_child(new_notif,0)
	
	
func _on_InformationPanel_show_information_panel():
	tween(get_node(InformationPanel),"position:x",get_window().size.x-450,.2,Tween.TRANS_LINEAR)

func _on_InformationPanel_hide_information_panel():
	tween(get_node(InformationPanel),"position:x",get_window().size.x,.2,Tween.TRANS_LINEAR)

func _on_CategoryPanel_reveal_category_panel():
	tween(get_node(CategoryPanel),"position:x",0,.2,Tween.TRANS_LINEAR)


func _on_CategoryPanel_hide_category_panel():
	tween(get_node(CategoryPanel),"position:x",-350,.2,Tween.TRANS_LINEAR)


func _on_TopPanel_save_category_request():
	add_notification(tr("SAVING"))
	


func _on_CategoryPanel_category_succesfully_saved(cname):
	var save_string = tr("SAVING")
	add_notification(save_string % cname)


func _on_CategoryPanel_category_failed_save(cname):
	add_notification(cname+" "+ tr("SAVE_FAILED"))
	


func _on_CategoryPanel_category_export_failed(cname):
	var fail_string := tr("EXPORT_FAILED")
	add_notification(fail_string % cname)


func _on_CategoryPanel_category_succesfully_exported(cname):
	var string := tr("EXPORTING")
	add_notification(string%cname)



func _on_availability_mode_entered() -> void:
	$AvailabilityMode.visible = true


func _on_availability_mode_exited() -> void:
	$AvailabilityMode.visible = false

	





func _on_information_panel_scanned_quests_and_factions():
	add_notification(tr("RESCANNED_QUEST_AND_FACTIONS"))



func _on_category_panel_saved_backups():
	add_notification(tr("SAVED_BACKUPS"))


func _on_category_panel_category_failed_sftp_save():
	add_notification(tr("Could not save ydec to SFTP Server (check logs)"))


func _on_category_panel_category_sftp_succesfully_saved():
	add_notification(tr("YDEC Saved to SFTP Server"))
	
func _on_sftp_error(error,message):
	add_notification(tr(message),Color(1,0,0))
	push_error(error)

func _on_sftp_not_connected():
	add_notification(tr("SFTP_ERROR_NOT_CONNECTED"),Color(1,0,0))
	push_error("No connection to SFTP server")


func _on_sftp_box_failed_to_reconnect():
	add_notification(tr("SFTP_ERROR_FAILED_RECONNECT"),Color(1,0,0))
	
func _on_sftp_disconnected():
	add_notification(tr("SFTP_NOTIF_DISCONNECTED"),Color(0,1,1))
	
func _on_sftp_connected():
	await get_tree().create_timer(1).timeout
	add_notification(tr("SFTP_NOTIF_CONNECTED"),Color(0,1,0))


func _on_sftp_box_reconnected():
	add_notification(tr("SFTP_NOTIF_DISCONNECTED"),Color(0,1,0))


func _on_undo_system_nothing_to_redo():
	add_notification(tr("NOTHING_REDO"))


func _on_undo_system_nothing_to_undo():
	add_notification(tr("NOTHING_UNDO"))
