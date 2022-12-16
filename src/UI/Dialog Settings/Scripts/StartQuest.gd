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
	$Panel/ChooseQuest.text = find_quest_name_from_id(quest_id)
	
		
func find_quest_name_from_id(id):
	if id == -1:
		return "Select Quest"
	for key in CurrentEnvironment.quest_dict.keys():
		for title in CurrentEnvironment.quest_dict[key].keys():
			if CurrentEnvironment.quest_dict[key][title] == id:
				return title
	return "Unindexed Quest"
		
func _on_ChooseQuest_quest_chosen(title,id):
	$Panel/ChooseQuest.text = title
	$Panel/QuestID.value = id


func _on_Button_pressed():
	$Panel/QuestID.value = -1
