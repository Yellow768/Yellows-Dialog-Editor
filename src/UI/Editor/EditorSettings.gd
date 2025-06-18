extends PanelContainer

signal snap_enabled_changed
signal autosave_time_changed
signal custom_npcs_plus_changed
signal language_changed

@onready var keybind_scene = load("res://src/UI/Editor/keybind.tscn")


@export var hide_connection_slider_path : NodePath
@export var hold_shift_check_path : NodePath
@export var auto_save_path : NodePath
@export var enable_grid_check_path : NodePath
@export var autosave_max_files_path : NodePath
@export var allow_more_than_six_path : NodePath
@export var keybinds_scroll_path : NodePath
@export var default_directory_label_path : NodePath
@export var default_directory_file_dialog_path : NodePath
@export var language_option_path : NodePath
@export var cnpc_plus_check_path : NodePath
@export var default_visual_preset_path : NodePath
@export var default_spacing_preset_path : NodePath
@export var dialog_name_preset_path : NodePath
@export var delete_clears_text_path : NodePath

@onready var HideConnectionSlider : HSlider= get_node(hide_connection_slider_path)
@onready var HoldShiftCheck :Button= get_node(hold_shift_check_path)
@onready var AutoSave = get_node(auto_save_path)
@onready var EnableGridCheck : CheckButton = get_node(enable_grid_check_path)
@onready var AutoSaveMaxFiles : SpinBox = get_node(autosave_max_files_path)
@onready var AllowMoreThanSix : CheckButton = get_node(allow_more_than_six_path)
@onready var KeybindsScroll : VBoxContainer = get_node(keybinds_scroll_path)
@onready var DefaultDirectoryLabel : Label = get_node(default_directory_label_path)
@onready var DefaultDirectoryFileDialog : FileDialog = get_node(default_directory_file_dialog_path)
@onready var LanguageOption : OptionButton = get_node(language_option_path)
@onready var CNPCPlusCheck : CheckButton = get_node(cnpc_plus_check_path)
@onready var DefaultVisualPreset : OptionButton = get_node(default_visual_preset_path)
@onready var DefaultSpacingPreset : OptionButton = get_node(default_spacing_preset_path)
@onready var DefaultDialogNamePreset : TextEdit = get_node(dialog_name_preset_path)
@onready var DeleteClearsText : CheckButton = get_node(delete_clears_text_path)

func _ready():
	HideConnectionSlider.value = GlobalDeclarations.hide_connection_distance
	HoldShiftCheck.button_pressed = GlobalDeclarations.hold_shift_for_individual_movement
	AutoSave.value = GlobalDeclarations.autosave_time
	EnableGridCheck.button_pressed = GlobalDeclarations.snap_enabled
	AutoSaveMaxFiles.value = GlobalDeclarations.autosave_max_files
	AllowMoreThanSix.button_pressed = GlobalDeclarations.allow_above_six_responses
	DeleteClearsText.button_pressed = GlobalDeclarations.del_clears_text
	DefaultDirectoryLabel.text = GlobalDeclarations.default_user_directory
	DefaultDirectoryFileDialog.current_dir = GlobalDeclarations.default_user_directory
	CNPCPlusCheck.button_pressed = GlobalDeclarations.enable_customnpcs_plus_options
	$"Preferences/Default Spacing Preset".visible = GlobalDeclarations.enable_customnpcs_plus_options
	DefaultDialogNamePreset.text = GlobalDeclarations.dialog_name_preset
	var color_highlighter = CodeHighlighter.new()
	color_highlighter.symbol_color = Color(1,1,1)
	color_highlighter.number_color = Color(1,1,1)
	color_highlighter.function_color = Color(1,1,1)
	color_highlighter.add_color_region("$"," ",Color(0, 1, 0),false)
	DefaultDialogNamePreset.syntax_highlighter = color_highlighter
	for action in GlobalDeclarations.actions:
		var keybind_instance = keybind_scene.instantiate()
		keybind_instance.assign_action(action)
		KeybindsScroll.add_child(keybind_instance)
		connect("language_changed",Callable(keybind_instance,"update_translation"))
	for lang in TranslationServer.get_loaded_locales():
		LanguageOption.add_item(language_names_in_their_language[TranslationServer.get_language_name(lang)])
	LanguageOption.selected = TranslationServer.get_loaded_locales().find(GlobalDeclarations.language)
	DefaultVisualPreset.add_item("Default",0)
	DefaultSpacingPreset.add_item("Default",0)
	for preset in GlobalDeclarations.visual_presets.keys():
		DefaultVisualPreset.add_item(GlobalDeclarations.visual_presets[preset].Name,preset)
	for preset in GlobalDeclarations.spacing_presets.keys():
		DefaultSpacingPreset.add_item(GlobalDeclarations.spacing_presets[preset].Name,preset)
	if GlobalDeclarations.visual_presets.has(GlobalDeclarations.default_visual_preset):
		DefaultVisualPreset.select(DefaultVisualPreset.get_item_index(GlobalDeclarations.default_visual_preset))
	if GlobalDeclarations.spacing_presets.has(GlobalDeclarations.default_spacing_preset):
		DefaultSpacingPreset.select(DefaultSpacingPreset.get_item_index(GlobalDeclarations.default_spacing_preset))
	

var language_names_in_their_language = {
	"English" : "English",
	"Spanish" : "Español",
	"Danish" : "Dansk",
	"Dutch" : "Nederlands",
	"French" : "Français",
	"German" : "Deutsch",
	"Chinese" : "中文",
	"Swedish" : "Svenska",
	"Russian" : "Русский",
	"Japanese" : "日本語",
	"Korean" : "한국말"
}
	
	
	
func _on_h_slider_value_changed(value : int):
	HideConnectionSlider.get_node("ValueEdit").text = str(value)
	GlobalDeclarations.hide_connection_distance = value


func _on_value_edit_text_submitted(new_text : String):
	HideConnectionSlider.value = int(new_text)
	


func _on_resetbutton_pressed():
	HideConnectionSlider.value = 1000


func _on_button_pressed():
	get_tree().paused = false
	GlobalDeclarations.save_config()
	visible = false
	


func _on_editor_settings_button_pressed():
	visible = true
	DefaultVisualPreset.clear()
	DefaultSpacingPreset.clear()
	for preset in GlobalDeclarations.visual_presets.keys():
		DefaultVisualPreset.add_item(GlobalDeclarations.visual_presets[preset].Name,preset)
	for preset in GlobalDeclarations.spacing_presets.keys():
		DefaultSpacingPreset.add_item(GlobalDeclarations.spacing_presets[preset].Name,preset)
	if GlobalDeclarations.visual_presets.has(GlobalDeclarations.default_visual_preset):
		DefaultVisualPreset.select(DefaultVisualPreset.get_item_index(GlobalDeclarations.default_visual_preset))
	if GlobalDeclarations.spacing_presets.has(GlobalDeclarations.default_spacing_preset):
		DefaultSpacingPreset.select(DefaultSpacingPreset.get_item_index(GlobalDeclarations.default_spacing_preset))
	get_tree().paused = true


func _on_check_button_toggled(button_pressed):
	GlobalDeclarations.hold_shift_for_individual_movement = button_pressed


func _on_undo_button_toggled(button_pressed):
	GlobalDeclarations.snap_enabled = button_pressed
	emit_signal("snap_enabled_changed",button_pressed)


func _on_autosave_value_edit_text_changed(new_text):
	AutoSave.value = int(new_text)


func _on_autosave_resetbutton_pressed():
	AutoSave.value = 3


func _on_autosave_h_slider_changed(value):
	GlobalDeclarations.autosave_time = value
	autosave_time_changed.emit()
	AutoSave.get_node("ValueEdit").text = str(GlobalDeclarations.autosave_time)


func _on_autosave_max_files_value_changed(value):
	GlobalDeclarations.autosave_max_files = value


func _on_allow_six_check_button_toggled(button_pressed):
	GlobalDeclarations.allow_above_six_responses = button_pressed


func _on_change_directorybutton_button_up():
	DefaultDirectoryFileDialog.current_dir = GlobalDeclarations.default_user_directory
	DefaultDirectoryFileDialog.popup_centered()


func _on_file_dialog_dir_selected(dir):
	GlobalDeclarations.default_user_directory = dir
	DefaultDirectoryLabel.text = "Default Directory: "+GlobalDeclarations.default_user_directory

func _on_file_dialog_canceled():
	DefaultDirectoryFileDialog.visible = false


func _on_language_option_item_selected(index):
	
	TranslationServer.set_locale(TranslationServer.get_loaded_locales()[index])
	GlobalDeclarations.language = TranslationServer.get_locale()
	
	emit_signal("language_changed")


func _on_cnpc_check_toggled(button_pressed):
	GlobalDeclarations.enable_customnpcs_plus_options = button_pressed
	$"Preferences/Default Spacing Preset".visible = button_pressed
	emit_signal("custom_npcs_plus_changed")


func _on_visual_preset_button_item_selected(index):
	GlobalDeclarations.default_visual_preset = DefaultVisualPreset.get_item_id(index)


func _on_spacing_preset_button_item_selected(index):
	GlobalDeclarations.default_spacing_preset = DefaultSpacingPreset.get_item_id(index)


func _on_file_dialog_visibility_changed():
	DefaultDirectoryFileDialog.set_ok_button_text(tr("FILE_SELECT_FOLDER"))


func _on_tab_bar_tab_changed(tab):
	if tab == 1:
		$KeyBinds.visible = true
		$Preferences.visible = false 
	else:
		$KeyBinds.visible = false
		$Preferences.visible = true
		


func _on_text_edit_text_changed():
	GlobalDeclarations.dialog_name_preset = DefaultDialogNamePreset.text



func _on_del_clears_check_toggled(button_pressed):
	GlobalDeclarations.del_clears_text = button_pressed
