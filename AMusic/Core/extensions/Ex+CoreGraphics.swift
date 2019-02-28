import CoreGraphics

// MARK: - CoreGraphics Extensions

// MARK: - Make initable with array
/// CGPoint,CGSize,CGRectの配列初期化用
///
/// Sample:
/// let hogePoint:CGPoint = [100, 100] // CGPoint(100, 100)
/// let fugaSize:CGSize = [200, 200] // CGSize(200, 200)
/// let piyoRect:CGRect = [50, 50, 300, 300] // CGRect(50, 50, 300, 300)
///
/// If there are not enough elements in the array, Out of Index Error causes the application to crash.
/// 配列の要素数が足りなかった場合 Out of Index Error で落ちます。
///
extension CGPoint: ExpressibleByArrayLiteral{
    public typealias ArrayLiteralElement = CGFloat
    
    public init(arrayLiteral elements: CGPoint.ArrayLiteralElement...) {
        self.init(x: elements[0], y: elements[1])
    }
}
extension CGSize:ExpressibleByArrayLiteral{
    public typealias ArrayLiteralElement = CGFloat
    
    public init(arrayLiteral elements: CGSize.ArrayLiteralElement...) {
        self.init(width: elements[0], height: elements[1])
    }
}
extension CGRect: ExpressibleByArrayLiteral{
    public typealias ArrayLiteralElement = CGFloat
    
    public init(arrayLiteral elements: CGRect.ArrayLiteralElement...) {
        self.init(x: elements[0], y: elements[1], width: elements[2], height: elements[3])
    }
}

// MARK: - A CGRect Extension
extension CGRect{
    ///Center of the Rect
    var center:CGPoint{
        let x = self.origin.x + self.size.width/2.0
        let y = self.origin.y + self.size.height/2.0
        
        return CGPoint(x: x, y: y)
    }
}


// MARK: - CGSize Operators

func * (lhs: CGSize, rhs: Double) -> CGSize {
    return CGSize(width: lhs.width*CGFloat(rhs), height: lhs.height*CGFloat(rhs))
}
func * (lhs: CGSize, rhs: Int) -> CGSize {
    return CGSize(width: lhs.width*CGFloat(rhs), height: lhs.height*CGFloat(rhs))
}
func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width*rhs, height: lhs.height*rhs)
}












