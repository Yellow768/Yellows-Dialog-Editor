extends Resource
class_name faction_change_object

export var factionID = -1
export var points = 100
export(int,"Increase","Decrease") var operator


signal operator_changed
signal id_changed

func reset():
	factionID = -1
	operator = 0

func set_id(id: int):
	factionID = id
	emit_signal("id_changed")

func set_availability(type: int):
	operator = type
	emit_signal("operator_changed")

func _ready():
	pass
