extends Resource
class_name dialog_availability_object

signal availability_changed
signal id_changed

export var dialog_id = -1
export(int,"Always","After","Before") var availability_type

func reset():
	dialog_id = -1
	availability_type = 0

func set_id(id: int):
	dialog_id = id
	emit_signal("id_changed")

func set_availability(type: int):
	availability_type = type
	emit_signal("availability_changed")

func _ready():
	pass
