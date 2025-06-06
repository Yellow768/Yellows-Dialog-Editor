using Godot;
using System;
using Renci.SshNet;
using Renci.SshNet.Sftp;
using System.IO;
using System.Threading.Tasks;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

public partial class SFTP_Client : Node
{

	[Signal]
	public delegate void ProgressEventHandler(int progress);

	[Signal]
	public delegate void ProgressMaxChangedEventHandler(int progressMax);

	[Signal]
	public delegate void ProgressItemChangedEventHandler(string item);

	[Signal]
	public delegate void ProgressDoneEventHandler();

	[Signal]
	public delegate void SftpNotConnectedEventHandler();

	[Signal]
	public delegate void SftpDisconnectedEventHandler();

	[Signal]
	public delegate void SftpConnectedEventHandler();

	[Signal]
	public delegate void SftpFailedToConnectEventHandler();

	[Signal]
	public delegate void SftpErrorEventHandler(string error,string message);



	private Renci.SshNet.SftpClient _SFTPClient;
	public Godot.Collections.Dictionary ConnectionInfoDict;
	public string local_file_cache;
	public string remote_file_directory;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
	/*
	there are 4 types of connections

	- password
	- password and key
	- no password and key
	- no password and key with passphrase

	on the connect button pressed, call the correct method based on


	*/

	public bool IsConnected(){
		return _SFTPClient.IsConnected;
	}


	
	public bool CheckConnection(){
		if(!_SFTPClient.IsConnected){
			EmitSignal(SignalName.SftpNotConnected);
		}
		return _SFTPClient.IsConnected;
	}

	public string ConnectToSftpServer(Godot.Collections.Dictionary connection_info)
	{
		try
		{
			var AuthMethods = new List<AuthenticationMethod>();
			if (connection_info.ContainsKey("password"))
			{
				AuthMethods.Add(new PasswordAuthenticationMethod(connection_info["username"].ToString(), connection_info["password"].ToString()));
			}
			if (connection_info.ContainsKey("private_key_file"))
			{
				PrivateKeyFile PrivateKey;
				if (connection_info.ContainsKey("private_key_passphrase"))
				{
					PrivateKey = new PrivateKeyFile(connection_info["private_key_file"].ToString(), connection_info["private_key_passphrase"].ToString());
				}
				else
				{
					PrivateKey = new PrivateKeyFile(connection_info["private_key_file"].ToString());
				}
				var KeyFiles = new[] { PrivateKey };
				AuthMethods.Add(new PrivateKeyAuthenticationMethod(connection_info["username"].ToString(), KeyFiles));
			}
			ConnectionInfo connectionInfo = new ConnectionInfo(connection_info["hostname"].ToString(), connection_info["port"].As<int>(), connection_info["username"].ToString(), AuthMethods.ToArray());
			_SFTPClient = new Renci.SshNet.SftpClient(connectionInfo);
			_SFTPClient.Connect();
			GD.Print("Connected: " + _SFTPClient.IsConnected + " Working Directory: " + _SFTPClient.WorkingDirectory);
			ConnectionInfoDict = connection_info;
			EmitSignal(SignalName.SftpConnected);
			return "OK";
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpFailedToConnect);
			return e.ToString();
			
		}
	}

	public void Disconnect()
	{
		if (_SFTPClient.IsConnected)
		{
			_SFTPClient.Disconnect();
			EmitSignal(SignalName.SftpDisconnected);
		}
	}

	public Godot.Collections.Dictionary<string, bool> ListDirectory(string directory)
	{
		Godot.Collections.Dictionary<string, bool> DirectoryList = new Godot.Collections.Dictionary<string, bool>();
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return DirectoryList;
		}
		else
		{
			if (_SFTPClient.Exists(directory))
			{
				foreach (var file in _SFTPClient.ListDirectory(directory))
				{
					DirectoryList.Add(file.Name, file.IsDirectory);
				}
			}
			return DirectoryList;
		}
	}

	public void ChangeDirectory(string path)
	{
		try
		{
			_SFTPClient.ChangeDirectory(path);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_CHANGE_DIR");
		}
	}

	public string GetCurrentDirectory()
	{
		return _SFTPClient.WorkingDirectory;
	}

	public bool Exists(string path)
	{
		return _SFTPClient.Exists(path);
	}

	public delegate void ProgressHandler(float progress);
	public event ProgressHandler OnProgress;

	public void DownloadFile(string file_path, string local_dest)
	{
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return;
		}
		try
		{
			_DownloadFile(file_path, local_dest);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError,e.Message,"SFTP_ERROR_DOWNLOAD");
		}
	}

	private async Task _DownloadFile(string file_path, string local_dest)
	{

		var remote_file = _SFTPClient.Get(file_path);
		using (Stream fileStream = File.OpenWrite(Path.Combine(local_dest, remote_file.Name)))
		{
			await Task.Run(() => _SFTPClient.DownloadFile(file_path, fileStream));
			fileStream.Position = 0;
			EmitSignal(SignalName.ProgressItemChanged, remote_file.Name);
			EmitSignal(SignalName.ProgressDone);
		}
	}

	private long GetTotalAmountOfFileSizesInDirectoryRecursive(string directory, bool only_directories, bool recursive = true)
	{
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return 0;
		}
		long total_amount = 0;
		System.Collections.IEnumerable files = _SFTPClient.ListDirectory(directory);
		foreach (ISftpFile file in files)
		{
			if (!file.IsDirectory)
			{
				if (!only_directories)
				{
					total_amount += file.Attributes.Size;
				}
			}
			else
			{
				if (file.Name != ".." && file.Name != "." && !file.IsSymbolicLink)
				{
					if (only_directories)
					{
						total_amount += 1;
					}
					if (recursive)
					{
						total_amount += GetTotalAmountOfFileSizesInDirectoryRecursive(directory + "/" + file.Name, only_directories, recursive);
					}
				}
			}
		}
		return total_amount;
	}


	public Godot.Collections.Array<string> GetAllDialogFiles(string dir){
		Godot.Collections.Array<string> all_files = new Godot.Collections.Array<string>();
		System.Collections.IEnumerable files = _SFTPClient.ListDirectory(dir);
		foreach(ISftpFile file in files){
			if(file.IsDirectory && file.Name != "." && file.Name != ".."){
				all_files += GetAllDialogFiles(dir+"/"+file.Name);
			}
			if(!file.IsDirectory){
				if(file.Name.Substring(file.Name.Length-5,5) == ".json"){
				all_files.Add(file.Name.Substring(0,file.Name.Length -5));
				}
				
			}



		}
		return all_files;
	}

	long downloadedSize = 0;
	long totalSize = 0;

	public void DownloadDirectory(string remote_directory_path, string local_directory_dest, bool onlyDownloadFolders = false, bool recursive = true)
	{
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return ;
		}
		downloadedSize = 0;
		totalSize = 0;

		try
		{
			totalSize = GetTotalAmountOfFileSizesInDirectoryRecursive(remote_directory_path, onlyDownloadFolders, recursive);
			EmitSignal(SignalName.ProgressMaxChanged, totalSize);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_DOWNLOAD_FILES");
			return;
		}
		if (totalSize == 0)
		{
			EmitSignal(SignalName.ProgressDone);
		return;
		}
		else
		{
			try
			{
				_DownloadDirectory(remote_directory_path, local_directory_dest, onlyDownloadFolders, recursive);
				return ;
			}
			catch (Exception e)
			{
				EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_DOWNLOAD_FILES");
				return;
			}
		}
	}

	public async Task _DownloadDirectory(string remote_directory_path, string local_directory_dest, bool onlyDownloadFolders = false, bool recursive = true)
	{
		System.Collections.IEnumerable files = _SFTPClient.ListDirectory(remote_directory_path);
		if (files.Cast<ISftpFile>().ToList().Count() == 0)
		{
			EmitSignal(SignalName.Progress, downloadedSize);
			if (downloadedSize == totalSize)
			{
				EmitSignal(SignalName.ProgressDone);
			}
		}
		else
		{
			try
			{
				foreach (ISftpFile file in files)
				{
					if (file.IsDirectory && !(file.Name == "." || file.Name == ".."))
					{
						await Task.Run(() => Directory.CreateDirectory(local_directory_dest + "/" + file.Name));
						if (onlyDownloadFolders)
						{
							downloadedSize += 1;
						}
						if (recursive)
						{
							_DownloadDirectory(file.FullName, local_directory_dest + "/" + file.Name, onlyDownloadFolders);
							EmitSignal(SignalName.ProgressItemChanged, file.Name);
						}
					}
					if (!file.IsDirectory)
					{
						if (!onlyDownloadFolders)
						{
							using (Stream fileStream = File.OpenWrite(Path.Combine(local_directory_dest, file.Name)))
							{
								await Task.Run(() => _SFTPClient.DownloadFile(file.FullName, fileStream));
								EmitSignal(SignalName.ProgressItemChanged, file.Name);
								downloadedSize += file.Attributes.Size;
								fileStream.Position = 0;
							}
						}
					}
					EmitSignal(SignalName.Progress, downloadedSize);
					if (downloadedSize == totalSize)
					{
						EmitSignal(SignalName.ProgressDone);
					}
				}
			}
			catch (Exception e)
			{
				EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_DOWNLOAD_FILES");
			}
		}

	}

	public void UploadFile(string local_file_path, string remote_file_path)
	{
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return ;
		}
		try
		{
			_UploadFile(local_file_path, remote_file_path);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_UPLOAD");
			return ;
		}
		GD.Print(remote_file_path);
	}

	private void _RecursiveCreateAllDirsInPath(string path){
			string[] each_directory = path.Split('/');
			string current_dir = "";
			for(int i = 0; i < each_directory.Length -1; i++){
				if(!string.IsNullOrEmpty(each_directory[i])){
					current_dir += "/"+each_directory[i];
					if(!_SFTPClient.Exists(current_dir)){
						_SFTPClient.CreateDirectory(current_dir);
					}
				}
				
			}
	}
	private async Task _UploadFile(string local_file_path, string remote_file_path)
	{
		try
		{
			_RecursiveCreateAllDirsInPath(remote_file_path);
			MemoryStream FileMemoryStream = new MemoryStream();

			using (Stream fileStream = File.OpenRead(local_file_path))
			{
				fileStream.CopyTo(FileMemoryStream);
			}
			FileMemoryStream.Position = 0;

			await Task.Run(() => _SFTPClient.UploadFile(FileMemoryStream, remote_file_path, true, null));
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message, "SFTP_ERROR_UPLOAD");
		}
	}

	public void UploadDirectory(string local_path, string remote_path)
	{
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
		}
		try
		{
			_UploadDirectory(local_path, remote_path);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message, "SFTP_ERROR_UPLOAD_DIRECTORY");
		}
	}

	private async Task _UploadDirectory(string local_path, string remote_path)
	{
		try{
		_RecursiveCreateAllDirsInPath(remote_path);
		foreach (ISftpFile file in _SFTPClient.ListDirectory(remote_path))
		{
			if (!file.IsDirectory && !file.Name.Contains("ydec"))
			{
				file.Delete();
			}
		}
		DirectoryInfo d = new DirectoryInfo(local_path);
		FileInfo[] Files = d.GetFiles("*.json");
		foreach (FileInfo file in Files)
		{
			
			
				using (Stream fileStream = File.OpenRead(Path.Join(local_path, file.Name)))
				{
					
					await Task.Run(() => _SFTPClient.UploadFile(fileStream, remote_path + "/" + file.Name, true, null));
				}
			
			
		}
		}
		catch (Exception e)
			{
				EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_UPLOAD_DIRECTORY");
			}
	}


private void DeleteDirectory(string path)
{
	foreach (SftpFile file in _SFTPClient.ListDirectory(path))
	{
		if ((file.Name != ".") && (file.Name != ".."))
		{
			if (file.IsDirectory)
			{
				DeleteDirectory(file.FullName);
			}
			else
			{
				_SFTPClient.DeleteFile(file.FullName);
			}
		}
	}

	_SFTPClient.DeleteDirectory(path);
}


	public void _OnNewCategoryCreated(string category_name)
	{
		try
		{
			_SFTPClient.CreateDirectory(_SFTPClient.WorkingDirectory + "/dialogs/" + category_name);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message, "SFTP_ERROR_CATEGORY_CREATE");
		}
	}

	public void _OnCategoryDeleted(string category_name)
	{
		try
		{
			GD.Print(_SFTPClient.WorkingDirectory+"/dialogs/"+category_name);
			DeleteDirectory(_SFTPClient.WorkingDirectory + "/dialogs/" + category_name);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_CATEGORY_DELETE");
		}

	}

	public void _OnCategoryRenamed(string old_name, string new_name)
	{
		try
		{
			_SFTPClient.RenameFile(_SFTPClient.WorkingDirectory + "/dialogs/" + old_name, _SFTPClient.WorkingDirectory + "/dialogs/" + new_name);
			if (_SFTPClient.Exists(_SFTPClient.WorkingDirectory + "/dialogs/" + new_name + "/" + old_name + ".ydec"))
			{
				_SFTPClient.RenameFile(_SFTPClient.WorkingDirectory + "/dialogs/" + new_name + "/" + old_name + ".ydec", _SFTPClient.WorkingDirectory + "/dialogs/" + new_name + "/" + new_name + ".ydec");
			}
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_CATEGORY_RENAME");
		}
	}

	public void _OnCategoryDuplicated(string old_category_name, string new_category_name){
		try{
			UploadDirectory(local_file_cache+"/dialogs/"+new_category_name,_SFTPClient.WorkingDirectory+"/dialogs/"+new_category_name);
		}
		catch(Exception e){
			EmitSignal(SignalName.SftpError, e.Message,"SFTP_ERROR_CATEGORY_DUPLICATE");
		}
	}


	public void _OnCategoryExported(string category_name){
		try{
		UploadDirectory(local_file_cache+"/dialogs/"+category_name,_SFTPClient.WorkingDirectory+"/dialogs/"+category_name+"/");
		}
		catch(Exception e){
			EmitSignal(SignalName.SftpError,e.Message,"SFTP_ERROR_CATEGORY_EXPORT");
		}
	}

	public void _OnCategorySaved(string category_name){
		try{
		UploadFile(local_file_cache+"/dialogs/"+category_name+"/"+category_name+".ydec",_SFTPClient.WorkingDirectory+"/dialogs/"+category_name+"/"+category_name+".ydec");
		}
		catch(Exception e){
			EmitSignal(SignalName.SftpError,e.Message,"SFTP_ERROR_CATEGORY_SAVE");
		}
	}
}

