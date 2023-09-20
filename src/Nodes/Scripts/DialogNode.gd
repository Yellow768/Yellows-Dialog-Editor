class_name dialog_node
extends GraphNode
enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 

const RESPONSE_VERTICAL_OFFSET : int = 100
const RESPONSE_HORIZONTAL_OFFSET :int = 350

signal add_response_request
signal request_delete_response_node
signal dialog_ready_for_deletion
signal set_self_as_selected
signal text_changed
signal title_changed
signal node_double_clicked
signal request_set_scroll_offset

@export var _dialog_text_path: NodePath
@export var _title_text_path: NodePath
@export var _add_response_path: NodePath
@export var _id_label_path: NodePath

@onready var TitleTextNode : LineEdit = get_node(_title_text_path)
@onready var DialogTextNode : TextEdit = get_node(_dialog_text_path)
@onready var AddResponseButtonNode : Button = get_node(_add_response_path)
@onready var IdLabelNode :Label= get_node(_id_label_path)


var node_type :String = "Dialog Node" 
var node_index :int = 0: set = set_node_index


var response_options : Array[response_node]= []
var connected_responses : Array[response_node]= []



var original_parent : response_node
var total_height : int

var initial_offset_x :float= 0
var initial_offset_y :float= 0

##Dialog Data#

@export var dialog_title : String = 'New Dialog'

#Immutable
@export var dialog_id : int = -1: set = set_dialog_id

#Display

@export var show_wheel : bool = false
@export var hide_npc : bool = false
@export var disable_esc : bool = false

#String Inputs
@export var command : String = ''
@export var sound : String = ''
var text : String = ''


#Availabilities
var dialog_availabilities : Array[dialog_availability_object] = [dialog_availability_object.new(),dialog_availability_object.new(),dialog_availability_object.new(),dialog_availability_object.new()]
var quest_availabilities : Array[quest_availability_object]= [quest_availability_object.new(),quest_availability_object.new(),quest_availability_object.new(),quest_availability_object.new()]
var scoreboard_availabilities = [scoreboard_availability_object.new(),scoreboard_availability_object.new()]
var faction_availabilities :Array[faction_availability_object]= [faction_availability_object.new(),faction_availability_object.new()]
var faction_changes :Array[faction_change_object]= [faction_change_object.new(),faction_change_object.new()]

@export var time_availability : int = 0
@export var min_level_availability : int = 0



#Outcomes
@export var start_quest : int = -1


func _ready():
	#set_slot(1,true,CONNECTION_TYPES.PORT_INTO_DIALOG,GlobalDeclarations.dialog_left_slot_color,true,CONNECTION_TYPES.PORT_FROM_DIALOG,GlobalDeclarations.dialog_right_slot_color)
	#emit_signal("set_self_as_selected",self)
	initial_offset_y = position_offset.y
	initial_offset_x = position_offset.x
	DialogTextNode.text = text
	TitleTextNode.text = dialog_title

func add_response_node():
	if response_options.size() < 6:
		emit_signal("add_response_request",self)

func delete_response_node(deletion_slot : int,response_node : response_node):
	for i in response_options:
		if i.slot > deletion_slot:
			i.slot -=1
	response_options.erase(response_node)
	emit_signal("request_delete_response_node",self,response_node)

func clear_responses():
	for response in response_options:
		emit_signal("request_delete_response_node",self,response)
	response_options.clear()

func add_connected_response(response : response_node):
	connected_responses.append(response)
	
func remove_connected_response(response : response_node):
	connected_responses.erase(response)

func delete_self(perm := true):

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
	emit_signal("request_set_scroll_offset",position_offset)
	
func set_focus_on_text():
	DialogTextNode.grab_focus()
	emit_signal("set_self_as_selected",self)
	emit_signal("request_set_scroll_offset",position_offset)

func set_dialog_title(string : String):
	if not is_inside_tree(): await self.ready
	TitleTextNode.text = string
	for i in connected_responses:
		i.update_connection_text()
		
func set_dialog_text(string : String):
	if not is_inside_tree(): await self.ready
	DialogTextNode.text = string
	
	


func set_dialog_id(id: int):
	dialog_id = id
	if not is_inside_tree(): await self.ready
	IdLabelNode.text = "    ID: "+str(id)

func set_node_index(index : int):
	node_index = index
	title = "Dialog Node "+str(index)

func _on_AddPlayerResponse_pressed():
	add_response_node()


func _on_DialogNode_close_request():
	delete_self(true)
	
func _on_DialogNode_offset_changed():
	if Input.is_action_pressed("drag_without_responses") != GlobalDeclarations.hold_shift_for_individual_movement:
		if response_options.size() > 0:
			for i in response_options:
				i.position_offset += position_offset - Vector2(initial_offset_x,initial_offset_y)
				i.check_dialog_distance()
		if connected_responses.size() > 0:
			for i in connected_responses:
				i.check_dialog_distance()
	initial_offset_x = position_offset.x
	initial_offset_y = position_offset.y
			
func _on_TitleText_text_changed(_new_text : String):
	dialog_title = TitleTextNode.text
	if connected_responses.size() > 0:
		for i in connected_responses:
			i.update_connection_text()
	emit_signal("title_changed")

func handle_clicking(event : InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("set_self_as_selected",self)
		if event.double_click:
			emit_signal("node_double_clicked")
	else:
		if Input.is_key_pressed(KEY_TAB):
			emit_signal("set_self_as_selected",self)


func _on_DialogNode_gui_input(event : InputEvent):
	handle_clicking(event)


func _on_DialogText_gui_input(event : InputEvent):
	handle_clicking(event)
		

func _on_TitleText_gui_input(event : InputEvent):
	handle_clicking(event)

func _on_DialogText_text_changed():
	text = DialogTextNode.text
	emit_signal("text_changed")


		
func save():
	var save_quest_av :Array[Dictionary]= []
	var save_dialog_av :Array[Dictionary] = []
	var save_faction_av :Array[Dictionary]= []
	var save_scoreboard_av :Array[Dictionary]= []
	var save_fact_changes :Array[Dictionary]= []
	var save_response_options :Array[Dictionary]= []
	
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
		var connected_index := -1
		if i.connected_dialog != null:
			connected_index = i.connected_dialog.node_index
		save_response_options.append({
			"slot" : i.slot,
			"option_type" : i.option_type,
			"color_decimal" : i.color_decimal,
			"command" : i.command,
			"connected_dialog_index" : connected_index,
			"response_title": i.response_title,
			"to_dialog_id" : i.to_dialog_id,
			"position_offset_x" : i.position_offset.x,
			"position_offset_y" : i.position_offset.y
			}
			)
	
	
	var save_dict = {
		"filename": get_scene_file_path(),
		"position_offset.x" : position_offset.x,
		"position_offset.y" : position_offset.y,
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


func get_full_tree(all_children : Array[GraphNode] = []):
	for response in response_options:
		all_children.append(response)
		all_children = response.get_full_tree(all_children)
	return all_children
