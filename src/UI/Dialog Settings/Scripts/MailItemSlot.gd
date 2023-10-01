extends VBoxContainer
class_name mail_item_slot

signal id_changed 
signal nbt_changed
signal count_changed
signal request_scroll_focus

@export var slot : int

var nbt_data : String
var item_id : String
var item_count : int

func _ready():
	$HBoxContainer/Label.text = "Item Slot "+str(slot)
	$NBTTextEdit.connect("expanded",Callable(self,"emit_signal").bind("request_scroll_focus",self))

func _on_button_toggled(button_pressed):
	$"ID and Count".visible = button_pressed
	$NBTTextEdit.visible = button_pressed
	if button_pressed : $HBoxContainer/Button.text = "V"
	if !button_pressed : $HBoxContainer/Button.text = ">"
	
func set_nbt_data(data:String):
	$NBTTextEdit.text = data
	
func set_item_id(id: String):
	$"ID and Count/ItemID".text = id
	item_id = id
	
func set_item_count(count : int):
	$"ID and Count/SpinBox".value = count
	item_count = count


func clear_textboxes():
	$NBTTextEdit.text = ""
	$"ID and Count/ItemID".text = ""
	
func _on_nbt_text_edit_text_changed():
	nbt_data = $NBTTextEdit.text
	emit_signal("nbt_changed")


func _on_item_id_text_changed(new_text):
	item_id = new_text
	emit_signal("id_changed")


func _on_spin_box_value_changed(value):
	item_count = value
	emit_signal("count_changed")
