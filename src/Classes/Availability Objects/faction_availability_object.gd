extends Resource
class_name faction_availability_object

@export var faction_id = -1

@export_enum("Always","Is","Is Not") var availability_operator : int = 0
@export_enum("Friendly","Neutral","Unfriendly") var stance_type : int = 0

signal availability_operator_changed
signal id_changed
signal stance_changed

func reset():
	faction_id = -1
	stance_type = 0

func set_id(id: int):
	faction_id = id
	emit_signal("id_changed")

func set_stance(type: int):
	stance_type = type
	emit_signal("stance_changed")
	
func set_operator(type: int):
	availability_operator = type
	emit_signal("availability_operator_changed")

func _ready():
	pass
