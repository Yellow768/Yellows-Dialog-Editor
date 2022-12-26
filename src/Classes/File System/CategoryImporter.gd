class_name category_importer
extends Node

signal save_category_request
signal clear_editor_request
signal update_current_category
signal request_add_dialog
signal request_add_response
signal request_connect_nodes


var current_category_directory
var imported_category_name
var imported_dialogs = []






var loaded_dialog_nodes = []
var loaded_responses = []
var unimported_dialog_position = Vector2(300,300)

func initial_dialog_chosen(category_name,dialog_jsons,index):
	emit_signal("clear_editor_request")	
	imported_dialogs = dialog_jsons
	create_nodes_from_index(category_name,index)


func create_nodes_from_index(category_name, index : int = 0):
	if index > imported_dialogs.size():
		printerr("The set index was larger than imported_dialogs size")
		index = 0
	if imported_dialogs.empty():
		printerr("There are no dialogs to import")
		return
	create_dialog_from_json(imported_dialogs[index],unimported_dialog_position)
	if !imported_dialogs.empty():
		unimported_dialog_position += Vector2(300,300)
		create_nodes_from_index(category_name,0)
	else:
		unimported_dialog_position = Vector2(300,300)
		emit_signal("update_current_category",imported_category_name)
		emit_signal("save_category_request")
		loaded_dialog_nodes = []
		loaded_responses = []
	
func create_dialog_from_json(current_json,offset):
	var new_node = GlobalDeclarations.DIALOG_NODE.instance()
	new_node.offset = offset
	new_node = update_dialog_node_information(new_node,current_json)
	imported_dialogs.erase(current_json)
	loaded_dialog_nodes.append(new_node)
	emit_signal("request_add_dialog",new_node,true)
	create_response_nodes_from_json(new_node,current_json)
	create_dialogs_from_responses(new_node)
	return new_node				

func create_dialogs_from_responses(dialog):
	for response in dialog.response_options:
		if response.to_dialog_id != -1 && response.option_type == 0:
			for loaded_dialog in loaded_dialog_nodes:
				if loaded_dialog.dialog_id == response.to_dialog_id:
					emit_signal("request_connect_nodes",response.get_name(),0,loaded_dialog.get_name(),0)
					
			for json_dialog in imported_dialogs:
				if json_dialog["DialogId"] == response.to_dialog_id:
					var connected_dialog = create_dialog_from_json(json_dialog,response.offset+Vector2(320,0))
					
					emit_signal("request_connect_nodes",response.get_name(),0,connected_dialog.get_name(),0)		
		loaded_responses.append(response)


func scan_category_for_changes(category_name = CurrentEnvironment.current_category_name):
	loaded_dialog_nodes = []
	loaded_responses = []
	var updated_dialog_nodes = []
	var parsed_jsons = dialog_jsons_loader.new().get_dialog_jsons(category_name)
	imported_dialogs = parsed_jsons.duplicate()
	imported_category_name = category_name
	var current_dialog_nodes = get_tree().get_nodes_in_group("Save")
	for current_dialog in current_dialog_nodes:
		loaded_dialog_nodes.append(current_dialog)
	for json in parsed_jsons:
		for current in current_dialog_nodes:
			if json["DialogId"] == current.dialog_id:
				current.clear_responses()
				update_dialog_node_information(current,json)
				create_response_nodes_from_json(current,json)
				updated_dialog_nodes.append(current)
				imported_dialogs.erase(json)
	for updated_dialog in updated_dialog_nodes:
		create_dialogs_from_responses(updated_dialog)
	if !imported_dialogs.empty():
		create_nodes_from_index(0)
	
		
	
	

func update_dialog_node_information(node,json):
	node.dialog_title = json["DialogTitle"]
	node.dialog_id = json["DialogId"]
	node.text = json["DialogText"]
	node.disable_esc = bool(json["DialogDisableEsc"])
	node.show_wheel = bool(json["DialogShowWheel"])
	node.start_quest = json["DialogQuest"]
	node.min_level_availability = json["AvailabilityMinPlayerLevel"]
	node.time_availability = json["AvailabilityDayTime"]
	var id = ["","2","3","4"]
	for i in 4:
		node.quest_availabilities[i].quest_id = json["AvailabilityQuest"+id[i]+"Id"]
		node.quest_availabilities[i].availability_type = json["AvailabilityQuest"+id[i]]
		node.dialog_availabilities[i].dialog_id = json["AvailabilityDialog"+id[i]+"Id"]
		node.dialog_availabilities[i].availability_type = json["AvailabilityDialog"+id[i]]
	for i in 2:
		node.scoreboard_availabilities[i].objective_name = json["AvailabilityScoreboard"+id[i]+"Objective"]
		node.scoreboard_availabilities[i].value = json["AvailabilityScoreboard"+id[i]+"Value"]
		node.scoreboard_availabilities[i].comparison_type = json["AvailabilityScoreboard"+id[i]+"Type"]
		
		node.faction_availabilities[i].faction_id = json["AvailabilityFaction"+id[i]+"Id"]
		node.faction_availabilities[i].stance_type = json["AvailabilityFaction"+id[i]+"Stance"]
		node.faction_availabilities[i].availability_operator = json["AvailabilityFaction"+id[i]]
		
		var operator = [1,-1]
		node.faction_changes[i].faction_id = json["OptionFactions"+String(i+1)]
		node.faction_changes[i].points = json["OptionFaction"+String(i+1)+"Points"] * operator[json["DecreaseFaction"+String(i+1)+"Points"]]
	
	
	return node


func create_response_nodes_from_json(node,json):
	for i in json["Options"]:
		var response = GlobalDeclarations.RESPONSE_NODE.instance() 
		response.slot = i["OptionSlot"]
		response.command = i["Option"]["DialogCommand"]
		response.to_dialog_id = i["Option"]["Dialog"]
		response.response_title = i["Option"]["Title"]
		response.color_decimal = i["Option"]["DialogColor"]
		response.set_option_from_json_index(i["Option"]["OptionType"])
		emit_signal("request_add_response",node,response)