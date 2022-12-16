extends Control

signal faction_id_changed
signal faction_points_changed

func _ready():
	pass

func set_points(value):
	$Panel/Factionpoints.value = value

func set_id(value):
	$Panel/FactionID.value = value


func _on_FactionID_value_changed(value):
	emit_signal("faction_id_changed",value)
	



func _on_Factionpoints_value_changed(value):
	emit_signal("faction_points_changed",value)
