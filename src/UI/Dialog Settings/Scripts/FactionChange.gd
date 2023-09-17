extends Control

signal faction_id_changed
signal faction_points_changed

var faction_data = {}

func _ready():
	$Panel/ChooseFaction.load_faction_data(faction_data)

func load_faction_data(data):
	faction_data = data

func set_points(value):
	$Panel/Factionpoints.value = value

func set_id(value):
	$Panel/FactionID.value = value
	
func _on_FactionID_value_changed(value):
	$Panel/ChooseFaction.set_faction_name_from_id(value)
	emit_signal("faction_id_changed",value)
	
func _on_Factionpoints_value_changed(value):
	emit_signal("faction_points_changed",value)
	
func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		print("what")
		$Panel/Factionpoints.get_line_edit().release_focus()
