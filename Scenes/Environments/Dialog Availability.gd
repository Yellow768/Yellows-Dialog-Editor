extends Control

signal type_changed
signal id_changed

func get_id():
	return $Panel/SpinBox.value

func get_availability_type():
	return $Panel/OptionButton.selected	
	
func set_id(value):
	$Panel/SpinBox.value = value
	
func set_availability_type(value):
	$Panel/OptionButton.selected = value

func _on_CategoryFinder_index_pressed(index):
	$Panel/ChooseDialog/CategoryFinder/DialogFinder.set_global_position($Panel/ChooseDialog.rect_global_position)
	$Panel/ChooseDialog/CategoryFinder/DialogFinder.popup()


func _on_ChooseDialog_pressed():
	$Panel/ChooseDialog/CategoryFinder.set_global_position($Panel/ChooseDialog.rect_global_position)
	$Panel/ChooseDialog/CategoryFinder.popup()



func _on_OptionButton_item_selected(index):
	emit_signal("type_changed",self,index)
	



func _on_SpinBox_value_changed(value):
	emit_signal("id_changed",self,value)
