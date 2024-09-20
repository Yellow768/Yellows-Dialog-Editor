extends Node

@export var InformationPanel: NodePath
@export var CategoryPanel: NodePath

func tween(node,property,to,speed,type):
	var tweener = get_tree().create_tween()
	tweener.tween_property(node,property,to,speed).set_trans(type)


func _on_InformationPanel_show_information_panel():
	tween(get_node(InformationPanel),"position:x",get_window().size.x-450,.2,Tween.TRANS_LINEAR)

func _on_InformationPanel_hide_information_panel():
	tween(get_node(InformationPanel),"position:x",get_window().size.x,.2,Tween.TRANS_LINEAR)

func _on_CategoryPanel_reveal_category_panel():
	tween(get_node(CategoryPanel),"position:x",0,.2,Tween.TRANS_LINEAR)


func _on_CategoryPanel_hide_category_panel():
	tween(get_node(CategoryPanel),"position:x",-350,.2,Tween.TRANS_LINEAR)


func _on_TopPanel_save_category_request():
	$SaveLabel.modulate = Color(1,1,1,1)
	tween($SaveLabel,"modulate",Color(1,1,1,0),.1,Tween.TRANS_BACK)
	


func _on_CategoryPanel_category_succesfully_saved(cname):
	var save_string := tr("SAVING")
	$SaveLabel.text = save_string % cname
	$SaveLabel.modulate = Color(1,1,1,1)
	tween($SaveLabel,"modulate",Color(1,1,1,0),1,Tween.TRANS_EXPO)


func _on_CategoryPanel_category_failed_save():
	$SaveFail.modulate = Color(1,1,1,1)
	tween($SaveFail,"modulate",Color(1,1,1,0),1,Tween.TRANS_EXPO)
	


func _on_CategoryPanel_category_export_failed(cname):
	var fail_string := tr("EXPORT_FAILED")
	$ExportLabel.modulate = Color(1,1,1,1)
	$ExportLabel.text = fail_string % cname
	tween($ExportFail,"modulate",Color(1,1,1,0),1,Tween.TRANS_EXPO)


func _on_CategoryPanel_category_succesfully_exported(cname):
	var string := tr("EXPORTING")
	$Export.text = string % cname
	$Export.modulate = Color(1,1,1,1)
	tween($Export,"modulate",Color(1,1,1,0),1,Tween.TRANS_EXPO)



func _on_availability_mode_entered() -> void:
	$AvailabilityMode.visible = true


func _on_availability_mode_exited() -> void:
	$AvailabilityMode.visible = false

func _on_information_panel_scanned_quests_and_factions():
	$Rescan.tr("Scanned Quests and Factions")
	$Rescan.modulate = Color(1,1,1,1)
	tween($Rescan,"modulate",Color(1,1,1,0),1,Tween.TRANS_EXPO)
