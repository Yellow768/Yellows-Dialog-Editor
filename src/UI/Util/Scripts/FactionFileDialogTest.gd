extends FileDialog

func _ready():
	popup()


func _on_FileDialog_file_selected(path):
	var file = FileAccess.open(path,FileAccess.READ)
	var other_file = FileAccess.open("F:\\Daruma Project\\Isles of Rainmire DirAccess\\Tools\\output.txt",FileAccess.WRITE)
	var fct_load = faction_loader.new()
	file
	other_file
	other_file.store_string(String(fct_load.create_faction_dict_from_dat_file(file)))
	
	file.close()
	other_file.close()


func _on_FileDialog_popup_hide():
	popup()
