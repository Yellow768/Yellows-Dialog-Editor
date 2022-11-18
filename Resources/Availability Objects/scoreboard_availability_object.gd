extends Resource
class_name scoreboard_availability_object

export(String) var objective_name
export(int) var value = 0
export(int,"Smaller Than","Equal To","Bigger Than") var comparison_type = 1

func reset():
	set_name('')
	set_value(0)
	set_comparison_type(0)
	
func set_name(new_name : String):
	objective_name = new_name

func set_value(new_value : int):
	value = new_value

func set_comparison_type(new_type : int):
	comparison_type = new_type

func _ready():
	pass
