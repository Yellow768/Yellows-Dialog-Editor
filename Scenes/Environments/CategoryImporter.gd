extends Node

signal save_category_request
signal clear_editor_request
signal set_current_category_path
signal category_has_ydec
signal update_current_category


export(NodePath) var _main_program_path
export(NodePath) var _dialog_list_vbox_path
export(NodePath) var _dialog_editor_path


var current_category_directory
var imported_dialogs = []
var imported_category_name

onready var MainProgram = get_node(_main_program_path)
onready var DialogButtonList = get_node(_dialog_list_vbox_path)
onready var DialogEditor = get_node(_dialog_editor_path)


func import_category(category_name):
	emit_signal("save_category_request")
	imported_dialogs = return_valid_dialog_jsons(category_name)
	if imported_dialogs.empty():
		emit_signal("clear_editor_request")
		emit_signal("update_current_category",category_name)
		emit_signal("save_category_request")	
	else:
		imported_category_name = category_name
		create_initial_dialog_tree_buttons(imported_dialogs)

func return_valid_dialog_jsons(category_name : String) -> Array:
	current_category_directory = CurrentEnvironment.current_dialog_directory+"/"+category_name
	var parsed_jsons = []
	var dir_search = DirectorySearch.new()
	var files = dir_search.scan_all_subdirectories(current_category_directory,["json"])
	if files.size() == 0 :
		return parsed_jsons
	else:
		var current_dialog = File.new()
		for file in files:
			current_dialog.open(current_category_directory+"/"+file,File.READ)
			var dialog_json_with_bad_values_replaced = JSON.parse(replace_unparseable_dialog_json_values(current_dialog))
			if !is_file_valid_dialog_json(dialog_json_with_bad_values_replaced):
				printerr("Error parsing JSON "+file+", skipping")
			else:
				parsed_jsons.append(dialog_json_with_bad_values_replaced.result)		
		parsed_jsons.sort_custom(self,"sort_array_by_dialog_title")
	return parsed_jsons

func replace_unparseable_dialog_json_values(json_file):
	var final_result = json_file.get_as_text()
	while(json_file.get_position() < json_file.get_len()):
		var current_line = json_file.get_line()
		if '"DialogShowWheel": ' in current_line or '"DialogHideNPC"' in current_line or '"DecreaseFaction1Points"' in current_line or '"DecreaseFaction2Points"' in current_line or '"BeenRead"' in current_line or '"DialogDisableEsc"' in current_line:
			var replace_line = current_line
			replace_line = current_line.replace("0b","0")
			replace_line = replace_line.replace("1b","1")
			final_result = final_result.replace(current_line,replace_line)
		if '"TimePast"' in current_line or '"Time' in current_line:
			var replace_line = current_line
			replace_line = current_line.replace("L","")
			final_result = final_result.replace(current_line,replace_line)
	return final_result

func is_file_valid_dialog_json(json_file):
	if json_file.error != OK:
		return false
	if is_json_valid_dialog_format(json_file.result):
		return true	

func is_json_valid_dialog_format(dialog_json):
	if !dialog_json.has("DialogTitle") or typeof(dialog_json["DialogTitle"]) != TYPE_STRING:
		printerr("DialogTitle is malformed")
		return false
	if !dialog_json.has("DialogId") or typeof(dialog_json["DialogId"]) != TYPE_REAL:
		printerr("DialogId is malformed")
		return false
	if !dialog_json.has("DialogText") or typeof(dialog_json["DialogText"]) != TYPE_STRING:
		printerr("DialogText is malformed")
		return false
	if !dialog_json.has("DialogQuest") or typeof(dialog_json["DialogQuest"]) != TYPE_REAL:
		printerr("DialogQuest is malformed")
		return false
	if !dialog_json.has("DialogDisableEsc") or typeof(dialog_json["DialogDisableEsc"]) != TYPE_REAL:
		printerr("DialogDisableEsc is malformed")
		return false
	if !dialog_json.has("DialogShowWheel") or typeof(dialog_json["DialogShowWheel"]) != TYPE_REAL:
		printerr("DialogShowWheel is malformed")
		return false
	if !dialog_json.has("AvailabilityMinPlayerLevel") or typeof(dialog_json["AvailabilityMinPlayerLevel"]) != TYPE_REAL:
		printerr("DialogLevelAvailability is malformed")
		return false
	if !dialog_json.has("AvailabilityDayTime") or typeof(dialog_json["AvailabilityDayTime"]) != TYPE_REAL:
		printerr("DialogDaytimeAvail is malformed")
		return false

	var id = ["","2","3","4"]
	for i in 4:
		if !dialog_json.has("AvailabilityQuest"+id[i]+"Id") or typeof(dialog_json["AvailabilityQuest"+id[i]+"Id"]) != TYPE_REAL:
			printerr("AvailabilityQuest"+id[i]+"Id"+" is malformed")
			return false
		if !dialog_json.has("AvailabilityQuest"+id[i]) or typeof(dialog_json["AvailabilityQuest"+id[i]]) != TYPE_REAL:
			printerr("AvailabilityQuest"+id[i]+" is malformed")
			return false
		if !dialog_json.has("AvailabilityDialog"+id[i]+"Id") or typeof(dialog_json["AvailabilityDialog"+id[i]+"Id"]) != TYPE_REAL:
			printerr("AvailabilityDialog"+id[i]+"Id"+" is malformed")
			return false
		if !dialog_json.has("AvailabilityDialog"+id[i]) or typeof(dialog_json["AvailabilityDialog"+id[i]]) != TYPE_REAL:
			printerr("AvailabilityDialog"+id[i]+" is malformed")
			return false
	for i in 2:
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Objective") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Objective"]) != TYPE_STRING:
			printerr("AvailabilityScoreboard"+id[i]+"Objective is malformed")
			return false
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Value") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Value"]) != TYPE_REAL:
			printerr("AvailabilityScoreboard"+id[i]+"Value is malformed")
			return false
		if !dialog_json.has("AvailabilityScoreboard"+id[i]+"Type") or typeof(dialog_json["AvailabilityScoreboard"+id[i]+"Type"]) != TYPE_REAL:
			printerr("AvailabilityScoreboard"+id[i]+"Type is malformed")
			return false
		
		if !dialog_json.has("AvailabilityFaction"+id[i]+"Id") or typeof(dialog_json["AvailabilityFaction"+id[i]+"Id"]) != TYPE_REAL:
			printerr("AvailabilityFaction"+id[i]+"Id is malformed")
			return false
		if !dialog_json.has("AvailabilityFaction"+id[i]+"Stance") or typeof(dialog_json["AvailabilityFaction"+id[i]+"Stance"]) != TYPE_REAL:
			printerr("AvailabilityFaction"+id[i]+"Stance is malformed")
			return false
		if !dialog_json.has("AvailabilityFaction"+id[i]) or typeof(dialog_json["AvailabilityFaction"+id[i]]) != TYPE_REAL:
			printerr("AvailabilityFaction"+id[i]+" is malformed")
			return false

		if !dialog_json.has("OptionFactions"+String(i+1)) or typeof(dialog_json["OptionFactions"+String(i+1)]) != TYPE_REAL:
			printerr("OptionFactions"+String(i+1)+" is malformed")
			return false
		if !dialog_json.has("OptionFaction"+String(i+1)+"Points") or typeof(dialog_json["OptionFaction"+String(i+1)+"Points"]) != TYPE_REAL:
			printerr("OptionFactions"+String(i+1)+"Points is malformed")
			return false
		if !dialog_json.has("DecreaseFaction"+String(i+1)+"Points") or typeof(dialog_json["DecreaseFaction"+String(i+1)+"Points"]) != TYPE_REAL:
			printerr("DecreaseFactions"+String(i+1)+"Points is malformed")
			return false
		
		if !dialog_json.has("Options") or typeof(dialog_json["Options"]) != TYPE_ARRAY:
			printerr("Options is malformed")
			return false
	
	var response_options_are_valid = true
	for i in dialog_json["Options"]:
		if !i.has("OptionSlot") or typeof(i["OptionSlot"]) != TYPE_REAL:
			printerr("A Response OptionSlot is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("DialogCommand") or typeof(i["Option"]["DialogCommand"]) != TYPE_STRING:
			printerr("A Response DialogCommand is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("Title") or typeof(i["Option"]["Title"]) != TYPE_STRING:
			printerr("A Response Title is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("DialogColor") or typeof(i["Option"]["DialogColor"]) != TYPE_REAL:
			printerr("A Response Color is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("OptionType") or typeof(i["Option"]["OptionType"]) != TYPE_REAL:
			printerr("A Response OptionType is malformed")
			response_options_are_valid = false
			return false
		if !i["Option"].has("Dialog") or typeof(i["Option"]["Dialog"]) != TYPE_REAL:
			printerr("A Response Dialog is malformed")
			response_options_are_valid = false
			return false
	
	if response_options_are_valid:
		return true
	else:
		return false



func sort_array_by_dialog_title(a,b):
	if a["DialogTitle"] != b["DialogTitle"]:
		return a["DialogTitle"] < b["DialogTitle"]
	else:
		return a["DialogTitle"]  < b["DialogTitle"] 

	
func create_initial_dialog_tree_buttons(dialogs_found_in_directory):
	for button in DialogButtonList.get_children():
		button.queue_free()
	for i in dialogs_found_in_directory.size():
		var dialog_button = Button.new()
		dialog_button.text = dialogs_found_in_directory[i]["DialogTitle"]
		dialog_button.connect("pressed",self,"initial_dialog_chosen",[i])
		DialogButtonList.add_child(dialog_button)	
	$PopupPanel.visible = true
	


var loaded_dialog_nodes = []
var loaded_responses = []
var unimported_dialog_position = Vector2(300,300)

func initial_dialog_chosen(index):
	emit_signal("clear_editor_request")	
	create_nodes_from_index(index)


func create_nodes_from_index(index : int = 0):
	if index > imported_dialogs.size():
		printerr("The set index was larger than imported_dialogs size")
		index = 0
	if imported_dialogs.empty():
		printerr("There are no dialogs to import")
		return
	CurrentEnvironment.loading_stage = true
	create_dialog_from_json(imported_dialogs[index],unimported_dialog_position)
	if !imported_dialogs.empty():
		unimported_dialog_position += Vector2(300,300)
		create_nodes_from_index(0)
	else:
		unimported_dialog_position = Vector2(300,300)
		emit_signal("update_current_category",imported_category_name)
		emit_signal("save_category_request")
		loaded_dialog_nodes = []
		loaded_responses = []
		CurrentEnvironment.loading_stage = false
	
	$PopupPanel.visible = false
	
func create_dialog_from_json(current_json,offset):
	var new_node = DialogEditor.add_dialog_node(offset,current_json["DialogTitle"],-1,true)
	new_node = update_dialog_node_information(new_node,current_json)
	imported_dialogs.erase(current_json)
	loaded_dialog_nodes.append(new_node)
	create_dialogs_from_responses(new_node)
	return new_node				

func create_dialogs_from_responses(dialog):
	print(dialog.dialog_title)
	for response in dialog.response_options:
		print(response)
		if response.to_dialog_id != -1 && response.option_type == 0:
			for loaded_dialog in loaded_dialog_nodes:
				if loaded_dialog.dialog_id == response.to_dialog_id:
					DialogEditor.connect_nodes(response.get_name(),0,loaded_dialog.get_name(),0)
			for json_dialog in imported_dialogs:
				if json_dialog["DialogId"] == response.to_dialog_id:
					var connected_dialog = create_dialog_from_json(json_dialog,response.offset+Vector2(320,0))
					DialogEditor.connect_nodes(response.get_name(),0,connected_dialog.get_name(),0)
		loaded_responses.append(response)

				
func reimport_category(category_name = CurrentEnvironment.current_category_name):
	emit_signal("clear_editor_request")
	loaded_dialog_nodes = []
	import_category(category_name)

func scan_category_for_changes(category_name = CurrentEnvironment.current_category_name):
	loaded_dialog_nodes = []
	loaded_responses = []
	var updated_dialog_nodes = []
	var parsed_jsons = return_valid_dialog_jsons(category_name)
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
	
	for i in json["Options"]:
		var response = DialogEditor.add_response_node(node)
		response.slot = i["OptionSlot"]
		response.command = i["Option"]["DialogCommand"]
		response.to_dialog_id = i["Option"]["Dialog"]
		response.response_title = i["Option"]["Title"]
		response.color_decimal = i["Option"]["DialogColor"]
		response.initial_color = "Color("+String(int_to_color(int(i["Option"]["DialogColor"])))+")"
		response.option_type = response.get_option_id(i["Option"]["OptionType"])
	return node




func int_to_color(integer):
	var r = (integer >> 16) & 0xff
	var g = (integer >> 8) & 0xff
	var b = integer & 0xff
	var color = Color(1,1,1)
	color.r8 = r
	color.g8 = g
	color.b8 = b
	return color


func _on_CategoryPanel_import_category_request(category_name):
	import_category(category_name)



func _on_CancelButton_pressed():
	$PopupPanel.visible = false




