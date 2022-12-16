class_name category_loader
extends Node

signal clear_editor_request
signal update_current_category
signal add_dialog
signal add_response


func load_category(category_name):
	emit_signal("clear_editor_request")
	var current_category_path = CurrentEnvironment.current_directory+"/dialogs/"+category_name+"/"+category_name+".ydec"
	var save_category = File.new()
	if not save_category.file_exists(current_category_path):
		print("Not a valid path")
	else:
		var loaded_dialogs = []
		var loaded_responses = []	
		if save_category.open(current_category_path,File.READ) != OK:
			pass
		else:
			while(save_category.get_position() < save_category.get_len()):
				var node_data = parse_json(save_category.get_line())
				var currently_loaded_dialog = create_new_dialog_node_from_ydec(node_data)
				emit_signal("add_dialog",currently_loaded_dialog,true)
				for response_data in node_data["response_options"]:
					var currently_loaded_response = create_response_node_from_ydec(response_data)
					emit_signal("add_response",currently_loaded_dialog,currently_loaded_response)
					loaded_responses.append(currently_loaded_response)
				loaded_dialogs.append(currently_loaded_dialog)
			for i in loaded_responses:
				var connected_dialog
				for dialog in loaded_dialogs:
					if dialog.dialog_id == i.to_dialog_id:
						connected_dialog = dialog
				if i.to_dialog_id > 0:
					emit_signal("connect_nodes",i.name,0,connected_dialog.name,0)
			save_category.close()
			emit_signal("update_current_category",category_name)


func create_new_dialog_node_from_ydec(node_data):
	var currently_loaded_dialog = GlobalDeclarations.DIALOG_NODE.instance()
	currently_loaded_dialog.offset = Vector2(node_data["offset.x"],node_data["offset.y"])
	for i in node_data.keys():
		if i == "offset.x" or i == "offset.y" or i == "filename" or i == "quest_availabilities" or i == "dialog_availabilities" or i == "faction_availabilities" or i == "scoreboard_availabilities" or i == "faction_changes" or i == "response_options":
			continue
		currently_loaded_dialog.set(i, node_data[i])
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
	return currently_loaded_dialog

func create_response_node_from_ydec(response_data):
	var currently_loaded_response = GlobalDeclarations.RESPONSE_NODE.instance()
	currently_loaded_response.slot = response_data.slot
	currently_loaded_response.color_decimal = response_data.color_decimal
	currently_loaded_response.to_dialog_id = response_data.to_dialog_id
	currently_loaded_response.command = response_data.command
	currently_loaded_response.option_type = response_data.option_type
	currently_loaded_response.response_title = response_data.response_title
	return currently_loaded_response
	
