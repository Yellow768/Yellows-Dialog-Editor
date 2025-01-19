using Godot;
using System;
using Renci.SshNet;
using Renci.SshNet.Sftp;
using System.IO;
using System.Threading.Tasks;

public partial class SFTP_Client : Node
{

[Signal]
public delegate void ProgressEventHandler(int progress,int total);

[Signal]
public delegate void ProgressDoneEventHandler();


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

	public delegate void ProgressHandler(float progress);
	public event ProgressHandler OnProgress;

	public void DownloadFile(string file_path, string local_dest){
		_DownloadFile(file_path,local_dest);
	}

	private async Task _DownloadFile(string file_path, string local_dest){
		var remote_file = _SFTPClient.Get(file_path);
		using(Stream fileStream = File.OpenWrite(Path.Combine(local_dest,remote_file.Name))){
		await Task.Run(() =>_SFTPClient.DownloadFile(file_path,fileStream));
		fileStream.Position = 0;
		EmitSignal(SignalName.ProgressDone);
		}
	}

	private long GetTotalAmountOfFileSizesInDirectoryRecursive(string directory,bool only_directories){
		long total_amount = 0;
		System.Collections.IEnumerable files = _SFTPClient.ListDirectory(directory);
		foreach (ISftpFile file in files){
			if(!file.IsDirectory){
				if(!only_directories){
				total_amount+=file.Attributes.Size;
				}
			}
			else{
				if(file.Name != ".." && file.Name != "." && !file.IsSymbolicLink){
					if(only_directories){
						total_amount+=1;
					}
				total_amount += GetTotalAmountOfFileSizesInDirectoryRecursive(directory+"/"+file.Name,only_directories);
				}
			}
		}
		return total_amount;
	}

	long downloadedSize = 0;
	long totalSize = 0; 

	public void DownloadDirectory(string remote_directory_path, string local_directory_dest,bool onlyDownloadFolders = false){
		downloadedSize = 0;
		totalSize = 0;

		try{
		totalSize = GetTotalAmountOfFileSizesInDirectoryRecursive(remote_directory_path,onlyDownloadFolders);
		}
		catch(Exception e){
			GD.Print(e);
		}
		
		_DownloadDirectory(remote_directory_path,local_directory_dest,onlyDownloadFolders);
	}

	public async Task _DownloadDirectory(string remote_directory_path, string local_directory_dest,bool onlyDownloadFolders = false){
		System.Collections.IEnumerable files = _SFTPClient.ListDirectory(remote_directory_path);

		foreach(ISftpFile file in files){
			if(file.IsDirectory && !(file.Name == "." || file.Name == "..")){
				await Task.Run(() => Directory.CreateDirectory(local_directory_dest+"/"+file.Name));
				if(onlyDownloadFolders){
					downloadedSize+=1;
				}
				_DownloadDirectory(file.FullName,local_directory_dest+"/"+file.Name,onlyDownloadFolders);
			}
			if(!file.IsDirectory){
				if(!onlyDownloadFolders){
					using(Stream fileStream = File.OpenWrite(Path.Combine(local_directory_dest,file.Name))){
						await Task.Run(() => _SFTPClient.DownloadFile(file.FullName,fileStream));
						downloadedSize += file.Attributes.Size;
						fileStream.Position = 0;
					}
				}
			}
					EmitSignal(SignalName.Progress,downloadedSize,totalSize);
					GD.Print(file.Name+" "+downloadedSize+" "+totalSize);
					if(downloadedSize==totalSize){
						GD.Print("DoneDownloading");
						EmitSignal(SignalName.ProgressDone);
					}	
		}
	}
}
