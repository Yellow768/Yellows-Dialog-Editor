extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func export():
	var json = {
		"id":$IDLineEdit.text,
		"display":$DisplayLineEdit.text,
		"value":$SpinBox.value
	}
	return JSON.stringify(json)


func _on_button_pressed():
	queue_free()
