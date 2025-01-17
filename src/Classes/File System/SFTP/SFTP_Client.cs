using Godot;
using System;
using Renci.SshNet;
using Renci.SshNet.Sftp;
using System.IO;

public partial class SFTP_Client : Node
{
	private Renci.SshNet.SftpClient _SFTPClient;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

	public void ConnectToSftpServer(string _user, string _hostname, int _port, string _password)
	{
		_SFTPClient = new Renci.SshNet.SftpClient(_hostname, _port, _user, _password);
		try
		{
			_SFTPClient.Connect();
			GD.Print("Connected" + _SFTPClient.IsConnected + " Working Directory: " + _SFTPClient.WorkingDirectory);
		}
		catch (Exception e)
		{
			GD.Print(e.Message);
		}
	}

	public Godot.Collections.Dictionary<string, bool> ListDirectory(string directory)
	{
		Godot.Collections.Dictionary<string, bool> DirectoryList = new Godot.Collections.Dictionary<string, bool>();
		if (!_SFTPClient.IsConnected)
		{
			GD.Print("SFTP Client is not connected");
			return DirectoryList;
		}
		else
		{
			foreach (var file in _SFTPClient.ListDirectory(directory))
			{
				DirectoryList.Add(file.Name, file.IsDirectory);
			}
			return DirectoryList;
		}
	}

	public void ChangeDirectory(string path){
		try{
			_SFTPClient.ChangeDirectory(path);
			GD.Print(_SFTPClient.WorkingDirectory);
		}
		catch(Exception e){
			GD.Print(e);
		}
	}

	public string GetCurrentDirectory(){
		return _SFTPClient.WorkingDirectory;
	}

	public bool Exists(string path){
		return _SFTPClient.Exists(path);
	}

	public void DownloadFile(string file_path, string local_dest){
		var remote_file = _SFTPClient.Get(file_path);
		using(Stream fileStream = File.OpenWrite(Path.Combine(local_dest,remote_file.Name))){
		_SFTPClient.DownloadFile(file_path,fileStream);
		fileStream.Position = 0;
		}
	}

	public void DownloadDirectory(string remote_directory_path, string local_directory_dest){
		System.Collections.IEnumerable files = _SFTPClient.ListDirectory(remote_directory_path);
		foreach(ISftpFile file in files){
			if(file.IsDirectory && !(file.Name == "." || file.Name == "..")){
				Directory.CreateDirectory(local_directory_dest+"/"+file.Name);
				DownloadDirectory(file.FullName,local_directory_dest+"/"+file.Name);
			}
			if(!file.IsDirectory){
				DownloadFile(file.FullName,local_directory_dest);
			}
		}
	}


	
	
}
