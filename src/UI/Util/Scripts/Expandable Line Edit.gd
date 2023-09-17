extends TextEdit


func _ready():
	pass


func _on_Button_toggled(button_pressed : bool):
	if button_pressed:
		custom_minimum_size.y = 125
		size.y = 125
		$Button.text = "^"
	if !button_pressed:
		custom_minimum_size.y = 25
		size.y = 25
		$Button.text = "v"
