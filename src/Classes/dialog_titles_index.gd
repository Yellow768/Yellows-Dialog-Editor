extends Node

signal dialog_title_changed
signal dialog_added_to_list

var all_loaded_dialogs : Array = []

func get_title_from_index(index):
	if index > all_loaded_dialogs.size() or index < 0:
		printerr("DIALOGLIST : Given Index is outside the range " + String(index))
		return "Unindexed Dialog"
	else:
		return all_loaded_dialogs[index]["dialog_title"]
		
func get_title_from_id(id):
	for i in all_loaded_dialogs.size():
		if all_loaded_dialogs[i]["dialog_id"] == id:
			return all_loaded_dialogs[i]["dialog_title"]
	return "Unindexed Dialog"

func add_dialog_to_loaded(dialog):
	var dialog_loaded = false
	for i in all_loaded_dialogs.size():
		if dialog.dialog_id == all_loaded_dialogs[i]["dialog_id"]:
			all_loaded_dialogs[i] = {
				"dialog_id" : dialog.dialog_id,
				"dialog_title" : dialog.dialog_title
			}
	if !dialog_loaded:
		all_loaded_dialogs.append({
				"dialog_id" : dialog.dialog_id,
				"dialog_title" : dialog.dialog_title
			})
	if !dialog.is_connected("title_changed",self,"dialog_title_changed"):
		dialog.connect("title_changed",self,"dialog_title_changed",[dialog])
	emit_signal("dialog_added_to_list")
			
func dialog_title_changed(dialog):
	for i in all_loaded_dialogs.size():
		if all_loaded_dialogs[i]["dialog_id"] == dialog.dialog_id:
			all_loaded_dialogs[i]["dialog_title"] = dialog.dialog_title
			emit_signal("dialog_title_changed",i)
			
			
func dialog_deleted(dialog_id):
	for i in all_loaded_dialogs.size():
		if all_loaded_dialogs[i]["dialog_id"] == dialog_id:
			all_loaded_dialogs.remove(i)


func dialog_node_added(dialog):
	add_dialog_to_loaded(dialog)


func _on_DialogAvailability_request_dialog_list_injection(dialog_availability):
	dialog_availability.dialog_list = self
