extends Control
signal expanded
signal collapsed
signal text_changed
var text : set = set_text, get = get_text
var placeholder_text : set = set_placeholder_text, get = get_placeholder_text

@export var min_size := 25
@export var max_size := 125

func _ready():
	pass

func get_text():
	return $HBoxContainer/LineEdit.text

func set_text(new_text : String):
	$HBoxContainer/LineEdit.text = new_text

func get_placeholder_text():
	return $HBoxContainer/LineEdit.placeholder_text

func set_placeholder_text(new_text):
	$HBoxContainer/LineEdit.placeholder_text = new_text

func _on_Button_toggled(button_pressed : bool):
	if button_pressed:
		$HBoxContainer/LineEdit.custom_minimum_size.y = max_size
		$HBoxContainer/LineEdit.size.y = max_size
		custom_minimum_size.y = max_size
		size.y = max_size
		$HBoxContainer/Button.text = "^"
		grab_focus()
		expanded.emit()
	if !button_pressed:
		$HBoxContainer/LineEdit.custom_minimum_size.y = min_size
		$HBoxContainer/LineEdit.size.y = min_size
		custom_minimum_size.y = min_size
		size.y = min_size
		$HBoxContainer/Button.text = "v"
		collapsed.emit()


func _on_line_edit_text_changed():
	emit_signal("text_changed")
