extends TextEdit


func _ready():
	pass


func _on_Button_toggled(button_pressed):
	if button_pressed:
		rect_min_size.y = 125
		rect_size.y = 125
		$Button.text = "^"
	if !button_pressed:
		rect_min_size.y = 25
		rect_size.y = 25
		$Button.text = "v"
