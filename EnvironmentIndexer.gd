extends Node
class_name EnvironmentIndexer

var environment_path
var unindexed_dialog_categories = []
var indexed_dialog_categories = []

var highest_index = 0

func _ready():
	pass

func index_categories():
	var dir_search = DirectorySearch.new()
	unindexed_dialog_categories = dir_search.scan_directory_for_folders(environment_path+"/dialogs")
	discover_existing_ydecs()
	
func find_highest_index():
	var dir_search = DirectorySearch.new()
	var numbers = dir_search.scan_all_subdirectories(environment_path+"/dialogs",["json"])
	numbers.sort()
	return numbers.back()

func discover_existing_ydecs():
	var dir_search = DirectorySearch.new()
	
	for i in unindexed_dialog_categories:
		
		var files = dir_search.scan_all_subdirectories(environment_path+"/dialogs/"+i,["ydec"])
		var index_dict = {
				"category_name" : i,
				"has_ydec" : false,
				}
		if files.size() > 0:
			index_dict["has_ydec"] = true
		indexed_dialog_categories.append(index_dict)


#Search through categories
#Gather all the dialog files, and grab the dialog titles
#Mark those that have a YDEC file
#Mark the highest index
