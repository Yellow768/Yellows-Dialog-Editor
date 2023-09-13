extends AnimationPlayer

func _on_InformationPanel_show_information_panel():
	var tween = Tween.new()
	tween.interpolate_property(get_node("../InformationPanel"),"rect_position:x",OS.window_size.x-450,OS.window_size.x,.2,Tween.TRANS_LINEAR)
	add_child(tween)
	tween.start()
	#tween.connect("tween_completed",tween,"queue_free")
	



func _on_InformationPanel_hide_information_panel():
	var tween = Tween.new()
	tween.interpolate_property(get_node("../InformationPanel"),"rect_position:x",OS.window_size.x,OS.window_size.x-450,.2,Tween.TRANS_LINEAR)
	add_child(tween)
	tween.start()
	#tween.connect("tween_completed",tween,"queue_free")


func _on_CategoryPanel_reveal_category_panel():
	play("CategoryPanel")


func _on_CategoryPanel_hide_category_panel():
	play_backwards("CategoryPanel")


func _on_TopPanel_save_category_request():
	play("SaveFlash")


func _on_CategoryPanel_category_succesfully_saved(cname):
	var save_string = "Category %s saved..."
	$SaveLAbel.text = save_string % cname
	play("SaveFlash")


func _on_CategoryPanel_category_failed_save():
	play("FailFlash")


func _on_CategoryPanel_category_export_failed(cname):
	$ExportFail.text = "Category failed to export..."
	play("ExportFailed")


func _on_CategoryPanel_category_succesfully_exported(cname):
	var string = "Category %s succesfully exported..."
	$ExportLabel.text = string % cname
	play("ExportSuccess")


func _on_InformationPanel_availability_mode_entered() -> void:
	$AvailabilityMode.visible = true
	$AvailabilityMode/Animation.play("AvailabilityMode")


func _on_InformationPanel_availability_mode_exited() -> void:
	$AvailabilityMode.visible = false
	$AvailabilityMode/Animation.stop(true)
	



