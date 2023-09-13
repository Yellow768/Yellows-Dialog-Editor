extends Node

export(NodePath) var InformationPanel
export(NodePath) var CategoryPanel

func tween(node,property,from,to,speed,type):
	var tween = Tween.new()
	tween.interpolate_property(node,property,from,to,speed,type)
	add_child(tween)
	tween.start()
	tween.connect("tween_all_completed",tween,"queue_free")


func _on_InformationPanel_show_information_panel():
	tween(get_node(InformationPanel),"rect_position:x",get_node(InformationPanel).rect_position.x,OS.window_size.x-450,.2,Tween.TRANS_LINEAR)

func _on_InformationPanel_hide_information_panel():
	tween(get_node(InformationPanel),"rect_position:x",get_node(InformationPanel).rect_position.x,OS.window_size.x,.2,Tween.TRANS_LINEAR)

func _on_CategoryPanel_reveal_category_panel():
	tween(get_node(CategoryPanel),"rect_position:x",get_node(CategoryPanel).rect_position.x,0,.2,Tween.TRANS_LINEAR)


func _on_CategoryPanel_hide_category_panel():
	tween(get_node(CategoryPanel),"rect_position:x",get_node(CategoryPanel).rect_position.x,-350,.2,Tween.TRANS_LINEAR)


func _on_TopPanel_save_category_request():
	tween($SaveLabel,"modulate",Color(1,1,1,1),Color(1,1,1,0),.1,Tween.TRANS_BACK)
	


func _on_CategoryPanel_category_succesfully_saved(cname):
	var save_string = "Category %s saved..."
	$SaveLabel.text = save_string % cname
	tween($SaveLabel,"modulate",Color(1,1,1,1),Color(1,1,1,0),1,Tween.TRANS_EXPO)


func _on_CategoryPanel_category_failed_save():
	tween($SaveFail,"modulate",Color(1,1,1,1),Color(1,1,1,0),1,Tween.TRANS_EXPO)
	


func _on_CategoryPanel_category_export_failed(cname):
	tween($ExportFail,"modulate",Color(1,1,1,1),Color(1,1,1,0),1,Tween.TRANS_EXPO)


func _on_CategoryPanel_category_succesfully_exported(cname):
	var string = "Category %s succesfully exported..."
	$Export.text = string % cname
	tween($Export,"modulate",Color(1,1,1,1),Color(1,1,1,0),1,Tween.TRANS_EXPO)


func _on_InformationPanel_availability_mode_entered() -> void:
	$AvailabilityMode.visible = true


func _on_InformationPanel_availability_mode_exited() -> void:
	$AvailabilityMode.visible = false

	



