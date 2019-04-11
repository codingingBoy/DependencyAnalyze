//
//  ViewController.swift
//  DependencyAnalyzer
//
//  Created by JGL on 2019/4/11.
//  Copyright © 2019 JGL. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSOpenSavePanelDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addProject(_ sender: NSButton) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.isFloatingPanel = true
        panel.directoryURL = URL.init(fileURLWithPath: NSHomeDirectory())
        panel.delegate = self
        
        panel.begin {[weak self] in
            guard let `self` = self, $0 == .OK,
                let path = panel.urls.first?.path,
                path.isDirExists(),
                let files = try? FileManager.default.contentsOfDirectory(atPath: path) else {
                    return
            }
            let file = files.element{$0.hasSuffix(".xcodeproj")}
            let errorMessage = "目录中没有有效的 iOS/MacOS 工程，或者可能包含多个工程"
            guard let project = file else {
                self.alertMessage(errorMessage)
                return
            }
            let package = try? FileManager.default.contentsOfDirectory(atPath: path + "/" + project)
            let pbxproj = package?.element{$0 == "project.pbxproj"}
            guard let proj = pbxproj else {
                self.alertMessage(errorMessage)
                return
            }
            let refrencies = self.refrenceList(path: path + "/" + project + "/" + proj)
            
        }
    }
    
    func refrenceList(path: String) -> [String] {
        guard path.isFileExists(), let handle = FileHandle.init(forReadingAtPath: path) else {
            return []
        }
        let data = handle.readDataToEndOfFile()
        let text = String.init(data: data, encoding: .utf8)
        return []
    }
    
    private func alertMessage(_ message: String) {
        let alert = NSAlert.init()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.addButton(withTitle: "确定")
        alert.beginSheetModal(for: NSApp.mainWindow!) { _ in
            
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension String {
    
    /// 判断是否是目录
    ///
    /// - Parameter path: 路径
    /// - Returns: true是目录
    public func isDirExists() -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &isDir) {
            return isDir.boolValue
        }
        
        return false
    }
    
    
    /// 判断文件是否已经存在
    ///
    /// - Returns: true文件存在
    public func isFileExists() -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &isDir) {
            return !isDir.boolValue
        }
        return false
    }
}


extension Array {
    subscript (safe index: Index) -> Element? {
        guard index >= 0 && index < count else {
            print("index out of range for array")
            return nil
        }
        
        return  self[index]
    }
}

extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        guard let i = self.index(of: element) else { return }
        remove(at: i)
    }
    
    mutating func remove(_ option: (Element)->Bool) {
        let elements = self.filter(option)
        elements.forEach{self.remove($0)}
    }
    
}

extension Array {
    func element(_ option: (Element)->Bool) -> Element? {
        let elements = self.filter { option($0)}
        guard let item = elements.first, elements.count == 1 else {
            return nil
        }
        return item
    }
}
