class_name category_importer
extends Node

signal save_category_request
signal clear_editor_request
signal request_add_dialog
signal request_add_response
signal request_connect_nodes
signal editor_offset_loaded
signal request_arrange_nodes

var current_category_directory
var imported_category_name : String
var imported_dialogs : Array[Dictionary] = []






var loaded_dialog_nodes :Array[dialog_node]= []
var loaded_responses :Array[response_node]= []
var unimported_dialog_position : Vector2 = Vector2(300,300)

func initial_dialog_chosen(category_name : String,dialog_jsons : Array[Dictionary],index : int):
	emit_signal("clear_editor_request")	
	imported_dialogs = dialog_jsons
	create_nodes_from_index(category_name,index)
	emit_signal("request_arrange_nodes")



func create_nodes_from_index(category_name : String, index : int = 0):
	if index > imported_dialogs.size():
		printerr("The set index was larger than imported_dialogs size")
		index = 0
	if imported_dialogs.is_empty():
		printerr("There are no dialogs to import")
		return
	create_dialog_from_json(imported_dialogs[index],unimported_dialog_position)
	if !imported_dialogs.is_empty():
		unimported_dialog_position += Vector2(0,700)
		create_nodes_from_index(category_name,0)
	else:
		unimported_dialog_position = Vector2(300,300)
		#emit_signal("save_category_request")
		loaded_dialog_nodes = []
		loaded_responses = []
	
func create_dialog_from_json(current_json :Dictionary ,offset : Vector2) -> dialog_node:
	var new_node : dialog_node = GlobalDeclarations.DIALOG_NODE.instantiate()
	new_node.position_offset = offset
	#emit_signal("editor_offset_loaded",new_node.offset)
	new_node = update_dialog_node_information(new_node,current_json)
	imported_dialogs.erase(current_json)
	loaded_dialog_nodes.append(new_node)
	emit_signal("request_add_dialog",new_node,true)
	create_response_nodes_from_json(new_node,current_json)
	create_dialogs_from_responses(new_node)
	return new_node				

func create_response_nodes_from_json(node : dialog_node,json : Dictionary) -> int:
	var total_num_of_responses = 0
	for i in json["Options"]:
		var response : response_node = GlobalDeclarations.RESPONSE_NODE.instantiate() 
		response.slot = i["OptionSlot"]
		if i["Option"].has(["DialogCommand"]):
			response.option_command = i["Option"]["DialogCommand"]
		response.to_dialog_id = i["Option"]["Dialog"]
		response.response_title = i["Option"]["Title"]
		response.response_text = i["Option"]["Text"]
		response.color_decimal = i["Option"]["DialogColor"]
		if i["Option"].has("Commands"):
			for command in i["Option"]["Commands"]:
				response.commands.append(command["Line"])
		response.set_option_from_json_index(i["Option"]["OptionType"])
		emit_signal("request_add_response",node,response)
	return total_num_of_responses
	

func create_dialogs_from_responses(dialog : dialog_node):
	for response in dialog.response_options:
		if response.to_dialog_id != -1 && response.option_type == 0:
			for loaded_dialog in loaded_dialog_nodes:
				if loaded_dialog.dialog_id == response.to_dialog_id:
					emit_signal("request_connect_nodes",response,0,loaded_dialog,0)
					
			for json_dialog in imported_dialogs:
				if json_dialog["DialogId"] == response.to_dialog_id:
					var connected_dialog : dialog_node = create_dialog_from_json(json_dialog,response.position_offset+Vector2(GlobalDeclarations.DIALOG_NODE_HORIZONTAL_OFFSET,0))
					
					emit_signal("request_connect_nodes",response,0,connected_dialog,0)		
		loaded_responses.append(response)


func scan_category_for_changes(category_name : String = CurrentEnvironment.current_category_name):
	loaded_dialog_nodes = []
	loaded_responses = []
	var updated_dialog_nodes : Array[dialog_node]= []
	var parsed_jsons := dialog_jsons_loader.new().get_dialog_jsons(category_name)
	imported_dialogs = parsed_jsons.duplicate()
	imported_category_name = category_name
	var current_dialog_nodes = get_tree().get_nodes_in_group("Save")
	for current_dialog in current_dialog_nodes:
		loaded_dialog_nodes.append(current_dialog)
	for json in parsed_jsons:
		for current in current_dialog_nodes:
			if current.node_type != "Dialog Node":
				continue
			if json["DialogId"] == current.dialog_id:
				for i in json["Options"].size():
					if i <= current.response_options.size():
						
						var response = current.response_options[i]
						response.slot = json["Options"][i]["OptionSlot"]
						response.set_command(json["Options"][i]["Option"]["DialogCommand"])
						response.set_connected_dialog(find_dialog_node_from_id(json["Options"][i]["Option"]["Dialog"])) 
						response.set_response_title(json["Options"][i]["Option"]["Title"])
						response.color_decimal = json["Options"][i]["Option"]["DialogColor"]
						response.set_option_from_json_index(json["Options"][i]["Option"]["OptionType"])
					else:
						var response : response_node = GlobalDeclarations.RESPONSE_NODE.instantiate() 
						response.slot = json["Options"][i]["OptionSlot"]
						response.command = json["Options"][i]["Option"]["DialogCommand"]
						response.to_dialog_id = json["Options"][i]["Option"]["Dialog"]
						response.response_title = json["Options"][i]["Option"]["Title"]
						response.color_decimal = json["Options"][i]["Option"]["DialogColor"]
						response.set_option_from_json_index(json["Options"][i]["Option"]["OptionType"])
						emit_signal("request_add_response",current,response)
						response.set_connected_dialog(find_dialog_node_from_id(json["Options"][i]["Option"]["Dialog"])) 
				update_dialog_node_information(current,json)
				updated_dialog_nodes.append(current)
				imported_dialogs.erase(json)
	if !imported_dialogs.is_empty():
		create_nodes_from_index(category_name,0)
	
		
func find_dialog_node_from_id(id : int):
	var dialog_nodes = get_tree().get_nodes_in_group("Save")
	for dialog in dialog_nodes:
		if dialog.dialog_id == id:
			return dialog	
	

func update_dialog_node_information(node : dialog_node,json : Dictionary) -> dialog_node:
	if node.node_type != "Dialog Node":
		return
	node.dialog_title = json["DialogTitle"]
	node.dialog_id = json["DialogId"]
	node.text = json["DialogText"]
	node.disable_esc = bool(json["DialogDisableEsc"])
	node.show_wheel = bool(json["DialogShowWheel"])
	node.start_quest = json["DialogQuest"]
	node.min_level_availability = json["AvailabilityMinPlayerLevel"]
	node.time_availability = json["AvailabilityDayTime"]
	if json.has("DialogAlignment"):
		print("Dialog "+str(json["DialogId"])+" has CustomNPCs+ formatting. Importing settings")
		node.visual_preset = 0
		node.spacing_preset = 0
		node.lock_spacing_preset = false
		node.lock_visual_preset = false
		node.alignment = bool(json["DialogAlignment"])
		node.option_offset_x = json["OptionOffsetX"]
		node.option_offset_y = json["OptionOffsetY"]
		node.text_offset_x = json["TextOffsetX"]
		node.text_offset_y = json["TextOffsetY"]
		node.title_pos = json["TitlePos"]
		node.title_color = json["TitleColor"]
		node.show_response_options = bool(json["ShowOptionLine"])
		node.dialog_color = json["Color"]
		node.npc_scale = json["NPCScale"]
		node.text_sound = json["TextSound"]
		node.text_pitch = json["TextPitch"]
		node.npc_offset_x = json["NPCOffsetX"]
		node.npc_offset_y = json["NPCOffsetY"]
		node.text_height = json["TextHeight"]
		node.text_width = json["TextWidth"]
		node.option_spacing_x = json["OptionSpaceX"]
		node.option_spacing_y = json["OptionSpaceY"]
		node.title_offset_x = json["TitleOffsetX"]
		node.title_offset_y = json["TitleOffsetY"]
		node.darken_screen = bool(json["DialogDarkScreen"])
		node.show_previous_dialog = json["PreviousBlocks"]
		for image in json["Images"]:
			node.image_dictionary[int(image["ID"])] = {
				"PosX" : image["PosX"],
				"PosY" : image["PosY"],
				"Color" :image["Color"],
				"TextureY" : image["TextureY"],
				"TextureX" : image["TextureX"],
				"Scale" : image["Scale"],
				"SelectedColor" : image["SelectedColor"],
				"Texture" : image["Texture"],
				"Rotation" : image["Rotation"],
				"ImageType" : image["ImageType"],
				"Alignment" : image["Alignment"],
				"Alpha" : image["Alpha"],
				"Height" : image["Height"],
				"Width" : image["Width"]
			}
		
		
	var id := ["","2","3","4"]
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
		
		if json.has("OptionFactions1"):
			var operator := [1,-1]
			node.faction_changes.append(faction_change_object.new())
			node.faction_changes[i].faction_id = json["OptionFactions"+str(i+1)]
			node.faction_changes[i].points = json["OptionFaction"+str(i+1)+"Points"] * operator[json["DecreaseFaction"+str(i+1)+"Points"]]
		
	for faction_change in json["Points"]:
		var operator := [1,-1]
		var new_faction_change = faction_change_object.new()
		node.faction_changes.append(new_faction_change)
		new_faction_change.faction_id = faction_change["Faction"]
		new_faction_change.points = faction_change["Points"] * operator[faction_change["Decrease"]]
	for command in json["DialogCommands"]:
		node.commands.append(command["Line"])
	if json.has("DialogCommand"):
		node.commands.append(json["DialogCommand"])
	
	node.mail.sender = json["DialogMail"]["Sender"]
	node.mail.subject = json["DialogMail"]["Subject"]
	node.mail.quest_id = json["DialogMail"]["MailQuest"]
	
	if json["DialogMail"].has("Message") && json["DialogMail"]["Message"].has("pages"):
		for page in json["DialogMail"]["Message"]["pages"]:
			node.mail.pages.append(page.c_unescape())
	if json["DialogMail"].has("Text"):
		node.mail.pages.append(json["DialogMail"]["Text"])
	var mail_items
	if json["DialogMail"].has("MailItems"):
		mail_items = json["DialogMail"]["MailItems"]
	else:
		mail_items = json["DialogMail"]["MailIItems"]
	for item in mail_items:
		var item_as_string := JSON.stringify(item,"	",false)
		item_as_string = item_as_string.replace('"Slot": 0,',"")
		item_as_string = item_as_string.replace('"Slot": 1,',"")
		item_as_string = item_as_string.replace('"Slot": 2,',"")
		item_as_string = item_as_string.replace('"Slot": 3,',"")
		item_as_string = item_as_string.replace('"Slot": 4,',"")
		item_as_string = item_as_string.substr(1,item_as_string.length()-2)
		item_as_string = item_as_string.strip_edges()
		item_as_string = item_as_string.replace("\\n","\n")
		var regex = RegEx.new()
		regex.compile('"(\\d+\\.?\\d*[bf])"')
		node.mail.items_slots[int(item["Slot"])] = {"id":"","count":0,"custom_nbt":regex.sub(item_as_string,"$1",true)}
	
	return node



