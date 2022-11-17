extends Resource
class_name dialog_availability_object

export var dialogID = -1
export(int,"Always","After","Before") var availability_type

signal availability_changed
signal id_changed

func reset():
	dialogID = -1
	availability_type = 0

func set_id(id: int):
	dialogID = id
	emit_signal("id_changed")

func set_availability(type: int):
	availability_type = type
	emit_signal("availability_changed")

func _ready():
	pass
