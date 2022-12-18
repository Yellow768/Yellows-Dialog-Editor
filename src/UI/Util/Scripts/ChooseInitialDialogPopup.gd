extends Panel

signal initial_dialog_chosen
signal no_dialogs

export(NodePath) var _button_list_path

onready var ButtonList = get_node(_button_list_path)

var category_name
var all_dialogs

func create_dialog_buttons(importing_category_name):
	category_name = importing_category_name
	var dialog_json_loader = dialog_jsons_loader.new()
	all_dialogs = dialog_json_loader.get_dialog_jsons(category_name)
	if all_dialogs.empty():
		emit_signal("no_dialogs")
		queue_free()
		
		return
	for button in $ScrollContainer/VBoxContainer.get_children():
		button.queue_free()
	for index in all_dialogs.size():
		var dialog_button = Button.new()
		dialog_button.text = all_dialogs[index]["DialogTitle"]
		dialog_button.connect("pressed",self,"initial_dialog_chosen",[index])
		$ScrollContainer/VBoxContainer.add_child(dialog_button)	
	visible = true
	
func initial_dialog_chosen(index_chosen):
	emit_signal("initial_dialog_chosen",category_name,all_dialogs,index_chosen)
	queue_free()


func _on_CancelButton_pressed():
	queue_free()
