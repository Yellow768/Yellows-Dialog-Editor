extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/HBoxContainer/TextEdit.text = CurrentEnvironment.dialog_name_preset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_text_edit_text_changed():
	CurrentEnvironment.dialog_name_preset = $Panel/HBoxContainer/TextEdit.text


func _on_button_pressed():
	queue_free()
