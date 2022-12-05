extends Control

signal id_changed

var quest_id

func _ready():
	pass


func get_id():
	return quest_id
	
func set_id(value):
	quest_id = value
	$Panel/QuestID.value = value

func _on_QuestID_value_changed(value):
	quest_id = value
	emit_signal("id_changed",quest_id)
