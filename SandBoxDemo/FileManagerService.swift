//
//  FileManagerService.swift
//  SandBoxDemo
//
//  Created by Aleksey Lexx on 01.12.2022.
//

import Foundation

class FileManagerService: FileManagerServiceProtocol {
    
    static let shared = FileManagerService()
    private let fileManager = FileManager.default
    
    func contentsOfDirectory(currentDirectory: URL) -> [URL] {
           var contents: [URL] = []
               do {
                   let files = try FileManager.default.contentsOfDirectory(at: currentDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                   contents = files
                   
               } catch {
                   print(error.localizedDescription)
               }
           return contents
       }
    
func createDirectory(folderPath: String) {
    do {
        try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: false)
    } catch {
        print(error)
    }
}

    func createFile(currentDirectory: URL, newFile: URL) {
            let fileURL = currentDirectory.appendingPathComponent(newFile.lastPathComponent)
            do {
                FileManager.default.createFile(atPath: fileURL.path, contents: Data())
            }
        }
    
    func removeContent(pathForItem: String) {
        do {
            try FileManager.default.removeItem(atPath: pathForItem)
        } catch {
            print(error.localizedDescription)
        }
    }
}
