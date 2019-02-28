import Foundation

// Path (c) obuchiyuki 2016.
// これも古いんだけどね... 消せないんっすよ...
// 依存により消せないというか、これはいまでも使ってるよね...

///旧 `RMPath`
struct Path{
    private var rawPath:String
    init(path:String) {
        rawPath = path
    }
}
extension Path{
    private var ns:NSString{
        return self.rawPath as NSString
    }
    enum PathType{
        case file
        case folder
        case notExist
    }
    var type:PathType{
        var isDir:ObjCBool = true
        let isExists = FileManager.default.fileExists(atPath: rawPath, isDirectory: &isDir)
        if isExists{
            return isDir.boolValue ? PathType.folder : PathType.file
        }else{
            return PathType.notExist
        }
    }
    var items:[Path]{
        return try! FileManager.default.contentsOfDirectory(atPath: rawPath).map{Path(path: $0)}
    }
    var fileName:String{
         return ns.lastPathComponent
    }
    var fileNameWithoutExtension:String {
        return NSURL(fileURLWithPath: rawPath).deletingPathExtension?.lastPathComponent ?? ""
    }
    var isExists:Bool{
        return FileManager.default.fileExists(atPath: rawPath)
    }
    var url: URL{
        return URL(fileURLWithPath: rawPath)
    }
    var path: String{
        return rawPath
    }
    func added(exp next:String)->Path{
        return Path(path: rawPath+"."+next)
    }
    func added(_ next:String)->Path{
        return Path(path: rawPath+"/"+next)
    }
}
extension Path{
    static var document:Path{
        return Path(path: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
    }
    static var user:Path{
        return Path(path: NSSearchPathForDirectoriesInDomains(.userDirectory, .userDomainMask, true).first!)
    }
    static var cache:Path{
        return Path(path: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!)
    }
}


extension FileManager{
    func move(from fromPath:Path, to targetPath:Path){
        try? moveItem(atPath: fromPath.path, toPath: targetPath.path)
    }
    func mkDir(at path:Path){
        try? self.createDirectory(atPath: path.path, withIntermediateDirectories: true)
    }
    func remove(at path:Path){
        try? FileManager.default.removeItem(atPath: path.path)
    }
    func write(at path:Path, data:Data){
        self.createFile(atPath: path.path, contents: data)
    }
    func read(at path:Path)->Data?{
        return try? Data(contentsOf: path.url)
    }
}


