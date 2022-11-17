extends Control

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
