extends Resource
class_name faction_change_object

@export var faction_id := -1
@export var points := 100
@export_enum("Increase","Decrease") var operator := 0


signal operator_changed
signal id_changed
signal points_changed

func reset():
	faction_id = -1
	operator = 0

func set_id(id: int):
	faction_id = id
	id_changed.emit()

func set_points(new_points : int):
	points = new_points
	if points >= 0:
		set_operator(0)
	else:
		set_operator(1)
	points_changed.emit()

func set_operator(type: int):
	operator = type
	operator_changed.emit()

func _ready():
	pass
