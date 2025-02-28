extends Node
class_name EnvironmentIndexer

signal new_category_created
signal category_renamed
signal category_deleted
signal clear_editor_request
signal category_duplicated
signal category_buttons_created


var indexed_dialog_categories : Array[String]= []

var highest_index := 0

func _ready():
	if CurrentEnvironment.sftp_client:
		connect("new_category_created",Callable(CurrentEnvironment.sftp_client,"_OnNewCategoryCreated"))
		connect("category_renamed",Callable(CurrentEnvironment.sftp_client,"_OnCategoryRenamed"))
		connect("category_deleted",Callable(CurrentEnvironment.sftp_client,"_OnCategoryDeleted"))
		#connect("category_duplicated",Callable(CurrentEnvironment.sftp_client,"_OnCategoryDuplicated"))

func index_categories() -> Array[String]:

	indexed_dialog_categories = []
	var dir_search := DirectorySearch.new()
	indexed_dialog_categories = dir_search.scan_directory_for_folders(CurrentEnvironment.current_directory+"/dialogs")
	indexed_dialog_categories.sort()
	CurrentEnvironment.highest_id = find_highest_index()
	emit_signal("category_buttons_created",indexed_dialog_categories)
	return indexed_dialog_categories
	
	
func find_highest_index(reindex := false) -> int:
	if reindex:
		DirAccess.remove_absolute(CurrentEnvironment.current_directory+"/dialogs/highest_index.json")
	var file : FileAccess
	if !FileAccess.file_exists(CurrentEnvironment.current_directory+"/dialogs/highest_index.json"):
		var id_numbers
		if CurrentEnvironment.sftp_client:
			print("test")
			id_numbers = CurrentEnvironment.sftp_client.GetAllDialogFiles(CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/dialogs")
		else:
			var dir_search := DirectorySearch.new()
			id_numbers = dir_search.scan_all_subdirectories(CurrentEnvironment.current_directory+"/dialogs",["json"])
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
	index_categories()
	emit_signal("new_category_created",new_category_name)

	
	




func rename_category(category_name : String,new_name : String):
	if index_categories().count(new_name)==0:
		for i in indexed_dialog_categories.size():
			if indexed_dialog_categories[i] == category_name:
				indexed_dialog_categories[i] = new_name
		var dir := DirAccess.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
		dir.rename(CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+category_name+".ydec",CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+new_name+".ydec")
		dir.rename(CurrentEnvironment.current_directory+"/dialogs/"+category_name,CurrentEnvironment.current_directory+"/dialogs/"+new_name)
		index_categories()
		emit_signal("category_renamed",category_name,new_name)

	
func delete_category(category_name : String):
	if category_name == CurrentEnvironment.current_category_name:
		emit_signal("clear_editor_request")
	var dir := DirAccess.open(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
	dir.remove(CurrentEnvironment.current_directory+"/dialogs/highest_index.json")
	if DirAccess.get_open_error() == OK:
		OS.move_to_trash(CurrentEnvironment.current_directory+"/dialogs/"+category_name)
		print("Deleting Category "+category_name)
	index_categories()
	emit_signal("category_deleted",category_name)
	
func duplicate_category(category_name : String):
	var dir := DirAccess.open(CurrentEnvironment.current_directory+'/dialogs/'+category_name)
	var new_category_name = add_as_many_underscores_needed_to_make_unique(category_name)
	dir.make_dir(CurrentEnvironment.current_directory+'/dialogs/'+new_category_name)
	await dir.copy(CurrentEnvironment.current_directory+'/dialogs/'+category_name+"/"+category_name+".ydec",CurrentEnvironment.current_directory+'/dialogs/'+new_category_name+"/"+new_category_name+".ydec")
	emit_signal("new_category_created",new_category_name)
	index_categories()
	emit_signal("category_duplicated",category_name,new_category_name)
	

func add_as_many_underscores_needed_to_make_unique(old_name):
	var new_name = old_name+"_"
	if indexed_dialog_categories.has(new_name):
		return add_as_many_underscores_needed_to_make_unique(new_name)
	else:
		return new_name


func _on_sftp_box_resync_cache():
	index_categories()
	
