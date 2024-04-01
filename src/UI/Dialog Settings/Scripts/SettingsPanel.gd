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
@export var dialog_general_settings_tab_path : NodePath
@export var dialog_availability_tab_path : NodePath
@export var dialog_mail_tab_path : NodePath
@export var dialog_spacing_tab_path : NodePath
@export var dialog_images_tab_path : NodePath
@export var category_panel_path : NodePath
@export var toggle_visiblity_path: NodePath
@export var dialog_editor_path: NodePath
@export var mail_data_path : NodePath



@onready var DialogSettingsTab := get_node(dialog_settings_tab_path)
@onready var DialogGeneralSettings := get_node(dialog_general_settings_tab_path)
@onready var DialogAvailabilityTab : Control = get_node(dialog_availability_tab_path)
@onready var DialogMailTab : Control = get_node(dialog_mail_tab_path)
@onready var DialogSpacingTab : Control = get_node(dialog_spacing_tab_path)
@onready var DialogImagesTab : Control = get_node(dialog_images_tab_path)
@onready var CategoryPanel := get_node(category_panel_path)
@onready var ToggleVisibility := get_node(toggle_visiblity_path)
@onready var DialogEditor : GraphEdit = get_node(dialog_editor_path)
@onready var MailData := get_node(mail_data_path)





var current_dialog : dialog_node

var current_image : Dictionary

func _ready(): 
	set_quest_dict()
	
	
	update_customnpcs_plus_enabled()
	




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


#func dialog_selected(dialog):
	#if !dialog_availability_mode:
		#load_dialog_settings(dialog)
		
		
		


	
	
	


		

func find_dialog_node_from_id(id : int):
	var dialog_nodes = get_tree().get_nodes_in_group("Save")
	for dialog in dialog_nodes:
		if dialog.dialog_id == id:
			return dialog
			


	
	
	



		
func load_dialog_settings(dialog : dialog_node):
	DialogSettingsTab.visible = true
	await get_tree().create_timer(.01).timeout
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
	
	
	
	
	
	MailData.load_mail_data(current_dialog.mail)
	
	
	
	
		









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



	








func _on_editor_settings_custom_npcs_plus_changed():
	update_customnpcs_plus_enabled()
	
func update_customnpcs_plus_enabled():
	$DialogNodeTabs.set_tab_hidden(3,!GlobalDeclarations.enable_customnpcs_plus_options)
	$DialogNodeTabs.set_tab_hidden(4,!GlobalDeclarations.enable_customnpcs_plus_options)
	
	
