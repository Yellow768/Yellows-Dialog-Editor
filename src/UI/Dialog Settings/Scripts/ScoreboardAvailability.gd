extends Control
class_name scoreboard_availability_object

@export var objective_name: String : set = set_objective_name
@export var value: int = 0 : set = set_value
@export_enum("Smaller Than","Equal To","Bigger Than") var comparison_type := 1 : set = set_comparison_type

signal comparison_type_changed
signal objective_name_changed
signal value_changed

func get_comparison():
	return $Panel/OptionButton.selected

func get_objective_name():
	return $Panel/LineEdit.text

func get_value():
	return $Panel/SpinBox.value

func set_comparison_type(type : int):
	comparison_type = type
	if not is_inside_tree(): await self.ready
	$Panel/OptionButton.selected = type
	
func set_objective_name(obj_name : String):
	objective_name = obj_name
	if not is_inside_tree(): await self.ready
	$Panel/LineEdit.text = obj_name
	
func set_value(val : int):
	value = val
	if not is_inside_tree(): await self.ready
	$Panel/SpinBox.value = val
	


func _on_LineEdit_text_changed(new_text : String):
	emit_signal("objective_name_changed",self,new_text)




func _on_SpinBox_value_changed(value : int):
	emit_signal("value_changed",self,value)
	



func _on_OptionButton_item_selected(index : int):
	emit_signal("comparison_type_changed",self,index)
