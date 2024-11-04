import SwiftUI

final class Sketch: ObservableObject {
 
    @Published var canvasDatas: [CanvasData] {
        didSet {
            recalculateIndices()
        }
    }
    
    @Published var frameNumberForGeneration: CGFloat = 1
    
    var currentCanvas: CanvasData
    
    var topCanvas: CanvasData {
        canvasDatas.last ?? CanvasData(id: 0)
    }
    
    var canClear: Bool {
        canvasDatas.count > 1 || !currentCanvas.paths.isEmpty
    }
    
    var canAdd: Bool {
        canvasDatas.count < Int.max
    }
    
    init(canvasDatas: [CanvasData] = []) {
        let currentCanvas: CanvasData
        if canvasDatas.isEmpty {
            currentCanvas = .init(id: 0, paths: [])
            self.canvasDatas = [currentCanvas]
        } else {
            self.canvasDatas = canvasDatas
            currentCanvas = canvasDatas.last ?? .init(id: 0)
        }
        
        self.currentCanvas = currentCanvas
    }
    
    func generateFrames(x: CGFloat, y: CGFloat) {
        var newFrames: [CanvasData] = []
        
        for i in 0..<Int(frameNumberForGeneration) {
            let startPoint = randomCGPoint(maxX: x, maxY: y)
            let endPoint = randomCGPoint(maxX: x, maxY: y)
            let type: ShapeType = .allCases.randomElement() ?? .rectangle
            
            let path = CanvasData.createShapePath(
                start: startPoint,
                end: endPoint,
                type: type
            )
            
            let id = UUID()
            
            let newCanvas: CanvasData = .init(
                id: canvasDatas.count + newFrames.count,
                paths: [
                    .init(
                        id: id,
                        path: path,
                        color: [.black, .white, .red, .green, .yellow].randomElement() ?? .black,
                        lineWidth: .random(in: 1...5),
                        drawingTool: .shape(type),
                        figureDraggable: .init(position: endPoint, id: id),
                        startPoint: startPoint,
                        endPoint: endPoint,
                        x: x,
                        y: y
                    )
                ]
            )
            
            newFrames.append(newCanvas)
        }
        
        canvasDatas.append(contentsOf: newFrames)
        
        frameNumberForGeneration = min(CGFloat(Int.max - canvasDatas.count), frameNumberForGeneration)
        currentCanvas = canvasDatas.last ?? currentCanvas
    }
    
    func randomCGPoint(maxX: CGFloat, maxY: CGFloat) -> CGPoint {
        let randomX = CGFloat.random(in: 0...maxX)
        let randomY = CGFloat.random(in: 0...maxY)
        
        return CGPoint(x: randomX, y: randomY)
    }

    
    func add() {
        guard let index = canvasDatas.firstIndex(of: currentCanvas) else {
            return
        }
        
        
        let newCanvas = CanvasData(id: canvasDatas.count)
        canvasDatas.insert(newCanvas, at: index + 1)
        
        currentCanvas = newCanvas
    }
    
    func remove(_ canvas: CanvasData) {
        if canvasDatas.count > 1 {
            let elementBefore = findCanvas(before: canvas)
            canvasDatas.removeAll { $0.id == canvas.id }
            
            currentCanvas = elementBefore
        }
        else {
            currentCanvas.clear()
        }
    }
    
    func removeAll() {
        for canvasData in canvasDatas.reversed() {
            remove(canvasData)
        }
        
        currentCanvas = canvasDatas.last ?? .init(id: 0)
    }
    
    func duplicate() {
        let index = canvasDatas.firstIndex(of: currentCanvas) ?? canvasDatas.endIndex - 1
        let copy = CanvasData(id: index + 1, paths: currentCanvas.paths)
        canvasDatas.insert(copy, at: index + 1)
        currentCanvas = copy
    }
    
    func findCanvas(after canvas: CanvasData, loop: Bool = true) -> CanvasData {
        canvasDatas.after(canvas, loop: loop) ?? .init(id: 0)
    }
    
    func findCanvas(before canvas: CanvasData, loop: Bool = true) -> CanvasData {
        canvasDatas.before(canvas, loop: loop) ?? .init(id: 0)
    }
    
    private func recalculateIndices() {
        canvasDatas.enumerated().forEach { offset, element in
            element.id = offset
        }
    }
    
}
