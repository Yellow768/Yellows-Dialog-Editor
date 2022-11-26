extends Panel

onready var file_button = $TopPanelContainer/File
var response_node = load("res://Scenes/Nodes/ResponseNode.tscn")

func _ready():
	var file_popup = file_button.get_popup()
	file_popup.connect("id_pressed",self,"file_menu")

func file_menu(id):
	match id:
		2:
			save()
		10:
			load_category()


func save():
	var save_category = File.new()
	var save_nodes = get_tree().get_nodes_in_group("Save")
	
	
	save_category.open("user://category_test.dec",File.WRITE)

	for node in save_nodes:
		if node.filename.empty():
			print("Node '%s' is not instanced, skipped" % node.name)
			continue
		
		if !node.has_method("save"):
			print("Node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		var category_data = node.call("save")
		
		save_category.store_line(to_json(category_data))
	save_category.close()

func load_category():
	var save_category = File.new()
	var loaded_dialogs = []
	var loaded_responses = []
	var save_nodes = get_tree().get_nodes_in_group("Save")
	var response_nodes = get_tree().get_nodes_in_group("Response_Nodes")
	if not save_category.file_exists("user://category_test.dec"):
		return
	save_category.open("user://category_test.dec",File.READ)
	

	$"..".selected_responses = []
	$"..".selected_nodes = []
	loaded_dialogs.resize(500)
	for i in save_nodes:
		i.delete_self()
	for i in response_nodes:
		i.delete_self()
	$"..".node_index = 0
	
	
	while(save_category.get_position() < save_category.get_len()):
		var node_data = parse_json(save_category.get_line())
		var new_object = load(node_data["filename"]).instance()
		
		new_object.offset = Vector2(node_data["offset.x"],node_data["offset.y"])
		
		for i in node_data.keys():
			if i == "offset.x" or i == "offset.y" or i == "filename" or i == "quest_availabilities" or i == "dialog_availabilities" or i == "faction_availabilities" or i == "scoreboard_availabilities" or i == "faction_changes" or i == "response_options":
				continue
			new_object.set(i, node_data[i])
		
		var currently_loaded_dialog = $"..".add_dialog_node(new_object.offset,new_object.dialog_title,new_object.node_index)
		
		currently_loaded_dialog.time_availability = node_data["time_availability"]
		currently_loaded_dialog.min_level_availability = node_data["min_level_availability"]
		
		for i in 4:
			currently_loaded_dialog.quest_availabilities[i].set_id(node_data["quest_availabilities"][i].quest_id)
			currently_loaded_dialog.quest_availabilities[i].set_availability(node_data["quest_availabilities"][i].availability_type)
			currently_loaded_dialog.dialog_availabilities[i].set_id(node_data["dialog_availabilities"][i].dialog_id)
			currently_loaded_dialog.dialog_availabilities[i].set_availability(node_data["dialog_availabilities"][i].availability_type)
			
		for i in 2:
			currently_loaded_dialog.faction_availabilities[i].set_id(node_data["faction_availabilities"][i].faction_id)
			currently_loaded_dialog.faction_availabilities[i].set_stance(node_data["faction_availabilities"][i].stance_type)
			currently_loaded_dialog.faction_availabilities[i].set_operator(node_data["faction_availabilities"][i].availability_operator)
			
			currently_loaded_dialog.faction_changes[i].set_id(node_data["faction_changes"][i].faction_id)
			currently_loaded_dialog.faction_changes[i].set_points(node_data["faction_changes"][i].points)
			
			currently_loaded_dialog.scoreboard_availabilities[i].set_name(node_data["scoreboard_availabilities"][i].objective_name)
			currently_loaded_dialog.scoreboard_availabilities[i].set_comparison_type(node_data["scoreboard_availabilities"][i].comparison_type)
			currently_loaded_dialog.scoreboard_availabilities[i].set_value(node_data["scoreboard_availabilities"][i].value)
		
		
		loaded_dialogs[new_object.node_index] = currently_loaded_dialog
		
		for i in node_data.response_options:
			var currently_loaded_response = $"..".add_response_node(currently_loaded_dialog)
			
			currently_loaded_response.slot = i.slot
			currently_loaded_response.color_decimal = i.color_decimal
			currently_loaded_response.to_dialog_id = i.connected_dialog_index
			currently_loaded_response.set_command(i.command)
			currently_loaded_response.set_option_type(i.option_type)
			currently_loaded_response.set_response_title(i.response_title)
			currently_loaded_response.set_initial_color(i.initial_color)
			loaded_responses.append(currently_loaded_response)
	
	for i in loaded_responses:
		if i.to_dialog_id > 0:
			$"..".connect_nodes(i.name,0,loaded_dialogs[i.to_dialog_id].name,0)
	save_category.close()
	



