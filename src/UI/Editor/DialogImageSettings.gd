extends Control

@export_group("Images")
@export var image_id_list_path : NodePath
@export var image_add_button_path : NodePath
@export var image_remove_button_path : NodePath

@export var image_id_path : NodePath
@export var image_texture_path : NodePath
@export var image_position_x_path : NodePath
@export var image_position_y_path : NodePath
@export var image_width_path : NodePath
@export var image_height_path : NodePath
@export var image_offset_x_path : NodePath
@export var image_offset_y_path : NodePath
@export var image_scale_path : NodePath
@export var image_alpha_path : NodePath
@export var image_rotation_path : NodePath
@export var image_color_path : NodePath
@export var image_selected_color_path : NodePath
@export var image_type_path : NodePath
@export var image_alignment_path : NodePath
@export var image_settings_container_path : NodePath
@export var image_alignment_container_path : NodePath
@export var selected_color_container_path : NodePath
@export var information_panel_path : NodePath

@onready var InformationPanel : Panel = get_node(information_panel_path)
@onready var ImageList : ItemList = get_node(image_id_list_path)
@onready var ImageAddButton : Button = get_node(image_add_button_path)
@onready var ImageRemoveButton : Button = get_node(image_remove_button_path)
@onready var ImageId : SpinBox = get_node(image_id_path)
@onready var ImageTextureString : TextEdit = get_node(image_texture_path)
@onready var ImagePositionX : SpinBox = get_node(image_position_x_path)
@onready var ImagePositionY : SpinBox = get_node(image_position_y_path)
@onready var ImageWidth : SpinBox = get_node(image_width_path)
@onready var ImageHeight : SpinBox = get_node(image_height_path)
@onready var ImageOffsetX : SpinBox = get_node(image_offset_x_path)
@onready var ImageOffsetY : SpinBox = get_node(image_offset_y_path)
@onready var ImageScale : SpinBox = get_node(image_scale_path)
@onready var ImageAlpha : SpinBox = get_node(image_alpha_path)
@onready var ImageRotation : SpinBox = get_node(image_rotation_path)
@onready var ImageColor : ColorPickerButton = get_node(image_color_path)
@onready var ImageSelectedColor : ColorPickerButton = get_node(image_selected_color_path)
@onready var ImageType : OptionButton = get_node(image_type_path)
@onready var ImageAlignment : ItemList = get_node(image_alignment_path)
@onready var ImageSettingsContainer : VBoxContainer = get_node(image_settings_container_path)

@onready var AlignmentContainer : HBoxContainer = get_node(image_alignment_container_path)
@onready var SelectedColorContainer : HBoxContainer = get_node(selected_color_container_path)
# Called when the node enters the scene tree for the first time.

var current_dialog : dialog_node
var current_image : Dictionary

func _ready():
	ImageHeight.update_on_text_changed = true
	ImageWidth.update_on_text_changed = true
	ImageId.update_on_text_changed = true
	ImageOffsetX.update_on_text_changed = true
	ImageOffsetY.update_on_text_changed = true
	ImagePositionX.update_on_text_changed = true
	ImagePositionY.update_on_text_changed = true
	ImageRotation.update_on_text_changed = true
	ImageScale.update_on_text_changed = true
	ImageAlpha.update_on_text_changed = true

func load_current_dialog_settings(dialog : dialog_node):
	current_dialog = dialog
	ImageSettingsContainer.visible = false
	ImageList.clear()
	for image in current_dialog.image_dictionary.keys():
		ImageList.add_item(str(image))
	sort_image_list()
	
	AlignmentContainer.visible = ImageType.selected == 0
	SelectedColorContainer.visible = ImageType.selected == 2
	if current_dialog.last_viewed_image != -1:
		ImageList.select(current_dialog.image_dictionary.keys().find(current_dialog.last_viewed_image))
		_on_item_list_item_selected(current_dialog.image_dictionary.keys().find(current_dialog.last_viewed_image))
	else:
		ImageSettingsContainer.visible = false

func _on_add_image_pressed():
	var new_id = current_dialog.add_image_to_dictionary()
	if new_id != null:
		ImageList.add_item(str(new_id))
	if ImageList.is_anything_selected():
		sort_image_list(ImageList.get_selected_items()[0])
	else:
		sort_image_list()
	InformationPanel.emit_signal("unsaved_change")
	

func _on_remove_image_pressed():
	if !ImageList.get_selected_items().is_empty():
		current_dialog.remove_image_from_dictionary(int(ImageList.get_item_text(ImageList.get_selected_items()[0])))
		ImageList.remove_item(ImageList.get_selected_items()[0])
		InformationPanel.emit_signal("unsaved_change")
	

func sort_image_list(selected_id : int = -1):
	ImageList.clear()
	var image_id_array = current_dialog.image_dictionary.keys()
	image_id_array.sort()
	for id in image_id_array:
		ImageList.add_item(str(id))
	if selected_id != -1:
		ImageList.select(image_id_array.find(selected_id))
	

var selecting_new_image := false


func _on_item_list_item_selected(index):
	selecting_new_image = true
	await get_tree().create_timer(.01).timeout
	ImageSettingsContainer.visible = true
	ImageScale.get_line_edit().release_focus()
	var image_id = int(ImageList.get_item_text(index))
	current_image = current_dialog.image_dictionary[image_id]
	ImageId.value = image_id
	ImageTextureString.text = current_image.Texture
	ImagePositionX.value = current_image.PosX
	ImagePositionY.value = current_image.PosY
	ImageWidth.value = current_image.Width
	ImageHeight.value = current_image.Height
	ImageOffsetX.value = current_image.TextureX
	ImageOffsetY.value = current_image.TextureY
	ImageScale.value = current_image.Scale
	ImageAlpha.value = current_image.Alpha
	ImageRotation.value = current_image.Rotation
	ImageColor.color = GlobalDeclarations.int_to_color(current_image.Color)
	ImageSelectedColor.color = GlobalDeclarations.int_to_color(current_image.SelectedColor)
	ImageType.select(current_image.ImageType)
	ImageAlignment.select(current_image.Alignment)
	current_dialog.last_viewed_image = image_id
	selecting_new_image = false
	

	




func _on_id_value_value_changed(value):
	if selecting_new_image:
		return
	var old_value = int(ImageList.get_item_text(ImageList.get_selected_items()[0]))
	if current_dialog.image_dictionary.keys().has(int(value)):
		ImageId.value = old_value
		return
	ImageList.set_item_text(ImageList.get_selected_items()[0],str(value))
	
	current_dialog.image_dictionary[int(value)] = current_dialog.image_dictionary[old_value]
	current_dialog.image_dictionary.erase(old_value)
	sort_image_list(value)
	InformationPanel.emit_signal("unsaved_change")
	


func _on_line_edit_text_changed():
	if selecting_new_image : return
	current_image.Texture = ImageTextureString.text
	InformationPanel.emit_signal("unsaved_change")


func _on_image_position_x_value_changed(value):
	if selecting_new_image : return
	current_image.PosX = value
	InformationPanel.emit_signal("unsaved_change")



func _on_image_position_y_value_changed(value):
	if selecting_new_image : return
	current_image.PosY = value
	InformationPanel.emit_signal("unsaved_change")



func _on_width_value_changed(value):
	if selecting_new_image : return
	current_image.Width = value
	InformationPanel.emit_signal("unsaved_change")



func _on_height_value_changed(value):
	if selecting_new_image : return
	current_image.Height = value
	InformationPanel.emit_signal("unsaved_change")



func _on_offset_x_value_changed(value):
	if selecting_new_image : return
	current_image.TextureX = value
	InformationPanel.emit_signal("unsaved_change")



func _on_offset_y_value_changed(value):
	if selecting_new_image : return
	current_image.TextureY = value
	InformationPanel.emit_signal("unsaved_change")



func _on_scale_value_value_changed(value):
	if selecting_new_image : return
	current_image.Scale = value
	InformationPanel.emit_signal("unsaved_change")



func _on_alpha_value_value_changed(value):
	if selecting_new_image : return
	current_image.Alpha = value
	InformationPanel.emit_signal("unsaved_change")



func _on_rotation_value_value_changed(value):
	if selecting_new_image : return
	current_image.Rotation = value
	InformationPanel.emit_signal("unsaved_change")	




func _on_image_color_color_changed(color):
	if selecting_new_image : return
	current_image.Color = color.to_html(false).hex_to_int() 
	InformationPanel.emit_signal("unsaved_change")



func _on_selected_color_color_changed(color):
	if selecting_new_image : return
	current_image.SelectedColor = color.to_html(false).hex_to_int() 
	InformationPanel.emit_signal("unsaved_change")

func _on_type_button_item_selected(index):
	if selecting_new_image : return
	current_image.ImageType = index
	AlignmentContainer.visible = index == 0
	SelectedColorContainer.visible = index == 2
	InformationPanel.emit_signal("unsaved_change")



func _on_alignment_item_selected(index):
	if selecting_new_image : return
	current_image.Alignment = index
	InformationPanel.emit_signal("unsaved_change")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
