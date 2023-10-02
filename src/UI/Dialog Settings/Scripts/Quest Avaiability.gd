extends Control


signal id_changed
signal type_changed



func get_id():
	return $Panel/SpinBox.value

func get_availability_type():
	return $Panel/OptionButton.selected



func set_id(id:int):
	$Panel/SpinBox.value = id

func set_availability_type(type:int):
	print(type)
	$Panel/OptionButton.selected = type
	

func _on_Choose_Quest_pressed():
	$Panel/ChooseQuest/CategoryFinder.set_global_position($Panel/ChooseQuest.global_position)
	$Panel/ChooseQuest/CategoryFinder.popup()


func _on_CategoryFinder_index_pressed(_index : int):
	$Panel/ChooseQuest/CategoryFinder/QuestFinder.set_global_position($Panel/ChooseQuest.global_position)
	$Panel/ChooseQuest/CategoryFinder/QuestFinder.popup()


func _on_SpinBox_value_changed(value : int):
	emit_signal("id_changed",self,value)
	$Panel/ChooseQuest.text = find_quest_name_from_id(value)
	
		
func find_quest_name_from_id(id : int) -> String:
	if id == -1:
		return "Select Quest"
	for key in $Panel/ChooseQuest.quest_dict.keys():
		for title in $Panel/ChooseQuest.quest_dict[key].keys():
			if $Panel/ChooseQuest.quest_dict[key][title] == id:
				return title
	return "Unindexed Quest"



func _on_OptionButton_item_selected(index: int):
	emit_signal("type_changed",self,index)
	$Panel/ChooseQuest.disabled = (index == 0)
	print(index)


func _on_ChooseQuest_quest_chosen(title : String,id : int):
	$Panel/ChooseQuest.text = title
	$Panel/SpinBox.value = id
