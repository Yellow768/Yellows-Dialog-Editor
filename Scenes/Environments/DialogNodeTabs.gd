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





var current_dialog

func load_dialog_settings(dialog):
	current_dialog = dialog
	visible = true
	title_label.text = current_dialog.dialog_title+" | Node "+String(current_dialog.node_index)
	hide_npc_checkbox.pressed = current_dialog.hide_npc
	show_wheel_checkbox.pressed = current_dialog.show_wheel
	disable_esc_checkbox.pressed = current_dialog.disable_esc
	command_edit.text = current_dialog.command
	playsound_edit.text = current_dialog.sound
	
	faction_changes_1.set_id(current_dialog.faction_changes[0].factionID)
	faction_changes_1.set_points(current_dialog.faction_changes[0].points)
	faction_changes_2.set_id(current_dialog.faction_changes[1].factionID)
	faction_changes_2.set_points(current_dialog.faction_changes[1].points)
#Dialog Changes

func _on_HideNPC_pressed():
	current_dialog.hide_npc = hide_npc_checkbox.pressed


func _on_ShowDialogWheel_pressed():
	current_dialog.show_wheel = show_wheel_checkbox.pressed


func _on_DisableEsc_pressed():
	current_dialog.disable_esc = disable_esc_checkbox.pressed



func _on_FactionChange_faction_id_changed(id):
	current_dialog.faction_changes[0].factionID = id


func _on_FactionChange2_faction_id_changed(id):
	current_dialog.faction_changes[1].factionID = id


func _on_FactionChange2_faction_points_changed(points):
	current_dialog.faction_changes[1].points = points


func _on_FactionChange_faction_points_changed(points):
	current_dialog.faction_changes[0].points = points


func _on_Command_text_changed():
	current_dialog.command = command_edit.text
