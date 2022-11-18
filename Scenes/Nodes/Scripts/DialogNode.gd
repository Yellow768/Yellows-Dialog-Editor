class_name dialog_node
extends GraphNode
enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 

onready var dialog_editor = get_parent().get_parent()

var node_type = "Dialog Node"
var graph
var player_response_node = load("res://Scenes/Nodes/Player Response Node.tscn")
var node_index = 0
var response_options = []
var connected_responses = []
var initial_offset_y = 0

##Dialog Data#

export var dialog_title = 'New Dialog'

#Immutable
export var dialogID = -1

#Display

export var show_wheel = false
export var hide_npc = false
export var disable_esc = false

#String Inputs
export var command = ''
export var sound = ''



#Availabilities
var dialog_availabilities = []
var quest_availabilities = []
var scoreboard_availabilities = []
var faction_availabilities = []

export(int,"Always","Night","Day") var time_availability
export var min_level_availability = 0



#Outcomes
var faction_changes = []
export var start_quest = -1


signal add_response_request
signal delete_response_node
signal dialog_ready_for_deletion
signal set_self_as_selected

func _ready():
	initial_offset_y = offset.y
	
	connect("add_response_request",dialog_editor,"add_response_node")
	connect("delete_response_node",dialog_editor,"delete_response_node")
	connect("dialog_ready_for_deletion",dialog_editor,"delete_dialog_node")
	connect("set_self_as_selected",dialog_editor,"_on_node_requests_selection")
	set_slot(1,true,CONNECTION_TYPES.PORT_INTO_DIALOG,Color(0,0,1,1),true,CONNECTION_TYPES.PORT_FROM_DIALOG,Color(0,1,0,1))
	$IDLabel.text = "ID: "+String(dialogID)
	$TitleText.text = dialog_title
	
	for i in 4:
		dialog_availabilities.append(dialog_availability_object.new())
		quest_availabilities.append(quest_availability_object.new())
		
	for i in 2:
		scoreboard_availabilities.append(scoreboard_availability_object.new())
		faction_availabilities.append(faction_availability_object.new())
		faction_changes.append(faction_change_object.new())


	
func export_to_json():
	pass

func delete_self():
	while response_options.size() > 0:
		for i in response_options:
			i.external_delete()
	while connected_responses.size() > 0:
		for i in connected_responses:
			i.disconnect_from_dialog()
			connected_responses.erase(i)
	emit_signal("dialog_ready_for_deletion",self)
	
func add_response_node():
	emit_signal("add_response_request",self)


func delete_response_node(deletion_slot,response_node):
	for i in response_options:
		if i.slot < deletion_slot:
			i.offset += Vector2(0,60)
		else:
			i.offset -= Vector2(0,60)
			i.slot -=1
	response_options.erase(response_node)
	emit_signal("delete_response_node",self,response_node)
	


func _on_AddPlayerResponse_pressed():
	if response_options.size() < 6:
		add_response_node()


func _on_DialogNode_close_request():
	delete_self()
	



func _on_DialogNode_offset_changed():
	if response_options.size() > 0:
		for i in response_options:
			i.offset = Vector2(offset.x+400,i.offset.y + (offset.y-initial_offset_y))
	initial_offset_y = offset.y
			


func _on_TitleText_text_changed():
	dialog_title = $TitleText.text


func _on_TitleText_focus_entered():
	selected = true
	emit_signal("set_self_as_selected",self)


func _on_DialogText_focus_entered():
	selected = true
	emit_signal("set_self_as_selected",self)


func _on_DialogText_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		selected = true
		emit_signal("set_self_as_selected",self)


func _on_TitleText_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		selected = true
		emit_signal("set_self_as_selected",self)
		
