extends Control




func _on_Choose_Quest_pressed():
	$Panel/ChooseDialog/CategoryFinder.set_global_position($Panel/ChooseDialog.rect_global_position)
	$Panel/ChooseDialog/CategoryFinder.popup()


func _on_CategoryFinder_index_pressed(index):
	$Panel/ChooseDialog/CategoryFinder/DialogFinder.set_global_position($Panel/ChooseDialog.rect_global_position)
	$Panel/ChooseDialog/CategoryFinder/DialogFinder.popup()
