extends Control

signal id_changed

var quest_id : int

func _ready():
	pass


func get_id():
	return quest_id
	
func set_id(value : int):
	quest_id = value
	$Panel/QuestID.value = value

func _on_QuestID_value_changed(value : int):
	quest_id = value
	emit_signal("id_changed",quest_id)
	$Panel/ChooseQuest.text = find_quest_name_from_id(quest_id)
	
		
func find_quest_name_from_id(id : int) -> String:
	if id == -1:
		return "SELECT_QUEST"
	for key in $Panel/ChooseQuest.quest_dict.keys():
		for title in $Panel/ChooseQuest.quest_dict[key].keys():
			if $Panel/ChooseQuest.quest_dict[key][title] == id:
				return title
	return "UNINDEXED_QUEST"
		
func _on_ChooseQuest_quest_chosen(title : String,id : int):
	$Panel/ChooseQuest.text = title
	$Panel/QuestID.value = id


func _on_Button_pressed():
	$Panel/QuestID.value = -1
