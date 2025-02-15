extends ConfirmationDialog
signal auth_data_entered

@export var password_line_edit_path : NodePath
@export var key_file_grid_container : NodePath
@export var key_file_line_edit_path : NodePath
@export var key_file_passphrase_line_edit_path : NodePath
@export var key_file_dialog_opener : NodePath
@export var private_key_toggle_path : NodePath

@onready var KeyfileGrid : GridContainer = get_node(key_file_grid_container)
@onready var PasswordLineEdit : LineEdit = get_node(password_line_edit_path)
@onready var KeyLineEdit : LineEdit = get_node(key_file_line_edit_path)
@onready var KeyPassphrase : LineEdit = get_node(key_file_passphrase_line_edit_path)
@onready var KeyFileDialogOpener : Button = get_node(key_file_dialog_opener)
@onready var PrivateKeyToggle : CheckBox = get_node(private_key_toggle_path)

var username : String
var hostname : String
var port : int
var password
var private_key_enabled
var private_key_file
var key_passphrase

func set_password(text):
	PasswordLineEdit.text = text
	password = text
	
func set_private_key_enabled(value):
	private_key_enabled = value
	PrivateKeyToggle.button_pressed = value
	if private_key_enabled:
		KeyfileGrid.modulate = Color(1,1,1)
	else:
		KeyfileGrid.modulate = Color(.5,.5,.5)
	KeyLineEdit.editable = private_key_enabled
	KeyPassphrase.editable = private_key_enabled
	KeyFileDialogOpener.disabled = !private_key_enabled
	
func set_private_key_file(file):
	private_key_file = file
	KeyLineEdit.text = file
	
func set_key_passphrase(key_phrase):
	KeyPassphrase.text = key_phrase
	key_passphrase = key_phrase

# Called when the node enters the scene tree for the first time.
func _ready():
	KeyfileGrid.modulate = Color(.5,.5,.5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_private_key_toggle_toggled(button_pressed):
	set_private_key_enabled(button_pressed)
	


func _on_passphrase_linedit_text_submitted(new_text):
	key_passphrase = new_text
	



func _on_path_to_key_line_edit_text_submitted(new_text):
	private_key_file = new_text
	



func _on_line_edit_text_submitted(new_text):
	password = new_text


func _on_file_dialog_opener_pressed():
	var key_file_dialog = FileDialog.new()
	key_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	key_file_dialog.title = "Select Private Key File"
	key_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	var ssh_dir
	if OS.has_feature("windows"):
		ssh_dir = OS.get_environment("USERPROFILE")+"/.ssh"
	else:
		ssh_dir = OS.get_environment("HOME")+"/.ssh"
	key_file_dialog.current_dir = ssh_dir
	key_file_dialog.connect("file_selected",Callable(self,"set_private_key_file"))
	key_file_dialog.min_size = Vector2(DisplayServer.window_get_size())/2
	key_file_dialog.popup_centered()
	get_parent().add_child(key_file_dialog)
	key_file_dialog.popup_centered()
	
func get_auth_data():
	var auth_data := {"username":username,
	"hostname":hostname,
	"port":port	
	}
	if password != "":
		auth_data["password"] = password
	if private_key_enabled:
		if private_key_file != "":
			auth_data["private_key"] = private_key_file
		if key_passphrase != "":
			auth_data["private_key_passphrase"] = key_passphrase
	return auth_data
