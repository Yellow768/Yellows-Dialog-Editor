extends Panel

signal hide_information_panel
signal show_information_panel
signal unsaved_change
signal scanned_quests_and_factions

@export var dialog_settings_tab_path: NodePath
@export var dialog_general_tab_path : NodePath
@export var dialog_availability_tab_path : NodePath
@export var dialog_mail_tab_path : NodePath
@export var dialog_spacing_tab_path : NodePath
@export var dialog_images_tab_path : NodePath
@export var category_panel_path : NodePath
@export var toggle_visiblity_path: NodePath
@export var dialog_editor_path: NodePath
@export var mail_data_path : NodePath
@export var response_settings_tab : TabContainer



@onready var DialogSettingsTab := get_node(dialog_settings_tab_path)
@onready var DialogGeneralTab := get_node(dialog_general_tab_path)
@onready var DialogAvailabilityTab : Control = get_node(dialog_availability_tab_path)
@onready var DialogMailTab : Control = get_node(dialog_mail_tab_path)
@onready var DialogSpacingTab : Control = get_node(dialog_spacing_tab_path)
@onready var DialogImagesTab : Control = get_node(dialog_images_tab_path)
@onready var CategoryPanel := get_node(category_panel_path)
@onready var ToggleVisibility := get_node(toggle_visiblity_path)
@onready var DialogEditor : GraphEdit = get_node(dialog_editor_path)
@onready var MailData := get_node(mail_data_path)


var current_dialog : dialog_node



func _ready(): 
	set_quest_dict()
	update_customnpcs_plus_enabled()
	DialogSpacingTab.create_preset_list()

func scan_quest_and_faction_data():
	if CurrentEnvironment.sftp_client:
		if CurrentEnvironment.sftp_client.ListDirectory(CurrentEnvironment.sftp_directory+"/quests").size() > 0:
			var Progress = load("res://src/UI/Util/EditorProgressBar.tscn").instantiate()
			get_parent().get_parent().add_child(Progress)
			Progress.set_overall_task_name("Downloading Quests")
			CurrentEnvironment.sftp_client.connect("ProgressMaxChanged",Callable(Progress,"set_max_progress"))
			CurrentEnvironment.sftp_client.connect("ProgressItemChanged",Callable(Progress,"set_current_item_text"))
			CurrentEnvironment.sftp_client.connect("Progress",Callable(Progress,"set_progress"))
			CurrentEnvironment.sftp_client.DownloadDirectory(CurrentEnvironment.sftp_directory+"/quests",CurrentEnvironment.current_directory+"/quests",false,true)
			await CurrentEnvironment.sftp_client.ProgressDone
			if CurrentEnvironment.sftp_client.Exists(CurrentEnvironment.sftp_directory+"/factions.dat"):
				Progress.set_overall_task_name("Downloading Factions")
				CurrentEnvironment.sftp_client.DownloadFile(CurrentEnvironment.sftp_directory+"/factions.dat",CurrentEnvironment.current_directory)
				await CurrentEnvironment.sftp_client.ProgressDone
			Progress.queue_free()
	
	set_quest_dict()
	CurrentEnvironment.load_faction_data()
	emit_signal("scanned_quests_and_factions")

func set_quest_dict():
	var access_to_quests = get_tree().get_nodes_in_group("quest_access")
	for node in access_to_quests:
		node.quest_dict = quest_indexer.new().index_quest_categories()

func disconnect_current_dialog(dialog : dialog_node,_bool : bool,_ignore : bool):
	if current_dialog == dialog:
		DialogGeneralTab.disconnect_current_dialog(dialog)
		dialog.disconnect("request_deletion", Callable(self, "disconnect_current_dialog"))
	current_dialog = null


func dialog_selected(dialog):
	if DialogAvailabilityTab.dialog_availability_mode:
		load_dialog_settings(dialog)



func load_dialog_settings(dialog : dialog_node):
	DialogSettingsTab.visible = true
	await get_tree().create_timer(.01).timeout
	if !is_instance_valid(dialog) || dialog == null:
		return
	DialogGeneralTab.load_current_dialog_settings(dialog)
	DialogAvailabilityTab.load_current_dialog_settings(dialog)
	DialogMailTab.load_current_dialog_settings(dialog)
	DialogSpacingTab.load_current_dialog_settings(dialog)
	DialogImagesTab.load_current_dialog_settings(dialog)
	if current_dialog != dialog:
		if current_dialog != null && is_instance_valid(current_dialog) && current_dialog.is_connected("request_deletion", Callable(self, "disconnect_current_dialog")):
			current_dialog.disconnect("request_deletion", Callable(self, "disconnect_current_dialog"))
		current_dialog = dialog
		if !current_dialog.is_connected("request_deletion", Callable(self, "disconnect_current_dialog")):
			current_dialog.connect("request_deletion", Callable(self, "disconnect_current_dialog"))
func no_dialog_selected():
	DialogSettingsTab.visible = false

func set_panel_visible(value : bool):
	if value:
		emit_signal("show_information_panel")
		ToggleVisibility.text = ">"
	else:
		emit_signal("hide_information_panel")
		ToggleVisibility.text = "<"

func _on_ToggleVisiblity_toggled(button_pressed : bool):
	set_panel_visible(button_pressed)


func _on_DialogEditor_finished_loading(_category_name : String):
	pass
	#emit_signal("ready_to_set_availability")

func _on_editor_settings_custom_npcs_plus_changed():
	update_customnpcs_plus_enabled()
	
func update_customnpcs_plus_enabled():
	$DialogNodeTabs.set_tab_hidden(3,!GlobalDeclarations.enable_customnpcs_plus_options)
	$DialogNodeTabs.set_tab_hidden(4,!GlobalDeclarations.enable_customnpcs_plus_options)
	


func _on_dialog_editor_response_selected(_node):
	if current_dialog:
		disconnect_current_dialog(current_dialog,false,false)
	$DialogNodeTabs.visible = false


func _on_category_panel_request_clear_editor():
	DialogSettingsTab.visible = false
	response_settings_tab.visible = false


func _on_sftp_box_resync_cache():
	pass # Replace with function body.
