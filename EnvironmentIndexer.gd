extends Node
class_name EnvironmentIndexer

var unindexed_dialog_categories = []
var indexed_dialog_categories = []

var highest_index = 0

func _ready():
	pass

func index_categories():
	var dir_search = DirectorySearch.new()
	unindexed_dialog_categories = dir_search.scan_directory_for_folders(CurrentEnvironment.current_directory+"/dialogs")
	discover_existing_ydecs()
	
func find_highest_index():
	var dir_search = DirectorySearch.new()
	var id_numbers = dir_search.scan_all_subdirectories(CurrentEnvironment.current_directory+"/dialogs",["json"])
	id_numbers.sort()
	return id_numbers.back()

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


#Search through categories
#Gather all the dialog files, and grab the dialog titles
#Mark those that have a YDEC file
#Mark the highest index
