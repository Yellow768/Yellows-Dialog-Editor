extends Panel

signal hide_information_panel
signal show_information_panel

signal request_store_current_category
signal request_switch_to_stored_category
signal availability_mode_entered
signal availability_mode_exited
signal ready_to_set_availability
signal unsaved_change

@export var dialog_settings_tab_path: NodePath
@export var category_panel_path : NodePath
@export var toggle_visiblity_path: NodePath
@export var dialog_editor_path: NodePath
@export var mail_data_path : NodePath

@export_group("General Visual")
@export var hide_npc_checkbox_path: NodePath
@export var show_wheel_checkbox_path: NodePath
@export var disable_esc_checkbox_path: NodePath
@export var darken_screen_checkbox_path : NodePath
@export var render_type_option_path : NodePath
@export var text_sound_path : NodePath
@export var text_pitch_path : NodePath
@export var show_previous_dialog_path : NodePath
@export var show_responses_path : NodePath
@export var color_path : NodePath
@export var title_color_path : NodePath
@export var title_label_path: NodePath

@export_group("General Settings")
@export var command_edit_path: NodePath
@export var playsound_edit_path: NodePath
@export var faction_changes_1_path: NodePath
@export var faction_changes_2_path: NodePath
@export var start_quest_path: NodePath
@export var dialog_text_edit_path: NodePath

@export_group("Availability")
@export var availability_quests_path: NodePath
@export var availability_dialogs_path: NodePath 
@export var availability_factions_path: NodePath 
@export var availability_scoreboard_path: NodePath
@export var availability_time_path: NodePath
@export var availability_level_path: NodePath


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



@onready var DialogSettingsTab := get_node(dialog_settings_tab_path)
@onready var CategoryPanel := get_node(category_panel_path)

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

@onready var AvailabilityQuests := get_node(availability_quests_path)
@onready var AvailabilityDialogs := get_node(availability_dialogs_path)
@onready var AvailabilityFactions := get_node(availability_factions_path)
@onready var AvailabilityScoreboard := get_node(availability_scoreboard_path)
@onready var AvailabilityTime := get_node(availability_time_path)
@onready var AvailabilityLevel := get_node(availability_level_path)

@onready var ToggleVisibility := get_node(toggle_visiblity_path)
@onready var DialogEditor : GraphEdit = get_node(dialog_editor_path)
@onready var MailData := get_node(mail_data_path)

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
@onready var OptionSpacingY : SpinBox = get_node(option_offset_y_path)
@onready var NPCOffsetX : SpinBox = get_node(npc_offset_x_path)
@onready var NPCOffsetY : SpinBox = get_node(npc_offset_y_path)
@onready var NPCScale : SpinBox = get_node(npc_scale_path)

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

var current_dialog : dialog_node
var dialog_availability_mode := false
var exiting_availability_mode := false
var availability_slot : int
var stored_current_dialog_id : int
var glob_node_selected_id : int
var current_image : Dictionary

func _ready(): 
	set_quest_dict()
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

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if dialog_availability_mode:
			exit_dialog_availability_mode()



func set_quest_dict():
	var access_to_quests = get_tree().get_nodes_in_group("quest_access")
	for node in access_to_quests:
		node.quest_dict = quest_indexer.new().index_quest_categories()

func disconnect_current_dialog(dialog : dialog_node,_bool : bool,_ignore : bool):
	if current_dialog == dialog:
		dialog.disconnect("text_changed", Callable(self, "update_text"))
		dialog.disconnect("request_deletion", Callable(self, "disconnect_current_dialog"))
		current_dialog.disconnect("title_changed", Callable(self, "update_title"))
	current_dialog = null


func dialog_selected(dialog):
	if !dialog_availability_mode:
		load_dialog_settings(dialog)
		
		
		
func enter_dialog_availability_mode(availability_scene):
	stored_current_dialog_id = current_dialog.dialog_id
	availability_slot = AvailabilityDialogs.get_children().find(availability_scene)
	dialog_availability_mode = true
	emit_signal("hide_information_panel")
	emit_signal("request_store_current_category")
	emit_signal("availability_mode_entered")
	ToggleVisibility.button_pressed = false
	ToggleVisibility.text = "<"
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
	emit_signal("show_information_panel")

	
	
	

func _on_category_panel_finished_loading(_ignore):
	if exiting_availability_mode:
		var initial_dialog : GraphNode = find_dialog_node_from_id(stored_current_dialog_id)
		emit_signal("availability_mode_exited")
		load_dialog_settings(initial_dialog)
		initial_dialog.dialog_availabilities[availability_slot].dialog_id = glob_node_selected_id
		AvailabilityDialogs.get_child(availability_slot).set_id(glob_node_selected_id)
		initial_dialog.selected = true
		initial_dialog.draggable = false
		
		
		emit_signal("unsaved_change")
		
		print("Availability Mode Exited")			
		dialog_availability_mode = false
		exiting_availability_mode = false
		

func find_dialog_node_from_id(id : int):
	var dialog_nodes = get_tree().get_nodes_in_group("Save")
	for dialog in dialog_nodes:
		if dialog.dialog_id == id:
			return dialog
			


	
	
	

func set_title_text(title_text : String,node_index : int):
	if title_text.length() > 35:
		title_text = title_text.left(35)+"..."
	TitleLabel.text = title_text+"| Node "+str(node_index)

		
func load_dialog_settings(dialog : dialog_node):
	DialogSettingsTab.visible = true
	if current_dialog != dialog:
		if current_dialog != null && is_instance_valid(current_dialog) && current_dialog.is_connected("text_changed", Callable(self, "update_text")):
			current_dialog.disconnect("text_changed", Callable(self, "update_text"))
			current_dialog.disconnect("request_deletion", Callable(self, "disconnect_current_dialog"))
			current_dialog.disconnect("title_changed", Callable(self, "update_title"))
		current_dialog = dialog
		if !current_dialog.is_connected("text_changed", Callable(self, "update_text")):
			current_dialog.connect("text_changed", Callable(self, "update_text"))
			current_dialog.connect("request_deletion", Callable(self, "disconnect_current_dialog"))
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
	
	AvailabilityTime.get_node("Panel/OptionButton").selected = current_dialog.time_availability
	AvailabilityLevel.get_node("Panel/SpinBox").value = current_dialog.min_level_availability
	
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
	MailData.load_mail_data(current_dialog.mail)
	DarkenScreenCheckbox.button_pressed = current_dialog.darken_screen
	RenderTypeOption.selected = current_dialog.render_gradual
	TextSound.text = current_dialog.text_sound
	TextPitch.value = current_dialog.text_pitch
	ShowPreviousDialog.button_pressed = current_dialog.show_previous_dialog
	ShowResponses.button_pressed = current_dialog.show_response_options
	DialogColor.color = current_dialog.dialog_color
	TitleColor.color = current_dialog.title_color
	
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
	ImageSettingsContainer.visible = false
	ImageList.clear()
	for image in current_dialog.image_dictionary.keys():
		ImageList.add_item(str(image))
	sort_image_list()
	
	
		
func scoreboard_objective_name_changed(child ,obj_name : String):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].objective_name = obj_name
	emit_signal("unsaved_change")
func scoreboard_comparison_type_changed(child,type : int):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].comparison_type = type
	emit_signal("unsaved_change")
	
func scoreboard_value_changed(child ,value : int):
	current_dialog.scoreboard_availabilities[AvailabilityScoreboard.get_children().find(child)].value = value
	emit_signal("unsaved_change")		
func faction_id_changed(child ,id : int):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].faction_id = id
	emit_signal("unsaved_change")
func faction_stance_changed(child,stance:int):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].stance_type = stance
	emit_signal("unsaved_change")
func faction_isisnot_changed(child ,isisnot : int):
	current_dialog.faction_availabilities[AvailabilityFactions.get_children().find(child)].availability_operator = isisnot
	emit_signal("unsaved_change")

func dialog_id_changed(child,id : int):
	current_dialog.dialog_availabilities[AvailabilityDialogs.get_children().find(child)].dialog_id = id
	emit_signal("unsaved_change")
	
func dialog_type_changed(child,type : int):
	current_dialog.dialog_availabilities[AvailabilityDialogs.get_children().find(child)].availability_type = type
	emit_signal("unsaved_change")



func quest_id_changed(child,id : int):
	current_dialog.quest_availabilities[AvailabilityQuests.get_children().find(child)].quest_id = id
	emit_signal("unsaved_change")

	
func quest_type_changed(child,type : int):
	current_dialog.quest_availabilities[AvailabilityQuests.get_children().find(child)].availability_type = type
	emit_signal("unsaved_change")
#Dialog Changes

func _on_HideNPC_pressed():
	current_dialog.hide_npc = HideNpcCheckbox.button_pressed
	emit_signal("unsaved_change")
	
func _on_ShowDialogWheel_pressed():
	current_dialog.show_wheel = ShowWheelCheckbox.button_pressed
	emit_signal("unsaved_change")

func _on_DisableEsc_pressed():
	current_dialog.disable_esc = DisableEscCheckbox.button_pressed
	emit_signal("unsaved_change")


func _on_FactionChange_faction_id_changed(id : int):
	current_dialog.faction_changes[0].faction_id = id
	emit_signal("unsaved_change")

func _on_FactionChange2_faction_id_changed(id : int):
	current_dialog.faction_changes[1].faction_id = id
	emit_signal("unsaved_change")

func _on_FactionChange2_faction_points_changed(points : int):
	current_dialog.faction_changes[1].points = points
	emit_signal("unsaved_change")

func _on_FactionChange_faction_points_changed(points : int):
	current_dialog.faction_changes[0].points = points
	emit_signal("unsaved_change")

func _on_Command_text_changed():
	current_dialog.command = CommandEdit.text
	emit_signal("unsaved_change")

func _on_TimeButton_item_selected(index : int):
	current_dialog.time_availability = index
	emit_signal("unsaved_change")

func _on_LevelSpinBox_value_changed(value : int):
	current_dialog.min_level_availability = value
	emit_signal("unsaved_change")



func _on_DialogText_text_changed():
	current_dialog.set_dialog_text(DialogTextEdit.text)
	emit_signal("unsaved_change")

func update_text():
	DialogTextEdit.text = current_dialog.text

func update_title(_text):
	set_title_text(current_dialog.dialog_title,current_dialog.node_index)

func _on_StartQuest_id_changed(value : int):
	current_dialog.start_quest = value
	emit_signal("unsaved_change")


func no_dialog_selected():
	DialogSettingsTab.visible = false


func _on_ToggleVisiblity_toggled(button_pressed : bool):
	if !button_pressed:
		emit_signal("hide_information_panel")
		ToggleVisibility.text = "<"
	else:
		emit_signal("show_information_panel")
		ToggleVisibility.text = ">"


	
	


func _on_DialogEditor_finished_loading(_category_name : String):
	emit_signal("ready_to_set_availability")



func _on_availability_timer_timeout() -> void:
	#fixes a dumb issue where the information panel doesn't update, by just delaying iy
	pass


func _on_soundfile_text_changed():
	current_dialog.sound = PlaysoundEdit.text





func _on_darken_screen_pressed():
	current_dialog.darken_screen = DarkenScreenCheckbox.button_pressed
	emit_signal("unsaved_change")


func _on_render_type_item_selected(index):
	current_dialog.render_gradual = index
	emit_signal("unsaved_change")

func _on_text_sound_text_changed():
	current_dialog.text_sound = TextSound.text
	emit_signal("unsaved_change")

func _on_text_pitch_text_changed():
	current_dialog.text_pitch = TextPitch.text
	emit_signal("unsaved_change")

func _on_show_previous_dialog_toggled(button_pressed):
	current_dialog.show_previous_dialog = button_pressed
	emit_signal("unsaved_change")

func _on_show_response_options_toggled(button_pressed):
	current_dialog.show_response_options = button_pressed
	emit_signal("unsaved_change")

func _on_color_color_changed(color):
	current_dialog.dialog_color = color
	emit_signal("unsaved_change")

func _on_title_color_color_changed(color):
	current_dialog.title_color = color
	emit_signal("unsaved_change")
	



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


func _on_add_image_pressed():
	var new_id = current_dialog.add_image_to_dictionary()
	if new_id != null:
		ImageList.add_item(str(new_id))
	if ImageList.is_anything_selected():
		sort_image_list(ImageList.get_selected_items()[0])
	else:
		sort_image_list()
	
	

func _on_remove_image_pressed():
	if !ImageList.get_selected_items().is_empty():
		current_dialog.remove_image_from_dictionary(int(ImageList.get_item_text(ImageList.get_selected_items()[0])))
		ImageList.remove_item(ImageList.get_selected_items()[0])
	
	

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
	ImageSettingsContainer.visible = true
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
	ImageColor.color = current_image.Color
	ImageSelectedColor.color = current_image.SelectedColor
	ImageType.selected = current_image.ImageType
	ImageAlignment.select(current_image.Alignment)
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
	
	


func _on_line_edit_text_changed():
	if selecting_new_image : return
	current_image.Texture = ImageTextureString.text



func _on_image_position_x_value_changed(value):
	if selecting_new_image : return
	current_image.PosX = value
	



func _on_image_position_y_value_changed(value):
	if selecting_new_image : return
	current_image.PosY = value
	



func _on_width_value_changed(value):
	if selecting_new_image : return
	current_image.Width = value
	



func _on_height_value_changed(value):
	if selecting_new_image : return
	current_image.Height = value
	



func _on_offset_x_value_changed(value):
	if selecting_new_image : return
	current_image.TextureX = value
	



func _on_offset_y_value_changed(value):
	if selecting_new_image : return
	current_image.TextureY = value
	



func _on_scale_value_value_changed(value):
	if selecting_new_image : return
	current_image.Scale = value
	



func _on_alpha_value_value_changed(value):
	if selecting_new_image : return
	current_image.Alpha = value
	



func _on_rotation_value_value_changed(value):
	if selecting_new_image : return
	current_image.Rotation = value
	




func _on_image_color_color_changed(color):
	if selecting_new_image : return
	current_image.Color = color
	



func _on_selected_color_color_changed(color):
	if selecting_new_image : return
	current_image.SelectedColor = color


func _on_type_button_item_selected(index):
	if selecting_new_image : return
	current_image.Type = index
	



func _on_alignment_item_selected(index):
	if selecting_new_image : return
	current_image.Alignment = index
