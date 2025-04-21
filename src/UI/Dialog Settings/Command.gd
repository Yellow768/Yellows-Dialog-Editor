extends HBoxContainer

signal text_changed
signal command_request_deletion
var text : set = set_text, get = get_text

@export var min_size := 25
@export var max_size := 125

func _ready():
	pass

func get_text():
	return $ExpandableLineEdit.get_text()

func set_text(new_text : String):
	$ExpandableLineEdit.set_text(new_text)


func _on_expandable_line_edit_text_changed():
	emit_signal("text_changed",self)


func _on_button_pressed():
	emit_signal("command_request_deletion",self)
