extends GraphEdit

signal no_dialog_selected
signal dialog_selected
signal editor_cleared
signal finished_loading

signal request_save
signal import_category_canceled

signal dialog_node_added
signal dialog_node_perm_deleted
signal node_double_clicked
signal unsaved_changes
signal save_all

var node_index := 0
var selected_nodes : Array[GraphNode]= []
var selected_responses :Array[GraphNode]= []
var previous_zoom := 1

var all_loaded_dialogs : Array[GraphNode]= []

var ignore_double_clicks := false

var multi_select_mouse_mode = false


func _ready():
	add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG)
	remove_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE)
	add_valid_left_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	add_valid_right_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE)
	set_process_input(false)

func _process(_delta):
	if Input.is_action_pressed("delete_nodes"):
		CurrentEnvironment.handle_subtracting_dialog_id(selected_nodes)
		for i in selected_nodes:
			i.delete_self(true)
			selected_nodes.erase(i)
		for i in selected_responses:
			i.delete_self()
			selected_responses.erase(i)



func add_dialog_node(new_dialog : dialog_node = GlobalDeclarations.DIALOG_NODE.instantiate(), use_exact_offset : bool = false) -> dialog_node:
	#Adds a new dialog node into the editor.
	if new_dialog.node_index == 0:
		new_dialog.node_index = node_index
	node_index += 1
	if new_dialog.dialog_id == -1:
		CurrentEnvironment.highest_id += 1
		new_dialog.dialog_id = CurrentEnvironment.highest_id
		
		
	if new_dialog.position_offset == Vector2.ZERO:
		new_dialog.position_offset = get_window().size/3
	if !use_exact_offset: 
		#Adjust the offset so that it's relative to the current position of the graph's view.
		new_dialog.position_offset = (new_dialog.position_offset+scroll_offset)/zoom	
	new_dialog.connect("add_response_request", Callable(self, "add_response_node"))
	new_dialog.connect("request_delete_response_node", Callable(self, "delete_response_node"))
	new_dialog.connect("dialog_ready_for_deletion", Callable(self, "delete_dialog_node"))
	new_dialog.connect("set_self_as_selected", Callable(self, "select_node"))
	new_dialog.connect("node_double_clicked", Callable(self, "handle_double_click").bind(new_dialog))
	new_dialog.connect("position_offset_changed",Callable(self,"relay_unsaved_changes"))
	new_dialog.connect("request_set_scroll_offset", Callable(self, "set_scroll_offset"))
	new_dialog.connect("unsaved_changes", Callable(self, "relay_unsaved_changes"))
	emit_signal("dialog_node_added",new_dialog)
	add_child(new_dialog)
	return new_dialog

func relay_unsaved_changes():
	emit_signal("unsaved_changes",CurrentEnvironment.current_category_name)

func delete_dialog_node(dialog : dialog_node,remove_from_global_index := false):
	if selected_nodes.find(dialog,0) != -1:
		selected_nodes.erase(dialog)
	set_last_selected_node_as_selected()
	if remove_from_global_index:
		emit_signal("dialog_node_perm_deleted",dialog.dialog_id)
		CurrentEnvironment.handle_subtracting_dialog_id([dialog])
	dialog.queue_free()
	relay_unsaved_changes()
	node_index -=1

	

func add_response_node(parent_dialog : dialog_node, new_response : response_node= GlobalDeclarations.RESPONSE_NODE.instantiate()) -> response_node:
	
	var new_offset
	if new_response.position_offset!=Vector2(0,0):
		new_offset = new_response.position_offset
	elif parent_dialog.response_options.size() == 0:
		new_offset = parent_dialog.position_offset +Vector2(400,0)
	else:
		new_offset = Vector2(parent_dialog.response_options[parent_dialog.response_options.size()-1].position_offset.x,parent_dialog.response_options[parent_dialog.response_options.size()-1].position_offset.y+300)
	parent_dialog.response_options.append(new_response)
	new_response.position_offset = new_offset
	new_response.slot = parent_dialog.response_options.size()-1
	new_response.parent_dialog = parent_dialog
	new_response.connect("request_delete_self", Callable(parent_dialog, "delete_response_node"))
	new_response.connect("connect_to_dialog_request", Callable(self, "connect_nodes"))
	new_response.connect("disconnect_from_dialog_request", Callable(self, "disconnect_nodes"))
	new_response.connect("request_connection_line_shown", Callable(self, "show_connection_line"))
	new_response.connect("request_connection_line_hidden", Callable(self, "hide_connection_line"))
	new_response.connect("request_set_scroll_offset", Callable(self, "set_scroll_offset"))
	new_response.connect("request_add_dialog", Callable(self, "add_dialog_node"))
	new_response.connect("set_self_as_selected", Callable(self, "select_node"))
	new_response.connect("dragged", Callable(self, "response_node_dragged").bind(new_response))
	new_response.connect("response_double_clicked", Callable(self, "handle_double_click").bind(new_response))
	new_response.connect("position_offset_changed",Callable(self,"relay_unsaved_changes"))
	new_response.connect("unsaved_change",Callable(self,"relay_unsaved_changes"))
	add_child(new_response)
	connect_node(parent_dialog.get_name(),0,new_response.get_name(),0)
	relay_unsaved_changes()
	return new_response

func delete_response_node(dialog : dialog_node,response : response_node):
	
	disconnect_node(dialog.get_name(),0,response.get_name(),0)
	if response.connected_dialog != null:
		disconnect_node(response.get_name(),0,response.connected_dialog.get_name(),0)
		response.connected_dialog.remove_connected_response(response)
		response.connected_dialog = null
	if selected_responses.find(response) != -1:
		selected_responses.erase(response)
	response.queue_free()
	relay_unsaved_changes()

var color_organizers = [] #Used to fix a bug where color organizers are made last, so dont allow mouse through them

func add_color_organizer(col_org :color_organizer= GlobalDeclarations.COLOR_ORGANIZER.instantiate(), use_exact_offset : bool = false):
	col_org.position_offset = col_org.initial_offset
	if col_org.initial_offset == Vector2.ZERO:
		col_org.position_offset = get_window().size/3
	if !use_exact_offset:
		col_org.position_offset = (col_org.position_offset+scroll_offset)/zoom
	add_child(col_org)
	color_organizers.append(col_org)

func response_node_dragged(from: Vector2,to : Vector2,response_node):
	if selected_nodes.size() == 0 && Input.is_action_pressed("swap_responses"):
		handle_swapping_responses(response_node,from,to)

func connect_nodes(from : GraphNode, from_slot : int, to: GraphNode, to_slot : int):
	
	var response : response_node
	var dialog : dialog_node
	if from.node_type == "Player Response Node":
		response = from
		dialog = to
	else:
		response = to
		dialog = from
	if response.connected_dialog != null:
		disconnect_node(response.get_name(),from_slot,response.connected_dialog.get_name(),to_slot)
	response.connected_dialog = dialog
	if response.position_offset.distance_to(dialog.position_offset) < GlobalDeclarations.hide_connection_distance:
		connect_node(from.get_name(),from_slot,to.get_name(),to_slot)
	dialog.add_connected_response(response)
	relay_unsaved_changes()

	
func disconnect_nodes(from: GraphNode, from_slot : int, to: GraphNode, to_slot : int):
	
	var response : response_node
	var dialog : dialog_node
	
	if from.node_type == "Player Response Node":
		response = from
		dialog = to
	else:
		response = to
		dialog = from
	
	if response.connected_dialog == dialog:
		response.set_connection_shown()
		disconnect_node(from.get_name(),from_slot,to.get_name(),to_slot)
		dialog.remove_connected_response(response)
		response.reveal_button()	
		response.connected_dialog = null	
	relay_unsaved_changes()

func hide_connection_line(from: GraphNode,to: GraphNode):
	disconnect_node(from.name,0,to.name,0)

func show_connection_line(from: GraphNode,to: GraphNode):
	connect_node(from.name,0,to.name,0)


func handle_swapping_responses(response_node : response_node ,from : Vector2 ,to: Vector2):
	if response_node.overlapping_response != null:
		
		var overlapping_response := response_node.overlapping_response
		var initial_slot := response_node.slot
		var initial_parent := response_node.parent_dialog
		var initial_offset := from
		
		#Switch Slots
		response_node.slot = overlapping_response.slot
		overlapping_response.slot = initial_slot
	
		
		var tween := get_tree().create_tween()
		var initial_tween := get_tree().create_tween()
		tween.tween_property(response_node,"position_offset",overlapping_response.position_offset,.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		initial_tween.tween_property(overlapping_response,"position_offset",from,.1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		
		#Remove from parents array
		response_node.parent_dialog.response_options.erase(response_node)
		disconnect_node(response_node.parent_dialog.get_name(),0,response_node.name,0)
		response_node.disconnect("request_delete_self", Callable(response_node.parent_dialog, "delete_response_node"))
		
		overlapping_response.parent_dialog.response_options.erase(overlapping_response)
		disconnect_node(overlapping_response.parent_dialog.get_name(),0,overlapping_response.get_name(),0)
		overlapping_response.disconnect("request_delete_self", Callable(overlapping_response.parent_dialog, "delete_response_node"))
		
		#Switch to other parents array. Make sure slot isn't invalid
		if response_node.parent_dialog.response_options.size() >= overlapping_response.slot:
			response_node.parent_dialog.response_options.insert(overlapping_response.slot,overlapping_response)
		else:
			response_node.parent_dialog.response_options.append(overlapping_response)
		connect_node(response_node.parent_dialog.get_name(),0,overlapping_response.get_name(),0)
		
		if overlapping_response.parent_dialog.response_options.size() >= response_node.slot:
			overlapping_response.parent_dialog.response_options.insert(response_node.slot,response_node)
		else:
			overlapping_response.parent_dialog.response_options.append(response_node)
		connect_node(overlapping_response.parent_dialog.get_name(),0,response_node.get_name(),0)
		
		#Switch Parents
		response_node.parent_dialog = overlapping_response.parent_dialog
		overlapping_response.parent_dialog = initial_parent
		
		response_node.connect("request_delete_self", Callable(response_node.parent_dialog, "delete_response_node"))
		overlapping_response.connect("request_delete_self", Callable(overlapping_response.parent_dialog, "delete_response_node"))

func set_category_zoom(new_zoom : float):
	zoom = new_zoom

func set_scroll_offset(new_offset : Vector2):
	var tween := get_tree().create_tween()
	tween.tween_property(self,"scroll_offset",(new_offset * zoom)-Vector2(get_window().size)/2,.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func set_last_selected_node_as_selected():
	if selected_nodes.size() < 1:
		emit_signal("no_dialog_selected")
	else:
		if selected_nodes.back().node_type == "Dialog Node":
			emit_signal("dialog_selected",selected_nodes.back())

	
func save():
	return {
		"editor_offset.x" : scroll_offset.x,
		"editor_offset.y" : scroll_offset.y,
		"zoom" : zoom
	}	
	
func on_no_dialogs(category_name):
	clear_editor()
	emit_signal("finished_loading",category_name)
	visible = true

func scan_for_changes(category_name):
	var new_category_importer = category_importer.new()
	new_category_importer.connect("request_add_dialog", Callable(self, "add_dialog_node"))
	new_category_importer.connect("request_add_response", Callable(self, "add_response_node"))
	new_category_importer.connect("request_connect_nodes", Callable(self, "connect_nodes"))
	add_child(new_category_importer)
	new_category_importer.scan_category_for_changes(category_name)
	relay_unsaved_changes()
	
func import_canceled():
	visible = false
	CurrentEnvironment.current_category_name = null
	CurrentEnvironment.allow_save_state = false
	emit_signal("import_category_canceled")
	
		
func clear_editor():
	color_organizers = []
	selected_responses = []
	selected_nodes = []
	var save_nodes = get_tree().get_nodes_in_group("Save")
	var response_nodes = get_tree().get_nodes_in_group("Response_Nodes")
	for i in save_nodes:
		i.delete_self(false)
		i.queue_free()
	for i in response_nodes:
		i.delete_self()
		i.queue_free()	
	node_index = 0
	emit_signal("editor_cleared")
	


func _on_DialogEditor_connection_request(from, from_slot, to, to_slot):
	connect_nodes(get_node(String(from)), from_slot, get_node(String(to)), to_slot)

func _on_DialogEditor_disconnection_request(from, from_slot, to, to_slot):
	disconnect_nodes(get_node(String(from)), from_slot, get_node(String(to)), to_slot)

func select_node(node):
	print("hmmm")
	node.draggable = true
	if Input.is_action_pressed("select_multiple") || multi_select_mouse_mode:
		if !selected_responses.has(node) and node.node_type == "Player Response Node":
			selected_responses.append(node)
			
			
		if !selected_nodes.has(node) and node.node_type == "Dialog Node" :
			selected_nodes.append(node)
	else:
		if (selected_nodes.size() == 1 || selected_responses.size() == 1) && not (selected_nodes.size()>0 && selected_responses.size() > 0):
			selected_responses.clear()
			selected_nodes.clear()
		if !selected_responses.has(node) and node.node_type == "Player Response Node":
			selected_responses.append(node)
				
		if !selected_nodes.has(node) and node.node_type == "Dialog Node" :
			selected_nodes.append(node)
	if node.node_type == "Dialog Node":
		emit_signal("dialog_selected",node)
		

func unselect_node(node):
	if node.node_type == "Player Response Node":
		selected_responses.erase(node)
	if node.node_type == "Dialog Node":
		selected_nodes.erase(node)
		set_last_selected_node_as_selected()
		if double_clicked:
			node.selected = true


var double_clicked = false

func handle_double_click(node):
	double_clicked = true
	multi_select_mouse_mode = true
	
	if node.node_type == "Dialog Node":
		emit_signal("node_double_clicked",node)
		if !ignore_double_clicks:
			for response in node.response_options:
				if !response.selected:
					response.selected = true
					#selected_responses.append(response)
					handle_double_click(response)
				
	if node.node_type == "Player Response Node":
		if !ignore_double_clicks:
			if node.connected_dialog != null and !node.connected_dialog.selected:
				if !node.connection_hidden:
					node.connected_dialog.selected = true
					handle_double_click(node.connected_dialog)
					node.connected_dialog.emit_signal("node_double_clicked")
					#selected_nodes.append(node.connected_dialog)
	multi_select_mouse_mode = false
			


func _on_CategoryImporter_clear_editor_request():
	clear_editor()


func _on_SaveLoad_clear_editor_request():
	clear_editor()



func _on_DialogEditor_gui_input(event):
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		multi_select_mouse_mode = true
	if Input.is_action_just_released("drag"):
		multi_select_mouse_mode = false
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if !Input.is_action_pressed("zoom_key"):
			accept_event()
		else:
			zoom += .02
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if !Input.is_action_pressed("zoom_key"):
			accept_event()
		else:
			zoom -= .02
	if Input.is_action_pressed("zoom_in"):
		zoom += 0.2
	if Input.is_action_pressed("zoom_out"):
		zoom -= 0.2
	if Input.is_key_pressed(KEY_CTRL):
		if Input.is_action_pressed("ui_left"):
			set_scroll_ofs(scroll_offset-Vector2(10,0))
		if Input.is_action_pressed("ui_right"):
			set_scroll_ofs(scroll_offset+Vector2(10,0))
		if Input.is_action_pressed("ui_up"):
			set_scroll_ofs(scroll_offset-Vector2(0,10))
		if Input.is_action_pressed("ui_down"):
			set_scroll_ofs(scroll_offset+Vector2(0,10))
	if Input.is_action_just_pressed("show_minimap"):	
		minimap_enabled = !minimap_enabled
	



func _on_CategoryPanel_current_category_deleted():
	clear_editor()
	visible = false







func _on_InformationPanel_availability_mode_entered() -> void:
	ignore_double_clicks = true


func _on_InformationPanel_availability_mode_exited() -> void:
	ignore_double_clicks = false

	
func reindex_ids():
	EnvironmentIndexer.new().find_highest_index(true)
	for child in get_children():
		if child is GraphNode && child.node_type == "Dialog Node":
			CurrentEnvironment.highest_id +=1
			child.set_dialog_id(CurrentEnvironment.highest_id) 


func _on_category_panel_request_dialog_ids_reassigned():
	reindex_ids()


func _on_autosave_timer_timeout():
	pass # Replace with function body.


func _on_editor_settings_snap_enabled_changed(value):
	use_snap = value


func _on_double_click_timer_timeout():
	double_clicked = false
