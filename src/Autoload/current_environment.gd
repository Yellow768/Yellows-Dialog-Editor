extends Node

var current_directory : set = set_current_directory
var current_dialog_directory
var current_category_name
var highest_id = 0: set = set_highest_id, get = get_highest_id
var loading_stage = false
var allow_save_state
var dialog_name_preset


var sftp_client
var sftp_hostname
var sftp_username
var sftp_port
var sftp_cached_path
var sftp_private_key

var sftp_saved_categories = []
var sftp_directory

var quest_dict
var faction_dict

func create_sftpclient():
	var SFTP_ClientScript = load("res://src/Classes/File System/SFTP/SFTP_Client.cs")
	sftp_client = SFTP_ClientScript.new()

func get_sftpclient():
	return sftp_client

func _ready():
	pass

func load_faction_data():
	var fact_loader := faction_loader.new()
	faction_dict = fact_loader.get_faction_data(current_directory)

func set_highest_id(new_id):
	print("new id "+ str(new_id))
	highest_id = new_id
	var file = FileAccess.open(current_directory+"/dialogs/highest_index.json",FileAccess.WRITE)
	file.store_line(str(new_id))
	file.close()
	if CurrentEnvironment.sftp_client && CurrentEnvironment.sftp_client.IsConnected():
		CurrentEnvironment.sftp_client.UploadFile(current_directory+"/dialogs/highest_index.json",CurrentEnvironment.sftp_client.GetCurrentDirectory()+"/dialogs/highest_index.json")

func get_highest_id():
	if CurrentEnvironment.sftp_client && CurrentEnvironment.sftp_client.IsConnected():
		print(CurrentEnvironment.sftp_client.GetHighestIDFromServer())
		return int(CurrentEnvironment.sftp_client.GetHighestIDFromServer())
	else:
		return highest_id
		

func set_current_directory(new_directory):
	current_directory = new_directory
	current_dialog_directory = new_directory+"/dialogs"
	
func handle_subtracting_dialog_id(dialogs_to_be_deleted : Array[GraphNode]):
	var sorted_ids = dialogs_to_be_deleted.duplicate()
	sorted_ids.sort_custom(Callable(self, "sort_array_by_dialog_id"))
	for node in sorted_ids:
		if node.dialog_id == highest_id:
			highest_id -= 1
			
func sort_array_by_dialog_id(a,b):
	if a.dialog_id != b.dialog_id:
		return a.dialog_id > b.dialog_id
	else:
		return a.dialog_id > b.dialog_id
		
func download_sftp_to_cache(source,dest):
	CurrentEnvironment.sftp_client.DownloadDirectory(source,dest)
	
	

	
