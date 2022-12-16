extends Resource
class_name quest_availability_object

export(int,"Always","After","Before","When Active","When Not Active","Completed") var availability_type = 0
export(int) var quest_id = -1

func reset():
	set_id(-1)
	set_availability(0)

func set_id(id:int):
	quest_id = id
	
func set_availability(type:int):
	availability_type = type


func _ready():
	pass
