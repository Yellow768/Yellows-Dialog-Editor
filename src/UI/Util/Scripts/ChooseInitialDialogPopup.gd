extends Panel

signal initial_dialog_chosen
signal no_dialogs
signal import_canceled

@export var _button_list_path: NodePath

@onready var ButtonList := get_node(_button_list_path)

var category_name : String
var all_dialogs : Array[Dictionary]

func create_dialog_buttons(importing_category_name : String):
	category_name = importing_category_name
	var dialog_json_loader := dialog_jsons_loader.new()
	all_dialogs = dialog_json_loader.get_dialog_jsons(category_name)
	if all_dialogs.is_empty():
		emit_signal("no_dialogs")
		queue_free()
		
		return
	for button in $Panel/ScrollContainer/VBoxContainer.get_children():
		button.queue_free()
	for index in all_dialogs.size():
		var dialog_button := Button.new()
		dialog_button.text = all_dialogs[index]["DialogTitle"]
		dialog_button.connect("pressed", Callable(self, "emit_initial_dialog_chosen").bind(index))
		$Panel/ScrollContainer/VBoxContainer.add_child(dialog_button)	
	visible = true
	
func emit_initial_dialog_chosen(index_chosen : int):
	emit_signal("initial_dialog_chosen",category_name,all_dialogs,index_chosen)
	queue_free()


func _on_CancelButton_pressed():
	emit_signal("import_canceled")
	queue_free()


func _on_Searchbar_text_changed(new_text : String):
	for button in $Panel/ScrollContainer/VBoxContainer.get_children():
		if new_text == "":
			button.visible = true
		else:
			if new_text.capitalize() in button.text.capitalize():
				button.visible = true
			else:
				button.visible = false
