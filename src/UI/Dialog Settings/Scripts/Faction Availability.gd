extends Control

signal id_changed
signal stance_changed
signal isisnot_changed


func get_id() -> int:
	return $Panel/SpinBox.value
	
func get_stance() -> int:
	return $Panel/StanceButton.selected

func get_isisnot() -> int:
	return $Panel/IsIsnotbutton.selected


func set_id(value : int):
	$Panel/SpinBox.value = value	
func set_stance(value : int):
	$Panel/StanceButton.selected = value
func set_isisnot(value : int):
	$Panel/IsIsnotbutton.selected = value

func _on_IsIsnotbutton_item_selected(index : int):
	emit_signal("isisnot_changed",self,index)


func _on_StanceButton_item_selected(index : int):
	emit_signal("stance_changed",self,index)


func _on_SpinBox_value_changed(value : int):
	$Panel/ChooseFaction.set_faction_name_from_id(value)
	emit_signal("id_changed",self,value)
