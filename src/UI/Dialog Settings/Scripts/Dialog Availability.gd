extends Control
var dialog_list

signal type_changed
signal id_changed
signal enter_dialog_availability_mode
signal request_dialog_list_injection

func _ready():
	emit_signal("request_dialog_list_injection",self)

func get_id():
	return $Panel/SpinBox.value

func get_availability_type():
	return $Panel/OptionButton.selected	
	
func set_id(value):
	$Panel/SpinBox.value = value
	
	
func set_availability_type(value):
	$Panel/OptionButton.selected = value

func _on_CategoryFinder_index_pressed(_index):
	$Panel/ChooseDialog/CategoryFinder/DialogFinder.set_global_position($Panel/ChooseDialog.global_position)
	$Panel/ChooseDialog/CategoryFinder/DialogFinder.popup()


func _on_ChooseDialog_pressed():
	emit_signal("enter_dialog_availability_mode")



func _on_OptionButton_item_selected(index):
	emit_signal("type_changed",self,index)
	if index != 0:
		$Panel/ChooseDialog.disabled = false
	else:
		$Panel/ChooseDialog.disabled = true
	



func _on_SpinBox_value_changed(value):
	if value == -1 or value == 0:
		$Panel/ChooseDialog.text = "Select Dialog"
	if dialog_list != null:
		$Panel/ChooseDialog.text = dialog_list.get_title_from_id(value)
	emit_signal("id_changed",self,value)

func set_choose_dialog_disbaled_proper():
	$Panel/ChooseDialog.disabled = ($Panel/OptionButton.selected==0)
