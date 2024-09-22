extends HBoxContainer

var display : set = set_display
var id : set = set_id
var value : set = set_value


func set_display(value):
	$DisplayLineEdit.text = value

func set_id(value) :
	$IDLineEdit.text = value
	
func set_value(value):
	$SpinBox.value = value

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
