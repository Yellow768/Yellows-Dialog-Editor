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
	public delegate void SftpErrorEventHandler(string error);



	private Renci.SshNet.SftpClient _SFTPClient;
	public Godot.Collections.Dictionary ConnectionInfoDict;

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


	public string ConnectToSftpServer(Godot.Collections.Dictionary connection_info)
	{
		try
		{
			var AuthMethods = new List<AuthenticationMethod>();
			if (connection_info.ContainsKey("password"))
			{
				AuthMethods.Add(new PasswordAuthenticationMethod(connection_info["username"].ToString(), connection_info["password"].ToString()));
			}
			if (connection_info.ContainsKey("private_key"))
			{
				PrivateKeyFile PrivateKey;
				if (connection_info.ContainsKey("private_key_passphrase"))
				{
					PrivateKey = new PrivateKeyFile(connection_info["private_key"].ToString(), connection_info["private_key_passphrase"].ToString());
				}
				else
				{
					PrivateKey = new PrivateKeyFile(connection_info["private_key"].ToString());
				}
				var KeyFiles = new[] { PrivateKey };
				AuthMethods.Add(new PrivateKeyAuthenticationMethod(connection_info["username"].ToString(), KeyFiles));
			}
			ConnectionInfo connectionInfo = new ConnectionInfo(connection_info["hostname"].ToString(), connection_info["port"].As<int>(), connection_info["username"].ToString(), AuthMethods.ToArray());
			_SFTPClient = new Renci.SshNet.SftpClient(connectionInfo);
			_SFTPClient.Connect();
			GD.Print("Connected" + _SFTPClient.IsConnected + " Working Directory: " + _SFTPClient.WorkingDirectory);
			ConnectionInfoDict = connection_info;
			return "OK";
		}
		catch (Exception e)
		{
			return e.ToString();
		}
	}

	public void Disconnect()
	{
		if (_SFTPClient.IsConnected)
		{
			_SFTPClient.Disconnect();
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
			GD.Print(_SFTPClient.WorkingDirectory);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message);
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

	public int DownloadFile(string file_path, string local_dest)
	{
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return -1;
		}
		try
		{
			_DownloadFile(file_path, local_dest);
			return 0;
		}
		catch (Exception e)
		{
			return 100;
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
		GD.Print("Runs");
		return total_amount;
	}

	long downloadedSize = 0;
	long totalSize = 0;

	public int DownloadDirectory(string remote_directory_path, string local_directory_dest, bool onlyDownloadFolders = false, bool recursive = true)
	{
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return -1;
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
			EmitSignal(SignalName.SftpError, e.Message);
			return 100;
		}
		if (totalSize == 0)
		{
			EmitSignal(SignalName.ProgressDone);
			return 0;
		}
		else
		{
			try
			{
				_DownloadDirectory(remote_directory_path, local_directory_dest, onlyDownloadFolders, recursive);
				return 0;
			}
			catch (Exception e)
			{
				EmitSignal(SignalName.SftpError, e.Message);
				return 100;
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
				GD.Print("test");
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
				EmitSignal(SignalName.SftpError, e.Message);
				GD.Print(e);
			}
		}

	}

	public int UploadFile(string local_file_path, string remote_file_path)
	{
		GD.Print(_SFTPClient.IsConnected);
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return -1;
		}
		try
		{
			_UploadFile(local_file_path, remote_file_path);
			return 0;
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message);
			return 100;
		}
	}

	private async Task _UploadFile(string local_file_path, string remote_file_path)
	{
		try
		{
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
			EmitSignal(SignalName.SftpError, e.Message);
			GD.Print(e);
		}
	}

	public int UploadDirectory(string local_path, string remote_path)
	{
		if (!_SFTPClient.IsConnected)
		{
			EmitSignal(SignalName.SftpNotConnected);
			return -1;
		}
		try
		{
			_UploadDirectory(local_path, remote_path);
			return 0;
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message);
			GD.Print(e);
			return 100;
		}
	}

	private async Task _UploadDirectory(string local_path, string remote_path)
	{
		foreach (ISftpFile file in _SFTPClient.ListDirectory(remote_path))
		{
			if (!file.IsDirectory && file.Name.Contains("ydec"))
			{
				file.Delete();
			}
		}
		DirectoryInfo d = new DirectoryInfo(local_path);
		FileInfo[] Files = d.GetFiles("*.json");
		foreach (FileInfo file in Files)
		{
			try
			{
				GD.Print("THE PATH IS --- " + Path.Join(local_path, file.Name) + " " + remote_path + "--- PATH END");
				using (Stream fileStream = File.OpenRead(Path.Join(local_path, file.Name)))
				{
					await Task.Run(() => _SFTPClient.UploadFile(fileStream, remote_path + "/" + file.Name, true, null));
				}
			}
			catch (Exception e)
			{
				EmitSignal(SignalName.SftpError, e.Message);
				GD.Print(e);
			}
		}
	}
	public void _OnNewCategoryCreated(string category_name)
	{
		try
		{
			GD.Print(_SFTPClient.WorkingDirectory + "/dialogs/" + category_name);
			_SFTPClient.CreateDirectory(_SFTPClient.WorkingDirectory + "/dialogs/" + category_name);
		}
		catch (Exception E)
		{
			EmitSignal(SignalName.SftpError, E.Message);
			GD.Print(E);
		}
	}

	public void _OnCategoryDeleted(string category_name)
	{
		try
		{
			_SFTPClient.DeleteDirectory(_SFTPClient.WorkingDirectory + "/dialogs/" + category_name);
		}
		catch (Exception e)
		{
			EmitSignal(SignalName.SftpError, e.Message);
			GD.Print(e);
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
			EmitSignal(SignalName.SftpError, e.Message);
			GD.Print(e);
		}
	}

	public void _OnCategoryDuplicated(string old_category_name, string new_category_name){
		try{
			_SFTPClient.CreateDirectory(_SFTPClient.WorkingDirectory+"/dialogs/"+new_category_name);
			var fsIn = _SFTPClient.OpenRead(_SFTPClient.WorkingDirectory+"/dialogs/"+old_category_name);
			var fsOut = _SFTPClient.OpenWrite(_SFTPClient.WorkingDirectory+"/dialogs/"+new_category_name);
			int data;
			while ((data = fsIn.ReadByte()) != -1)
				fsOut.WriteByte((byte)data);
			fsOut.Flush();
			fsIn.Close();
			fsOut.Close();

		}
		catch(Exception e){
			EmitSignal(SignalName.SftpError, e.Message);
			GD.Print(e);
		}
	}
}

