extends Control
var current_dialog

@export var information_panel_path : NodePath

@export_group("General Visual")
@export var hide_npc_checkbox_path: NodePath
@export var show_wheel_checkbox_path: NodePath
@export var disable_esc_checkbox_path: NodePath
@export var darken_screen_checkbox_path : NodePath
@export var render_type_option_path : NodePath
@export var text_sound_options : NodePath
@export var text_sound_path : NodePath
@export var text_pitch_path : NodePath
@export var show_previous_dialog_path : NodePath
@export var show_responses_path : NodePath
@export var color_path : NodePath
@export var title_color_path : NodePath
@export var title_label_path: NodePath
@export var color_options_path : NodePath

@export_group("General Settings")
@export var command_edit_path: NodePath
@export var playsound_edit_path: NodePath
@export var faction_changes_1_path: NodePath
@export var faction_changes_2_path: NodePath
@export var start_quest_path: NodePath
@export var dialog_text_edit_path: NodePath


@onready var InformationPanel : Panel = get_node(information_panel_path)
@onready var HideNpcCheckbox := get_node(hide_npc_checkbox_path)
@onready var ShowWheelCheckbox := get_node(show_wheel_checkbox_path)
@onready var DisableEscCheckbox := get_node(disable_esc_checkbox_path)
@onready var DarkenScreenCheckbox := get_node(darken_screen_checkbox_path)
@onready var RenderTypeOption : OptionButton = get_node(render_type_option_path)
@onready var TextSound : TextEdit = get_node(text_sound_path)
@onready var TextPitch : SpinBox = get_node(text_pitch_path)
@onready var ShowPreviousDialog : CheckBox = get_node(show_previous_dialog_path)
@onready var ShowResponses : CheckBox = get_node(show_responses_path)
@onready var DialogColor : ColorPickerButton= get_node(color_path)
@onready var TitleColor : ColorPickerButton= get_node(title_color_path)
@onready var TitleLabel := get_node(title_label_path)
@onready var CommandEdit := get_node(command_edit_path)
@onready var PlaysoundEdit := get_node(playsound_edit_path)
@onready var FactionChanges1 := get_node(faction_changes_1_path)
@onready var FactionChanges2 := get_node(faction_changes_2_path)
@onready var StartQuest := get_node(start_quest_path)
@onready var DialogTextEdit := get_node(dialog_text_edit_path)
@onready var ColorOptions := get_node(color_options_path)
@onready var TextSoundOptions : VBoxContainer = get_node(text_sound_options)
# Called when the node enters the scene tree for the first time.

func update_customnpcs_plus_options():
	DarkenScreenCheckbox.visible = GlobalDeclarations.enable_customnpcs_plus_options
	RenderTypeOption.visible = GlobalDeclarations.enable_customnpcs_plus_options
	if GlobalDeclarations.enable_customnpcs_plus_options && RenderTypeOption.selected == 1:
		TextSoundOptions.visible = true
	else:
		TextSoundOptions.visible = false
	ShowPreviousDialog.visible = GlobalDeclarations.enable_customnpcs_plus_options
	ShowResponses.visible = GlobalDeclarations.enable_customnpcs_plus_options
	ColorOptions.visible = GlobalDeclarations.enable_customnpcs_plus_options


func load_current_dialog_settings(dialog : dialog_node):
	if current_dialog != dialog:
		if current_dialog != null && is_instance_valid(current_dialog) && current_dialog.is_connected("text_changed", Callable(self, "update_text")):
			current_dialog.disconnect("text_changed", Callable(self, "update_text"))
			current_dialog.disconnect("title_changed", Callable(self, "update_title"))
		current_dialog = dialog
		if !current_dialog.is_connected("text_changed", Callable(self, "update_text")):
			current_dialog.connect("text_changed", Callable(self, "update_text"))
			current_dialog.connect("title_changed", Callable(self, "update_title").bind(current_dialog))
	set_title_text(current_dialog.dialog_title,current_dialog.node_index)	
	HideNpcCheckbox.button_pressed = current_dialog.hide_npc
	ShowWheelCheckbox.button_pressed = current_dialog.show_wheel
	DisableEscCheckbox.button_pressed = current_dialog.disable_esc
	CommandEdit.text = current_dialog.command
	PlaysoundEdit.text = current_dialog.sound
	StartQuest.set_id(current_dialog.start_quest)
	DialogTextEdit.text = current_dialog.text
	FactionChanges1.set_id(current_dialog.faction_changes[0].faction_id)
	FactionChanges1.set_points(current_dialog.faction_changes[0].points)
	FactionChanges2.set_id(current_dialog.faction_changes[1].faction_id)
	FactionChanges2.set_points(current_dialog.faction_changes[1].points)
	DarkenScreenCheckbox.button_pressed = current_dialog.darken_screen
	RenderTypeOption.selected = current_dialog.render_gradual
	TextSound.text = current_dialog.text_sound
	TextPitch.value = current_dialog.text_pitch
	ShowPreviousDialog.button_pressed = current_dialog.show_previous_dialog
	ShowResponses.button_pressed = current_dialog.show_response_options
	DialogColor.color = GlobalDeclarations.int_to_color(current_dialog.dialog_color)
	TitleColor.color = GlobalDeclarations.int_to_color(current_dialog.title_color)
	TextSoundOptions.visible = bool(RenderTypeOption.selected)
	
	
func _language_updated():
	FactionChanges1.update_language()
	FactionChanges2.update_language()

func set_title_text(title_text : String,node_index : int):
	if title_text.length() > 35:
		title_text = title_text.left(35)+"..."
	TitleLabel.text = title_text+"| Node "+str(node_index)

func _on_HideNPC_pressed():
	current_dialog.hide_npc = HideNpcCheckbox.button_pressed
	InformationPanel.emit_signal("unsaved_change")
	
func _on_ShowDialogWheel_pressed():
	current_dialog.show_wheel = ShowWheelCheckbox.button_pressed
	InformationPanel.emit_signal("unsaved_change")

func _on_DisableEsc_pressed():
	current_dialog.disable_esc = DisableEscCheckbox.button_pressed
	InformationPanel.emit_signal("unsaved_change")


func _on_FactionChange_faction_id_changed(id : int):
	current_dialog.faction_changes[0].faction_id = id
	InformationPanel.emit_signal("unsaved_change")

func _on_FactionChange2_faction_id_changed(id : int):
	current_dialog.faction_changes[1].faction_id = id
	InformationPanel.emit_signal("unsaved_change")

func _on_FactionChange2_faction_points_changed(points : int):
	current_dialog.faction_changes[1].points = points
	InformationPanel.emit_signal("unsaved_change")

func _on_FactionChange_faction_points_changed(points : int):
	current_dialog.faction_changes[0].points = points
	InformationPanel.emit_signal("unsaved_change")

func _on_Command_text_changed():
	current_dialog.command = CommandEdit.text
	InformationPanel.emit_signal("unsaved_change")
	
func _on_DialogText_text_changed():
	current_dialog.set_dialog_text(DialogTextEdit.text)
	InformationPanel.emit_signal("unsaved_change")

func update_text():
	DialogTextEdit.text = current_dialog.text

func update_title(_text):
	set_title_text(current_dialog.dialog_title,current_dialog.node_index)
	
func _on_StartQuest_id_changed(value : int):
	current_dialog.start_quest = value
	InformationPanel.emit_signal("unsaved_change")
	
func _on_soundfile_text_changed():
	current_dialog.sound = PlaysoundEdit.text





func _on_darken_screen_pressed():
	current_dialog.darken_screen = DarkenScreenCheckbox.button_pressed
	InformationPanel.emit_signal("unsaved_change")


func _on_render_type_item_selected(index):
	current_dialog.render_gradual = index
	TextSoundOptions.visible = bool(index)
	InformationPanel.emit_signal("unsaved_change")

func _on_text_sound_text_changed():
	current_dialog.text_sound = TextSound.text
	InformationPanel.emit_signal("unsaved_change")

func _on_text_pitch_value_changed(value):
	current_dialog.text_pitch = value
	InformationPanel.emit_signal("unsaved_change")

func _on_show_previous_dialog_toggled(button_pressed):
	current_dialog.show_previous_dialog = button_pressed
	InformationPanel.emit_signal("unsaved_change")

func _on_show_response_options_toggled(button_pressed):
	current_dialog.show_response_options = button_pressed
	InformationPanel.emit_signal("unsaved_change")

func _on_color_color_changed(color):
	current_dialog.dialog_color = color.to_html(false).hex_to_int() 
	InformationPanel.emit_signal("unsaved_change")

func _on_title_color_color_changed(color):
	current_dialog.title_color = color.to_html(false).hex_to_int() 
	InformationPanel.emit_signal("unsaved_change")
