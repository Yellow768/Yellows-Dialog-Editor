extends Control

signal request_store_current_category
signal request_switch_to_stored_category
signal availability_mode_entered
signal availability_mode_exited
signal ready_to_set_availability
signal initial_dialog_from_availability_mode_loaded

var dialog_availability_mode := false
var exiting_availability_mode := false
var availability_slot : int
var stored_current_dialog_id : int
var glob_node_selected_id : int




@export_group("Availability")
@export var availability_quests_path: NodePath
@export var availability_dialogs_path: NodePath 
@export var availability_factions_path: NodePath 
@export var availability_scoreboard_path: NodePath
@export var availability_time_path: NodePath
@export var availability_level_path: NodePath
@export var information_panel_path : NodePath

@onready var AvailabilityQuests := get_node(availability_quests_path)
@onready var AvailabilityDialogs := get_node(availability_dialogs_path)
@onready var AvailabilityFactions := get_node(availability_factions_path)
@onready var AvailabilityScoreboard := get_node(availability_scoreboard_path)
@onready var AvailabilityTime := get_node(availability_time_path)
@onready var AvailabilityLevel := get_node(availability_level_path)
@onready var InformationPanel : Panel = get_node(information_panel_path)

var current_dialog

func _ready():
	get_tree().get_root().size_changed.connect(Callable(self,"resized"))
	for i in 4:
		AvailabilityQuests.get_child(i).connect("id_changed", Callable(self, "quest_id_changed"))
		AvailabilityQuests.get_child(i).connect("type_changed", Callable(self, "quest_type_changed"))
		AvailabilityDialogs.get_child(i).connect("id_changed", Callable(self, "dialog_id_changed"))
		AvailabilityDialogs.get_child(i).connect("type_changed", Callable(self, "dialog_type_changed"))
		AvailabilityDialogs.get_child(i).connect("enter_dialog_availability_mode", Callable(self, "enter_dialog_availability_mode").bind(AvailabilityDialogs.get_child(i)))
	for i in 2:
		AvailabilityFactions.get_child(i).connect("id_changed", Callable(self, "faction_id_changed"))
		AvailabilityFactions.get_child(i).connect("stance_changed", Callable(self, "faction_stance_changed"))
		AvailabilityFactions.get_child(i).connect("isisnot_changed", Callable(self, "faction_isisnot_changed"))
		
		AvailabilityScoreboard.get_child(i).connect("objective_name_changed", Callable(self, "scoreboard_objective_name_changed"))
		AvailabilityScoreboard.get_child(i).connect("comparison_type_changed", Callable(self, "scoreboard_comparison_type_changed"))
		AvailabilityScoreboard.get_child(i).connect("value_changed", Callable(self, "scoreboard_value_changed"))

func load_current_dialog_settings(dialog : dialog_node):
	current_dialog = dialog
	AvailabilityTime.selected = current_dialog.time_availability
	AvailabilityLevel.value = current_dialog.min_level_availability
	
	for i in 4:
		AvailabilityQuests.get_child(i).set_id(current_dialog.quest_availabilities[i].quest_id)
		AvailabilityQuests.get_child(i).set_availability_type(current_dialog.quest_availabilities[i].availability_type)
		AvailabilityDialogs.get_child(i).set_id(current_dialog.dialog_availabilities[i].dialog_id)
		AvailabilityDialogs.get_child(i).set_availability_type(current_dialog.dialog_availabilities[i].availability_type)
		AvailabilityDialogs.get_child(i).set_choose_dialog_disbaled_proper()
	for i in 2:
		AvailabilityFactions.get_child(i).set_id(current_dialog.faction_availabilities[i].faction_id)
		AvailabilityFactions.get_child(i).set_stance(current_dialog.faction_availabilities[i].stance_type)
		AvailabilityFactions.get_child(i).set_isisnot(current_dialog.faction_availabilities[i].availability_operator)
		
		AvailabilityScoreboard.get_child(i).set_objective_name(current_dialog.scoreboard_availabilities[i].objective_name)
		AvailabilityScoreboard.get_child(i).set_comparison_type(current_dialog.scoreboard_availabilities[i].comparison_type)
		AvailabilityScoreboard.get_child(i).set_value(current_dialog.scoreboard_availabilities[i].value)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if dialog_availability_mode:
			exit_dialog_availability_mode()

func enter_dialog_availability_mode(availability_scene):
	stored_current_dialog_id = current_dialog.dialog_id
	availability_slot = AvailabilityDialogs.get_children().find(availability_scene)
	dialog_availability_mode = true
	emit_signal("request_store_current_category")
	emit_signal("availability_mode_entered")
	InformationPanel.set_panel_visible(false)
	print("Availability Mode Entered")

	
func set_dialog_availability_from_selected_node(node_selected : GraphNode):
	if dialog_availability_mode:
		glob_node_selected_id = node_selected.dialog_id
		var new_timer = Timer.new()
		add_child(new_timer)
		new_timer.start(0.3)
		await new_timer.timeout
		new_timer.queue_free()
		#I know that using a delay is a bad solution for a race condition,
		#but I'm not even really sure what the race condition is. This little
		#delay prevents the node that was chosen for the dialog availability
		#remaining selected if it's within the same category
		if node_selected.is_inside_tree():
			node_selected.set_self_as_unselected()
		exit_dialog_availability_mode()
		
		
		
func exit_dialog_availability_mode():
	exiting_availability_mode = true
	emit_signal("request_switch_to_stored_category")
	InformationPanel.set_panel_visible(true)


func find_dialog_node_from_id(id : int):
	var dialog_nodes = get_tree().get_nodes_in_group("Save")
	for dialog in dialog_nodes:
		if dialog.node_type == "Dialog Node" && dialog.dialog_id == id:
			return dialog
			

func _on_category_panel_finished_loading(_ignore):
	if exiting_availability_mode:
		var initial_dialog : GraphNode = find_dialog_node_from_id(stored_current_dialog_id)
		emit_signal("availability_mode_exited")
		emit_signal("initial_dialog_from_availability_mode_loaded",initial_dialog)
		initial_dialog.dialog_availabilities[availability_slot].dialog_id = glob_node_selected_id
		initial_dialog.selected = true
		initial_dialog.draggable = false
		InformationPanel.emit_signal("unsaved_change")
		print("Availability Mode Exited")			
		dialog_availability_mode = false
		exiting_availability_mode = false



func scoreboard_objective_name_changed(child ,obj_name : String):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].objective_name = obj_name
	InformationPanel.emit_signal("unsaved_change")
func scoreboard_comparison_type_changed(child,type : int):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].comparison_type = type
	InformationPanel.emit_signal("unsaved_change")
	
func scoreboard_value_changed(child ,value : int):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].value = value
	InformationPanel.emit_signal("unsaved_change")		
func faction_id_changed(child ,id : int):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].faction_id = id
	InformationPanel.emit_signal("unsaved_change")
func faction_stance_changed(child,stance:int):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].stance_type = stance
	InformationPanel.emit_signal("unsaved_change")
func faction_isisnot_changed(child ,isisnot : int):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].availability_operator = isisnot
	InformationPanel.emit_signal("unsaved_change")

func dialog_id_changed(child,id : int):
	current_dialog.dialog_availabilities[AvailabilityDialogs.get_children().find(child)].dialog_id = id
	InformationPanel.emit_signal("unsaved_change")
	
func dialog_type_changed(child,type : int):
	current_dialog.dialog_availabilities[AvailabilityDialogs.get_children().find(child)].availability_type = type
	InformationPanel.emit_signal("unsaved_change")



func quest_id_changed(child,id : int):
	current_dialog.quest_availabilities[AvailabilityQuests.get_children().find(child)].quest_id = id
	InformationPanel.emit_signal("unsaved_change")

	
func quest_type_changed(child,type : int):
	current_dialog.quest_availabilities[AvailabilityQuests.get_children().find(child)].availability_type = type
	InformationPanel.emit_signal("unsaved_change")
#Dialog Changes

func _on_TimeButton_item_selected(index : int):
	current_dialog.time_availability = index
	InformationPanel.emit_signal("unsaved_change")

func _on_LevelSpinBox_value_changed(value : int):
	current_dialog.min_level_availability = value
	InformationPanel.emit_signal("unsaved_change")

func resized():
	$Availability.size.y = DisplayServer.window_get_size().y
