extends Panel

signal hide_information_panel
signal show_information_panel

export(NodePath) var dialog_settings_tab_path


export(NodePath) var hide_npc_checkbox_path
export(NodePath) var show_wheel_checkbox_path
export(NodePath) var disable_esc_checkbox_path
export(NodePath) var title_label_path
export(NodePath) var command_edit_path
export(NodePath) var playsound_edit_path
export(NodePath) var faction_changes_1_path
export(NodePath) var faction_changes_2_path
export(NodePath) var start_quest_path
export(NodePath) var dialog_text_edit_path

export(NodePath) var availability_quests_path
export(NodePath) var availability_dialogs_path 
export(NodePath) var availability_factions_path 
export(NodePath) var availability_scoreboard_path
export(NodePath) var availability_time_path
export(NodePath) var availability_level_path

export(NodePath) var toggle_visiblity_path

onready var DialogSettingsTab = get_node(dialog_settings_tab_path)

onready var HideNpcCheckbox = get_node(hide_npc_checkbox_path)
onready var ShowWheelCheckbox = get_node(show_wheel_checkbox_path)
onready var DisableEscCheckbox = get_node(disable_esc_checkbox_path)
onready var TitleLabel = get_node(title_label_path)
onready var CommandEdit = get_node(command_edit_path)
onready var PlaysoundEdit = get_node(playsound_edit_path)
onready var FactionChanges1 = get_node(faction_changes_1_path)
onready var FactionChanges2 = get_node(faction_changes_2_path)
onready var StartQuest = get_node(start_quest_path)
onready var DialogTextEdit = get_node(dialog_text_edit_path)

onready var AvailabilityQuests = get_node(availability_quests_path)
onready var AvailabilityDialogs = get_node(availability_dialogs_path)
onready var AvailabilityFactions = get_node(availability_factions_path)
onready var AvailabilityScoreboard = get_node(availability_scoreboard_path)
onready var AvailabilityTime = get_node(availability_time_path)
onready var AvailabilityLevel = get_node(availability_level_path)

onready var ToggleVisibility = get_node(toggle_visiblity_path)

var current_dialog
var dialog_availability_mode = false

func _ready(): 
	set_quest_dict()
	for i in 4:
		AvailabilityQuests.get_child(i).connect("id_changed",self,"quest_id_changed")
		AvailabilityQuests.get_child(i).connect("type_changed",self,"quest_type_changed")
		AvailabilityDialogs.get_child(i).connect("id_changed",self,"dialog_id_changed")
		AvailabilityDialogs.get_child(i).connect("type_changed",self,"dialog_type_changed")
		AvailabilityDialogs.get_child(i).connect("enter_dialog_availability_mode",self,"enter_dialog_availability_mode",[AvailabilityDialogs.get_child(i)])
	for i in 2:
		AvailabilityFactions.get_child(i).connect("id_changed",self,"faction_id_changed")
		AvailabilityFactions.get_child(i).connect("stance_changed",self,"faction_stance_changed")
		AvailabilityFactions.get_child(i).connect("isisnot_changed",self,"faction_isisnot_changed")
		
		AvailabilityScoreboard.get_child(i).connect("objective_name_changed",self,"scoreboard_objective_name_changed")
		AvailabilityScoreboard.get_child(i).connect("comparison_type_changed",self,"scoreboard_comparison_type_changed")
		AvailabilityScoreboard.get_child(i).connect("value_changed",self,"scoreboard_value_changed")

func set_quest_dict():
	var access_to_quests = get_tree().get_nodes_in_group("quest_access")
	for node in access_to_quests:
		node.quest_dict = quest_indexer.new().index_quest_categories()

func disconnect_current_dialog(dialog):
	if current_dialog == dialog:
		dialog.disconnect("text_changed",self,"update_text")
		dialog.disconnect("dialog_ready_for_deletion",self,"disconnect_current_dialog")
	current_dialog = null


func dialog_selected(dialog):
	if !dialog_availability_mode:
		load_dialog_settings(dialog)
	else:
		var availability_dialog_id = dialog.dialog_id
		var availability_dialog_title
		
func enter_dialog_availability_mode(availability_scene):
	var current_dialog_id = current_dialog.dialog_id
	var current_category = CurrentEnvironment.current_category_name
	dialog_availability_mode = true
	emit_signal("hide_information_panel")
	ToggleVisibility.toggled = false
	ToggleVisibility.text = "<"


		
func load_dialog_settings(dialog):
	DialogSettingsTab.visible = true
	if current_dialog != dialog:
		if current_dialog != null && is_instance_valid(current_dialog) && current_dialog.is_connected("text_changed",self,"update_text"):
			current_dialog.disconnect("text_changed",self,"update_text")
			current_dialog.disconnect("dialog_ready_for_deletion",self,"disconnect_current_dialog")
		current_dialog = dialog
		if !current_dialog.is_connected("text_changed",self,"update_text"):
			current_dialog.connect("text_changed",self,"update_text")
			current_dialog.connect("dialog_ready_for_deletion",self,"disconnect_current_dialog")
		
		
	TitleLabel.text = current_dialog.dialog_title+" | Node "+String(current_dialog.node_index)
	HideNpcCheckbox.pressed = current_dialog.hide_npc
	ShowWheelCheckbox.pressed = current_dialog.show_wheel
	DisableEscCheckbox.pressed = current_dialog.disable_esc
	CommandEdit.text = current_dialog.command
	PlaysoundEdit.text = current_dialog.sound
	StartQuest.set_id(current_dialog.start_quest)
	DialogTextEdit.text = current_dialog.text
	
	FactionChanges1.set_id(current_dialog.faction_changes[0].faction_id)
	FactionChanges1.set_points(current_dialog.faction_changes[0].points)
	FactionChanges2.set_id(current_dialog.faction_changes[1].faction_id)
	FactionChanges2.set_points(current_dialog.faction_changes[1].points)
	
	AvailabilityTime.get_node("Panel/OptionButton").selected = current_dialog.time_availability
	AvailabilityLevel.get_node("Panel/SpinBox").value = current_dialog.min_level_availability
	
	for i in 4:
		AvailabilityQuests.get_child(i).set_id(current_dialog.quest_availabilities[i].quest_id)
		AvailabilityQuests.get_child(i).set_availability_type(current_dialog.quest_availabilities[i].availability_type)
		AvailabilityDialogs.get_child(i).set_id(current_dialog.dialog_availabilities[i].dialog_id)
		AvailabilityDialogs.get_child(i).set_availability_type(current_dialog.dialog_availabilities[i].availability_type)
	for i in 2:
		AvailabilityFactions.get_child(i).set_id(current_dialog.faction_availabilities[i].faction_id)
		AvailabilityFactions.get_child(i).set_stance(current_dialog.faction_availabilities[i].stance_type)
		AvailabilityFactions.get_child(i).set_isisnot(current_dialog.faction_availabilities[i].availability_operator)
		
		AvailabilityScoreboard.get_child(i).set_objective_name(current_dialog.scoreboard_availabilities[i].objective_name)
		AvailabilityScoreboard.get_child(i).set_comparison_type(current_dialog.scoreboard_availabilities[i].comparison_type)
		AvailabilityScoreboard.get_child(i).set_value(current_dialog.scoreboard_availabilities[i].value)
		
func scoreboard_objective_name_changed(child,obj_name):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].objective_name = obj_name

func scoreboard_comparison_type_changed(child,type):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].comparison_type = type
	
	
func scoreboard_value_changed(child,value):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].value = value
		
func faction_id_changed(child,id):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].faction_id = id

func faction_stance_changed(child,stance):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].stance_type = stance

func faction_isisnot_changed(child,isisnot):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].availability_operator = isisnot


func dialog_id_changed(child,id):
	current_dialog.dialog_availabilities[AvailabilityDialogs.get_children().find(child)].dialog_id = id

	
func dialog_type_changed(child,type):
	current_dialog.dialog_availabilities[AvailabilityDialogs.get_children().find(child)].availability_type = type




func quest_id_changed(child,id):
	current_dialog.quest_availabilities[AvailabilityQuests.get_children().find(child)].quest_id = id

	
func quest_type_changed(child,type):
	current_dialog.quest_availabilities[AvailabilityQuests.get_children().find(child)].availability_type = type

#Dialog Changes

func _on_HideNPC_pressed():
	current_dialog.hide_npc = HideNpcCheckbox.pressed


func _on_ShowDialogWheel_pressed():
	current_dialog.show_wheel = ShowWheelCheckbox.pressed


func _on_DisableEsc_pressed():
	current_dialog.disable_esc = DisableEscCheckbox.pressed



func _on_FactionChange_faction_id_changed(id):
	current_dialog.faction_changes[0].faction_id = id


func _on_FactionChange2_faction_id_changed(id):
	current_dialog.faction_changes[1].faction_id = id


func _on_FactionChange2_faction_points_changed(points):
	current_dialog.faction_changes[1].points = points


func _on_FactionChange_faction_points_changed(points):
	current_dialog.faction_changes[0].points = points


func _on_Command_text_changed():
	current_dialog.command = CommandEdit.text


func _on_TimeButton_item_selected(index):
	current_dialog.time_availability = index


func _on_LevelSpinBox_value_changed(value):
	current_dialog.min_level_availability = value



func _on_DialogText_text_changed():
	current_dialog.text = DialogTextEdit.text

func update_text(text):
	DialogTextEdit.text = text


func _on_StartQuest_id_changed(value):
	current_dialog.start_quest = value


func no_dialog_selected():
	DialogSettingsTab.visible = false


func _on_ToggleVisiblity_toggled(button_pressed):
	if !button_pressed:
		emit_signal("hide_information_panel")
		ToggleVisibility.text = "<"
	else:
		emit_signal("show_information_panel")
		ToggleVisibility.text = ">"


	
	
