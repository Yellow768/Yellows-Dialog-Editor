class_name response_node
extends GraphNode

@export var _response_text_node_path: NodePath
@export var _color_picker_node_path: NodePath
@export var _option_type_node_path: NodePath
@export var _command_text_node_path: NodePath
@export var _new_dialog_button_path: NodePath
@export var _remote_connection_container_path: NodePath
@export var _remote_connection_text_path: NodePath
@export var _remote_connection_disconnect_button_path: NodePath
@export var _remote_connection_jump_button_path: NodePath
@export var _remote_connection_vseparation_path : NodePath
@export var _id_spinbox: NodePath

@onready var ResponseTextNode := get_node(_response_text_node_path)
@onready var ColorPickerNode : ColorPickerButton = get_node(_color_picker_node_path)
@onready var OptionTypeNode : OptionButton = get_node(_option_type_node_path)
@onready var CommandTextNode := get_node(_command_text_node_path)
@onready var NewDialogButtonNode := get_node(_new_dialog_button_path)
@onready var RemoteConnectionContainer := get_node(_remote_connection_container_path)
@onready var RemoteConnectionText := get_node(_remote_connection_text_path)
@onready var RemoteConnectionDisconnectButton := get_node(_remote_connection_disconnect_button_path)
@onready var RemoteConnectionJumpButton := get_node(_remote_connection_jump_button_path)
@onready var RemoteConnectionVSeparator : VSeparator = get_node(_remote_connection_vseparation_path)

@onready var IdSpinbox : SpinBox= get_node(_id_spinbox)




signal set_self_as_selected
signal request_delete_self
signal connect_to_dialog_request
signal disconnect_from_dialog_request
signal request_connection_line_shown
signal request_connection_line_hidden
signal request_add_dialog
signal request_set_scroll_offset
signal response_double_clicked
signal unsaved_change

signal type_changed
signal title_changed
signal text_changed
signal to_id_changed
signal option_command_changed
signal color_changed


var node_type : String = "Player Response Node"

var slot : int = -1: set = set_response_slot


var response_title : String = ''
var response_text : String = ''
var color_decimal :int = 16777215: set = set_color_decimal
var option_command :String = ''
var commands : Array[String]
var connected_dialog : dialog_node = null: set = set_connected_dialog
var to_dialog_id = -1: set = set_to_dialog_id
var option_type = 0: set = set_option_type
var node_index := -1

var parent_dialog : dialog_node : set = set_parent_dialog
var parent_dialog_id : int

var total_height : int

var connection_hidden := false
var overlapping_response : response_node = null

var minimized = false

var do_not_send_position_changed_signal := false


func _ready():
	ColorPickerNode.color = GlobalDeclarations.int_to_color(color_decimal)
	#set_slot(1,true,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE,GlobalDeclarations.response_left_slot_color,true,GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE,GlobalDeclarations.response_right_slot_color)
	OptionTypeNode.select(option_type)
	ResponseTextNode.text = response_title
	CommandTextNode.text = option_command
	IdSpinbox.set_value_no_signal(to_dialog_id) 
	IdSpinbox.update_on_text_changed = true
	ResponseTextNode.add_theme_color_override("font_color",ColorPickerNode.color)
	for color in GlobalDeclarations.color_presets:
		ColorPickerNode.get_picker().add_preset(color)
	ColorPickerNode.get_picker().connect("preset_added",Callable(GlobalDeclarations,"add_color_preset"))
	ColorPickerNode.get_picker().connect("preset_removed",Callable(GlobalDeclarations,"remove_color_preset"))

func get_option_id_from_index(index : int):
	return OptionTypeNode.get_item_id(index)


func set_option_from_json_index(option_int : int):
	if not is_inside_tree(): await self.ready
	OptionTypeNode.select(OptionTypeNode.get_item_index(option_int))
	set_option_type(OptionTypeNode.get_item_index(option_int))
	
func set_option_from_index(index : int):
	if not is_inside_tree(): await self.ready
	OptionTypeNode.select(index)
	set_option_type(index)

func set_focus_on_title():
	if not is_inside_tree(): await self.ready
	ResponseTextNode.grab_focus()
	selected = true
	emit_signal("request_set_scroll_offset",position_offset)

func set_response_slot(value : int):
	slot = value
	title = tr("RESPONSE_OPTION")+" "+str(value+1) 
	emit_signal("unsaved_change")
	

func set_option_type(new_type : int):
	option_type = new_type
	if not is_inside_tree(): await self.ready
	if new_type == 2:
		CommandTextNode.visible = true
	else:
		CommandTextNode.visible = false
		size.y = 215
	if new_type == 0:
		reveal_button()
		set_slot_enabled_right(1,true)
		IdSpinbox.visible = true
	else:
		hide_button()
		set_slot_enabled_right(1,false)
		IdSpinbox.visible = false
		IdSpinbox.value = -1
		RemoteConnectionContainer.visible = false
		if connected_dialog != null:
			emit_signal("disconnect_from_dialog_request",self,0,connected_dialog,0)
	emit_signal("unsaved_change")
	emit_signal("type_changed")
	
func set_color_decimal(new_color : int):
	color_decimal = new_color
	emit_signal("unsaved_change")

func set_command(new_command : String):
	option_command = new_command
	if not is_inside_tree(): await self.ready
	CommandTextNode.text = new_command
	emit_signal("unsaved_change")

func set_connected_dialog(new_connected_dialog):
	if connected_dialog != null:
		if connected_dialog.dialog_id == IdSpinbox.value:
			IdSpinbox.set_value_no_signal(0)
	connected_dialog = new_connected_dialog
	if not is_inside_tree(): await self.ready
	if connected_dialog != null && connected_dialog.dialog_id != -1:
		to_dialog_id = connected_dialog.dialog_id
		IdSpinbox.set_value_no_signal(to_dialog_id) 
		hide_button()
		update_connection_text()
		check_dialog_distance()	
	else:
		reveal_button()

func set_to_dialog_id(new_id : int):
	to_dialog_id = new_id
	emit_signal("to_id_changed")

func set_parent_dialog(new_parent_dialog):
	parent_dialog = new_parent_dialog
	if new_parent_dialog == null: 
		parent_dialog_id = 0
		return
	
	parent_dialog_id = parent_dialog.dialog_id

func set_connection_text(dialog_name : String,dialog_node_index: int):
	if not is_inside_tree(): await self.ready
	RemoteConnectionText.text = tr("RESPONSE_CONNECTED")+dialog_name+" | "+tr("NODE") +str(dialog_node_index)
	
func reveal_button():
	if option_type == 0:
		NewDialogButtonNode.modulate = Color(1,1,1,1)
		NewDialogButtonNode.disabled = false
		set_slot_enabled_right(1,true)

	
func hide_button():
	NewDialogButtonNode.modulate = Color(1,1,1,0)
	NewDialogButtonNode.disabled = true
	

func update_connection_text():
	if connected_dialog != null:
		var format_string := "Connected to %s | Node "+str(connected_dialog.node_index)
		RemoteConnectionText.text = format_string % connected_dialog.dialog_title.left(10)
		RemoteConnectionJumpButton.visible = true
		RemoteConnectionDisconnectButton.visible = true
		RemoteConnectionVSeparator.visible = true
		
func check_dialog_distance():
	
	if connected_dialog != null:
		if position_offset.distance_to(connected_dialog.position_offset) > GlobalDeclarations.hide_connection_distance:
			set_connection_hidden()		
		if position_offset.distance_to(connected_dialog.position_offset) < GlobalDeclarations.hide_connection_distance:
			set_connection_shown()

func set_connection_hidden():
	emit_signal("request_connection_line_hidden",self,connected_dialog)
	connection_hidden = true
	RemoteConnectionContainer.visible = true
	RemoteConnectionVSeparator.visible = true
	set_slot_color_right(0,GlobalDeclarations.response_right_slot_color_hidden)
	set_slot_enabled_right(1,false)
	connected_dialog.set_slot_color_left(0,GlobalDeclarations.dialog_left_slot_color_hidden)
	update_connection_text()
	

func set_connection_shown():
	
	emit_signal("request_connection_line_shown",self,connected_dialog)
	connection_hidden = false
	set_slot_color_right(0,GlobalDeclarations.response_right_slot_color)
	connected_dialog.set_slot_color_left(0,GlobalDeclarations.dialog_left_slot_color)
	set_slot_enabled_right(1,true)
	RemoteConnectionContainer.visible = false
	size.y = 215
	

func disconnect_from_dialog(commit_to_undo := true):
	if connected_dialog!=null:
		connected_dialog.remove_connected_response(self)
		emit_signal("disconnect_from_dialog_request",self,0,connected_dialog,0,commit_to_undo)
		connected_dialog = null
	to_dialog_id = -1
	IdSpinbox.value = 0
	RemoteConnectionContainer.visible = false


func delete_self(commit_to_undo := true):
	if(connected_dialog != null):
		connected_dialog.remove_connected_response(self)
	emit_signal("request_delete_self",parent_dialog,self,commit_to_undo)
	
func set_orphaned(orphaned):
	if orphaned:
		title = tr("ORPHANED_RESPONSE_OPTION")
		$"Warning Label".visible = true
		add_to_group("Save")
	else:
		remove_from_group("Save")
		$"Warning Label".visible = false
		size.y = 215



func _on_PlayerResponseNode_gui_input(event):
	if event is InputEventMouseButton and event.double_click:
		emit_signal("response_double_clicked")
	
	

func toggle_minimize_node():
	match minimized:
		false:
			$HSeparator.custom_minimum_size.y = 25
			$HBoxContainer/VBoxContainer.visible = false
			$HBoxContainer/AddNewDialog.visible = false
			custom_minimum_size.y = 60
			size.y = 47
			minimized = true
			overlay = GraphNode.OVERLAY_BREAKPOINT
		true:
			$HSeparator.custom_minimum_size.y = 35
			$HBoxContainer/VBoxContainer.visible = true
			$HBoxContainer/AddNewDialog.visible = true
			custom_minimum_size.y = 215
			size.y = 215
			overlay =GraphNode.OVERLAY_DISABLED
			minimized = false
			
			
			

func _on_PlayerResponseNode_close_request():
	delete_self()
	

func _on_AddNewDialog_pressed():
	add_new_connected_dialog()

func add_new_connected_dialog(commit_to_undo := true):
	if option_type != 0:
		return
	if connected_dialog:
		return
	var new_dialog : dialog_node = GlobalDeclarations.DIALOG_NODE.instantiate()
	new_dialog.position_offset = position_offset + Vector2(GlobalDeclarations.DIALOG_NODE_HORIZONTAL_OFFSET,0)
	if ResponseTextNode.text != '':
		new_dialog.dialog_title = ResponseTextNode.text
	connected_dialog = new_dialog
	emit_signal("request_add_dialog",new_dialog,true,commit_to_undo)
	emit_signal("connect_to_dialog_request",self,0,connected_dialog,0,false)

func _on_OptionButton_item_selected(index : int):
	set_option_type(index)


func _on_ColorPickerButton_color_changed(color : Color):
	var colorHex = "0x"+String(color.to_html(false))
	color_decimal = colorHex.hex_to_int()
	ResponseTextNode.add_theme_color_override("font_color",color)
	emit_signal("color_changed",color)
	
func update_color(color):
	ColorPickerNode.color = color

func set_response_title(text: String):
	ResponseTextNode.text = text

func _on_ResponseText_text_changed(new_text : String):
	response_title = ResponseTextNode.text
	emit_signal("title_changed")
	emit_signal("unsaved_change")

func _on_CommandText_text_changed():
	option_command = CommandTextNode.text
	emit_signal("option_command_changed")
	emit_signal("unsaved_change")


func _on_DisconnectButton_pressed():
	disconnect_from_dialog()
	reveal_button()


func _on_JumpButton_pressed():
	var dialog_location = connected_dialog.position_offset
	emit_signal("request_set_scroll_offset",dialog_location)
	connected_dialog.selected = true


func _on_ResponseNodeArea_area_entered(area : Area2D):
	overlapping_response = area.get_parent()
	

func _on_ResponseNodeArea_area_exited(_area : Area2D):
	if !$ResponseNodeArea.get_overlapping_areas().is_empty():
		overlapping_response = $ResponseNodeArea.get_overlapping_areas().back().get_parent()
	else:
		overlapping_response = null


func _on_PlayerResponseNode_offset_changed():
	check_dialog_distance()
	
	
func get_full_tree(all_children : Array = []) -> Array:
	if connected_dialog != null and connected_dialog.original_parent == self:
		all_children.append(connected_dialog)
		all_children = connected_dialog.get_full_tree(all_children)
	return all_children


func _on_spin_box_value_changed(value):
	attempt_to_connect_to_dialog_from_id(value)

func attempt_to_connect_to_dialog_from_id(id):
	to_dialog_id = id
	for dialog in get_tree().get_nodes_in_group("Save"):
		if dialog.node_type == "Dialog Node" && dialog.dialog_id == to_dialog_id:
			disconnect_from_dialog(true)
			set_connected_dialog(dialog)
			emit_signal("connect_to_dialog_request",self,0,dialog,0,false)
			dialog.connected_responses.append(self)
			return
	RemoteConnectionContainer.visible = true
	RemoteConnectionVSeparator.visible = false
	RemoteConnectionJumpButton.visible = false
	RemoteConnectionText.text = "ID Manually Set."
	
	if connected_dialog != null:
		connected_dialog.remove_connected_response(self)
		emit_signal("disconnect_from_dialog_request",self,0,connected_dialog,0)

func update_to_id_spinbox(value):
	IdSpinbox.value = value

func save():
	if parent_dialog:
		parent_dialog_id = parent_dialog.dialog_id
	else:
		parent_dialog_id = -1
	return {
		"node_type" : node_type,
		"slot" : slot,
		"option_type" : option_type,
		"color_decimal" :  color_decimal,
		"option_command" : option_command,
		"commands" : commands,
		"response_title": response_title,
		"to_dialog_id" : to_dialog_id,
		"position_offset_x" : position_offset.x,
		"position_offset_y" : position_offset.y,
		"parent_dialog_id" : parent_dialog_id,
		"node_index" : node_index
	}





func _on_response_text_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			selected = true



func _on_color_picker_button_pressed():
	for color in ColorPickerNode.get_picker().get_presets():
		ColorPickerNode.get_picker().erase_preset(color)
	for color in GlobalDeclarations.color_presets:
		ColorPickerNode.get_picker().add_preset(color)
		

