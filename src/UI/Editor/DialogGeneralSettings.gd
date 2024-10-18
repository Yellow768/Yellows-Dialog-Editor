extends Control
var current_dialog : dialog_node

@export var information_panel_path : NodePath

@export_group("General Visual")
@export var visual_options_group_path : NodePath
@export var visual_options_toggle_path : NodePath
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
@export var preset_options_path : NodePath
@export var toggle_preset_visible_path : NodePath
@export var preset_text_edit_path : NodePath
@export var preset_option_button_path : NodePath
@export var visual_settings_path : NodePath
@export var preset_lock_path : NodePath

@export_group("General Settings")
@export var command_edit_path: NodePath
@export var playsound_edit_path: NodePath
@export var faction_changes_1_path: NodePath
@export var faction_changes_2_path: NodePath
@export var start_quest_path: NodePath
@export var dialog_text_edit_path: NodePath


@onready var InformationPanel : Panel = get_node(information_panel_path)
@onready var VisualOptionsGroup : VBoxContainer = get_node(visual_options_group_path)
@onready var VisualOptionsToggle : Button = get_node(visual_options_toggle_path)
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
@onready var PresetOptions : VBoxContainer = get_node(preset_options_path)
@onready var TogglePresetOptionsVisible : Button = get_node(toggle_preset_visible_path)
@onready var VisualSettings : VBoxContainer = get_node(visual_settings_path)
@onready var PresetLock : Button = get_node(preset_lock_path)


@onready var PresetOptionButton : OptionButton = get_node(preset_option_button_path)
@onready var PresetTextEdit : TextEdit = get_node(preset_text_edit_path)
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

func _ready():
	for color in GlobalDeclarations.color_presets:
		DialogColor.get_picker().add_preset(color)
		TitleColor.get_picker().add_preset(color)
	DialogColor.get_picker().connect("preset_added",Callable(GlobalDeclarations,"add_color_preset"))
	DialogColor.get_picker().connect("preset_removed",Callable(GlobalDeclarations,"remove_color_preset"))
	TitleColor.get_picker().connect("preset_added",Callable(GlobalDeclarations,"add_color_preset"))
	TitleColor.get_picker().connect("preset_removed",Callable(GlobalDeclarations,"remove_color_preset"))
	create_preset_list()
	PresetTextEdit.placeholder_text = tr("NEW_PRESET_TEXT")
	update_customnpcs_plus_options()

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
	set_title_text(current_dialog.dialog_title,current_dialog.dialog_id)	
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
	if current_dialog.visual_preset != -1 && GlobalDeclarations.visual_presets.has(current_dialog.visual_preset):
		PresetOptionButton.select(PresetOptionButton.get_item_index(current_dialog.visual_preset))
	else:
		PresetOptionButton.select(-1)
		current_dialog.visual_preset = -1
	PresetLock.button_pressed = current_dialog.lock_visual_preset
	PresetLock.toggled.emit(PresetLock.button_pressed)
	if current_dialog.lock_visual_preset:
		set_settings_to_preset(current_dialog.visual_preset)
	

func disconnect_current_dialog(dialog: dialog_node):
	dialog.disconnect("text_changed", Callable(self, "update_text"))
	dialog.disconnect("title_changed", Callable(self, "update_title"))
	
func _language_updated():
	FactionChanges1.update_language()
	FactionChanges2.update_language()

func set_title_text(title_text : String,node_index : int):
	if title_text.length() > 35:
		title_text = title_text.left(35)+"..."
	TitleLabel.text = title_text+"| ID "+str(node_index)

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
	set_title_text(current_dialog.dialog_title,current_dialog.dialog_id)
	
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


func _on_title_color_pressed():
	for color in TitleColor.get_picker().get_presets():
		TitleColor.get_picker().erase_preset(color)
	for color in GlobalDeclarations.color_presets:
		TitleColor.get_picker().add_preset(color)


func _on_color_pressed():
	for color in DialogColor.get_picker().get_presets():
		DialogColor.get_picker().erase_preset(color)
	for color in GlobalDeclarations.color_presets:
		DialogColor.get_picker().add_preset(color)


func _on_toggle_visual_options_toggled(button_pressed):
	VisualOptionsGroup.visible = button_pressed
	if button_pressed:
		VisualOptionsToggle.text = "V"
	else:
		VisualOptionsToggle.text = ">"
		


func _on_toggle_preset_visible_toggled(button_pressed):
	PresetOptions.visible = button_pressed
	if button_pressed:
		TogglePresetOptionsVisible.text = "V"
	else:
		TogglePresetOptionsVisible.text = ">"
		
		


func create_preset_list():
	PresetOptionButton.clear()
	for preset in GlobalDeclarations.visual_presets.keys():
		PresetOptionButton.add_item(GlobalDeclarations.visual_presets[preset].Name,int(preset))
	if current_dialog:
		PresetOptionButton.select(PresetOptionButton.get_item_index(current_dialog.visual_preset))

func _on_add_preset_button_pressed():
	if PresetTextEdit.text != "":
		var preset_name = PresetTextEdit.text
		for preset in GlobalDeclarations.visual_presets:
			if GlobalDeclarations.visual_presets[preset].Name == PresetTextEdit.text:
				preset_name += "_"
		var preset_keys = GlobalDeclarations.visual_presets.keys()
		preset_keys.sort()
		var ID 
		if preset_keys.size() == 0:
			ID = 0
		else:
			ID = preset_keys.back() + 1
		GlobalDeclarations.visual_presets[ID] = {
			"Name" : preset_name,
			"HideNPC" : HideNpcCheckbox.button_pressed,
			"ShowDialogWheel" : ShowWheelCheckbox.button_pressed,
			"DisableEsc" : DisableEscCheckbox.button_pressed,
			"DarkenScreen" : DarkenScreenCheckbox.button_pressed,
			"RenderType" : RenderTypeOption.selected,
			"TextSound" : TextSound.text,
			"TextPitch" : TextPitch.value,
			"ShowPreviousDialog" : ShowPreviousDialog.button_pressed,
			"ShowResponseOptions" : ShowResponses.button_pressed,
			"DialogColor" : DialogColor.color.to_html(false).hex_to_int(),
			"TitleColor" : TitleColor.color.to_html(false).hex_to_int() 
		}
		current_dialog.visual_preset = ID
	create_preset_list()
	GlobalDeclarations.save_config()


func _on_remove_preset_button_pressed():
	if PresetOptionButton.selected == -1 or PresetOptionButton.selected == 0:
		return
	var confirm_deletion_popup = load("res://src/UI/Util/ConfirmDeletion.tscn").instantiate()
	confirm_deletion_popup.connect("confirmed", Callable(self, "delete_preset"))
	var format_text = tr("PRESET_CONFIRM_DELETION")
	confirm_deletion_popup.dialog_text = format_text % PresetOptionButton.get_item_text(PresetOptionButton.selected)
	$".".add_child(confirm_deletion_popup)
	confirm_deletion_popup.popup_centered()


func delete_preset():
	if GlobalDeclarations.default_visual_preset == PresetOptionButton.get_item_id(PresetOptionButton.selected):
		GlobalDeclarations.default_visual_preset = -1
	GlobalDeclarations.visual_presets.erase(PresetOptionButton.get_item_id(PresetOptionButton.selected))
	current_dialog.visual_preset = -1
	create_preset_list()
	GlobalDeclarations.save_config()
	

func _on_update_preset_button_pressed():
	
	if PresetOptionButton.selected == -1 or PresetOptionButton.selected == 0:
		return
	var preset_name
	if PresetTextEdit.text.is_empty():
		preset_name = PresetOptionButton.get_item_text(PresetOptionButton.selected)
	else:
		preset_name = PresetTextEdit.text
	GlobalDeclarations.visual_presets[PresetOptionButton.get_item_id(PresetOptionButton.selected)]={
		"Name" : preset_name,
		"HideNPC" : HideNpcCheckbox.button_pressed,
		"ShowDialogWheel" : ShowWheelCheckbox.button_pressed,
		"DisableEsc" : DisableEscCheckbox.button_pressed,
		"DarkenScreen" : DarkenScreenCheckbox.button_pressed,
		"RenderType" : RenderTypeOption.selected,
		"TextSound" : TextSound.text,
		"TextPitch" : TextPitch.value,
		"ShowPreviousDialog" : ShowPreviousDialog.button_pressed,
		"ShowResponseOptions" : ShowResponses.button_pressed,
		"DialogColor" : DialogColor.color.to_html(false).hex_to_int(),
		"TitleColor" : TitleColor.color.to_html(false).hex_to_int()
	}
	create_preset_list()
	GlobalDeclarations.save_config()
	for node in get_tree().get_nodes_in_group("Save"):
		if node.node_type == "Dialog Node" && node.visual_preset == PresetOptionButton.get_item_id(PresetOptionButton.selected) && node.lock_visual_preset:
			node.update_visual_options_to_preset()


func _on_preset_option_button_item_selected(index):
	if index == -1:
		return
	set_settings_to_preset(PresetOptionButton.get_item_id(index))
	
func set_settings_to_preset(ID):

	var preset_parameters = GlobalDeclarations.visual_presets[int(ID)]
	PresetTextEdit.text = ""
	current_dialog.hide_npc = preset_parameters.HideNPC
	current_dialog.show_wheel = preset_parameters.ShowDialogWheel
	current_dialog.disable_esc = preset_parameters.DisableEsc
	current_dialog.darken_screen = preset_parameters.DarkenScreen
	current_dialog.render_gradual = preset_parameters.RenderType
	current_dialog.text_sound = preset_parameters.TextSound
	current_dialog.text_pitch = preset_parameters.TextPitch
	current_dialog.show_previous_dialog = preset_parameters.ShowPreviousDialog
	current_dialog.show_response_options = preset_parameters.ShowResponseOptions
	current_dialog.dialog_color = preset_parameters.DialogColor
	current_dialog.title_color = preset_parameters.TitleColor
	current_dialog.visual_preset = ID
	HideNpcCheckbox.button_pressed = current_dialog.hide_npc
	ShowWheelCheckbox.button_pressed = current_dialog.show_wheel
	DisableEscCheckbox.button_pressed = current_dialog.disable_esc
	DarkenScreenCheckbox.button_pressed = current_dialog.darken_screen
	RenderTypeOption.selected = current_dialog.render_gradual
	TextSound.text = current_dialog.text_sound
	TextPitch.value = current_dialog.text_pitch
	ShowPreviousDialog.button_pressed = current_dialog.show_previous_dialog
	ShowResponses.button_pressed = current_dialog.show_response_options
	DialogColor.color = GlobalDeclarations.int_to_color(current_dialog.dialog_color)
	TitleColor.color = GlobalDeclarations.int_to_color(current_dialog.title_color)



func _on_lock_toggled(button_pressed):
	current_dialog.lock_visual_preset = button_pressed
	if button_pressed:
		VisualSettings.mouse_filter = Control.MOUSE_FILTER_STOP
		VisualSettings.modulate = Color(.5,.5,.5)
		
	else:
		VisualSettings.mouse_filter = Control.MOUSE_FILTER_IGNORE
		VisualSettings.modulate = Color(1,1,1)



