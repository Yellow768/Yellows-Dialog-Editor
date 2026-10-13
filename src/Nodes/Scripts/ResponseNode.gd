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
@onready var IndexSpinBox : SpinBox = SpinBox.new()



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

signal request_slot_change


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
	get_titlebar_hbox().add_child(IndexSpinBox)
	get_titlebar_hbox().move_child(IndexSpinBox,0)
	IndexSpinBox.min_value = 1
	IndexSpinBox.value_changed.connect(index_spinbox_changed)
	IndexSpinBox.get_line_edit().add_theme_constant_override("minimum_character_width", 1)
	var close_btn = Button.new()
	close_btn.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
	close_btn.add_theme_stylebox_override("hover",StyleBoxEmpty.new())
	close_btn.add_theme_stylebox_override("pressed",StyleBoxEmpty.new())
	close_btn.text = "X  "
	close_btn.pressed.connect(Callable(self,"delete_self"))
	get_titlebar_hbox().add_child(close_btn)

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
	request_set_scroll_offset.emit(position_offset)

func set_response_slot(value : int):
	var original_value = slot
	slot = value
	title = tr("RESPONSE_OPTION")
	if IndexSpinBox:
		IndexSpinBox.set_value_no_signal(value+1)
	unsaved_change.emit()
	
func update_max_size_id(value):
	IndexSpinBox.max_value = value
	
	
func update_other_responses_slots(original_slot):
	if !parent_dialog:
		return
	for response in parent_dialog.response_options:
		if response == self:
			continue
		response.update_max_size_id(parent_dialog.response_options.size())
		if response.slot == slot:
			response.set_response_slot(original_slot)
		
	
func index_spinbox_changed(value):
	request_slot_change.emit(self,value-1)
	

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
			disconnect_from_dialog_request.emit(self,0,connected_dialog,0)
	unsaved_change.emit()
	type_changed.emit()
	
func set_color_decimal(new_color : int):
	color_decimal = new_color
	unsaved_change.emit()

func set_command(new_command : String):
	option_command = new_command
	if not is_inside_tree(): await self.ready
	CommandTextNode.text = new_command
	unsaved_change.emit()

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
	to_id_changed.emit()

func set_parent_dialog(new_parent_dialog):
	parent_dialog = new_parent_dialog
	if new_parent_dialog == null: 
		parent_dialog_id = 0
		return
	parent_dialog_id = parent_dialog.dialog_id
	IndexSpinBox.set_value_no_signal(slot+1)
	update_max_size_id(parent_dialog.response_options.size()) 
	update_other_responses_slots(slot)

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
	request_connection_line_hidden.emit(self,connected_dialog)
	connection_hidden = true
	RemoteConnectionContainer.visible = true
	RemoteConnectionVSeparator.visible = true
	set_slot_color_right(0,GlobalDeclarations.response_right_slot_color_hidden)
	set_slot_enabled_right(1,false)
	connected_dialog.set_slot_color_left(0,GlobalDeclarations.dialog_left_slot_color_hidden)
	update_connection_text()
	

func set_connection_shown():
	
	request_connection_line_shown.emit(self,connected_dialog)
	connection_hidden = false
	set_slot_color_right(0,GlobalDeclarations.response_right_slot_color)
	connected_dialog.set_slot_color_left(0,GlobalDeclarations.dialog_left_slot_color)
	set_slot_enabled_right(1,true)
	RemoteConnectionContainer.visible = false
	size.y = 215
	

func disconnect_from_dialog(commit_to_undo := true):
	if connected_dialog!=null:
		connected_dialog.remove_connected_response(self)
		disconnect_from_dialog_request.emit(self,0,connected_dialog,0,commit_to_undo)
		connected_dialog = null
	to_dialog_id = -1
	IdSpinbox.value = 0
	RemoteConnectionContainer.visible = false


func delete_self(commit_to_undo := true):
	if(connected_dialog != null):
		connected_dialog.remove_connected_response(self)
	request_delete_self.emit(parent_dialog,self,commit_to_undo)
	
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
		response_double_clicked.emit()
	
	

func toggle_minimize_node():
	match minimized:
		false:
			$HSeparator.custom_minimum_size.y = 25
			$HBoxContainer/VBoxContainer.visible = false
			$HBoxContainer/AddNewDialog.visible = false
			custom_minimum_size.y = 60
			size.y = 47
			minimized = true
		true:
			$HSeparator.custom_minimum_size.y = 35
			$HBoxContainer/VBoxContainer.visible = true
			$HBoxContainer/AddNewDialog.visible = true
			custom_minimum_size.y = 215
			size.y = 215
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
	connected_dialog = new_dialog
	request_add_dialog.emit(new_dialog,true,commit_to_undo)
	new_dialog.determine_name(self)
	connect_to_dialog_request.emit(self,0,connected_dialog,0,false)

func _on_OptionButton_item_selected(index : int):
	set_option_type(index)


func _on_ColorPickerButton_color_changed(color : Color):
	var colorHex = "0x"+String(color.to_html(false))
	color_decimal = colorHex.hex_to_int()
	update_color(color)
	color_changed.emit(color)
	
func update_color(color):
	ColorPickerNode.color = color
	ResponseTextNode.add_theme_color_override("font_color",color)

func set_response_title(text: String):
	ResponseTextNode.text = text

func _on_ResponseText_text_changed(new_text : String):
	response_title = ResponseTextNode.text
	title_changed.emit()
	unsaved_change.emit()

func _on_CommandText_text_changed():
	option_command = CommandTextNode.text
	option_command_changed.emit()
	unsaved_change.emit()


func _on_DisconnectButton_pressed():
	disconnect_from_dialog()
	reveal_button()


func _on_JumpButton_pressed():
	var dialog_location = connected_dialog.position_offset
	request_set_scroll_offset.emit(dialog_location)
	connected_dialog.selected = true


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
			connect_to_dialog_request.emit(self,0,dialog,0,false)
			dialog.connected_responses.append(self)
			return
	RemoteConnectionContainer.visible = true
	RemoteConnectionVSeparator.visible = false
	RemoteConnectionJumpButton.visible = false
	RemoteConnectionText.text = "ID Manually Set."
	
	if connected_dialog != null:
		connected_dialog.remove_connected_response(self)
		disconnect_from_dialog_request.emit(self,0,connected_dialog,0)

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
		"response_text" : response_text,
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
		



func _on_node_selected():
	set_slot_color_left(1,GlobalDeclarations.orange_slot_highlighted_color)
	set_slot_color_right(1,GlobalDeclarations.blue_slot_highlighted_color)
	if parent_dialog:
		parent_dialog.set_slot_color_right(1,GlobalDeclarations.orange_slot_highlighted_color)
	if connected_dialog:
		connected_dialog.set_slot_color_left(1,GlobalDeclarations.blue_slot_highlighted_color)


func _on_node_deselected():
	set_slot_color_left(1,GlobalDeclarations.response_left_slot_color)
	set_slot_color_right(1,GlobalDeclarations.response_right_slot_color)
	if parent_dialog:
		parent_dialog.set_slot_color_right(1,GlobalDeclarations.dialog_right_slot_color)
		for response in parent_dialog.response_options:
			if response.selected:
				parent_dialog.set_slot_color_right(1,GlobalDeclarations.orange_slot_highlighted_color)
	if connected_dialog:
		connected_dialog.set_slot_color_left(1,GlobalDeclarations.dialog_left_slot_color)
		for response in connected_dialog.connected_responses:
			if response.selected:
				connected_dialog.set_slot_color_left(1,GlobalDeclarations.blue_slot_highlighted_color)
	
