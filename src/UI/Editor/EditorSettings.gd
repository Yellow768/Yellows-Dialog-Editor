extends Panel

@onready var keybind_scene = load("res://src/UI/Editor/keybind.tscn")


@export var ConnectionDistanceNodePath : NodePath
@export var HoldShiftCheckPath : NodePath

@onready var hide_connection_slider : HSlider= get_node(ConnectionDistanceNodePath)
@onready var hold_shift_check :Button= get_node(HoldShiftCheckPath)



func _ready():
	hide_connection_slider.value = GlobalDeclarations.hide_connection_distance
	hold_shift_check.button_pressed = GlobalDeclarations.hold_shift_for_individual_movement
	for action in GlobalDeclarations.actions:
		var keybind_instance = keybind_scene.instantiate()
		keybind_instance.assign_action(action)
		$VBoxContainer/ScrollContainer/KeyBinds.add_child(keybind_instance)
	
	
	
	
func _on_h_slider_value_changed(value : int):
	hide_connection_slider.get_node("ValueEdit").text = str(value)
	GlobalDeclarations.hide_connection_distance = value


func _on_value_edit_text_submitted(new_text : String):
	hide_connection_slider.value = int(new_text)
	


func _on_resetbutton_pressed():
	hide_connection_slider.value = 1000


func _on_button_pressed():
	get_tree().paused = false
	GlobalDeclarations.save_config()
	visible = false
	


func _on_editor_settings_button_pressed():
	visible = true
	get_tree().paused = true


func _on_check_button_toggled(button_pressed):
	GlobalDeclarations.hold_shift_for_individual_movement = button_pressed


func _on_undo_button_toggled(button_pressed):
	GlobalDeclarations.undo_enabled = button_pressed
