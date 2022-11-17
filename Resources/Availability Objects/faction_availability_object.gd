extends Resource
class_name faction_availability_object

export var factionID = -1

export(int,"Always","Is","Is Not") var availability_operator
export(int,"Friendly","Neutral","Unfriendly") var availability_type

signal availability_changed
signal id_changed
signal availability_operator_changed

func reset():
	factionID = -1
	availability_type = 0

func set_id(id: int):
	factionID = id
	emit_signal("id_changed")

func set_availability(type: int):
	availability_type = type
	emit_signal("availability_changed")
	
func set_operator(type: int):
	availability_operator = type
	emit_signal("availability_operator_changed")

func _ready():
	pass
