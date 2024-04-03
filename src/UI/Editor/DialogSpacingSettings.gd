extends Control

@export_group("CustomNPCS+ Spacing")
@export var title_position_path : NodePath
@export var alignment_path : NodePath
@export var width_path : NodePath
@export var height_path : NodePath
@export var text_offset_x_path : NodePath
@export var text_offset_y_path : NodePath
@export var title_offset_x_path : NodePath
@export var title_offset_y_path : NodePath
@export var option_offset_x_path : NodePath
@export var option_offset_y_path : NodePath
@export var option_spacing_x_path : NodePath
@export var option_spacing_y_path : NodePath
@export var npc_offset_x_path : NodePath
@export var npc_offset_y_path : NodePath
@export var npc_scale_path : NodePath
@export var information_panel_path : NodePath
@export var preset_text_edit_path : NodePath
@export var preset_option_button_path : NodePath
@export var update_preset_button_path : NodePath

@onready var InformationPanel : Panel = get_node(information_panel_path)
@onready var TitlePosition : OptionButton = get_node(title_position_path)
@onready var Alignment : OptionButton = get_node(alignment_path)
@onready var DialogWidth : SpinBox = get_node(width_path)
@onready var DialogHeight : SpinBox = get_node(height_path)
@onready var TextOffsetX : SpinBox = get_node(text_offset_x_path)
@onready var TextOffsetY : SpinBox = get_node(text_offset_y_path)
@onready var TitleOffsetX : SpinBox = get_node(title_offset_x_path)
@onready var TitleOffsetY : SpinBox = get_node(title_offset_y_path)
@onready var OptionOffsetX : SpinBox = get_node(option_offset_x_path)
@onready var OptionOffsetY : SpinBox = get_node(option_offset_y_path)
@onready var OptionSpacingX : SpinBox = get_node(option_spacing_x_path)
@onready var OptionSpacingY : SpinBox = get_node(option_spacing_y_path)
@onready var NPCOffsetX : SpinBox = get_node(npc_offset_x_path)
@onready var NPCOffsetY : SpinBox = get_node(npc_offset_y_path)
@onready var NPCScale : SpinBox = get_node(npc_scale_path)
@onready var PresetOptionButton : OptionButton = get_node(preset_option_button_path)
@onready var PresetTextEdit : TextEdit = get_node(preset_text_edit_path)
@onready var UpdatePresetButton : Button = get_node(update_preset_button_path)

var current_dialog : dialog_node

func load_current_dialog_settings(dialog : dialog_node):
	current_dialog = dialog
	TitlePosition.selected = current_dialog.title_pos
	Alignment.selected = current_dialog.alignment
	DialogWidth.value = current_dialog.text_width
	DialogHeight.value = current_dialog.text_height
	TextOffsetX.value = current_dialog.text_offset_x
	TextOffsetY.value = current_dialog.text_offset_y
	TitleOffsetX.value = current_dialog.title_offset_x
	TitleOffsetY.value = current_dialog.title_offset_y
	OptionOffsetX.value = current_dialog.option_offset_x
	OptionOffsetY.value = current_dialog.option_offset_y
	OptionSpacingX.value = current_dialog.option_spacing_x
	OptionSpacingY.value = current_dialog.option_spacing_y
	NPCOffsetX.value = current_dialog.npc_offset_x
	NPCOffsetY.value = current_dialog.npc_offset_y
	NPCScale.value = current_dialog.npc_scale
	if current_dialog.spacing_preset != -1 && GlobalDeclarations.spacing_presets.has(current_dialog.spacing_preset):
		PresetOptionButton.select(PresetOptionButton.get_item_index(current_dialog.spacing_preset))
		set_settings_to_preset(current_dialog.spacing_preset)
	else:
		PresetOptionButton.select(-1)
		current_dialog.spacing_preset = -1
	
func _on_title_position_option_item_selected(index):
	current_dialog.title_pos = index
	InformationPanel.emit_signal("unsaved_change")


func _on_alignment_button_item_selected(index):
	current_dialog.alignment = index
	InformationPanel.emit_signal("unsaved_change")


func _on_width_value_value_changed(value):
	current_dialog.text_width = value
	InformationPanel.emit_signal("unsaved_change")
	

func _on_height_value_value_changed(value):
	current_dialog.text_height = value
	InformationPanel.emit_signal("unsaved_change")
	
	

func _on_text_x_offset_value_changed(value):
	current_dialog.text_offset_x = value
	InformationPanel.emit_signal("unsaved_change")




func _on_text_y_offset_value_changed(value):
	current_dialog.text_offset_y = value
	InformationPanel.emit_signal("unsaved_change")


func _on_title_x_offset_value_changed(value):
	current_dialog.title_offset_x = value
	InformationPanel.emit_signal("unsaved_change")


func _on_title_y_offset_value_changed(value):
	current_dialog.title_offset_y = value
	InformationPanel.emit_signal("unsaved_change")
	



func _on_option_x_offset_value_changed(value):
	current_dialog.option_offset_x = value
	InformationPanel.emit_signal("unsaved_change")
	



func _on_option_y_offset_value_changed(value):
	current_dialog.option_offset_y = value
	InformationPanel.emit_signal("unsaved_change")



func _on_option_spacing_x_offset_value_changed(value):
	current_dialog.option_spacing_x = value
	InformationPanel.emit_signal("unsaved_change")
	



func _on_option_spacing_y_offset_value_changed(value):
	current_dialog.option_spacing_y = value
	InformationPanel.emit_signal("unsaved_change")
	



func _on_npcx_offset_value_changed(value):
	current_dialog.npc_offset_x = value
	InformationPanel.emit_signal("unsaved_change")




func _on_npcy_offset_value_changed(value):
	current_dialog.npc_offset_y = value
	InformationPanel.emit_signal("unsaved_change")
	



func _on_npc_scale_value_value_changed(value):
	current_dialog.npc_scale = value
	InformationPanel.emit_signal("unsaved_change")
# Called when the node enters the scene tree for the first time.


func create_preset_list():
	PresetOptionButton.clear()
	for preset in GlobalDeclarations.spacing_presets.keys():
		PresetOptionButton.add_item(GlobalDeclarations.spacing_presets[preset].Name,int(preset))
	if current_dialog:
		PresetOptionButton.select(current_dialog.spacing_preset)

func _on_add_preset_button_pressed():
	if PresetTextEdit.text != "":
		var preset_keys = GlobalDeclarations.spacing_presets.keys()
		preset_keys.sort()
		var ID 
		if preset_keys.size() == 0:
			ID = 0
		else:
			ID = preset_keys.back() + 1
		GlobalDeclarations.spacing_presets[ID] = {
			"Name" : PresetTextEdit.text,
			"TitlePosition" : TitlePosition.selected,
			"Alignment" : Alignment.selected,
			"Width" : DialogWidth.value,
			"Height" : DialogHeight.value,
			"TextOffsetX" : TextOffsetX.value,
			"TextOffsetY" : TextOffsetY.value,
			"TitleOffsetX" : TitleOffsetX.value,
			"TitleOffsetY" : TitleOffsetY.value,
			"OptionOffsetX" : OptionOffsetX.value,
			"OptionOffsetY" : OptionOffsetY.value,
			"OptionSpacingX" : OptionSpacingX.value,
			"OptionSpacingY" : OptionSpacingY.value,
			"NPCOffsetX" : NPCOffsetX.value,
			"NPCOffsetY" : NPCOffsetY.value,
			"NPCScale" : NPCScale.value
		}
		current_dialog.spacing_preset = ID
	create_preset_list()


func _on_remove_preset_button_pressed():
	if PresetOptionButton.selected == -1:
		return
	var confirm_deletion_popup = load("res://src/UI/Util/ConfirmDeletion.tscn").instantiate()
	confirm_deletion_popup.connect("confirmed", Callable(self, "delete_preset"))
	var format_text = "Are you sure you want to delete %s ? Any dialogs that use this preset will revert to having no preset"
	confirm_deletion_popup.dialog_text = format_text % PresetOptionButton.get_item_text(PresetOptionButton.selected)
	$".".add_child(confirm_deletion_popup)
	confirm_deletion_popup.popup_centered()


func delete_preset():
	GlobalDeclarations.spacing_presets.erase(PresetOptionButton.get_item_id(PresetOptionButton.selected))
	current_dialog.spacing_preset = -1
	create_preset_list()

func _on_update_preset_button_pressed():
	if PresetOptionButton.selected == -1:
		return
	var preset_name
	if PresetTextEdit.text == "":
		preset_name = PresetOptionButton.get_item_text(PresetOptionButton.selected)
	else:
		preset_name = PresetTextEdit.text
	GlobalDeclarations.spacing_presets[PresetOptionButton.get_item_id(PresetOptionButton.selected)]={
		"Name" : preset_name,
		"TitlePosition" : TitlePosition.selected,
			"Alignment" : Alignment.selected,
			"Width" : DialogWidth.value,
			"Height" : DialogHeight.value,
			"TextOffsetX" : TextOffsetX.value,
			"TextOffsetY" : TextOffsetY.value,
			"TitleOffsetX" : TitleOffsetX.value,
			"TitleOffsetY" : TitleOffsetY.value,
			"OptionOffsetX" : OptionOffsetX.value,
			"OptionOffsetY" : OptionOffsetY.value,
			"OptionSpacingX" : OptionSpacingX.value,
			"OptionSpacingY" : OptionSpacingY.value,
			"NPCOffsetX" : NPCOffsetX.value,
			"NPCOffsetY" : NPCOffsetY.value,
			"NPCScale" : NPCScale.value
	}
	create_preset_list()


func _on_preset_option_button_item_selected(index):
	if index == -1:
		return
	set_settings_to_preset(PresetOptionButton.get_item_id(index))
	
func set_settings_to_preset(ID):
	var preset_parameters = GlobalDeclarations.spacing_presets[ID]
	PresetTextEdit.text = ""
	current_dialog.title_pos = preset_parameters.TitlePosition
	current_dialog.alignment = preset_parameters.Alignment
	current_dialog.text_width = preset_parameters.Width
	current_dialog.text_height = preset_parameters.Height
	current_dialog.title_offset_x = preset_parameters.TitleOffsetX
	current_dialog.title_offset_y = preset_parameters.TitleOffsetY
	current_dialog.text_offset_x = preset_parameters.TextOffsetX
	current_dialog.text_offset_y = preset_parameters.TextOffsetY
	current_dialog.option_offset_x = preset_parameters.OptionOffsetX
	current_dialog.option_offset_y = preset_parameters.OptionOffsetY
	current_dialog.option_spacing_x = preset_parameters.OptionSpacingX
	current_dialog.option_spacing_y = preset_parameters.OptionSpacingY
	current_dialog.npc_offset_x = preset_parameters.NPCOffsetX
	current_dialog.npc_offset_y = preset_parameters.NPCOffsetY
	current_dialog.npc_scale = preset_parameters.NPCScale
	current_dialog.spacing_preset = ID
	TitlePosition.selected = current_dialog.title_pos
	Alignment.selected = current_dialog.alignment
	DialogWidth.value = current_dialog.text_width
	DialogHeight.value = current_dialog.text_height
	TextOffsetX.value = current_dialog.text_offset_x
	TextOffsetY.value = current_dialog.text_offset_y
	TitleOffsetX.value = current_dialog.title_offset_x
	TitleOffsetY.value = current_dialog.title_offset_y
	OptionOffsetX.value = current_dialog.option_offset_x
	OptionOffsetY.value = current_dialog.option_offset_y
	OptionSpacingX.value = current_dialog.option_spacing_x
	OptionSpacingY.value = current_dialog.option_spacing_y
	NPCOffsetX.value = current_dialog.npc_offset_x
	NPCOffsetY.value = current_dialog.npc_offset_y
	NPCScale.value = current_dialog.npc_scale
