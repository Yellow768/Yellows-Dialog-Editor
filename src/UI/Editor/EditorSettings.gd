extends Panel

func _on_h_slider_value_changed(value : int):
	$HideConnectionDistance/HSlider/ValueEdit.text = str(value)
	GlobalDeclarations.hide_connection_distance = value


func _on_value_edit_text_submitted(new_text : String):
	$HideConnectionDistance/HSlider.value = int(new_text)
	


func _on_resetbutton_pressed():
	$HideConnectionDistance/HSlider.value = 1000


func _on_button_pressed():
	visible = false


func _on_editor_settings_button_pressed():
	visible = true
