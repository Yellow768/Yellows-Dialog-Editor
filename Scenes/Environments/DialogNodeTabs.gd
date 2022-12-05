extends TabContainer

onready var hide_npc_checkbox = $DialogSettings/DialogSettings/VBoxContainer/HideNPC
onready var show_wheel_checkbox = $DialogSettings/DialogSettings/VBoxContainer/ShowDialogWheel
onready var disable_esc_checkbox = $DialogSettings/DialogSettings/VBoxContainer/DisableEsc
onready var title_label = $DialogSettings/DialogSettings/VBoxContainer/Title
onready var command_edit = $DialogSettings/DialogSettings/VBoxContainer/Command
onready var playsound_edit = $DialogSettings/DialogSettings/VBoxContainer/Soundfile
onready var faction_changes_1 = $DialogSettings/DialogSettings/VBoxContainer/FactionChange
onready var faction_changes_2 = $DialogSettings/DialogSettings/VBoxContainer/FactionChange2
onready var start_quest = $DialogSettings/DialogSettings/VBoxContainer/StartQuest
onready var dialog_text_edit = $DialogSettings/DialogSettings/VBoxContainer/DialogText

onready var availability_quests = $AvailabilitySettings/ScrollContainer/Availability/VBoxContainer/QuestOptions
onready var availability_dialogs = $AvailabilitySettings/ScrollContainer/Availability/VBoxContainer/DialogOptions
onready var availability_factions = $AvailabilitySettings/ScrollContainer/Availability/VBoxContainer/FactionOptions
onready var availability_scoreboard = $AvailabilitySettings/ScrollContainer/Availability/VBoxContainer/ScoreboardOptions
onready var availability_time = $AvailabilitySettings/ScrollContainer/Availability/VBoxContainer/TimeandLevel/Time
onready var availability_level = $AvailabilitySettings/ScrollContainer/Availability/VBoxContainer/TimeandLevel/PlayerLevel
var current_dialog

func _ready():
	for i in 4:
		availability_quests.get_child(i).connect("id_changed",self,"quest_id_changed")
		availability_quests.get_child(i).connect("type_changed",self,"quest_type_changed")
		availability_dialogs.get_child(i).connect("id_changed",self,"dialog_id_changed")
		availability_dialogs.get_child(i).connect("type_changed",self,"dialog_type_changed")
	for i in 2:
		availability_factions.get_child(i).connect("id_changed",self,"faction_id_changed")
		availability_factions.get_child(i).connect("stance_changed",self,"faction_stance_changed")
		availability_factions.get_child(i).connect("isisnot_changed",self,"faction_isisnot_changed")
		
		availability_scoreboard.get_child(i).connect("objective_name_changed",self,"scoreboard_objective_name_changed")
		availability_scoreboard.get_child(i).connect("comparison_type_changed",self,"scoreboard_comparison_type_changed")
		availability_scoreboard.get_child(i).connect("value_changed",self,"scoreboard_value_changed")

func disconnect_current_dialog(dialog):
	print("what")
	if current_dialog == dialog:
		dialog.disconnect("text_changed",self,"update_text")
		dialog.disconnect("dialog_ready_for_deletion",self,"disconnect_current_dialog")
	current_dialog = null

		
func load_dialog_settings(dialog):
	get_parent().visible = true
	if current_dialog != null:
		current_dialog.disconnect("text_changed",self,"update_text")
		current_dialog.disconnect("dialog_ready_for_deletion",self,"disconnect_current_dialog")
	
	current_dialog = dialog
	current_dialog.connect("text_changed",self,"update_text")
	current_dialog.connect("dialog_ready_for_deletion",self,"disconnect_current_dialog")
	
	title_label.text = current_dialog.dialog_title+" | Node "+String(current_dialog.node_index)
	hide_npc_checkbox.pressed = current_dialog.hide_npc
	show_wheel_checkbox.pressed = current_dialog.show_wheel
	disable_esc_checkbox.pressed = current_dialog.disable_esc
	command_edit.text = current_dialog.command
	playsound_edit.text = current_dialog.sound
	start_quest.set_id(current_dialog.start_quest)
	dialog_text_edit.text = current_dialog.text
	
	faction_changes_1.set_id(current_dialog.faction_changes[0].faction_id)
	faction_changes_1.set_points(current_dialog.faction_changes[0].points)
	faction_changes_2.set_id(current_dialog.faction_changes[1].faction_id)
	faction_changes_2.set_points(current_dialog.faction_changes[1].points)
	
	availability_time.get_node("Panel/OptionButton").selected = current_dialog.time_availability
	availability_level.get_node("Panel/SpinBox").value = current_dialog.min_level_availability
	
	for i in 4:
		availability_quests.get_child(i).set_id(current_dialog.quest_availabilities[i].quest_id)
		availability_quests.get_child(i).set_availability_type(current_dialog.quest_availabilities[i].availability_type)
		availability_dialogs.get_child(i).set_id(current_dialog.dialog_availabilities[i].dialog_id)
		availability_dialogs.get_child(i).set_availability_type(current_dialog.dialog_availabilities[i].availability_type)
	for i in 2:
		availability_factions.get_child(i).set_id(current_dialog.faction_availabilities[i].faction_id)
		availability_factions.get_child(i).set_stance(current_dialog.faction_availabilities[i].stance_type)
		availability_factions.get_child(i).set_isisnot(current_dialog.faction_availabilities[i].availability_operator)
		
		availability_scoreboard.get_child(i).set_objective_name(current_dialog.scoreboard_availabilities[i].objective_name)
		availability_scoreboard.get_child(i).set_comparison_type(current_dialog.scoreboard_availabilities[i].comparison_type)
		availability_scoreboard.get_child(i).set_value(current_dialog.scoreboard_availabilities[i].value)
		
func scoreboard_objective_name_changed(child,obj_name):
	current_dialog.scoreboard_availabilities[availability_scoreboard.get_children().find(child)].objective_name = obj_name

func scoreboard_comparison_type_changed(child,type):
	current_dialog.scoreboard_availabilities[availability_scoreboard.get_children().find(child)].comparison_type = type
	
	
func scoreboard_value_changed(child,value):
	current_dialog.scoreboard_availabilities[availability_scoreboard.get_children().find(child)].value = value
		
func faction_id_changed(child,id):
	current_dialog.faction_availabilities[availability_factions.get_children().find(child)].faction_id = id

func faction_stance_changed(child,stance):
	current_dialog.faction_availabilities[availability_factions.get_children().find(child)].stance_type = stance

func faction_isisnot_changed(child,isisnot):
	current_dialog.faction_availabilities[availability_factions.get_children().find(child)].availability_operator = isisnot


func dialog_id_changed(child,id):
	current_dialog.dialog_availabilities[availability_dialogs.get_children().find(child)].dialog_id = id

	
func dialog_type_changed(child,type):
	current_dialog.dialog_availabilities[availability_dialogs.get_children().find(child)].availability_type = type




func quest_id_changed(child,id):
	current_dialog.quest_availabilities[availability_quests.get_children().find(child)].quest_id = id

	
func quest_type_changed(child,type):
	current_dialog.quest_availabilities[availability_quests.get_children().find(child)].availability_type = type

#Dialog Changes

func _on_HideNPC_pressed():
	current_dialog.hide_npc = hide_npc_checkbox.pressed


func _on_ShowDialogWheel_pressed():
	current_dialog.show_wheel = show_wheel_checkbox.pressed


func _on_DisableEsc_pressed():
	current_dialog.disable_esc = disable_esc_checkbox.pressed



func _on_FactionChange_faction_id_changed(id):
	current_dialog.faction_changes[0].faction_id = id


func _on_FactionChange2_faction_id_changed(id):
	current_dialog.faction_changes[1].faction_id = id


func _on_FactionChange2_faction_points_changed(points):
	current_dialog.faction_changes[1].points = points


func _on_FactionChange_faction_points_changed(points):
	current_dialog.faction_changes[0].points = points


func _on_Command_text_changed():
	current_dialog.command = command_edit.text


func _on_TimeButton_item_selected(index):
	current_dialog.time_availability = index


func _on_SLevelpinBox_value_changed(value):
	current_dialog.min_level_availability = value



func _on_DialogText_text_changed():
	current_dialog.text = dialog_text_edit.text

func update_text(text):
	dialog_text_edit.text = text


func _on_StartQuest_id_changed(value):
	current_dialog.start_quest = value
