import SwiftUI

struct DraggableModel: Identifiable {
    var position: CGPoint
    var id: UUID
}

struct CanvasView: View {
    
    @EnvironmentObject var drawingSettings: DrawingSettings
    
    @State private var currentShape: CanvasShape?
    @State private var isDrawingShape: Bool = false
    @State private var startPoint: CGPoint?
    @State private var currentPath = Path()
    @State var shouldErase: Bool = false
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    @State private var lastOffset: CGSize = .zero
    
    @State var dragLocation: CGPoint?
    @State var currentDraggableID: UUID?
    
    let shouldShowFiguresView: Bool
    
    var canvasData: CanvasData
    let lastCanvas: CanvasData?
    
    var isDrawingEnabled = true
    var needBackground = true
    
    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                // last canvas
                
                if let lastCanvas {
                    for canvasPath in lastCanvas.paths {
                        switch canvasPath.drawingTool {
                        case .eraser:
                            context.blendMode = .clear
                            
                        case .pencil, .shape:
                            context.blendMode = .normal
                        }
                        
                        context.stroke(
                            canvasPath.path.applying(
                                .init(
                                    scaleX: proxy.size.width / canvasPath.x,
                                    y: proxy.size.height / canvasPath.y
                                )
                            ),
                            with: .color(canvasPath.color.opacity(0.5)),
                            lineWidth: canvasPath.lineWidth
                        )
                    }
                }
                
                for canvasPath in canvasData.paths {
                    switch canvasPath.drawingTool {
                    case .eraser:
                        context.blendMode = .clear
                        
                    case .pencil, .shape:
                        context.blendMode = .normal
                    }
                    
                    context.stroke(
                        canvasPath.path.applying(
                            .init(
                                scaleX: proxy.size.width / canvasPath.x,
                                y: proxy.size.height / canvasPath.y
                            )
                        ),
                        with: .color(canvasPath.color),
                        lineWidth: canvasPath.lineWidth
                    )
                }
                
                if let currentShape, let startPoint {
                    context.blendMode = .normal
                    let path = CanvasData.createShapePath(
                        start: startPoint,
                        end: currentShape.position,
                        type: currentShape.type
                    )
                    context.stroke(
                        path,
                        with: .color(currentShape.color),
                        lineWidth: drawingSettings.lineWidth / totalZoom
                    )
                } else if !currentPath.isEmpty {
                    if shouldErase {
                        context.blendMode = .clear
                    } else {
                        context.blendMode = .normal
                    }
                    
                    context.stroke(
                        currentPath,
                        with: .color(drawingSettings.color),
                        lineWidth: drawingSettings.lineWidth / totalZoom
                    )
                }
            }
            .onChange(of: drawingSettings.drawingTool) { oldTool, newTool in
                if case .eraser = newTool {
                    shouldErase = true
                } else {
                    shouldErase = false
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        if isDrawingEnabled {
                            if case .shape(let shapeType) = drawingSettings.drawingTool {
                                if !isDrawingShape {
                                    isDrawingShape = true
                                    startPoint = value.startLocation
                                    
                                    currentShape = CanvasShape(
                                        type: shapeType,
                                        position: value.location,
                                        size: .zero,
                                        color: drawingSettings.color
                                    )
                                } else {
                                    currentShape?.position = value.location
                                }
                            } else {
                                currentPath.addLine(to: value.location)
                            }
                        }
                    }
                    .onEnded { value in
                        if case .shape = drawingSettings.drawingTool {
                            if let shape = currentShape, let start = startPoint {
                                let end: CGPoint = value.location
                                
                                let path = CanvasData.createShapePath(
                                    start: start,
                                    end: end,
                                    type: shape.type
                                )
                                
                                
                                canvasData.paths.append(
                                    .init(
                                        id: shape.id,
                                        path: path,
                                        color: drawingSettings.color,
                                        lineWidth: drawingSettings.lineWidth / totalZoom,
                                        drawingTool: drawingSettings.drawingTool,
                                        figureDraggable: .init(
                                            position: end,
                                            id: shape.id
                                        ),
                                        startPoint: start,
                                        endPoint: end,
                                        x: proxy.size.width,
                                        y: proxy.size.height
                                    )
                                )
                                
                                
                            }
                            
                            isDrawingShape = false
                            currentShape = nil
                            startPoint = nil
                        } else {
                            canvasData.paths.append(
                                .init(
                                    path: currentPath,
                                    color: drawingSettings.color,
                                    lineWidth: drawingSettings.lineWidth / totalZoom,
                                    drawingTool: drawingSettings.drawingTool,
                                    x: proxy.size.width,
                                    y: proxy.size.height
                                )
                            )
                            currentPath = Path()
                        }
                        
                        canvasData.clearBuffer()
                    }
            )
            .background(
                background
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(currentZoom + totalZoom)
//            .gesture(
//                MagnifyGesture()
//                    .onChanged { value in
//                        if isDrawingEnabled {
//                            currentZoom = value.magnification - 1
//                        }
//                    }
//                    .onEnded { value in
//                        if isDrawingEnabled {
//                            let newZoom = max(1, totalZoom + currentZoom)
//                            
//                            totalZoom = min(3, newZoom)
//                            currentZoom = 0
//                        }
//                    }
//            )
            .onAppear {
                shouldErase = drawingSettings.drawingTool == .eraser
            }
            .overlay(
                figuresView(proxy: proxy)
            )
            
            // figuresDraggable
            if isDrawingEnabled {
                draggableViews()
            }
        }
        .clipped()
        
    }
    
    @ViewBuilder
    private var background: some View {
        if needBackground {
            Image("paper")
                .resizable()
        }
        else {
            Color.white
        }
    }
    
    @ViewBuilder
    private func draggableViews() -> some View {
        ForEach(canvasData.paths.compactMap { $0.figureDraggable }) { draggable in
            Circle()
                .foregroundStyle(.pink)
                .frame(
                    width: draggable.id == currentDraggableID ? 40 : 20,
                    height: draggable.id == currentDraggableID ? 40 : 20
                )
                .position(
                    position(for: draggable)
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if currentDraggableID == nil {
                                currentDraggableID = draggable.id
                            }
                            
                            dragLocation = value.location
                            
                            
                            if let index = canvasData.paths.firstIndex(where: { $0.id == draggable.id }) {
                                if canvasData.paths.indices.contains(index) {
                                    if case let .shape(type) = canvasData.paths[index].drawingTool {
                                        canvasData.paths[index].path = CanvasData.createShapePath(
                                            start: canvasData.paths[index].startPoint,
                                            end: value.location,
                                            type: type
                                        )
                                        
                                        canvasData.paths[index].endPoint = value.location
                                    }
                                }
                            }
                        }
                        .onEnded { value in
                            currentDraggableID = nil
                            dragLocation = nil
                        }
                )
        }

    }
    
    func position(for draggable: DraggableModel) -> CGPoint {
        let shape = canvasData.paths.first {
            $0.id == draggable.id
        }
        
        return shape?.endPoint ?? .zero
    }
        
    struct CircleView: View {
        
        let onDragChanged: (DragGesture.Value) -> Void
        let onDragEnded: (DragGesture.Value) -> Void
        
        @State var width: CGFloat = 20
        @State var height: CGFloat = 20
        
        var body: some View {
            Circle()
                .foregroundStyle(.pink)
                .frame(width: width, height: height)
                .gesture(
                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { value in
                            width = 45
                            height = 45
                            
                            onDragChanged(value)
                        }
                        .onEnded { value in
                            width = 30
                            height = 30
                            
                            onDragEnded(value)
                        }
                )
        }
        
    }
    
    @ViewBuilder
    private func figuresView(proxy: GeometryProxy) -> some View {
        if shouldShowFiguresView {
            VStack {
                Spacer()
                
                ShapeToolbar(onShapeSelected: { shapeType in
                    drawingSettings.drawingTool = .shape(shapeType)
                })
                .padding()
            }
        }
    }
    
}

enum ShapeType: Equatable, CaseIterable {
    case rectangle
    case circle
    case triangle
}

struct CanvasShape: Identifiable {
    let id = UUID()
    var type: ShapeType
    var position: CGPoint
    var size: CGSize
    var rotation: Double = 0
    var color: Color
}

struct ShapeToolbar: View {
    
    let onShapeSelected: (ShapeType) -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Button(action: { onShapeSelected(.rectangle) }) {
                Image(systemName: "rectangle")
                    .font(.title2)
            }
            
            Button(action: { onShapeSelected(.circle) }) {
                Image(systemName: "circle")
                    .font(.title2)
            }
            
            Button(action: { onShapeSelected(.triangle) }) {
                Image(systemName: "triangle")
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(10)
    }
    
}

#Preview {
    CanvasView(
        shouldShowFiguresView: false, canvasData: .init(id: 1, paths: []), lastCanvas: nil
    )
    .environmentObject(DrawingSettings())
}
