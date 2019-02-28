import Foundation

// MARK: - Foundation Extensions

protocol IDEquatable :Equatable{
    var id:UUID { get }
}
extension IDEquatable{
    static func == (lhs: Self, rhs: Self) -> Bool{
        return lhs.id == rhs.id
    }
}

// MARK: - Array Extesions in Foundation
extension Array{
    func shuffled() -> [Element] {
        var copied = Array<Element>(self)
        for i in 0..<copied.count {
            let j = Int(arc4random_uniform(UInt32(copied.indices.last!)))
            if i != j {copied.swapAt(i, j)}
        }
        return copied
    }
}

// MARK: - String Extesions in Foundation
extension String{
    private var ns:NSString{
        return NSString(string: self)
    }
    /// String converted to URL.
    var url:URL?{
        return URL(string: self)
    }
    /// String converted to File URL.
    var fileUrl:URL{
        return URL(fileURLWithPath: self)
    }
    func appending(path: String) -> String {
        return ns.appendingPathComponent(path)
    }
}
// MARK: - A NotificationCenter Extesion
extension NotificationCenter{
    /// For Easy Use.
    @discardableResult func addObserver(forName name: NSNotification.Name?, using block: @escaping ()->Void) -> NSObjectProtocol{
        return self.addObserver(forName: name, object: nil, queue: nil, using: {_ in block()})
    }
}

// MARK: - A Progress Extesion
extension Progress{
    /// Double Value of the progress
    var progress:Double{
        return Double(self.completedUnitCount)/Double(self.totalUnitCount)
    }
}


// MARK: - URLComponents Extesions
extension URLComponents{
    /// UrlParamators converted to Dictionary type.
    var paramators:[String:String]{
        return self.queryItems?.reduce(into: [String:String]()){$0[$1.name] = $1.value ?? ""} ?? [:]
    }
}
