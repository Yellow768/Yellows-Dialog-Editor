extends Node

signal dialog_title_changed
signal dialog_added_to_list

var all_loaded_dialogs := {}

func _ready():
	load_environment_settings()

func load_environment_settings():
	if !FileAccess.file_exists(CurrentEnvironment.current_directory+"/environment_settings.json"):
		FileAccess.open(CurrentEnvironment.current_directory+"/environment_settings.json",FileAccess.WRITE)
	var environment_settings_file := FileAccess.open(CurrentEnvironment.current_directory+"/environment_settings.json",FileAccess.READ)
	var loaded_list = JSON.parse_string(environment_settings_file.get_as_text())
	if loaded_list && loaded_list.has("dialog_names_map"):
		all_loaded_dialogs = loaded_list["dialog_names_map"]
		print("Loaded Dialog Names Map")
	else:
		push_warning("Dialog Names Map not valid.")

func save_environment_settings():
	var file := FileAccess.open(CurrentEnvironment.current_directory+"/environment_settings.json",FileAccess.WRITE)
	var environment_settings = {
		"dialog_names_map" : all_loaded_dialogs
	}
	file.store_line(JSON.stringify(environment_settings))

func get_title_from_index(index : int) -> String:
	if index > all_loaded_dialogs.size() or index < 0:
		printerr("DIALOGLIST : Given Index is outside the range " + str(index))
		return "Unindexed Dialog"
	else:
		return all_loaded_dialogs[index]
		
func get_title_from_id(id : int) -> String:
	if all_loaded_dialogs.has(str(id)):
		return all_loaded_dialogs.get(str(id))
	if all_loaded_dialogs.has(id):
		return all_loaded_dialogs.get(id)
	return "Unindexed Dialog"

func add_dialog_to_loaded(dialog : dialog_node):
	if !dialog.is_connected("title_changed", Callable(self, "update_changed_dialog_title")):
		dialog.connect("title_changed", Callable(self, "update_changed_dialog_title").bind(dialog))
	if all_loaded_dialogs.has(dialog.dialog_id):
		return
	all_loaded_dialogs[dialog.dialog_id] = dialog.dialog_title
	save_environment_settings()
	
	
	
			
func update_changed_dialog_title(dialog : dialog_node) -> void:
	all_loaded_dialogs[int(dialog.dialog_id)] = dialog.dialog_title
	save_environment_settings()
			
			
func dialog_deleted(dialog_id : int) -> void:
	
	all_loaded_dialogs.erase(dialog_id)


func dialog_node_added(dialog : dialog_node) -> void:
	add_dialog_to_loaded(dialog)


func _on_DialogAvailability_request_dialog_list_injection(dialog_availability) -> void:
	dialog_availability.dialog_list = self
