extends Panel

onready var file_button = $TopPanelContainer/File
var response_node = load("res://Scenes/Nodes/ResponseNode.tscn")
var array_god = []

func _ready():
	var file_popup = file_button.get_popup()
	file_popup.connect("id_pressed",self,"file_menu")

func file_menu(id):
	match id:
		2:
			save_category()
		10:
			load_category()
		9:
			export_category()
		6:
			read_file()

func read_file():
	var array_of_shit = ["test",'test2','"Time": '+String(56)]
	var read_category = File.new()
	var write_category = File.new()
	read_category.open("user://96.json",File.READ)
	write_category.open("user://test.json",File.WRITE)
	while(read_category.get_position() < read_category.get_len()):
		var cool_thing = read_category.get_line()
		array_of_shit.append(cool_thing)
		
	read_category.close()
	
	print(array_of_shit)
	for i in array_of_shit:
		write_category.store_line(i)
	array_god = array_of_shit
	write_category.close()

func export_category():
	var exported_category_dir = Directory.new()
	var save_nodes = get_tree().get_nodes_in_group("Save")

	exported_category_dir.open("user://")
	if !exported_category_dir.dir_exists("new_category"):
		exported_category_dir.make_dir("new_category")

	for i in save_nodes:
		var dialog_file = File.new()
		dialog_file.open(exported_category_dir.get_current_dir()+String(i.dialog_id)+".json",File.WRITE)
		var new_dict = create_dialog_dict(i)
		#var jsonprint = JSON.print(new_dict,"\r\n")
		for line in new_dict:
			dialog_file.store_line(line)
		dialog_file.close()
		
		

func create_dialog_dict(dialog):
	var options_array = []
	for i in dialog.response_options.size():
		print(String(i)+"  "+String(dialog.response_options.size()))
		var new_option_dict = create_option_dict(dialog.response_options[i],i==dialog.response_options.size()-1)
		for line in new_option_dict:
			options_array.append(line)
	
	var dialog_json_array = [
	'{',
	'	"DialogShowWheel": '+String(int(dialog.show_wheel))+'b,',
	'	"AvailabilityQuestId": '+String(dialog.quest_availabilities[0].quest_id)+',',
	'	"Options": '+String(options_array)+',',
	'	"AvailabilityScoreboardType": '+String(dialog.scoreboard_availabilities[0].comparison_type)+',',
	'	"DialogHideNPC": '+String(int(dialog.hide_npc))+'b,',
	'	"AvailabilityFactionStance": '+String(dialog.faction_availabilities[0].stance_type)+',',
	'	"AvailabilityScoreboard2Value": '+String(dialog.scoreboard_availabilities[1].value)+',',
	'	"DialogId": '+String(dialog.dialog_id)+',',
	'	"AvailabilityQuest": '+String(dialog.quest_availabilities[0].availability_type)+',',
	'	"AvailabilityDialog4": '+String(dialog.dialog_availabilities[3].availability_type)+',',
	'	"AvailabilityScoreboardObjective": "'+String(dialog.scoreboard_availabilities[0].objective_name)+'",',
	'	"AvailabilityDialog3": '+String(dialog.dialog_availabilities[2].availability_type)+',',
	'	"AvailabilityQuest2": '+String(dialog.quest_availabilities[1].availability_type)+',',
	'	"AvailabilityQuest3": '+String(dialog.quest_availabilities[2].availability_type)+',',
	'	"AvailabilityScoreboard2Objective": "'+String(dialog.scoreboard_availabilities[1].objective_name)+'",',
	'	"AvailabilityQuest4": '+String(dialog.quest_availabilities[3].availability_type)+',',
	'	"ModRev": '+String(18)+',',
	'	"DecreaseFaction1Points": '+String(dialog.faction_changes[0].operator)+'b,',
	'	"DialogQuest": '+String(dialog.start_quest)+',',
	'	"AvailabilityDialog2": '+String(dialog.dialog_availabilities[1].availability_type)+',',
	'	"OptionFactions1": '+String(dialog.faction_changes[0].faction_id)+',',
	'	"AvailabilityDayTime": '+String(dialog.time_availability)+',',
	'	"OptionFactions2": '+String(dialog.faction_changes[1].faction_id)+',',
	'	"AvailabilityFaction2Id": '+String(dialog.faction_availabilities[1].faction_id)+',',
	'	"OptionFaction1Points": '+String(abs(dialog.faction_changes[0].points))+',',
	'	"AvailabilityScoreboardValue": '+String(dialog.scoreboard_availabilities[0].value)+',',
	'	"DialogDisableEsc": '+String(int(dialog.disable_esc))+'b,',
	'	"AvailabilityFaction": '+String(dialog.faction_availabilities[0].availability_operator)+',',
	'	"DialogTitle": "'+String(dialog.dialog_title)+'",',
	'	"AvailabilityDialog": '+String(dialog.dialog_availabilities[0].availability_type)+',',
	'	"AvailabilityScoreboard2Type": '+String(dialog.scoreboard_availabilities[1].comparison_type)+',',
	'	"AvailabilityFaction2": '+String(dialog.faction_availabilities[1].availability_operator)+',',
	'	"AvailabilityFactionId": '+String(dialog.faction_availabilities[0].faction_id)+',',
	'	"AvailabilityFaction2Stance": '+String(dialog.faction_availabilities[1].stance_type)+',',
	'	"DialogCommand": "'+ String(dialog.command)+'",',
	'	"AvailabilityDialogId": '+String(dialog.dialog_availabilities[0].dialog_id)+',',
	'	"OptionFaction2Points": '+String(abs(dialog.faction_changes[1].points))+',',
	'	"DialogText": "'+String(dialog.text)+'",',
	'	"AvailabilityQuest4Id": '+String(dialog.quest_availabilities[3].quest_id)+',',
	'	"AvailabilityQuest3Id": '+String(dialog.quest_availabilities[2].quest_id)+',',
	'	"AvailabilityQuest2Id": '+String(dialog.quest_availabilities[1].quest_id)+',',
	'	"AvailabilityDialog2Id": '+String(dialog.dialog_availabilities[1].dialog_id)+',',
	'	"AvailabilityDialog3Id": '+String(dialog.dialog_availabilities[2].dialog_id)+',',
	'	"AvailabilityDialog4Id": '+String(dialog.dialog_availabilities[3].dialog_id)+',',
	'	"AvailabilityMinPlayerLevel": '+String(dialog.min_level_availability)+',',
	'	"DecreaseFaction2Points": '+String(dialog.faction_changes[0].operator)+'b,',
		'	"DialogMail": {',
		'		"Sender": "",',
		'		"BeenRead": 0,',
		'		"Message": {',
		'		},',
		'		"MailItems": [',
		'		],',
		'		"MailQuest": -1,',
		'		"TimePast": 1669491043541L,',
		'		"Time": 0L,',
		'		"Subject": ""',
		'	}',
	'}'
	]
	return dialog_json_array
	


		
func create_option_dict(response,islast):
	print(islast)
	var response_dict = []
	if islast == false:
		response_dict = [
				'\n		{\n			"OptionSlot": '+String(response.slot-1),
				'\n			"Option": {\n				"DialogCommand": "'+String(response.command)+'"',
					'\n				"Dialog": '+String(response.to_dialog_id),
					'\n				"Title": "'+String(response.response_title)+'"',
					'\n				"DialogColor": '+String(response.color_decimal),
					'\n				"OptionType": '+String(response.option_type)+"\n			}\n		}",	
			]
	else:
		response_dict = [
				'\n		{\n			"OptionSlot": '+String(response.slot-1),
				'\n			"Option": {\n				"DialogCommand": "'+String(response.command)+'"',
					'\n				"Dialog": '+String(response.to_dialog_id),
					'\n				"Title": "'+String(response.response_title)+'"',
					'\n				"DialogColor": '+String(response.color_decimal),
					'\n				"OptionType": '+String(response.option_type)+"\n			}\n		}\n	",	
			]
	return response_dict	
	

func save_category():
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
	

	


