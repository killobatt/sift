import Foundation
import Shout

final class SSH: SSHExecutor, ShellExecutor {
    private let ssh: Shout.SSH
    private let host: String
    private let port: Int32
    private var sftp: SFTP!
	private let arch: Config.NodeConfig.Arch?
    
    init(host: String, port: Int32 = 22, arch: Config.NodeConfig.Arch? = nil) throws {
        self.ssh = try Shout.SSH(host: host, port: port)
        self.host = host
        self.port = port
		self.arch = arch
    }
    
    func authenticate(username: String, password: String?, privateKey: String?, publicKey: String?, passphrase: String?) throws {
        if let password = password {
            try ssh.authenticate(username: username, password: password)
        } else if let privateKey = privateKey {
            try ssh.authenticate(username: username, privateKey: privateKey, publicKey: publicKey, passphrase: passphrase)
        } else {
            try ssh.authenticateByAgent(username: username)
        }
        self.sftp = try ssh.openSftp()
    }
    
    @discardableResult
    func uploadFile(localPath: String, remotePath: String) throws -> Self {
        try self.sftp.upload(localURL: URL(fileURLWithPath: localPath), remotePath: remotePath)
        return self
    }
    
    @discardableResult
    func uploadFile(data: Data, remotePath: String) throws -> Self {
        try self.sftp.upload(data: data, remotePath: remotePath)
        return self
    }
    
    @discardableResult
    func uploadFile(string: String, remotePath: String) throws -> Self {
        try self.sftp.upload(string: string, remotePath: remotePath)
        return self
    }
    
    @discardableResult
    func downloadFile(remotePath: String, localPath: String) throws -> Self {
        try self.sftp.download(remotePath: remotePath, localURL: URL(fileURLWithPath: localPath))
        return self
    }
    
    @discardableResult
    func run(_ command: String) throws -> (status: Int32, output: String) {
		let command = arch != nil ? "arch -\(arch!.rawValue) /bin/sh -c \"\(command)\"" : command
		return try self.ssh.capture(command)
    }
}
