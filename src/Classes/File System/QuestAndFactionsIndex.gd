class_name quest_indexer
extends Node

var quest_dict = {}
var indexed_quest_categories = []

var faction_dict = {}
var indexed_factions = []

func _ready():
	pass



func index_quest_categories():
	var unindexed_quest_categories = []
	var dir_search = DirectorySearch.new()
	indexed_quest_categories = dir_search.scan_directory_for_folders(CurrentEnvironment.current_directory+"/quests")
	for quest_category in indexed_quest_categories:
		quest_dict[quest_category] = index_quest_names(quest_category)
	return quest_dict
	
func index_quest_names(quest_category):
	var quest_names_dict = {}
	var dir_search = DirectorySearch.new()
	var quest_names = dir_search.scan_all_subdirectories(CurrentEnvironment.current_directory+"/quests/"+quest_category,["json"])
	for quest in quest_names:
		var file = FileAccess.open(CurrentEnvironment.current_directory+"/quests/"+quest_category+"/"+quest,FileAccess.READ)
		var title = return_quest_title_key(file)
		var id = quest.replace(".json","")
		quest_names_dict[title] = int(id)
	return quest_names_dict
				
func return_quest_title_key(file):
	while(file.get_position() < file.get_length()):
		var current_line = file.get_line()
		if '"Title"' in current_line:
			current_line.erase(0,14)
			current_line.erase(current_line.length()-2,2)
			return current_line
