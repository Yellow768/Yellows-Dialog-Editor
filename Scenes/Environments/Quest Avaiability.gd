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
	$Panel/OptionButton.selected = type

func _on_Choose_Quest_pressed():
	$Panel/ChooseQuest/CategoryFinder.set_global_position($Panel/ChooseQuest.rect_global_position)
	$Panel/ChooseQuest/CategoryFinder.popup()


func _on_CategoryFinder_index_pressed(index):
	$Panel/ChooseQuest/CategoryFinder/QuestFinder.set_global_position($Panel/ChooseQuest.rect_global_position)
	$Panel/ChooseQuest/CategoryFinder/QuestFinder.popup()


func _on_SpinBox_value_changed(value):
	emit_signal("id_changed",self,value)
	



func _on_OptionButton_item_selected(index):
	emit_signal("type_changed",self,index)
