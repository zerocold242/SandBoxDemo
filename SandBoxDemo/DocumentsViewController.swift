//
//  ViewController.swift
//  SandBoxDemo
//
//  Created by Aleksey Lexx on 06.11.2022.
//

import UIKit

class DocumentsViewController: UIViewController, UINavigationControllerDelegate {
    
    var fileURL: URL
    var contents: [URL] = []
    var directoryTitle: String
    //переменная показывающая путь к документу
    var path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    init(fileURL: URL, directoryTitle: String) {
        self.fileURL = fileURL
        self.directoryTitle = directoryTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //переменная показывает массив имен документов(файлы, папки)
    var documents: [String]{
        do {
            return try FileManager.default.contentsOfDirectory(atPath: path)
        } catch {
            print(error)
        }
        return []
    }
    
    private lazy var docsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        return picker
    }()
    
    private func setupNavigationBar() {
        navigationItem.title = directoryTitle
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.isTranslucent = true
        let addFiles =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFile))
        let addDirectory = UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"), style: .plain, target: self, action: #selector(addDirectory))
        navigationItem.rightBarButtonItems = [addFiles, addDirectory]
    }
    
    private func setupView() {
        view.addSubview(docsTableView)
        docsTableView.delegate = self
        docsTableView.dataSource = self
        docsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        imagePicker.delegate = self
        
        NSLayoutConstraint.activate([
            docsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            docsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            docsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            docsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func addFile ( _ : Any) {
        present(imagePicker, animated: true)
    }
    //создание папки
    @objc private func addDirectory(){
        TextPicker.defaultPicker.getText(showTextPickerIn: self,
                                         title: "Create folder",
                                         message: "Enter folder name") {text in
            let folderPath = self.path + "/" + text
            FileManagerService.shared.createDirectory(folderPath: folderPath)
            self.docsTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupView()
        view.backgroundColor = .white
        
    }
}

extension DocumentsViewController: UITableViewDelegate, UITableViewDataSource {
    //число ячеек соответствует числу документов
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //название ячейки
        cell.textLabel?.text = documents[indexPath.row]
        //проверяем файл это или папка и если папка добавляем индикатор кликабельности ячейки
        var objcBool: ObjCBool = false
        FileManager.default.fileExists(atPath: path + "/" + documents[indexPath.row], isDirectory: &objcBool)
        if objcBool.boolValue {
            //добавляем стрелку на кликабельную ячейку
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    //удаление обЬектов
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pathForItem = path + "/" + documents[indexPath.row]
            FileManagerService.shared.removeContent(pathForItem: pathForItem)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPath = path + "/" + documents[indexPath.row]
        //проверяем файл или папка
        var objcBool: ObjCBool = false
        FileManager.default.fileExists(atPath: selectedPath, isDirectory: &objcBool)
        if objcBool.boolValue {
            //если это папка то переходим
            let directoryPath = URL(fileURLWithPath: (path + "/" + documents[indexPath.row]))
            let nextController = DocumentsViewController(fileURL: directoryPath, directoryTitle: directoryPath.lastPathComponent)
            nextController.path = selectedPath
            navigationController?.popViewController(animated: true)
            navigationController?.pushViewController(nextController, animated: true)
        }
    }
}

extension DocumentsViewController: UIImagePickerControllerDelegate {
    //сохраняем файл из галереи
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.imageURL] as! URL
        self.dismiss(animated: true, completion: nil)
        FileManagerService.shared.createFile(currentDirectory: fileURL, newFile: image)
        contents = FileManagerService.shared.contentsOfDirectory(currentDirectory: fileURL)
        self.docsTableView.reloadData()
    }
}


