using Godot;
using System;
using Renci.SshNet;

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

}
