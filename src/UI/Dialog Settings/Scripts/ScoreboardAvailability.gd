extends Control

signal comparison_type_changed
signal objective_name_changed
signal value_changed

func get_comparison():
	return $Panel/OptionButton.selected

func get_objective_name():
	return $Panel/LineEdit.text

func get_value():
	return $Panel/SpinBox.value

func set_comparison_type(type):
	$Panel/OptionButton.selected = type
	
func set_objective_name(obj_name):
	$Panel/LineEdit.text = obj_name
	
func set_value(value):
	$Panel/SpinBox.value = value
	



func _ready():
	pass


func _on_LineEdit_text_changed(new_text):
	emit_signal("objective_name_changed",self,new_text)




func _on_SpinBox_value_changed(value):
	emit_signal("value_changed",self,value)
	



func _on_OptionButton_item_selected(index):
	emit_signal("comparison_type_changed",self,index)
