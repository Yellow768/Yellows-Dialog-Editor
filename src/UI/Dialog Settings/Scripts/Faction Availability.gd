extends Control

signal id_changed
signal stance_changed
signal isisnot_changed


func get_id():
	return $Panel/SpinBox.value
	
func get_stance():
	return $Panel/StanceButton.selected

func get_isisnot():
	return $Panel/IsIsnotbutton.selected


func set_id(value):
	$Panel/SpinBox.value = value	
func set_stance(value):
	$Panel/StanceButton.selected = value
func set_isisnot(value):
	$Panel/IsIsnotbutton.selected = value

func _on_IsIsnotbutton_item_selected(index):
	emit_signal("isisnot_changed",self,index)


func _on_StanceButton_item_selected(index):
	emit_signal("stance_changed",self,index)


func _on_SpinBox_value_changed(value):
	$Panel/ChooseFaction.set_faction_name_from_id(value)
	emit_signal("id_changed",self,value)
