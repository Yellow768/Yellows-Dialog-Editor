extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_h_slider_value_changed(value):
	$HideConnectionDistance/HSlider/ValueEdit.text = str(value)
	GlobalDeclarations.hide_connection_distance = value


func _on_value_edit_text_submitted(new_text):
	$HideConnectionDistance/HSlider.value = int(new_text)
	


func _on_resetbutton_pressed():
	$HideConnectionDistance/HSlider.value = 1000


func _on_button_pressed():
	visible = false


func _on_editor_settings_button_pressed():
	visible = true
