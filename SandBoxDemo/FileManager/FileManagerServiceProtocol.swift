//
//  FileManagerServiceProtocol.swift
//  SandBoxDemo
//
//  Created by Aleksey Lexx on 01.12.2022.
//

import Foundation
import UIKit

protocol FileManagerServiceProtocol {
    
    func contentsOfDirectory(currentDirectory: URL) -> [URL]
    func createDirectory(folderPath: String)
    func createFile(currentDirectory: URL, fileName: String, image: UIImage)
    func removeContent(pathForItem: String)
    
}
