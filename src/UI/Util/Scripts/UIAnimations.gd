extends Node

@export var InformationPanel: NodePath
@export var CategoryPanel: NodePath

func tween(node,property,to,speed,type):
	var tweener = get_tree().create_tween()
	tweener.tween_property(node,property,to,speed).set_trans(type)

func add_notification(text):
	var new_notif = GlobalDeclarations.NOTIFICATION.instantiate()
	new_notif.set_notification_text(text)
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
