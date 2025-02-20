extends Node

var current_directory : set = set_current_directory
var current_dialog_directory
var current_category_name
var highest_id = 0: set = set_highest_id
var loading_stage = false
var allow_save_state
var dialog_name_preset

var quest_dict
var faction_dict

func _ready():
	pass

func load_faction_data():
	var fact_loader := faction_loader.new()
	faction_dict = fact_loader.get_faction_data(current_directory)

func set_highest_id(new_id):
	highest_id = new_id
	var file = FileAccess.open(current_directory+"/dialogs/highest_index.json",FileAccess.WRITE)
	file.store_line(str(highest_id))

func set_current_directory(new_directory):
	current_directory = new_directory
	current_dialog_directory = new_directory+"/dialogs"
	
func handle_subtracting_dialog_id(dialogs_to_be_deleted : Array[GraphNode]):
	var sorted_ids = dialogs_to_be_deleted.duplicate()
	sorted_ids.sort_custom(Callable(self, "sort_array_by_dialog_id"))
	for node in sorted_ids:
		if node.dialog_id == highest_id:
			highest_id -= 1
			
func sort_array_by_dialog_id(a,b):
	if a.dialog_id != b.dialog_id:
		return a.dialog_id > b.dialog_id
	else:
		return a.dialog_id > b.dialog_id
