class_name dialog_node
extends GraphNode
enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 

const RESPONSE_VERTICAL_OFFSET = 100
const RESPONSE_HORIZONTAL_OFFSET = 350

signal add_response_request
signal delete_response_node
signal dialog_ready_for_deletion
signal set_self_as_selected
signal text_changed
signal title_changed
signal node_double_clicked

export(NodePath) var _dialog_text_path
export(NodePath) var _title_text_path
export(NodePath) var _add_response_path
export(NodePath) var _id_label_path

onready var TitleTextNode = get_node(_title_text_path)
onready var DialogTextNode = get_node(_dialog_text_path)
onready var AddResponseButtonNode = get_node(_add_response_path)
onready var IdLabelNode = get_node(_id_label_path)


var node_type = "Dialog Node" 
var node_index = 0 setget set_node_index


var response_options = []
var connected_responses = []



var original_parent
var total_height

var initial_offset_x = 0
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
var dialog_availabilities = [dialog_availability_object.new(),dialog_availability_object.new(),dialog_availability_object.new(),dialog_availability_object.new()]
var quest_availabilities = [quest_availability_object.new(),quest_availability_object.new(),quest_availability_object.new(),quest_availability_object.new()]
var scoreboard_availabilities = [scoreboard_availability_object.new(),scoreboard_availability_object.new()]
var faction_availabilities = [faction_availability_object.new(),faction_availability_object.new()]
var faction_changes = [faction_change_object.new(),faction_change_object.new()]

export(int,"Always","Night","Day") var time_availability = 0
export var min_level_availability = 0



#Outcomes
export var start_quest = -1


func _ready():
	#set_slot(1,true,CONNECTION_TYPES.PORT_INTO_DIALOG,GlobalDeclarations.dialog_left_slot_color,true,CONNECTION_TYPES.PORT_FROM_DIALOG,GlobalDeclarations.dialog_right_slot_color)
	#emit_signal("set_self_as_selected",self)
	initial_offset_y = offset.y
	initial_offset_x = offset.x

func add_response_node():
	if response_options.size() < 6:
		emit_signal("add_response_request",self)

func delete_response_node(deletion_slot,response_node):
	for i in response_options:
		if i.slot > deletion_slot:
			i.slot -=1
	response_options.erase(response_node)
	emit_signal("delete_response_node",self,response_node)

func clear_responses():
	for response in response_options:
		emit_signal("delete_response_node",self,response)
	response_options.clear()

func add_connected_response(response):
	connected_responses.append(response)
	
func remove_connected_response(response):
	connected_responses.erase(response)

func delete_self(perm = true):
	while response_options.size() > 0:
		for i in response_options:
			i.delete_self()
	while connected_responses.size() > 0:
		for i in connected_responses:
			i.disconnect_from_dialog()
			connected_responses.erase(i)
	emit_signal("dialog_ready_for_deletion",self,perm)

func set_focus_on_title():
	TitleTextNode.grab_focus()
	emit_signal("set_self_as_selected",self)

func set_dialog_title(string):
	dialog_title = string
	if not is_inside_tree(): yield(self,'ready')
	TitleTextNode.text = string
	for i in connected_responses:
		i.update_connection_text()
	emit_signal("title_changed")
	
	
func set_dialog_text(string):
	text = string
	if not is_inside_tree(): yield(self,'ready')
	DialogTextNode.text = text

func set_dialog_id(id):
	dialog_id = id
	if not is_inside_tree(): yield(self,'ready')
	IdLabelNode.text = "ID: "+String(id)

func set_node_index(index):
	node_index = index
	title = "Dialog Node "+String(index)

func _on_AddPlayerResponse_pressed():
	add_response_node()


func _on_DialogNode_close_request():
	delete_self(true)
	
func _on_DialogNode_offset_changed():
	if !Input.is_action_pressed("drag_without_responses"):
		if response_options.size() > 0:
			for i in response_options:
				i.offset += offset - Vector2(initial_offset_x,initial_offset_y)
				i.check_dialog_distance()
		if connected_responses.size() > 0:
			for i in connected_responses:
				i.check_dialog_distance()
	initial_offset_x = offset.x
	initial_offset_y = offset.y
			
func _on_TitleText_text_changed(new_text):
	dialog_title = new_text
	if connected_responses.size() > 0:
		for i in connected_responses:
			i.update_connection_text()
	emit_signal("title_changed")

func handle_clicking(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			emit_signal("set_self_as_selected",self)
		if event.doubleclick:
			emit_signal("node_double_clicked")
		if event.pressed and event.button_index == BUTTON_RIGHT:
			$PopupMenu.popup()


func _on_DialogNode_gui_input(event):
	handle_clicking(event)


func _on_DialogText_gui_input(event):
	handle_clicking(event)
		

func _on_TitleText_gui_input(event):
	handle_clicking(event)

func _on_DialogText_text_changed():
	text = DialogTextNode.text
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


func get_full_tree(all_children : Array = []):
	for response in response_options:
		all_children.append(response)
		all_children = response.get_full_tree(all_children)
	return all_children

