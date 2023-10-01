extends TextEdit
signal expanded
signal collapsed

@export var min_size := 25
@export var max_size := 125

func _ready():
	pass


func _on_Button_toggled(button_pressed : bool):
	if button_pressed:
		custom_minimum_size.y = max_size
		size.y = 125
		$Button.text = "^"
		grab_focus()
		expanded.emit()
	if !button_pressed:
		custom_minimum_size.y = min_size
		size.y = 25
		$Button.text = "v"
		collapsed.emit()
