extends Node

const RESPONSE_NODE_VERTICAL_OFFSET := 100
const DIALOG_NODE_HORIZONTAL_OFFSET := 400

var user_settings_path = "user://user_settings.cfg"

var DIALOG_NODE := preload("res://src/Nodes/DialogNode.tscn")
var RESPONSE_NODE := preload("res://src/Nodes/ResponseNode.tscn")
var COLOR_ORGANIZER := preload("res://src/Nodes/color_organizer.tscn")

enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 


var dialog_left_slot_color := Color(0.172549, 0.239216, 0.592157)
var dialog_right_slot_color := Color(0.94902, 0.282353, 0.078431)

var response_left_slot_color := Color(0.94902, 0.282353, 0.078431)
var response_right_slot_color := Color(0.172549, 0.239216, 0.592157)

var response_right_slot_color_hidden := Color(1,0,1)
var dialog_left_slot_color_hidden := Color(1,0,1)

var hide_connection_distance
var hold_shift_for_individual_movement = false
var snap_enabled := true
var color_presets : PackedColorArray
var autosave_time := 3
var autosave_max_files := 10
var enable_customnpcs_plus_options := false
var last_used_export_version := 2
var spacing_presets : Dictionary = {}
var spacing_presets_stringified : String

var allow_above_six_responses := false

var default_user_directory := OS.get_data_dir()+"/.minecraft/saves"

var actions : Array[String] = ["focus_above","focus_below","focus_left","focus_right","zoom_key","drag_responses_key","delete_nodes","add_dialog_at_mouse","create_response","zoom_in","zoom_out","select_multiple","save","export","scan_for_changes","reimport_category","swap_responses"]

var assigning_keybind = false

var language = OS.get_locale()

func _ready():
	var config = ConfigFile.new()
	config.load("user://user_settings.cfg")
	hide_connection_distance = config.get_value("user_settings","hide_connection_distance",1000)
	hold_shift_for_individual_movement = config.get_value("user_settings","hold_shift_for_individual_movement",false)
	snap_enabled = config.get_value("user_settings","snap_enabled",snap_enabled)
	color_presets = config.get_value("user_settings","color_presets",color_presets)
	autosave_time = config.get_value("user_settings","autosave_time",autosave_time)
	autosave_max_files = config.get_value("user_settings","autosave_max_files",autosave_max_files)
	default_user_directory = config.get_value("user_settings","default_user_directory",default_user_directory)
	allow_above_six_responses = config.get_value("user_settings","allow_above_six_responses",allow_above_six_responses)
	enable_customnpcs_plus_options = config.get_value("user_settings","enable_customnpcs_plus_options",enable_customnpcs_plus_options)
	last_used_export_version = config.get_value("user_settings","last_used_export_version",last_used_export_version)
	spacing_presets_stringified = config.get_value("user_settings","spacing_presets","{}")
	spacing_presets = JSON.parse_string(spacing_presets_stringified)
	language = config.get_value("user_settings","language",language)
	TranslationServer.set_locale(language)
	for action in actions:
		var temp_action = InputMap.action_get_events(action)
		InputMap.action_erase_events(action)
		for event in config.get_value("keybinds",action,temp_action):
			InputMap.action_add_event(action,event)
		
func save_config():
	var config = ConfigFile.new()
	config.load(user_settings_path)
	config.set_value("user_settings","hide_connection_distance",hide_connection_distance)
	config.set_value("user_settings","hold_shift_for_individual_movement",hold_shift_for_individual_movement)
	config.set_value("user_settings","snap_enabled",snap_enabled)
	config.set_value("prev_dirs","dir_array",config.get_value("prev_dirs","dir_array","[]"))
	config.set_value("user_settings","color_presets",color_presets)
	config.set_value("user_settings","autosave_time",autosave_time)
	config.set_value("user_settings","autosave_max_files",autosave_max_files)
	config.set_value("user_settings","allow_above_six_responses",allow_above_six_responses)
	config.set_value("user_settings","default_user_directory",default_user_directory)
	config.set_value("user_settings","language",language)
	config.set_value("user_settings","enable_customnpcs_plus_options",enable_customnpcs_plus_options)
	config.set_value("user_settings","last_used_export_version",last_used_export_version)
	config.set_value("user_settings","spacing_presets",JSON.stringify(spacing_presets))
	for action in actions:
		config.set_value("keybinds",action,InputMap.action_get_events(action))
	config.save(user_settings_path)

func add_color_preset(preset):
	color_presets.append(preset)
	save_config()
	
func remove_color_preset(preset):
	color_presets.append(preset)
	save_config()

func int_to_color(integer : int) -> Color:
	var r = (integer >> 16) & 0xff
	var g = (integer >> 8) & 0xff
	var b = integer & 0xff
	var color = Color(1,1,1)
	color.r8 = r
	color.g8 = g
	color.b8 = b
	return color
