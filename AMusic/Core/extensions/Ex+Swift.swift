// MARK: - LibSwift Extensions

// MARK: - General Array Extensions
extension Array{
    
    /// Retrieve the element without causing an index error.
    /// If the index does not exist, nil is returned.
    ///
    /// - Parameter index: Index of the element to retrieve.
    /// - Returns: Elements retrieved
    func at(_ index:Int)->Element?{
        return self.indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Equatable Elements Array Extensions
extension Array where Element: Equatable {
    
    /// Returns an array without duplication.
    var unique: [Element] {return reduce([]) {$0.contains($1) ? $0 : $0 + [$1]}}
    
    /// Remove a specific element from the array.
    ///
    /// - Parameter element: Element to removed
    /// - Returns: Removed element
    @discardableResult mutating func remove(of element:Element)->Element?{
        if let index = index(of: element){
            return remove(at: index)
        }
        return nil
    }
}


// MARK: - String Extensions
extension String{
    
    /// Returns a string from which a specific character string has been removed.
    ///
    /// - Parameter item: String to delete.
    /// - Returns: String with specific String removed.
    func removed(_ item:String)->String{
        return self.replacingOccurrences(of: item, with: "")
    }
    
    /// Remove the String contained in the given array.
    ///
    /// - Parameter items: Array of strings to remove.
    /// - Returns: String with specific String removed.
    func removed(items:[String])->String{
        var result = self
        for item in items{
            result = result.removed(item)
        }
        return result
    }
}









