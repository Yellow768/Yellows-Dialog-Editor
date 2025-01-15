extends PanelContainer
@export var username_textbox_path : NodePath
@export var hostname_textbox_path : NodePath
@export var port_spinbox_path : NodePath
@export var password_textbox_path : NodePath
@export var connect_button_path : NodePath
@export var tree_path : NodePath

@onready var UsernameTextEdit : LineEdit = get_node(username_textbox_path)
@onready var HostnameTextEdit : LineEdit = get_node(hostname_textbox_path)
@onready var PortSpinBox : SpinBox = get_node(port_spinbox_path)
@onready var PasswordTextEdit : LineEdit = get_node(password_textbox_path)
@onready var ConnectButton : Button = get_node(connect_button_path)
@onready var FileTree : Tree = get_node(tree_path)

var tree_root
var SFTP_ClientScript = load("res://src/Classes/File System/SFTP/SFTP_Client.cs")
var sftp_client = SFTP_ClientScript.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	tree_root = FileTree.create_item()
	FileTree.hide_root = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


var files_in_sftp_directory : Dictionary

func _on_button_pressed():
	
	sftp_client.ConnectToSftpServer(UsernameTextEdit.text,HostnameTextEdit.text,PortSpinBox.value,PasswordTextEdit.text)
	files_in_sftp_directory = sftp_client.ListDirectory()
	for file in files_in_sftp_directory:
		var new_file = FileTree.create_item(tree_root)
		new_file.set_text(0,file)
		if files_in_sftp_directory[file]:
			new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/folder-line.svg"))
		else:
			new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/file-line.svg"))
		
		
	


func _on_tree_item_activated():
	if files_in_sftp_directory[FileTree.get_selected().get_text(0)]:
		sftp_client.ChangeDirectory(FileTree.get_selected().get_text(0))
		FileTree.deselect_all()
		var item = tree_root.get_first_child()
		var item_to_delete = tree_root.get_first_child()
		for tree_item in tree_root.get_children():
			tree_item.free()
		files_in_sftp_directory = sftp_client.ListDirectory()
		for file in files_in_sftp_directory:
			var new_file = FileTree.create_item(tree_root)
			new_file.set_text(0,file)
			if files_in_sftp_directory[file]:
				new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/folder-line.svg"))
			else:
				new_file.set_icon(0,load("res://Assets/UI Textures/Icon Font/file-line.svg"))
