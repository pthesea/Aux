import Foundation

public class Core {
    
    var fileManager: FileManager
    var envURL: URL? = nil
    
    init() {
        self.fileManager = FileManager.default
        self.envURL = checkFolder()
    }
    
    public func checkFolder() -> URL {
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let envFolder = docsURL.appendingPathComponent("Envs")
        
        var isDirectory: ObjCBool = false
        let folderExists = fileManager.fileExists(atPath: envFolder.path, isDirectory: &isDirectory)

        if !folderExists || !isDirectory.boolValue {
            do {
                try fileManager.createDirectory(at: envFolder, withIntermediateDirectories: true, attributes: nil)
                print("Environments directory was ceated successfully at /Documents/Envs/.")
            } catch {
                print("Error: Unable to create directory.")
            }
        }
    
        return envFolder
    }
    
    public func checkFiles() -> [URL] {
        let folderURL = checkFolder()
        var filesPaths = Array<URL>()
        do {
            let filesURL = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            if filesURL.count > 0 {
                for url in filesURL {
                    filesPaths.append(url)
                }
            }
            
        } catch {
            filesPaths = []
        }
        return filesPaths
    }
    
    public func createFile(content: [String], fileName: String) {
        if let envURL = self.envURL {
            let fileURL = envURL.appendingPathComponent("\(fileName).txt")
            let content = content.joined(separator: "\n")
            do {
                print("Trying to create \(fileName) environment.")
                try content.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                print("The \(fileName) was created successfully.")
            } catch {
                print("Eror: Failed to create this environment.")
            }
        }
        return
    }
    
    public func readFile(fileName: String) -> [URL?] {
        var appsURL: Array<URL?> = [nil]
        if let envURL = self.envURL {
            let fileURL = envURL.appendingPathComponent("\(fileName).txt")
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    let content = try String(contentsOf: fileURL, encoding: .utf8).split(separator: "\n")
                    appsURL = content.map { URL(fileURLWithPath: String($0)) }
                } catch {
                    print("Error: Unabe to read environment.\n")
                }
            } else {
                print("Error: Non-existent environment.\n")
            }
        }
        return appsURL
    }
    
    public func deleteFile(fileName: String) {
        do{
            try fileManager.removeItem(at: (envURL?.appendingPathComponent("\(fileName).txt"))!)
            print("The \(fileName) environment was deleted successfully.\n")
        } catch{
            print("Failed to delete this file. It may been removed.\n")
        }
        return
    }
    
    public func listApps() -> [URL] {
        let systemAppsURL = fileManager.urls(for: .applicationDirectory, in: .systemDomainMask)[0]
        let userAppsURL = URL(fileURLWithPath: "/Applications/")
        var systemApps = Array<URL>()
        var userApps = Array<URL>()
        var installedApps = Array<URL>()
        
        do {
            systemApps = try fileManager.contentsOfDirectory(at: systemAppsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            print("Unable to get System installed apps.")
        }
        
        do {
            userApps = try fileManager.contentsOfDirectory(at: userAppsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        } catch {
            print("Unable to get User installed apps.")
        }
        
        installedApps = userApps + systemApps
        
        return installedApps
    }
    
    public func openApp(appURL: URL) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["\(appURL.path)"]
        do {
            print("Trying to run \(appURL.lastPathComponent)")
            try task.run()
            print("Running \(appURL.lastPathComponent)")
        } catch {
            print("Error: Failed to run \"\(appURL.lastPathComponent)\"\n")
        }
        task.waitUntilExit()
    }
}
