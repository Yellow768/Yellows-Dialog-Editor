class_name dialog_node
extends GraphNode
enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 

const RESPONSE_VERTICAL_OFFSET = 60
const RESPONSE_HORIZONTAL_OFFSET = 350

signal add_response_request
signal delete_response_node
signal dialog_ready_for_deletion
signal set_self_as_selected
signal text_changed

export(NodePath) var _dialog_text_path
export(NodePath) var _title_text_path
export(NodePath) var _add_response_path
export(NodePath) var _id_label_path

onready var title_text_node = get_node(_title_text_path)
onready var dialog_text_node = get_node(_dialog_text_path)
onready var add_response_button_node = get_node(_add_response_path)
onready var id_label_node = get_node(_id_label_path)
onready var dialog_editor = get_parent().get_parent()


var node_type = "Dialog Node" 
var node_index = 0
var response_options = []
var connected_responses = []
var initial_offset_y = 0

##Dialog Data#

export var dialog_title = 'New Dialog' setget set_dialog_title

#Immutable
export var dialog_id = -1 setget set_dialog_id

#Display

export var show_wheel = false
export var hide_npc = false
export var disable_esc = false

#String Inputs
export var command = ''
export var sound = ''
var text = '' setget set_dialog_text


#Availabilities
var dialog_availabilities = []
var quest_availabilities = []
var scoreboard_availabilities = []
var faction_availabilities = []

export(int,"Always","Night","Day") var time_availability = 0
export var min_level_availability = 0



#Outcomes
var faction_changes = []
export var start_quest = -1



func _ready():
	initial_offset_y = offset.y
	set_slot(1,true,CONNECTION_TYPES.PORT_INTO_DIALOG,Color(0,0,1,1),true,CONNECTION_TYPES.PORT_FROM_DIALOG,Color(0,1,0,1))
	id_label_node.text = "ID: "+String(dialog_id)
	title_text_node.text = dialog_title
	for i in 4:
		dialog_availabilities.append(dialog_availability_object.new())
		quest_availabilities.append(quest_availability_object.new())
		
	for i in 2:
		scoreboard_availabilities.append(scoreboard_availability_object.new())
		faction_availabilities.append(faction_availability_object.new())
		faction_changes.append(faction_change_object.new())
		
	for i in response_options:
		i.check_dialog_distance()
		i.update_connection_text()
	for i in connected_responses:
		i.check_dialog_distance()
		i.update_connection_text()


	


func delete_self():
	while response_options.size() > 0:
		for i in response_options:
			i.delete_self()
	while connected_responses.size() > 0:
		for i in connected_responses:
			if i.connected_dialog == self:
				i.disconnect_from_dialog()
			connected_responses.erase(i)
	emit_signal("dialog_ready_for_deletion",self)
	
	


func add_response_node():
	emit_signal("add_response_request",self)


func delete_response_node(deletion_slot,response_node):
	for i in response_options:
		if i.slot < deletion_slot:
			i.offset += Vector2(0,RESPONSE_VERTICAL_OFFSET)
		else:
			i.offset -= Vector2(0,RESPONSE_VERTICAL_OFFSET)
			i.slot -=1
	response_options.erase(response_node)
	emit_signal("delete_response_node",self,response_node)
	
func add_connected_response(response):
	connected_responses.append(response)
	
func remove_connected_response(response):
	connected_responses.erase(response)



func set_dialog_title(string):
	dialog_title = string
	$TitleText.text = string
	for i in connected_responses:
		i.update_connection_text()
		print("checking the got danged text")
	
	
func set_dialog_text(string):
	
	text = string
	$HBoxContainer/DialogText.text = text

func set_dialog_id(id):
	dialog_id = id
	$IDLabel.text = String(id)


func _on_AddPlayerResponse_pressed():
	if response_options.size() < 6:
		add_response_node()


func _on_DialogNode_close_request():
	delete_self()
	



func _on_DialogNode_offset_changed():
	if response_options.size() > 0:
		for i in response_options:
			i.offset = Vector2(offset.x+RESPONSE_HORIZONTAL_OFFSET,i.offset.y + (offset.y-initial_offset_y))
			i.check_dialog_distance()
	if connected_responses.size() > 0:
		for i in connected_responses:
			i.check_dialog_distance()
	initial_offset_y = offset.y
			


func _on_TitleText_text_changed():
	dialog_title = title_text_node.text
	if connected_responses.size() > 0:
		for i in connected_responses:
			i.update_connection_text()

func _on_DialogText_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		selected = true
		emit_signal("set_self_as_selected",self)
		


func _on_TitleText_gui_input(event):
	if event is InputEventMouseButton and event.pressed  and event.button_index == BUTTON_LEFT:
		print(dialog_title)
		selected = true
		emit_signal("set_self_as_selected",self)

func _on_DialogText_text_changed():
	text = dialog_text_node.text
	emit_signal("text_changed",text)


		
func save():
	var save_quest_av = []
	var save_dialog_av = []
	var save_faction_av = []
	var save_scoreboard_av = []
	var save_fact_changes = []
	var save_response_options = []
	
	for i in quest_availabilities:
		save_quest_av.append({
			"availability_type": i.availability_type,
			"quest_id": i.quest_id
		})
	for i in dialog_availabilities:
		save_dialog_av.append({
			"availability_type" : i.availability_type,
			"dialog_id": i.dialog_id
		})
	for i in faction_availabilities:
		save_faction_av.append({
			"faction_id" : i.faction_id,
			"availability_operator" : i.availability_operator,
			"stance_type" : i.stance_type
		})
	for i in scoreboard_availabilities:
		save_scoreboard_av.append({
			"objective_name" : i.objective_name,
			"comparison_type" : i.comparison_type,
			"value" : i.value
		})
	for i in faction_changes:
		save_fact_changes.append({
			"faction_id" : i.faction_id,
			"points" : i.points
		})
	
	for i in response_options:
		var connected_index = -1
		if i.connected_dialog != null:
			connected_index = i.connected_dialog.node_index
		save_response_options.append({
			"slot" : i.slot,
			"option_type" : i.option_type,
			"color_decimal" : i.color_decimal,
			"command" : i.command,
			"connected_dialog_index" : connected_index,
			"initial_color" : i.initial_color,
			"response_title": i.response_title,
			"to_dialog_id" : i.to_dialog_id
			}
			)
	
	
	var save_dict = {
		"filename": get_filename(),
		"offset.x" : offset.x,
		"offset.y" : offset.y,
		"node_index": node_index,
		"dialog_id" : dialog_id,
		"dialog_title": dialog_title,
		"show_wheel" : show_wheel,
		"hide_npc" : hide_npc,
		"disable_esc" : disable_esc,
		"sound" : sound,
		"command" : command,
		"text" : text,
		"start_quest" : start_quest,
		"quest_availabilities": save_quest_av,
		"dialog_availabilities" : save_dialog_av,
		"faction_availabilities" : save_faction_av,
		"scoreboard_availabilities" : save_scoreboard_av,
		"faction_changes" : save_fact_changes,
		"time_availability" : time_availability,
		"min_level_availability" : min_level_availability,
		"response_options":save_response_options
	}
	return save_dict
	

func export_to_json():
	pass
