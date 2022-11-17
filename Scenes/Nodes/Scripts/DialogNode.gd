class_name dialog_node
extends GraphNode
enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 


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
export(Array,Resource) var dialog_availabilities
export(Array,Resource) var quest_availabilities
export(Array,Resource) var scoreboard_availabilities
export(Array,Resource) var faction_availabilities

export(int,"Always","Night","Day") var time_availability
export var min_level_availability = 0



#Outcomes
export(Array,Resource) var faction_changes
export var start_quest = -1



signal dialog_deletion_request
signal player_response_ready_for_deletion
signal dialog_ready_for_deletion
signal set_self_as_selected

func _ready():
	initial_offset_y = offset.y
	connect("player_response_ready_for_deletion",get_parent().get_parent(),"delete_player_response")
	connect("dialog_ready_for_deletion",get_parent().get_parent(),"delete_dialog")
	connect("set_self_as_selected",get_parent().get_parent(),"_on_node_requests_selection")
	connect("dialog_deletion_request",get_parent().get_parent(),"handle_deletion_request")
	set_slot(1,true,CONNECTION_TYPES.PORT_INTO_DIALOG,Color(0,0,1,1),true,CONNECTION_TYPES.PORT_FROM_DIALOG,Color(0,1,0,1))
	$IDLabel.text = "ID: "+String(dialogID)
	$TitleText.text = dialog_title


	
func export_to_json():
	pass
	
func add_new_response():
	var new_prn = player_response_node.instance()
	var new_instance_offset = Vector2(400,50+(60*response_options.size()))
	for i in response_options:
		i.offset -= Vector2(0,60)
	
	new_prn.offset = offset + new_instance_offset
	new_prn.initial_y_offset = new_instance_offset.y
	new_prn.slot = response_options.size()
	new_prn.graph = graph
	response_options.append(new_prn)
	new_prn.connect("deleting_player_response",self,"handle_deleting_player_response")
	graph.add_child(new_prn)
	graph.connect_node(self.get_name(),0,new_prn.get_name(),0)



func handle_deleting_player_response(deletion_slot,response_node):
	for i in response_options:
		if i.slot < deletion_slot:
			i.offset += Vector2(0,60)
		else:
			i.offset -= Vector2(0,60)
			i.slot -=1
	
	emit_signal("player_response_ready_for_deletion",self,response_node)
	#get_parent().disconnect_node(self.get_name(),0,response_options[deletion_slot].get_name(),0)
	response_options.remove(deletion_slot)

func _on_AddPlayerResponse_pressed():
	if response_options.size() < 6:
		add_new_response()


func _on_DialogNode_close_request():
	delete_self()
	

func delete_self():
	while response_options.size() > 0:
		for i in response_options:
			i.external_delete()
	while connected_responses.size() > 0:
		for i in connected_responses:
			i.disconnect_from_dialog()
			connected_responses.erase(i)
	emit_signal("dialog_ready_for_deletion",self)

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
		
