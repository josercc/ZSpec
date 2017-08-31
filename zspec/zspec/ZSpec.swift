//
//  ZSpec.swift
//  zspec
//
//  Created by 张行 on 2017/8/31.
//  Copyright © 2017年 张行. All rights reserved.
//


import Foundation

class ZSpec {
    struct Name:RawRepresentable {
        typealias RawValue = String
        var rawValue: String
        public init (rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    var specName:String?
    var summary:String?
    var deploymentTarget:String = "8.0"
    var license:String = "MIT"
    var version:String = "1.0.0"
    var homepage:String?
    var authorName:String?
    var authorEmail:String?
    var source:String?
    var rootPath:String? = ProcessInfo.processInfo.environment["PWD"]
    var dependency:[String] = []
    var commandLineTool = CommandLineTools()
    func canParse() -> Bool {
        if canParseCommandLine(command: "--init", description: "用于初始化创建 spec 文件") {
            setupSpec()
            return true
        }
        if parseStore(key: ZSpec.Name.homePage, description: "设置介绍的首页") {
            return true
        }
        if parseStore(key: ZSpec.Name.license, description: "设置协议类型默认为 MIT") {
            return true
        }
        if parseStore(key: ZSpec.Name.authorName, description: "设置作者名称") {
            return true
        }
        if parseStore(key: ZSpec.Name.authorEmail, description: "设置作者邮箱") {
            return true
        }
        if parseStore(key: ZSpec.Name.source, description: "设置 Spec 的 SVN 地址") {
            return true
        }
        if canParseCommandLine(command: "--add", description: "增加依赖") {
            if let vaue = parseCommand().value {
                dependency.append(vaue)
            }
            return true
        }
        if canParseCommandLine(command: "--remove", description: "移除依赖") {
            if let vaue = parseCommand().value, let index = dependency.index(of: vaue) {
                dependency.remove(at: index)
            }
            return true
        }
        if canParseCommandLine(command: "--save", description: "执行重新保存") {
            save()
            return true
        }
        if canParseCommandLine(command: "--clear", description: "清除本地保存的信息") {
            return false
        }
        return false
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: ZSpec.Name.homePage.rawValue)
        UserDefaults.standard.removeObject(forKey: ZSpec.Name.authorName.rawValue)
        UserDefaults.standard.removeObject(forKey: ZSpec.Name.authorEmail.rawValue)
        UserDefaults.standard.removeObject(forKey: ZSpec.Name.license.rawValue)
        UserDefaults.standard.removeObject(forKey: ZSpec.Name.source.rawValue)
    }
    
    func setupSpec() {
        print("请输入你Spec名称:")
        specName = readLine(strippingNewline:true) ?? specName
        print("请输入描述:")
        summary = readLine(strippingNewline:true) ?? summary
        save()
    }
    
    func check() -> Bool {
        guard homepage != nil else {
            print("请使用--\(ZSpec.Name.homePage.rawValue)设置首页地址")
            return false
        }
        guard specName != nil else {
            print("请使用--init 先初始化")
            return false
        }
        guard summary != nil else {
            print("请使用--init 先初始化")
            return false
        }
        guard authorName != nil else {
            print("请使用--\(ZSpec.Name.authorName.rawValue)设置作者名称")
            return false
        }
        guard authorEmail != nil else {
            print("请使用--\(ZSpec.Name.authorEmail.rawValue)设置作者的邮箱")
            return false
        }
        guard source != nil else {
            print("请使用--\(ZSpec.Name.source.rawValue)设置 Spec 的源")
            return false
        }
        guard rootPath != nil else {
            print("请使用--init 初始化")
            return false
        }
        return true
    }
    
    func save() {
        homepage = UserDefaults.standard[ZSpec.Name.homePage]
        if homepage == nil {
            print("请设置首页:")
            homepage = readLine(strippingNewline: true) ?? homepage
            UserDefaults.standard[ZSpec.Name.homePage] = homepage
        }
        license = UserDefaults.standard[ZSpec.Name.license] ?? license
        authorName = UserDefaults.standard[ZSpec.Name.authorName]
        if authorName == nil {
            print("请先设置作者名称:")
            authorName = readLine(strippingNewline: true) ?? authorName
            UserDefaults.standard[ZSpec.Name.authorName] = authorName
        }
        authorEmail = UserDefaults.standard[ZSpec.Name.authorEmail]
        if authorEmail == nil {
            print("请先设置作者的邮箱:")
            authorEmail = readLine(strippingNewline: true) ?? authorEmail
            UserDefaults.standard[ZSpec.Name.authorEmail] = authorEmail
        }
        source = UserDefaults.standard[ZSpec.Name.source]
        if source == nil {
            print("请先设置 Spec源:")
            source = readLine(strippingNewline: true) ?? source
            UserDefaults.standard[ZSpec.Name.source] = source
        }
        var specContent:String = ""
        specContent += "Pod::Spec.new do |s|\n"
        specContent += "  s.name             = '\(specName!)'\n"
        specContent += "  s.version          = '1.0.0'\n"
        specContent += "  s.summary          = '\(summary!)'\n"
        specContent += "  s.homepage         = '\(homepage!)'\n"
        specContent += "  s.license          = { :type => '\(license)', :file => 'LICENSE' }\n"
        specContent += "  s.author           = { '\(authorName!)' => '\(authorEmail!)' }\n"
        specContent += "  s.source           = { :svn => '\(source!)/\(specName!)', :tag => s.version.to_s }\n"
        specContent += "  s.ios.deployment_target = '\(deploymentTarget)'\n"
        specContent += "  s.source_files = '\(specName!)/\(specName!)/Classes/**/*'"
        for de in dependency {
            specContent += "  s.dependency '\(de)'\n"
        }
        specContent += "end"
        try? specContent.write(toFile: "\(rootPath!)/\(specName!).podspec", atomically: true, encoding: String.Encoding.utf8)
    }
    
    func parseStore(key:ZSpec.Name, description:String) -> Bool {
        if canParseCommandLine(command: "--\(key.rawValue)", description: description) {
            UserDefaults.standard[key] = parseCommand().value
            return true
        }
        return false
    }
    
    func parseCommand() -> (name:String?, value:String?) {
        guard CommandLine.argc > 1 else {
            return (nil,nil)
        }
        let name = CommandLine.arguments[1]
        guard CommandLine.argc > 2 else {
            return (name,nil)
        }
        let value = CommandLine.arguments[2]
        return (name,value)
    }
    
    /// command commandName commandValue commandName commandValue
    func canParseCommandLine(command:String, description:String) -> Bool {
        commandLineTool.commands.append((command,description))
        let p = parseCommand()
        guard let name = p.name else {
            return false
        }
        guard name == command else {
            return false
        }
        return true
    }

}

extension UserDefaults {
    subscript(key:ZSpec.Name) -> String? {
        get {
            return string(forKey: key.rawValue)
        }
        set {
            set(newValue, forKey: key.rawValue)
        }
    }
}

extension ZSpec.Name {
    static let homePage:ZSpec.Name = ZSpec.Name(rawValue: "homePage")
    static let license:ZSpec.Name = ZSpec.Name(rawValue: "license")
    static let authorName:ZSpec.Name = ZSpec.Name(rawValue: "authorName")
    static let authorEmail:ZSpec.Name = ZSpec.Name(rawValue: "authorEmail")
    static let source:ZSpec.Name = ZSpec.Name(rawValue: "source")
}



struct CommandLineTools {
    var commands:[(String,String)] = []
    func printCommand() -> String {
        var commandContent = ""
        for command in commands {
            commandContent += "\(command.0)   \(command.1)\n"
        }
        return commandContent
    }
}
