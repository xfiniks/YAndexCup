import SwiftUI

@Observable
final class CanvasData: Identifiable {
    
    struct CanvasPath {
        var id = UUID()
        var path: Path
        let color: Color
        let lineWidth: CGFloat
        let drawingTool: DrawingTool
        var figureDraggable: DraggableModel?
        var startPoint: CGPoint = .zero
        var endPoint: CGPoint = .zero
        let x: CGFloat
        let y: CGFloat
    }
    
    var id: Int
    var paths: [CanvasPath]
    
    private var buffer: [CanvasPath] = []
    
    init(id: Int, paths: [CanvasPath] = []) {
        self.id = id
        self.paths = paths
    }
    
    var canReturn: Bool {
        !paths.isEmpty
    }
    
    var canGoForward: Bool {
        !buffer.isEmpty
    }
    
    func clearBuffer() {
        buffer.removeAll()
    }
    
    func back() {
        guard let element = paths.popLast() else {
            return
        }
        
        buffer.append(element)
    }
    
    func forward() {
        guard let element = buffer.popLast() else {
            return
        }
        
        paths.append(element)
    }
    
    func clear() {
        paths.removeAll()
        buffer.removeAll()
    }
    
    static func createShapePath(start: CGPoint, end: CGPoint, type: ShapeType) -> Path {
        let rect = CGRect(
            origin: start,
            size: CGSize(
                width: end.x - start.x,
                height: end.y - start.y
            )
        ).standardized
        
        var path = Path()
        
        switch type {
        case .rectangle:
            path.addRect(rect)
            
        case .circle:
            path.addEllipse(in: rect)
            
        case .triangle:
            let midX = rect.midX
            let minY = rect.minY
            let maxX = rect.maxX
            let maxY = rect.maxY
            let minX = rect.minX
            
            path.move(to: CGPoint(x: midX, y: minY))
            path.addLine(to: CGPoint(x: maxX, y: maxY))
            path.addLine(to: CGPoint(x: minX, y: maxY))
            path.closeSubpath()
        }
        
        return path
    }
    
}

extension CanvasData: Equatable {
    
    static func == (lhs: CanvasData, rhs: CanvasData) -> Bool {
        lhs.id == rhs.id
    }
    
}
