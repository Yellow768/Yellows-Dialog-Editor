extends Node

signal dialog_title_changed
signal dialog_added_to_list

var all_loaded_dialogs := {}

func get_title_from_index(index):
	if index > all_loaded_dialogs.size() or index < 0:
		printerr("DIALOGLIST : Given Index is outside the range " + String(index))
		return "Unindexed Dialog"
	else:
		return all_loaded_dialogs[index]
		
func get_title_from_id(id):
	if all_loaded_dialogs.has(id):
		return all_loaded_dialogs[id]
	return "Unindexed Dialog"

func add_dialog_to_loaded(dialog):
	if all_loaded_dialogs.has(dialog.dialog_id):
		print("already have dialog")
		return
	all_loaded_dialogs[dialog.dialog_id] = dialog.dialog_title
	emit_signal("dialog_added_to_list")
	if !dialog.is_connected("title_changed",self,"dialog_title_changed"):
		dialog.connect("title_changed",self,"dialog_title_changed",[dialog])
	
	
			
func dialog_title_changed(dialog):
	all_loaded_dialogs[dialog.dialog_id] = dialog.dialog_title
	emit_signal("dialog_title_changed")
			
			
func dialog_deleted(dialog_id):
	
	all_loaded_dialogs.erase(dialog_id)


func dialog_node_added(dialog):
	add_dialog_to_loaded(dialog)


func _on_DialogAvailability_request_dialog_list_injection(dialog_availability):
	dialog_availability.dialog_list = self
