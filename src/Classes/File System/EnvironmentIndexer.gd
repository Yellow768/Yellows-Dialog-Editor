extends Node
class_name EnvironmentIndexer

signal new_category_created
signal category_renamed
signal category_deleted
signal clear_editor_request
signal category_duplicated



var indexed_dialog_categories : Array[String]= []

var highest_index := 0

func _ready():
	pass

func index_categories() -> Array[String]:

	indexed_dialog_categories = []
	var dir_search := DirectorySearch.new()
	indexed_dialog_categories = dir_search.scan_directory_for_folders(CurrentEnvironment.current_directory+"/dialogs")
	CurrentEnvironment.highest_id = find_highest_index()
	return indexed_dialog_categories
	
	
func find_highest_index() -> int:
	var file : FileAccess
	if !FileAccess.file_exists(CurrentEnvironment.current_directory+"/dialogs/highest_index.json"):
		
		var dir_search := DirectorySearch.new()
		var id_numbers : Array[String] = dir_search.scan_all_subdirectories(CurrentEnvironment.current_directory+"/dialogs",["json"])
		var proper_id_numbers : Array[int]= []
		for number in id_numbers:
			number = number.replace(".json","")
			if number.is_valid_int():
				proper_id_numbers.append(int(number))
		proper_id_numbers.sort()
		file = FileAccess.open(CurrentEnvironment.current_directory+"/dialogs/highest_index.json",FileAccess.WRITE)
		if proper_id_numbers != []:
			file.store_line(str(proper_id_numbers.back()))
			return proper_id_numbers.back()
		else:
			file.store_line(str(0))
			return 0
		
	else:
		file = FileAccess.open(CurrentEnvironment.current_directory+"/dialogs/highest_index.json",FileAccess.READ)
		var line := file.get_line()
		if line.is_valid_int():
			return int(line)
		else:
			printerr("highest_index.json does not contain a valid integer.")
			return 0


func create_new_category(new_category_name : String = ''):
	if new_category_name == '':
		new_category_name = "New Category"
	
	for category in indexed_dialog_categories:
		if category == new_category_name:
			new_category_name += "_"
	
	var dir = DirAccess.open(CurrentEnvironment.current_directory+"/dialogs/")
	dir.make_dir(CurrentEnvironment.current_directory+"/dialogs/"+new_category_name)
	indexed_dialog_categories.append(new_category_name)
	indexed_dialog_categories.sort()
	emit_signal("new_category_created",indexed_dialog_categories)
	
	

func sort_array_by_category_name(a,b):
	if a["category_name"].to_lower() != b["category_name"].to_lower():
		return a["category_name"].to_lower() < b["category_name"].to_lower()
	else:
		return a["category_name"].to_lower()  < b["category_name"].to_lower() 	



func rename_category(category_name : String,new_name : String):
	if index_categories().count(new_name)==0:
		for i in indexed_dialog_categories.size():
			if indexed_dialog_categories[i] == category_name:
				indexed_dialog_categories[i] = new_name

		indexed_dialog_categories.sort()
		var dir := DirAccess.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
		dir.rename(CurrentEnvironment.current_directory+"/dialogs/"+category_name,CurrentEnvironment.current_directory+"/dialogs/"+new_name)
		emit_signal("category_renamed",indexed_dialog_categories)


	
func delete_category(category_name : String):
	emit_signal("clear_editor_request")
	var dir := DirAccess.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
	dir.remove(CurrentEnvironment.current_directory+"/dialogs/highest_index.json")
	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name := dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				delete_category(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+file_name)
			else:
				dir.remove(file_name)
			file_name = dir.get_next()
		dir.remove(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
	index_categories()
	emit_signal("category_deleted",indexed_dialog_categories)
	
func duplicate_category(category_name : String):
	var dir := DirAccess.open(CurrentEnvironment.current_directory+'/dialogs/'+category_name)
	dir.make_dir(CurrentEnvironment.current_directory+'/dialogs/'+category_name+"_")
	dir.copy(CurrentEnvironment.current_directory+'/dialogs/'+category_name+"/"+category_name+".ydec",CurrentEnvironment.current_directory+'/dialogs/'+category_name+"_/"+category_name+"_.ydec")
	indexed_dialog_categories.append(category_name+"_")
	indexed_dialog_categories.sort()
	emit_signal("new_category_created",indexed_dialog_categories)
	emit_signal("category_duplicated",category_name+"_")
