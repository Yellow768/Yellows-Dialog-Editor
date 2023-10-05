extends Node
class_name UndoSystem

signal undo_saved
signal redo_saved

var undo_history = []
var redo_history = []
var dialog_editor

func add_to_undo(type,node):
	var undo_action
	match type:
		"add_dialog" :
			undo_action = create_action_add_dialog(node.node_index)
		"delete_dialog" :
			undo_action = create_action_delete_dialog(node.save())
		"move_dialog":
			undo_action = create_action_move_dialog(node.node_index,node.position_offset)
	undo_history.append(undo_action)
	redo_history.clear()
#Each function will save the information needed to undo it.


func undo():
	match undo_history.back().type:
		"add_dialog" :
			execute_undo_add_dialog(undo_history.back())
		"delete_dialog" :
			execute_undo_delete_dialog(undo_history.back())
		"move_dialog":
			execute_undo_move_dialog(undo_history.back())

func create_action_add_dialog(node_index : int) -> Dictionary:
	var action = {
		"type" : "add_dialog",
		"node_index" : node_index
	}
	
	return action
	
func create_action_delete_dialog(dialog_data : Dictionary) -> Dictionary:
	var action = {
		"type" : "delete_dialog",
		"dialog_data" : dialog_data
	}
	return action
	
func create_action_move_dialog(node_index : int, prev_position : Vector2) -> Dictionary:
	var action = {
		"type" : "dialog_moved",
		"node_index" : node_index,
		"prev_position" : prev_position
	}
	return action



func execute_undo_move_dialog(action):
	emit_signal("move_dialog_node",action.node_index,action.position)
	
func execute_undo_add_dialog(action):
	emit_signal("delete_dialog_node",action.node_index)
	
func execute_undo_delete_dialog(action):
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
	emit_signal("add_dialog_node",recreated_dialog)
