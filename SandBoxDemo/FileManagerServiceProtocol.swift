//
//  FileManagerServiceProtocol.swift
//  SandBoxDemo
//
//  Created by Aleksey Lexx on 01.12.2022.
//

import Foundation

protocol FileManagerServiceProtocol {
    
    func contentsOfDirectory(currentDirectory: URL) -> [URL]
    func createDirectory(folderPath: String)
    func createFile(currentDirectory: URL, newFile: URL)
    func removeContent(pathForItem: String)
    
}
