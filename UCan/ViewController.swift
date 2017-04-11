//
//  ViewController.swift
//  UCan
//
//  Created by qifx on 06/04/2017.
//  Copyright © 2017 Manfred. All rights reserved.
//


import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var tableView: UITableView!
    var folderManager: FolderManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
        folderManager = FolderManager(rootURL: URL.init(fileURLWithPath: docPath))
        
        navigationItem.title = folderManager.currentURL.lastPathComponent
        
        tableView = UITableView(frame: view.bounds)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createDir(_ sender: Any) {
        let ac = UIAlertController(title: "Create a directory on here", message: nil, preferredStyle: .alert)
        ac.addTextField { (tf: UITextField) in
            
        }
        ac.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action: UIAlertAction) in
            if let name = ac.textFields!.first!.text {
                if !name.isEmpty {
                    if self.folderManager.createDirectory(name: name) {
                        self.tableView.reloadData()
                    } else {
                        print("create filed")
                    }
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func goUp(_ sender: Any) {
        if folderManager.goToParent() {
            tableView.reloadData()
            self.navigationItem.title = folderManager.currentURL.lastPathComponent
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return folderManager.getChilds().0.count
        } else {
            return folderManager.getChilds().1.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        let path: String
        cell?.imageView?.contentMode = .scaleAspectFit
        if indexPath.section == 0 {
            path = (folderManager.getChilds().0)[indexPath.row]
            cell?.imageView?.image = #imageLiteral(resourceName: "folder")
        } else {
            path = (folderManager.getChilds().1)[indexPath.row].lowercased()
            if path.hasSuffix(".mp4") || path.hasSuffix(".mov") || path.hasSuffix(".mkv") || path.hasSuffix(".rmvb") || path.hasSuffix(".avi") {
                cell?.imageView?.image = #imageLiteral(resourceName: "video")
            } else if path.hasSuffix(".png") || path.hasSuffix(".jpg") || path.hasSuffix(".jpeg") {
                cell?.imageView?.image = #imageLiteral(resourceName: "picture")
            } else if path.hasSuffix(".mp3") || path.hasSuffix(".wav") {
                cell?.imageView?.image = #imageLiteral(resourceName: "music")
            } else {
                cell?.imageView?.image = #imageLiteral(resourceName: "file")
            }
        }
        cell?.textLabel?.text = path
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let path = (folderManager.getChilds().0)[indexPath.row]
            folderManager.goToChild(url: folderManager.currentURL.appendingPathComponent(path))
            self.navigationItem.title = path
            tableView.reloadData()
        } else {
            let path = (folderManager.getChilds().1)[indexPath.row].lowercased()
            if path.hasSuffix(".mp4") || path.hasSuffix(".mov") || path.hasSuffix(".mkv") || path.hasSuffix(".rmvb") || path.hasSuffix(".avi") {
                if let vc = KxMovieViewController.movieViewController(withContentPath: folderManager.currentURL.appendingPathComponent(path).path, parameters: nil) as? KxMovieViewController {
                    present(vc, animated: true, completion: nil)
                }
            } else if path.hasSuffix(".png") || path.hasSuffix(".jpg") || path.hasSuffix(".jpeg") {
                
            } else if path.hasSuffix(".mp3") || path.hasSuffix(".wav") {
                
            } else {

            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let ac = UIAlertController(title: "Delete Item", message: "If you delete a folder, the sub folder and file will be deleted too.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
            let name = indexPath.section == 0 ? (self.folderManager.getChilds().0)[indexPath.row] : (self.folderManager.getChilds().1)[indexPath.row]
            if self.folderManager.deleteDirectoryOrFile(name: name) {
                self.tableView.reloadData()
            } else {
                print("delete failed")
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
}
