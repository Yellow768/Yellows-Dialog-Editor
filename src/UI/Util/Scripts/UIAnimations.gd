extends AnimationPlayer


func _ready():
	play("Initial")




func _on_InformationPanel_show_information_panel():
	play_backwards("InformationPanel")
	



func _on_InformationPanel_hide_information_panel():
	play("InformationPanel")


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
