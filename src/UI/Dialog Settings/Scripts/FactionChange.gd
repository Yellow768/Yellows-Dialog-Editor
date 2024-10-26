extends Control

signal faction_id_changed
signal faction_points_changed
signal faction_change_request_deletion

var faction_data := {}
@export var allow_deletion := true
func _ready():
	$Panel/HBoxContainer/ChooseFaction.load_faction_data(CurrentEnvironment.faction_dict)
	$Panel/HBoxContainer/Factionpoints.prefix = "+"
	$Panel/HBoxContainer/Factionpoints.suffix = tr("POINTS_ABBRV")

func load_faction_data(data : Dictionary):
	faction_data = data

func set_points(value : int):
	$Panel/HBoxContainer/Factionpoints.value = value

func set_id(value : int):
	$Panel/HBoxContainer/FactionID.value = value
	
func _on_FactionID_value_changed(value : int):
	$Panel/HBoxContainer/ChooseFaction.set_faction_name_from_id(value)
	emit_signal("faction_id_changed",value,self)
	
func _on_Factionpoints_value_changed(value : int):
	emit_signal("faction_points_changed",value,self)
	if value >= 0:
		$Panel/HBoxContainer/Factionpoints.prefix = "+"
	else:
		$Panel/HBoxContainer/Factionpoints.prefix = ""
	
func _input(_event : InputEvent):
	if Input.is_key_pressed(KEY_ENTER):
		$Panel/HBoxContainer/Factionpoints.get_line_edit().release_focus()

func update_language():
	$Panel/HBoxContainer/Factionpoints.suffix = tr("POINTS_ABBRV")


func _on_delete_button_pressed():
	emit_signal("faction_change_request_deletion",self)
