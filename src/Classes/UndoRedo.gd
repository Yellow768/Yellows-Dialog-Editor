extends Node
class_name UndoSystem

enum ACTION_TYPES {CREATE_DIALOG,DELETE_DIALOG,MOVE_DIALOG,MOVE_RESPONSE,MOVE_COLOR,CREATE_RESPONSE,DELETE_RESPONSE,CREATE_COLOR_ORG,DELETE_COLOR_ORG,MULTI_DELETE}

signal undo_saved
signal redo_saved

signal request_action_move_dialog_node
signal request_action_add_dialog_node
signal request_action_delete_dialog_node

signal request_action_move_response_node

#These signals are not 'actions', meaning they are not commited to the UndoRedo history.
signal request_add_response
signal request_connect_nodes

var currentUndoCategoryName : String
var undoRedoHistories : Dictionary

var undo_history = []
var redo_history = []
@export var dialog_editor : DialogGraphEdit

var ignore_all_changes := false


func load_category_undo_redo_history(category_name):
	ignore_all_changes = false
	print("loaded")
	if undoRedoHistories.has(category_name):
		currentUndoCategoryName = category_name
	else:
		undoRedoHistories[category_name] = {
			"undo_history" = [],
			"redo_history" = []
		}
	currentUndoCategoryName = category_name
	

func add_to_undo(type,node,args = []):
	if ignore_all_changes:
		return
	var undo_action
	match type:
		ACTION_TYPES.CREATE_DIALOG :
			undo_action = create_action_add_dialog(node)
		ACTION_TYPES.DELETE_DIALOG :
			undo_action = create_action_delete_dialog(node.node_index)
		ACTION_TYPES.MOVE_DIALOG:
			undo_action = create_action_move_dialog(node.node_index,args[0])
		ACTION_TYPES.MOVE_RESPONSE:
			undo_action = create_action_move_response(node.node_index,args[0])
	undoRedoHistories[currentUndoCategoryName].undo_history.append(undo_action)
	undoRedoHistories[currentUndoCategoryName].redo_history.clear()
#Each function will save the information needed to undo it.




func undo():
	if 	undoRedoHistories[currentUndoCategoryName].undo_history.is_empty():
		print("Nothing to undo")
		return
	var action = undoRedoHistories[currentUndoCategoryName].undo_history.back()
	var redo
	match action.type:
		ACTION_TYPES.CREATE_DIALOG :
			redo = create_action_delete_dialog(action.dialog_data.node_index)
			execute_action_add_dialog(action)
		ACTION_TYPES.DELETE_DIALOG :
			redo = create_action_add_dialog(dialog_editor.current_dialog_index_map[action.node_index].save())
			execute_action_delete_dialog(action)
		ACTION_TYPES.MOVE_DIALOG:
			redo = create_action_move_dialog(action.node_index,dialog_editor.current_dialog_index_map[action.node_index].position_offset)
			execute_action_move_dialog(action)
		ACTION_TYPES.CREATE_DIALOG :
			redo = create_action_delete_dialog(action.dialog_data.node_index)
			execute_action_add_dialog(action)
		ACTION_TYPES.DELETE_DIALOG :
			redo = create_action_add_dialog(dialog_editor.current_dialog_index_map[action.node_index].save())
			execute_action_delete_dialog(action)
		ACTION_TYPES.MOVE_RESPONSE:
			redo = create_action_move_response(action.node_index,dialog_editor.current_response_index_map[action.node_index].position_offset)
			execute_action_move_response(action)	
	undoRedoHistories[currentUndoCategoryName].redo_history.append(redo)
	undoRedoHistories[currentUndoCategoryName].undo_history.pop_back()

			
func redo():
	if 	undoRedoHistories[currentUndoCategoryName].redo_history.is_empty():
		print("Nothing to redo")
		return
	var action = undoRedoHistories[currentUndoCategoryName].redo_history.back()
	var undo
	match action.type:
		ACTION_TYPES.CREATE_DIALOG :
			undo = create_action_delete_dialog(action.dialog_data.node_index)
			execute_action_add_dialog(action)
		ACTION_TYPES.DELETE_DIALOG :
			undo = create_action_add_dialog(dialog_editor.current_dialog_index_map[action.node_index].save())
			execute_action_delete_dialog(action)
		ACTION_TYPES.MOVE_DIALOG:
			undo = create_action_move_dialog(action.node_index,dialog_editor.current_dialog_index_map[action.node_index].position_offset)
			execute_action_move_dialog(action)
			
		ACTION_TYPES.CREATE_RESPONSE :
			undo = create_action_delete_dialog(action.response_data.node_index)
			execute_action_add_dialog(action)
		ACTION_TYPES.DELETE_RESPONSE :
			undo = create_action_add_dialog(dialog_editor.current_response_index_map[action.node_index].save())
			execute_action_delete_dialog(action)
		ACTION_TYPES.MOVE_RESPONSE:
			undo = create_action_move_response(action.node_index,dialog_editor.current_response_index_map[action.node_index].position_offset)
			execute_action_move_response(action)
	undoRedoHistories[currentUndoCategoryName].undo_history.append(undo)
	undoRedoHistories[currentUndoCategoryName].redo_history.pop_back()


func create_action_delete_dialog(node_index : int) -> Dictionary:
	var action = {
		"type" : ACTION_TYPES.DELETE_DIALOG,
		"node_index" : node_index
	}
	
	return action
	
func create_action_add_dialog(dialog_data : Dictionary) -> Dictionary:
	var action = {
		"type" : ACTION_TYPES.CREATE_DIALOG,
		"dialog_data" : dialog_data
	}
	return action
	
func create_action_move_dialog(node_index : int, prev_position : Vector2) -> Dictionary:
	var action = {
		"type" : ACTION_TYPES.MOVE_DIALOG,
		"node_index" : node_index,
		"prev_position" : prev_position
	}
	return action

func create_action_move_response(node_index : int, prev_position : Vector2) -> Dictionary:
	var action = {
		"type" : ACTION_TYPES.MOVE_RESPONSE,
		"node_index" : node_index,
		"prev_position" : prev_position
	}
	return action


func execute_action_move_dialog(action):
	emit_signal("request_action_move_dialog_node",action.node_index,action.prev_position)
	
func execute_action_move_response(action):
	emit_signal("request_action_move_response_node",action.node_index,action.prev_position)
	
func execute_action_delete_dialog(action):
	emit_signal("request_action_delete_dialog_node",dialog_editor.current_dialog_index_map[action.node_index],true,false)
	
func execute_action_add_dialog(action):
	var recreated_dialog = GlobalDeclarations.DIALOG_NODE.instantiate()
	var node_data = action.dialog_data
	recreated_dialog.position_offset = Vector2(node_data["position_offset.x"],node_data["position_offset.y"])
	for i in node_data.keys():
		if i == "position_offset.x" or i == "position_offset.y" or i == "filename" or i == "quest_availabilities" or i == "dialog_availabilities" or i == "faction_availabilities" or i == "scoreboard_availabilities" or i == "faction_changes" or i == "response_options" or i == "mail":
			continue
		recreated_dialog.set(i, node_data[i])
	recreated_dialog.time_availability = node_data["time_availability"]
	recreated_dialog.min_level_availability = node_data["min_level_availability"]
	for i in 4:
		recreated_dialog.quest_availabilities[i].set_id(node_data["quest_availabilities"][i].quest_id)
		recreated_dialog.quest_availabilities[i].set_availability(node_data["quest_availabilities"][i].availability_type)
		recreated_dialog.dialog_availabilities[i].set_id(node_data["dialog_availabilities"][i].dialog_id)
		recreated_dialog.dialog_availabilities[i].set_availability(node_data["dialog_availabilities"][i].availability_type)
		
	for i in 2:
		recreated_dialog.faction_availabilities[i].set_id(node_data["faction_availabilities"][i].faction_id)
		recreated_dialog.faction_availabilities[i].set_stance(node_data["faction_availabilities"][i].stance_type)
		recreated_dialog.faction_availabilities[i].set_operator(node_data["faction_availabilities"][i].availability_operator)
		
		recreated_dialog.faction_changes[i].set_id(node_data["faction_changes"][i].faction_id)
		recreated_dialog.faction_changes[i].set_points(node_data["faction_changes"][i].points)
		
		recreated_dialog.scoreboard_availabilities[i].set_objective_name(node_data["scoreboard_availabilities"][i].objective_name)
		recreated_dialog.scoreboard_availabilities[i].set_comparison_type(node_data["scoreboard_availabilities"][i].comparison_type)
		recreated_dialog.scoreboard_availabilities[i].set_value(node_data["scoreboard_availabilities"][i].value)
	recreated_dialog.mail.sender = node_data["mail"].sender
	recreated_dialog.mail.subject = node_data["mail"].subject
	recreated_dialog.mail.items_slots = JSON.parse_string(node_data["mail"].items)
	recreated_dialog.mail.pages = JSON.parse_string(node_data["mail"].pages) as Array[String]
	recreated_dialog.mail.quest_id = node_data["mail"].quest_id
	emit_signal("request_action_add_dialog_node",recreated_dialog,true,false)
	for response_data in node_data["response_options"]:
		print("cmon")
		var recreated_response = create_response_node_from_ydec(response_data)
		emit_signal("request_add_response",recreated_dialog,recreated_response,false)
		var connected_dialog
		if recreated_response.to_dialog_id != -1:
			connected_dialog = find_dialog_node_from_id(recreated_response.to_dialog_id)
		
		if recreated_response.to_dialog_id > 0 && connected_dialog != null:
			print("attempted connection")
			emit_signal("request_connect_nodes",recreated_response,0,connected_dialog,0,false)


			
func create_response_node_from_ydec(response_data):
	var currently_loaded_response : response_node = GlobalDeclarations.RESPONSE_NODE.instantiate()
	currently_loaded_response.slot = response_data.slot
	currently_loaded_response.color_decimal = response_data.color_decimal
	currently_loaded_response.to_dialog_id = response_data.to_dialog_id
	currently_loaded_response.command = response_data.command
	currently_loaded_response.set_option_from_index(response_data.option_type)
	currently_loaded_response.response_title = response_data.response_title
	currently_loaded_response.position_offset = Vector2(response_data.position_offset_x,response_data.position_offset_y)
	return currently_loaded_response

func find_dialog_node_from_id(id : int):
	var dialog_nodes = get_tree().get_nodes_in_group("Save")
	for dialog in dialog_nodes:
		if dialog.dialog_id == id:
			return dialog
	return null
			

func _on_category_panel_category_loading_initiated(_ignore):
	ignore_all_changes = true
	print("do not commit")



func _on_category_panel_category_loading_finished(_ignore):
	ignore_all_changes = false
	print("loaded")


func _on_dialog_editor_dialog_node_added(dialog):
	print("oy ma8")
	add_to_undo(ACTION_TYPES.DELETE_DIALOG,dialog)


func _on_dialog_editor_dialog_node_perm_deleted(dialog):
	add_to_undo(ACTION_TYPES.CREATE_DIALOG,dialog)


func _on_dialog_editor_dialog_moved(dialog,from):
	print("that thing moved")
	add_to_undo(ACTION_TYPES.MOVE_DIALOG,dialog,[from])


func _on_dialog_editor_dialog_node_deleted(dialog_data):
	add_to_undo(ACTION_TYPES.CREATE_DIALOG,dialog_data)


func _on_dialog_editor_response_moved(response,from):
	print("that response moved")
	add_to_undo(ACTION_TYPES.MOVE_RESPONSE,response,[from])


func _on_dialog_editor_response_node_added(response):
	add_to_undo(ACTION_TYPES.DELETE_RESPONSE,response)
