class_name dialog_node
extends GraphNode
enum CONNECTION_TYPES{PORT_INTO_DIALOG,PORT_INTO_RESPONSE,PORT_FROM_DIALOG,PORT_FROM_RESPONSE} 

const RESPONSE_VERTICAL_OFFSET : int = 100
const RESPONSE_HORIZONTAL_OFFSET :int = 350

signal add_response_request
signal request_delete_response_node
signal request_deletion
signal set_self_as_selected
signal text_changed
signal title_changed
signal node_double_clicked
signal request_set_scroll_offset
signal unsaved_changes

@export var _dialog_text_path: NodePath
@export var _title_text_path: NodePath
@export var _add_response_path: NodePath
@export var _id_label_path: NodePath

@onready var TitleTextNode : LineEdit = get_node(_title_text_path)
@onready var DialogTextNode : TextEdit = get_node(_dialog_text_path)
@onready var AddResponseButtonNode : Button = get_node(_add_response_path)
@onready var IdLabelNode :Label= get_node(_id_label_path)


var node_type :String = "Dialog Node" 
var node_index :int = -1: set = set_node_index


var response_options : Array[response_node]= []
var connected_responses : Array[response_node]= []



var original_parent : response_node
var total_height : int

var initial_offset_x :float= 0
var initial_offset_y :float= 0

##Dialog Data#

@export var dialog_title : String = tr("NEW_DIALOG_TITLE")

#Immutable
@export var dialog_id : int = -1: set = set_dialog_id

#Display

@export var show_wheel : bool = false
@export var hide_npc : bool = false
@export var disable_esc : bool = false
var darken_screen : bool = true
var render_gradual : bool = false
var show_previous_dialog : bool = true
var show_response_options : bool = true
var title_color : int = 0xffffff
var dialog_color : int = 0xffffff
var text_sound : String = 'minecraft:random.wood_click'
var text_pitch : float = 1.0

#Spacing CustomNPCs + Option

var title_pos : int = 0
var alignment : bool = true 
var text_height : int = 400
var text_width : int = 300
var text_offset_y : int = 0
var text_offset_x : int = 0
var title_offset_y : int = 0
var title_offset_x : int = 0
var option_offset_x : int = 0
var option_offset_y : int = 0
var option_spacing_x : int = 0
var option_spacing_y : int = 0
var npc_offset_x : int = 0
var npc_offset_y : int = 0
var npc_scale : float = 1.0
var spacing_preset : int = -1


var image_dictionary : Dictionary = {}
var last_viewed_image : int = -1
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
var mail = mail_data_object.new()

@export var time_availability : int = 0
@export var min_level_availability : int = 0



#Outcomes
@export var start_quest : int = -1

#States

var set_as_availability := false
var do_not_send_position_changed_signal := false

func set_self_as_unselected():
	selected = false

func _ready():
	#set_slot(1,true,CONNECTION_TYPES.PORT_INTO_DIALOG,GlobalDeclarations.dialog_left_slot_color,true,CONNECTION_TYPES.PORT_FROM_DIALOG,GlobalDeclarations.dialog_right_slot_color)
	#emit_signal("set_self_as_selected",self)
	initial_offset_y = position_offset.y
	initial_offset_x = position_offset.x
	DialogTextNode.text = text
	TitleTextNode.text = dialog_title
	if spacing_preset != -1:
		update_spacing_options_to_preset()
		

func add_response_node(commit_to_undo := true):
	if !GlobalDeclarations.allow_above_six_responses:
		if response_options.size() < 6:
			emit_signal("add_response_request",self,GlobalDeclarations.RESPONSE_NODE.instantiate(),commit_to_undo)
			emit_signal("unsaved_changes")
	else:
		emit_signal("add_response_request",self,GlobalDeclarations.RESPONSE_NODE.instantiate(),commit_to_undo)
		emit_signal("unsaved_changes")
	
func delete_response_node(deletion_slot : int,response_node : response_node):
	for i in response_options:
		if i.slot > deletion_slot:
			i.slot -=1
	response_options.erase(response_node)
	emit_signal("unsaved_changes")
	
func clear_responses():
	var responses_to_clear = response_options.duplicate()
	for response in responses_to_clear:
		print(response.response_title)
		response.delete_self(false)
		
	response_options.clear()
	emit_signal("unsaved_changes")

func add_connected_response(response : response_node):
	connected_responses.append(response)
	
func remove_connected_response(response : response_node):
	connected_responses.erase(response)

func delete_self(perm := true,commit_to_undo := true):
	emit_signal("request_deletion",self,perm,commit_to_undo)
	emit_signal("unsaved_changes")

func delete_response_options():
	while response_options.size() > 0:
		for i in response_options:
			i.delete_self(false)
	while connected_responses.size() > 0:
		for i in connected_responses:
			i.disconnect_from_dialog(false)
			connected_responses.erase(i)

func set_focus_on_title():
	TitleTextNode.grab_focus()
	selected = true
	emit_signal("request_set_scroll_offset",position_offset)
	
func set_focus_on_text():
	DialogTextNode.grab_focus()
	selected = true
	emit_signal("request_set_scroll_offset",position_offset)




func set_dialog_title(string : String):
	if not is_inside_tree(): await self.ready
	TitleTextNode.text = string
	for i in connected_responses:
		i.update_connection_text()
	emit_signal("unsaved_changes")
		
func set_dialog_text(string : String):
	if not is_inside_tree(): await self.ready
	DialogTextNode.text = string
	text = DialogTextNode.text
	emit_signal("unsaved_changes")
	
	


func set_dialog_id(id: int):
	dialog_id = id
	if not is_inside_tree(): await self.ready
	IdLabelNode.text = "    ID: "+str(id)
	emit_signal("unsaved_changes")
	for response in connected_responses:
		response.set_connected_dialog(self)

func set_node_index(index : int):
	node_index = index
	title = tr("DIALOG_NODE")+" "+str(index)

func _on_AddPlayerResponse_pressed():
	add_response_node()


func _on_DialogNode_close_request():
	delete_self(true)
	
func _on_DialogNode_offset_changed():
	if Input.is_action_pressed("drag_responses_key") != GlobalDeclarations.hold_shift_for_individual_movement:
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
	emit_signal("unsaved_changes")

func handle_clicking(event : InputEvent, emit_signal = true):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and emit_signal:
			#emit_signal("set_self_as_selected",self)
			selected = true
			pass
		if event.double_click:
			emit_signal("node_double_clicked")

	else:
		if Input.is_key_pressed(KEY_TAB):
			selected = true


func _on_DialogNode_gui_input(event : InputEvent):
	handle_clicking(event,false)
	

func _on_DialogText_gui_input(event : InputEvent):
	handle_clicking(event)

func _on_TitleText_gui_input(event : InputEvent):
	handle_clicking(event)


func update_spacing_options_to_preset():
	var preset_parameters = GlobalDeclarations.spacing_presets[spacing_preset]
	title_pos = preset_parameters.TitlePosition
	alignment = preset_parameters.Alignment
	text_width = preset_parameters.Width
	text_height = preset_parameters.Height
	title_offset_x = preset_parameters.TitleOffsetX
	title_offset_y = preset_parameters.TitleOffsetY
	text_offset_x = preset_parameters.TextOffsetX
	text_offset_y = preset_parameters.TextOffsetY
	option_offset_x = preset_parameters.OptionOffsetX
	option_offset_y = preset_parameters.OptionOffsetY
	option_spacing_x = preset_parameters.OptionSpacingX
	option_spacing_y = preset_parameters.OptionSpacingY
	npc_offset_x = preset_parameters.NPCOffsetX
	npc_offset_y = preset_parameters.NPCOffsetY
	npc_scale = preset_parameters.NPCScale

func sort_ascending(a, b):
	if a[0] < b[0]:
		return true
	return false


func add_image_to_dictionary() :
	if image_dictionary.size() == 9 :
		return
	var gap := false
	var previous_id = -1
	var next_value := -1
	if !image_dictionary.is_empty():
		var image_id_array = image_dictionary.keys()
		image_id_array.sort()
		for id in image_id_array:
			if id - previous_id > 1:
				next_value = previous_id + 1
				break
			previous_id = id
	if next_value == -1:
		next_value = image_dictionary.size()
	image_dictionary[next_value] = {
		"PosX" : 0,
		"PosY" : 0,
		"Color" : 0xffffff,
		"TextureX" : 0,
		"TextureY" : 0,
		"Scale" : 1.0,
		"SelectedColor" : 0xffffff,
		"Texture" : "",
		"Rotation" : 0.0,
		"ImageType" : 0,
		"Alignment" : 0,
		"Alpha" : 1.0,
		"Height" : 0,
		"Width" : 0
	}
	return next_value
		
func remove_image_from_dictionary(id : int):
	image_dictionary.erase(id)

func save():
	var save_quest_av :Array[Dictionary]= []
	var save_dialog_av :Array[Dictionary] = []
	var save_faction_av :Array[Dictionary]= []
	var save_scoreboard_av :Array[Dictionary]= []
	var save_fact_changes :Array[Dictionary]= []
	var save_response_options :Array[Dictionary]= []
	var save_mail : Dictionary
	var save_images : Dictionary
	
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
		save_response_options.append(i.save())
		
	var connected_response_indexes = []
	for i in connected_responses:
		connected_response_indexes.append(i.node_index)
	
	save_mail = {
		"sender" : mail.sender,
		"subject" : mail.subject,
		"pages" : JSON.stringify(mail.pages),
		"items" : JSON.stringify(mail.items_slots),
		"quest_id" : mail.quest_id
	}
	
	var save_dict = {
		"node_type" : node_type,
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
		"darken_screen" : darken_screen,
		"render_gradual": render_gradual,
		"show_previous_dialog": show_previous_dialog,
		"show_response_options": show_response_options,
		"dialog_color" : dialog_color,
		"title_color" : title_color, 
		"text_sound" : text_sound,
		"text_pitch" : text_pitch,
		"title_pos" : title_pos,
		"alignment" : alignment,
		"text_width" : text_width,
		"text_height" : text_height,
		"text_offset_x" : text_offset_x,
		"text_offset_y" : text_offset_y,
		"option_offset_x" : option_offset_x,
		"option_offset_y" : option_offset_y,
		"option_spacing_x" : option_spacing_x,
		"option_spacing_y" : option_spacing_y,
		"npc_offset_x" : npc_offset_x,
		"npc_offset_y" : npc_offset_y,
		"npc_scale" : npc_scale,
		"quest_availabilities": save_quest_av,
		"dialog_availabilities" : save_dialog_av,
		"faction_availabilities" : save_faction_av,
		"scoreboard_availabilities" : save_scoreboard_av,
		"faction_changes" : save_fact_changes,
		"time_availability" : time_availability,
		"min_level_availability" : min_level_availability,
		"response_options":save_response_options,
		"mail" : save_mail,
		"connected_response_indexes" : connected_response_indexes,
		"image_dictionary" : JSON.stringify(image_dictionary),
		"spacing_preset" : spacing_preset
	}
	return save_dict


func get_full_tree(all_children : Array[GraphNode] = []):
	for response in response_options:
		all_children.append(response)
		all_children = response.get_full_tree(all_children)
	return all_children




func update_language():
	title = tr("DIALOG_NODE")+" "+str(node_index)
	for response in response_options:
		response.title = tr("RESPONSE_OPTION")+" "+str(response.node_index)

func _on_dialog_text_text_changed():
	text = DialogTextNode.text
	emit_signal("text_changed")
	emit_signal("unsaved_changes")
