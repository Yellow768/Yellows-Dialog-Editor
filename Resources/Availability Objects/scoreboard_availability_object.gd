extends Resource
class_name scoreboard_availability_object

export(String) var scoreboard_name
export(int) var value = 0
export(int,"Equal To","Bigger Than","Smaller Than") var comparison

func reset():
	set_name('')
	set_value(0)
	set_comparison_type(0)
	
func set_name(new_name : String):
	scoreboard_name = new_name

func set_value(new_value : int):
	value = new_value

func set_comparison_type(new_type : int):
	comparison = new_type

func _ready():
	pass
