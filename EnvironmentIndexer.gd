extends Node
class_name EnvironmentIndexer

signal save_category_request
signal new_category_created
signal category_renamed
signal category_deleted
signal clear_editor_request



var unindexed_dialog_categories = []
var indexed_dialog_categories = []

var highest_index = 0

func _ready():
	pass

func index_categories():
	unindexed_dialog_categories = []
	indexed_dialog_categories = []
	var dir_search = DirectorySearch.new()
	unindexed_dialog_categories = dir_search.scan_directory_for_folders(CurrentEnvironment.current_directory+"/dialogs")
	discover_existing_ydecs()
	CurrentEnvironment.highest_id = find_highest_index()
	
	
func find_highest_index():
	var file = File.new()
	if file.open(CurrentEnvironment.current_directory+"/dialogs/highest_index.json",File.READ) != OK:
		var dir_search = DirectorySearch.new()
		var id_numbers = dir_search.scan_all_subdirectories(CurrentEnvironment.current_directory+"/dialogs",["json"])
		var proper_id_numbers = []
		for number in id_numbers:
			number = number.replace(".json","")
			if number.is_valid_integer():
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
		if line.is_valid_integer():
			return int(line)
		else:
			printerr("highest_index.json does not contain a valid integer.")
			return 0

func discover_existing_ydecs():
	var dir_search = DirectorySearch.new()
	for i in unindexed_dialog_categories:
		var files = dir_search.scan_all_subdirectories(CurrentEnvironment.current_directory+"/dialogs/"+i,["ydec"])
		var index_dict = {
				"category_name" : i,
				"has_ydec" : false,
				}
		if files.size() > 0:
			index_dict["has_ydec"] = true
		indexed_dialog_categories.append(index_dict)


func add_ydec_to_indexed_category(category_name):
	for i in indexed_dialog_categories:
		if i["category_name"] == category_name:
			i["has_ydec"] = true

func get_category_has_ydec(category_name):
	for i in indexed_dialog_categories:
		if i["category_name"] == category_name:
			return i["has_ydec"]
	printerr("Category "+category_name+" does not exist")
	return false


func create_new_category(new_category_name):

	emit_signal("save_category_request",CurrentEnvironment.current_category_name)
	if new_category_name == null:
		new_category_name = "New Category"
	
	for category in indexed_dialog_categories:
		if category["category_name"] == new_category_name:
			new_category_name += "_"
	
	var dir = Directory.new()
	dir.open(CurrentEnvironment.current_directory+"/dialogs/")
	dir.make_dir(CurrentEnvironment.current_directory+"/dialogs/"+new_category_name)
	indexed_dialog_categories.append({
		"category_name" : new_category_name,
		"has_ydec" : false
	})
	indexed_dialog_categories.sort_custom(self,"sort_array_by_category_name")
	emit_signal("new_category_created")
	
	

func sort_array_by_category_name(a,b):
	if a["category_name"].to_lower() != b["category_name"].to_lower():
		return a["category_name"].to_lower() < b["category_name"].to_lower()
	else:
		return a["category_name"].to_lower()  < b["category_name"].to_lower() 	



func rename_category(category_name,new_name):
	print("renaming categroy")
	for i in indexed_dialog_categories:
		if i["category_name"] == category_name:
			i["category_name"] = new_name
	indexed_dialog_categories.sort_custom(self,"sort_array_by_category_name")
	var dir = Directory.new()
	dir.rename(CurrentEnvironment.current_directory+"/dialogs/"+category_name,CurrentEnvironment.current_directory+"/dialogs/"+new_name)
	emit_signal("category_renamed")


	
func delete_category(category_name):
	emit_signal("clear_editor_request")
	var dir = Directory.new()
	dir.remove(CurrentEnvironment.current_directory+"/dialogs/highest_index.json")
	if dir.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name) == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				delete_category(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+file_name)
			else:
				dir.remove(file_name)
			file_name = dir.get_next()
		dir.remove(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
	index_categories()
	emit_signal("category_deleted")
	CurrentEnvironment.current_category_name = null
