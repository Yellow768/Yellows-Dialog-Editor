extends Node
class_name DirectorySearch

func scan_directory_for_folders(scan_dir: String):
	var folders = []
	var dir = DirAccess.open(scan_dir)
	if dir == null : return
	dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir() && (file_name != "." && file_name != ".."):
			folders.append(file_name)
		file_name = dir.get_next()
	return folders
	
func scan_directory_for_files(scan_dir: String):
	var files = []
	var dir = DirAccess.open(scan_dir)
	dir.list_dir_begin() # TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
	var file_name = dir.get_next()
	while file_name != "":
		if !dir.current_is_dir():
			files.append(file_name)
		file_name = dir.get_next()
	
	return files

func scan_all_subdirectories(scan_dir : String, filter_exts : Array = []) -> Array:
	var my_files : Array = []
	var dir = DirAccess.open(scan_dir)
	if DirAccess.get_open_error() != OK:
		printerr("Warning: could not open directory: ", scan_dir)
		return []

	if dir.list_dir_begin()  != OK:# TODOConverter3To4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		printerr("Warning: could not list contents of: ", scan_dir)
		return []

	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			my_files += scan_all_subdirectories(dir.get_current_dir() + "/" + file_name, filter_exts)
		else:
			if filter_exts.size() == 0:
				my_files.append(file_name)
			else:
				for ext in filter_exts:
					if file_name.get_extension() == ext:
						my_files.append(file_name)
		file_name = dir.get_next()
	return my_files
	
	
