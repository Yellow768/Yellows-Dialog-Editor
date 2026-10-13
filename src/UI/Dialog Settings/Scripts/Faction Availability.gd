extends Control

signal id_changed
signal stance_changed
signal isisnot_changed


func get_id() -> int:
	return $Panel/HBoxContainer/SpinBox.value
	
func get_stance() -> int:
	return $Panel/HBoxContainer/StanceButton.selected

func get_isisnot() -> int:
	return $Panel/HBoxContainer/IsIsnotbutton.selected


func set_id(value : int):
	$Panel/HBoxContainer/SpinBox.value = value	
func set_stance(value : int):
	$Panel/HBoxContainer/StanceButton.selected = value
func set_isisnot(value : int):
	$Panel/HBoxContainer/IsIsnotbutton.selected = value

func _on_IsIsnotbutton_item_selected(index : int):
	isisnot_changed.emit(self,index)


func _on_StanceButton_item_selected(index : int):
	stance_changed.emit(self,index)


func _on_SpinBox_value_changed(value):
	$Panel/HBoxContainer/ChooseFaction.set_faction_name_from_id(value)
	id_changed.emit(self,value)
