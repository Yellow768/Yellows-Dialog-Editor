using Godot;
using System;
using Renci.SshNet;
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

	public Godot.Collections.Dictionary<string, bool> ListDirectory()
	{
		Godot.Collections.Dictionary<string, bool> DirectoryList = new Godot.Collections.Dictionary<string, bool>();
		if (!_SFTPClient.IsConnected)
		{
			GD.Print("SFTP Client is not connected");
			return DirectoryList;
		}
		else
		{
			foreach (var file in _SFTPClient.ListDirectory(_SFTPClient.WorkingDirectory))
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

	public void DownloadDirectory(string source, string dest){
		_DownloadDirectory(_SFTPClient,source,dest);
	}

	private static void _DownloadDirectory(Renci.SshNet.SftpClient sftp_client,string sourceRemotePath, string destLocalPath){
		Directory.CreateDirectory(destLocalPath);
		System.Collections.IEnumerable files = sftp_client.ListDirectory(sourceRemotePath);
		foreach (Renci.SshNet.Sftp.SftpFile file in files){
			if ((file.Name != ".") && (file.Name != ".")){
				string sourceFilePath = sourceRemotePath+"/"+file.Name;
				string destFilePath = Path.Combine(destLocalPath,file.Name);
				if(file.IsDirectory){
					_DownloadDirectory(sftp_client,sourceRemotePath,destFilePath);
				}
				else{
					using(Stream fileStream = File.Create(destFilePath)){
						sftp_client.DownloadFile(sourceFilePath,fileStream);
					}
				}
			}
		} 
	}
}
