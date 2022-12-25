extends GraphEdit

signal no_dialog_selected
signal dialog_selected
signal editor_cleared
signal finished_loading


signal dialog_node_added
signal dialog_node_perm_deleted
signal node_double_clicked

var node_index = 0
var selected_nodes = []
var selected_responses = []
var previous_zoom = 1

var all_loaded_dialogs = []



func _ready():
	get_zoom_hbox().visible = false
	add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	add_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE,GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG)
	
	remove_valid_connection_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_DIALOG,GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_RESPONSE)
	add_valid_left_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_INTO_DIALOG)
	add_valid_right_disconnect_type(GlobalDeclarations.CONNECTION_TYPES.PORT_FROM_RESPONSE)
	set_process_input(false)

func _process(_delta):
	if Input.is_action_pressed("ui_delete"):
		handle_subtracting_dialog_id(selected_nodes)
		for i in selected_nodes:
			i.delete_self()
			selected_nodes.erase(i)
		for i in selected_responses:
			i.delete_self()
			selected_responses.erase(i)

func add_dialog_node(new_dialog = GlobalDeclarations.DIALOG_NODE.instance(), use_exact_offset : bool = false):
	#Adds a new dialog node into the editor.
	
	if new_dialog.node_index == 0:
		new_dialog.node_index = node_index
	node_index += 1
	if new_dialog.dialog_id == -1:
		new_dialog.dialog_id = CurrentEnvironment.highest_id+1
		CurrentEnvironment.highest_id += 1
		
	if new_dialog.offset == Vector2.ZERO:
		new_dialog.offset = OS.window_size/2
	if !use_exact_offset: 
		#Adjust the offset so that it's relative to the current position of the graph's view.
		new_dialog.offset = (new_dialog.offset+scroll_offset)/zoom	
	new_dialog.connect("add_response_request",self,"add_response_node")
	new_dialog.connect("delete_response_node",self,"delete_response_node")
	new_dialog.connect("dialog_ready_for_deletion",self,"delete_dialog_node")
	new_dialog.connect("set_self_as_selected",self,"_on_node_requests_selection")
	new_dialog.connect("node_double_clicked",self,"emit_signal",["node_double_clicked",new_dialog])
	add_child(new_dialog)
	emit_signal("dialog_node_added",new_dialog)
	return new_dialog


func delete_dialog_node(dialog,remove_from_loaded_list = false):
	if selected_nodes.find(dialog,0) != -1:
		selected_nodes.erase(dialog)
	set_last_selected_node_as_selected()
	if remove_from_loaded_list:
		emit_signal("dialog_node_perm_deleted",dialog.dialog_id)
	dialog.queue_free()
	node_index -=1
	

func add_response_node(parent_dialog : dialog_node, new_response = GlobalDeclarations.RESPONSE_NODE.instance()):
	var new_instance_offset = Vector2(350,GlobalDeclarations.RESPONSE_NODE_VERTICAL_OFFSET*parent_dialog.response_options.size())
	for response in parent_dialog.response_options:
		response.offset -= Vector2(0,GlobalDeclarations.RESPONSE_NODE_VERTICAL_OFFSET)
	parent_dialog.response_options.append(new_response)
	new_response.offset = parent_dialog.offset + new_instance_offset
	new_response.slot = parent_dialog.response_options.size()-1
	new_response.parent_dialog = parent_dialog
	new_response.connect("delete_self",parent_dialog,"delete_response_node")
	new_response.connect("connect_to_dialog_request", self, "connect_nodes")
	new_response.connect("disconnect_from_dialog_request",self,"disconnect_nodes")
	new_response.connect("request_connection_line_shown",self,"show_connection_line")
	new_response.connect("request_connection_line_hidden",self,"hide_connection_line")
	new_response.connect("request_set_scroll_offset",self,"set_scroll_offset")
	new_response.connect("request_add_dialog",self,"add_dialog_node")
	new_response.connect("dragged",self,"response_node_dragged",[new_response])
	add_child(new_response)
	new_response.set_focus_on_title()
	connect_node(parent_dialog.get_name(),0,new_response.get_name(),0)
	return new_response

func delete_response_node(dialog,response):
	disconnect_node(dialog.get_name(),0,response.get_name(),0)
	if response.connected_dialog != null:
		disconnect_node(response.get_name(),0,response.connected_dialog.get_name(),0)
		response.connected_dialog.remove_connected_response(response)
		response.connected_dialog = null
	if selected_responses.find(response) != -1:
		selected_responses.erase(response)
	response.queue_free()



func response_node_dragged(from,to,response_node):
	if selected_nodes.size() == 0:
		handle_swapping_responses(response_node,from,to)
	elif selected_nodes.find(response_node.parent_dialog) == -1:
		response_node.offset = from

func handle_swapping_responses(response_node : response_node ,from : Vector2 ,to: Vector2):
	if response_node.overlapping_response != null:
		var overlapping_response = response_node.overlapping_response
		var initial_slot = response_node.slot
		var initial_parent = response_node.parent_dialog
		var initial_offset = from
		
		#Switch Slots
		response_node.slot = overlapping_response.slot
		overlapping_response.slot = initial_slot
		
		#Switch positions
		response_node.offset = overlapping_response.offset
		overlapping_response.offset = initial_offset
		
		#Remove from parents array
		response_node.parent_dialog.response_options.erase(response_node)
		disconnect_node(response_node.parent_dialog.get_name(),0,response_node.name,0)
		response_node.disconnect("delete_self",response_node.parent_dialog,"delete_response_node")
		
		overlapping_response.parent_dialog.response_options.erase(overlapping_response)
		disconnect_node(overlapping_response.parent_dialog.get_name(),0,overlapping_response.get_name(),0)
		overlapping_response.disconnect("delete_self",overlapping_response.parent_dialog,"delete_response_node")
		
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
		
		response_node.connect("delete_self",response_node.parent_dialog,"delete_response_node")
		overlapping_response.connect("delete_self",overlapping_response.parent_dialog,"delete_response_node")
	else:
		response_node.offset = from

func set_cat_zoom(new_zoom):
	zoom = new_zoom

func set_scroll_offset(new_offset,ignore_zoom : bool = false):
	if ignore_zoom:
		set_scroll_ofs((new_offset * zoom)-OS.window_size/2)
	else:
		set_scroll_ofs(new_offset-(OS.window_size/2))	
	


func connect_nodes(from, from_slot, to, to_slot):
	var response
	var dialog
	if get_node(from).node_type == "Player Response Node":
		response = get_node(from)
		dialog = get_node(to)
	else:
		response = get_node(to)
		dialog = get_node(from)
	
	
	if response.connected_dialog != null:
		disconnect_node(response.get_name(),from_slot,response.connected_dialog.get_name(),to_slot)
	response.connected_dialog = dialog
	if(response.offset.distance_to(dialog.offset) < 1000):
		connect_node(from,from_slot,to,to_slot)
	dialog.add_connected_response(response)


	
func disconnect_nodes(from, from_slot, to, to_slot):
	var response
	var dialog
	
	if get_node(from).node_type == "Player Response Node":
		response = get_node(from)
		dialog = get_node(to)
	else:
		response = get_node(to)
		dialog = get_node(from)
	
	if response.connected_dialog == dialog:
		response.set_connection_shown()
		disconnect_node(from,from_slot,to,to_slot)
		dialog.remove_connected_response(response)
		response.reveal_button()
		
		response.connected_dialog = null
		
		
	else:
		disconnect_node(from,from_slot,to,to_slot)
		response.reveal_button()

func hide_connection_line(from,to):
	disconnect_node(from.name,0,to.name,0)

func show_connection_line(from,to):
	connect_node(from.name,0,to.name,0)
	
func set_last_selected_node_as_selected():
	if selected_nodes.size() < 1:
		emit_signal("no_dialog_selected")
	else:
		if selected_nodes.back().node_type == "Dialog Node":
			emit_signal("dialog_selected",selected_nodes.back())

func handle_subtracting_dialog_id(dialogs_to_be_deleted : Array):
	var sorted_ids = dialogs_to_be_deleted.duplicate()
	sorted_ids.sort_custom(self,"sort_array_by_dialog_id")
	for node in sorted_ids:
		print(node.dialog_id)
		if node.dialog_id == CurrentEnvironment.highest_id:
			CurrentEnvironment.highest_id -= 1

func sort_array_by_dialog_id(a,b):
	if a.dialog_id != b.dialog_id:
		return a.dialog_id > b.dialog_id
	else:
		return a.dialog_id > b.dialog_id
	
	

func _on_CategoryPanel_request_load_category(category_name):
	var new_category_loader = category_loader.new()
	new_category_loader.connect("add_dialog",self,"add_dialog_node")
	new_category_loader.connect("add_response",self,"add_response_node")
	new_category_loader.connect("no_ydec_found",self,"initialize_category_import")
	new_category_loader.connect("clear_editor_request",self,"clear_editor")
	new_category_loader.connect("request_connect_nodes",self,"connect_nodes")
	new_category_loader.connect("set_scroll_offset",self,"set_scroll_offset",[true])
	new_category_loader.connect("set_zoom",self,"set_cat_zoom")
	if new_category_loader.load_category(category_name) == OK:
		emit_signal("finished_loading",category_name)
		visible = true
		
	
func initialize_category_import(category_name):
	var choose_dialog_popup = load("res://src/UI/Util/ChooseInitialDialogPopup.tscn").instance()
	choose_dialog_popup.connect("initial_dialog_chosen",self,"import_category")
	choose_dialog_popup.connect("no_dialogs",self,"on_no_dialogs",[category_name])
	add_child(choose_dialog_popup)
	choose_dialog_popup.create_dialog_buttons(category_name)
	
func import_category(category_name,all_dialogs,index):
	var new_category_importer = category_importer.new()
	new_category_importer.connect("request_add_dialog",self,"add_dialog_node")
	new_category_importer.connect("request_add_response",self,"add_response_node")
	new_category_importer.connect("request_connect_nodes",self,"connect_nodes")
	new_category_importer.connect("clear_editor_request",self,"clear_editor")
	new_category_importer.initial_dialog_chosen(category_name,all_dialogs,index)
	var new_cat_save = category_saver.new()
	add_child(new_cat_save)
	new_cat_save.save_category(category_name)	
	emit_signal("finished_loading",category_name)
	visible = true	
		
func on_no_dialogs(category_name):
	clear_editor()
	emit_signal("finished_loading",category_name)
	visible = true

func scan_for_changes(category_name):
	var new_category_importer = category_importer.new()
	new_category_importer.connect("request_add_dialog",self,"add_dialog_node")
	new_category_importer.connect("request_add_response",self,"add_response_node")
	new_category_importer.connect("request_connect_nodes",self,"connect_nodes")
	add_child(new_category_importer)
	new_category_importer.scan_category_for_changes(category_name)
	
		
func clear_editor():
	
	selected_responses = []
	selected_nodes = []
	var save_nodes = get_tree().get_nodes_in_group("Save")
	var response_nodes = get_tree().get_nodes_in_group("Response_Nodes")
	for i in save_nodes:
		i.delete_self()
	for i in response_nodes:
		i.delete_self()	
	node_index = 0
	emit_signal("editor_cleared")



	
func _on_BTN_AddNode_pressed():
	add_dialog_node()


func _on_DialogEditor_connection_request(from, from_slot, to, to_slot):
	connect_nodes(from, from_slot, to, to_slot)

func _on_DialogEditor_disconnection_request(from, from_slot, to, to_slot):
	disconnect_nodes(from, from_slot, to, to_slot)

func _on_DialogEditor_node_selected(node):
	if node.node_type == "Player Response Node":
		selected_responses.append(node)
	if selected_nodes.find(node,0) == -1 and node.node_type == "Dialog Node" :
		selected_nodes.append(node)
		emit_signal("dialog_selected",node)

func _on_DialogEditor_node_unselected(node):
	if node.node_type == "Player Response Node":
		selected_responses.erase(node)
	if node.node_type == "Dialog Node":
		selected_nodes.erase(node)
		set_last_selected_node_as_selected()
		


		
func _on_node_requests_selection(node):
	selected_nodes = []
	selected_responses = []
	set_selected(node)
	_on_DialogEditor_node_selected(node)


func _on_CategoryImporter_clear_editor_request():
	clear_editor()


func _on_SaveLoad_clear_editor_request():
	clear_editor()



func _on_DialogEditor_gui_input(event):
	if event is InputEventMouseButton && event.button_index == BUTTON_WHEEL_UP:
		if !Input.is_action_pressed("shift"):
			accept_event()
		else:
			zoom += .02
	if event is InputEventMouseButton && event.button_index == BUTTON_WHEEL_DOWN:
		if !Input.is_action_pressed("shift"):
			accept_event()
		else:
			zoom -= .02


func _on_CategoryPanel_current_category_deleted():
	clear_editor()
	visible = false
