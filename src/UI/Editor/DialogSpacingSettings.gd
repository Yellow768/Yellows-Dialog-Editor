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

var current_dialog

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
	
	
func _on_title_position_option_item_selected(index):
	current_dialog.title_pos = index
	emit_signal("unsaved_change")


func _on_alignment_button_item_selected(index):
	current_dialog.alignment = index
	emit_signal("unsaved_change")


func _on_width_value_value_changed(value):
	current_dialog.text_width = value
	emit_signal("unsaved_change")
	

func _on_height_value_value_changed(value):
	current_dialog.text_height = value
	emit_signal("unsaved_change")
	
	

func _on_text_x_offset_value_changed(value):
	current_dialog.text_offset_x = value
	emit_signal("unsaved_change")




func _on_text_y_offset_value_changed(value):
	current_dialog.text_offset_y = value
	emit_signal("unsaved_change")


func _on_title_x_offset_value_changed(value):
	current_dialog.title_offset_x = value
	emit_signal("unsaved_change")


func _on_title_y_offset_value_changed(value):
	current_dialog.title_offset_y = value
	emit_signal("unsaved_change")
	



func _on_option_x_offset_value_changed(value):
	current_dialog.option_offset_x = value
	emit_signal("unsaved_change")
	



func _on_option_y_offset_value_changed(value):
	current_dialog.option_offset_y = value
	emit_signal("unsaved_change")



func _on_option_spacing_x_offset_value_changed(value):
	current_dialog.option_spacing_x = value
	emit_signal("unsaved_change")
	



func _on_option_spacing_y_offset_value_changed(value):
	current_dialog.option_spacing_y = value
	emit_signal("unsaved_change")
	



func _on_npcx_offset_value_changed(value):
	current_dialog.npc_offset_x = value
	emit_signal("unsaved_change")




func _on_npcy_offset_value_changed(value):
	current_dialog.npc_offset_y = value
	emit_signal("unsaved_change")
	



func _on_npc_scale_value_value_changed(value):
	current_dialog.npc_scale = value
	emit_signal("unsaved_change")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
