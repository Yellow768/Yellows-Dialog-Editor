extends Node
class_name EnvironmentIndexer

signal new_category_created
signal category_renamed
signal category_deleted
signal clear_editor_request




var indexed_dialog_categories = []

var highest_index = 0

func _ready():
	pass

func index_categories():

	indexed_dialog_categories = []
	var dir_search = DirectorySearch.new()
	indexed_dialog_categories = dir_search.scan_directory_for_folders(CurrentEnvironment.current_directory+"/dialogs")
	CurrentEnvironment.highest_id = find_highest_index()
	return indexed_dialog_categories
	
	
func find_highest_index():
	var file = File.new()
	if file.open(CurrentEnvironment.current_directory+"/dialogs/highest_index.json",File.READ) != OK:
		var dir_search = DirectorySearch.new()
		var id_numbers = dir_search.scan_all_subdirectories(CurrentEnvironment.current_directory+"/dialogs",["json"])
		var proper_id_numbers = []
		for number in id_numbers:
			number = number.replace(".json","")
			if number.is_valid_int():
				proper_id_numbers.append(int(number))
		proper_id_numbers.sort()
		file.open(CurrentEnvironment.current_directory+"/dialogs/highest_index.json",File.WRITE)
		if proper_id_numbers != []:
			file.store_line(String(proper_id_numbers.back()))
			return proper_id_numbers.back()
		else:
			file.store_line(String(0))
			return 0
		
	else:
		var line = file.get_line()
		if line.is_valid_int():
			return int(line)
		else:
			printerr("highest_index.json does not contain a valid integer.")
			return 0


func create_new_category(new_category_name):
	if new_category_name == null:
		new_category_name = "New Category"
	
	for category in indexed_dialog_categories:
		if category == new_category_name:
			new_category_name += "_"
	
	var dir = DirAccess.new()
	dir.open(CurrentEnvironment.current_directory+"/dialogs/")
	dir.make_dir(CurrentEnvironment.current_directory+"/dialogs/"+new_category_name)
	indexed_dialog_categories.append(new_category_name)
	indexed_dialog_categories.sort()
	emit_signal("new_category_created",indexed_dialog_categories)
	
	

func sort_array_by_category_name(a,b):
	if a["category_name"].to_lower() != b["category_name"].to_lower():
		return a["category_name"].to_lower() < b["category_name"].to_lower()
	else:
		return a["category_name"].to_lower()  < b["category_name"].to_lower() 	



func rename_category(category_name,new_name):
	print("renaming categroy")
	for i in indexed_dialog_categories.size():
		if indexed_dialog_categories[i] == category_name:
			indexed_dialog_categories[i] = new_name

	indexed_dialog_categories.sort()
	var dir = DirAccess.new()
	dir.rename(CurrentEnvironment.current_directory+"/dialogs/"+category_name,CurrentEnvironment.current_directory+"/dialogs/"+new_name)
	emit_signal("category_renamed",indexed_dialog_categories)


	
func delete_category(category_name):
	emit_signal("clear_editor_request")
	var dir = DirAccess.new()
	dir.remove(CurrentEnvironment.current_directory+"/dialogs/highest_index.json")
	if dir.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name) == OK:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				delete_category(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+file_name)
			else:
				dir.remove(file_name)
			file_name = dir.get_next()
		dir.remove(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
	index_categories()
	emit_signal("category_deleted",indexed_dialog_categories)
