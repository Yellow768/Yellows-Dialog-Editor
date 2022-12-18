class_name category_exporter
extends Node


func _ready():
	pass

func export_category(directory : String = CurrentEnvironment.current_directory+"/dialogs/",category_name : String = CurrentEnvironment.current_category_name):
	var exported_category_dir = Directory.new()
	var save_nodes = get_tree().get_nodes_in_group("Save")

	
	if !exported_category_dir.dir_exists(directory+category_name):
		exported_category_dir.make_dir(directory+category_name)
	for i in save_nodes:
		var dialog_file = File.new()
		dialog_file.open(directory+category_name+"/"+String(i.dialog_id)+".json",File.WRITE)
		var new_dict = create_dialog_dict(i)
		#var jsonprint = JSON.print(new_dict,"\r\n")
		for line in new_dict:
			dialog_file.store_line(line)
		dialog_file.close()
		
		

func create_dialog_dict(dialog):
	var options_array = []
	for i in dialog.response_options.size():
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
