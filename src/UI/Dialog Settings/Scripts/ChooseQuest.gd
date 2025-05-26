extends Button

var quest_dict

signal quest_chosen

@export var quest_finder_path: NodePath
@export var category_finder_path: NodePath

@onready var CategoryFinder : PopupMenu = get_node(category_finder_path)
@onready var QuestFinder := get_node(quest_finder_path)

var quest_list_updated := false
	


func _on_ChooseQuest_pressed():
	if !quest_list_updated:
		update_category_finder()
	CategoryFinder.position = global_position
	QuestFinder.position = global_position
	CategoryFinder.popup()


func update_category_finder():
	CategoryFinder.clear()
	var id_counter := 1
	CategoryFinder.add_item("[Cancel X]",0)
	for key in quest_dict.keys():
		CategoryFinder.add_item(key,id_counter)
		CategoryFinder.set_item_metadata(CategoryFinder.get_item_index(id_counter),key)
		id_counter+=1



func _on_CategoryFinder_index_pressed(index):
	if index != 0:
		var quest_category_name : String = CategoryFinder.get_item_metadata(index)
		QuestFinder.clear()
		QuestFinder.add_item("[Back...]",0)
		for key in quest_dict[quest_category_name].keys():
			QuestFinder.add_item(key,quest_dict[quest_category_name][key])
		
		QuestFinder.popup()
	


func _on_QuestFinder_id_pressed(id : int):
	if id == 0:
		CategoryFinder.popup()
	else:
		emit_signal("quest_chosen",QuestFinder.get_item_text(QuestFinder.get_item_index(id)),id)
