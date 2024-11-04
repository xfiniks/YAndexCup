import SwiftUI

struct DrawingView: View {
    
    @EnvironmentObject var sketch: Sketch
    @EnvironmentObject var drawingSettings: DrawingSettings
    
    @State var isPlaying = false
    @State var canvasSize: CGSize = .zero
    
    @State var shoudShowFiguresView = false
    @State var shoudShowAnimationsSettings = false
    @State var shouldShowFramesGenerator = false
    @State var shouldShowShareSheet = false
    
    @Binding var canvas: CanvasData
    @Binding var isShowingFullScreen: Bool
    
    var animation: Namespace.ID
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                controlsView
                
                Menu {
                    Button(action: {
                        shoudShowAnimationsSettings.toggle()
                    }) {
                        Text("Настройка скорости анимации")
                    }
                    
                    Button {
//                        DispatchQueue.global(qos: .userInitiated).async {
//                            if let url = CanvasGif.createGIF(canvasDatas: sketch.canvasDatas, size: canvasSize, drawingSettings: drawingSettings) {
//                                DispatchQueue.main.async {
//                                    shareGIF(url: url)
//                                }
//                            }
//                        }
                        shouldShowShareSheet = true
                    } label: {
                      Text("Экспорт GIF")
                    }
                    
                    if !isPlaying {
                        Button(action: {
                            shoudShowFiguresView.toggle()
                        }) {
                            Label("Добавление фигур", systemImage: shoudShowFiguresView ? "checkmark.circle.fill" : "circle")
                        }
                        
                        Button(action: {
                            sketch.removeAll()
                        }) {
                            Text("Удалить все кадры")
                        }
                        
                        Button(action: {
                            sketch.duplicate()
                        }) {
                            Text("Дублировать текущий кадр")
                        }
                        
                        Button(action: {
                            shouldShowFramesGenerator.toggle()
                        }) {
                            Text("Генерация кадров")
                        }
                    }
                 } label: {
                     Image(systemName: "ellipsis.circle")
                         .resizable()
                         .frame(width: 24, height: 24)
                         .foregroundStyle(.pink)
                 }
            }
            
            Spacer(minLength: 24)
            
            if isPlaying {
                VStack {
                    HStack {
                        Text("Просмотр")
                        
                        Spacer()
                    }
                    
                    AnimationView(
                        canvases: sketch.canvasDatas,
                        animationSpeed: drawingSettings.animationSpeed
                    )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            else {
                HStack {
                    Text("Кадр: \(canvas.id + 1)")
                        .matchedGeometryEffect(id: "title_\(canvas.id)", in: animation)
                    
                    Spacer()
                }
                
                CanvasView(
                    shouldShowFiguresView: shoudShowFiguresView,
                    canvasData: canvas,
                    lastCanvas: sketch.findCanvas(before: canvas, loop: false)
                )
                .contentSize(in: $canvasSize)
                
            }
            
            Spacer(minLength: 24)
            
            ToolsView(isPlaying: isPlaying)
                .disabled(isPlaying)
        }
        .sheet(isPresented: $shoudShowAnimationsSettings) {
            VStack {
                Text("Частота смены кадров: \(String(format: "%.2f", drawingSettings.animationSpeed)) с")
                    .font(.headline)
                    .padding()
                
                Slider(value: $drawingSettings.animationSpeed, in: 0.1...3, step: 0.1)
                    .padding()
                
                Button("Закрыть") {
                    shoudShowAnimationsSettings = false
                }
                .foregroundStyle(.pink)
                .padding()
            }
            .presentationDetents([.height(200)])
        }
        .sheet(isPresented: $shouldShowFramesGenerator) {
            VStack {
                Text("Генерация кадров")
                    .font(.title)
                    .padding(.bottom, 24)
                    .padding(.top, 10)
                
                Text("Количество кадров: \(Int(sketch.frameNumberForGeneration))")
                    .font(.headline)
                    .padding()
                
                Slider(value: $sketch.frameNumberForGeneration, in: 0...100, step: 1)
                    .padding()
                
                Button("Сгенерировать") {
                    sketch.generateFrames(x: canvasSize.width, y: canvasSize.height)
                }
                .foregroundStyle(.pink)
                .padding()
                
                Button("Закрыть") {
                    shouldShowFramesGenerator = false
                }
                .foregroundStyle(.gray)
                .padding()
            }
            .presentationDetents([.height(350)])
        }
        .sheet(isPresented: $shouldShowShareSheet) {
            if let url = CanvasGif.createGIF(canvasDatas: sketch.canvasDatas, size: canvasSize, drawingSettings: drawingSettings) {
                ShareSheet(activityItems: [url])
            }
        }
        .animation(.easeIn, value: isPlaying)
        .padding(.all, 16)
        
    }
    
    var controlsView: some View {
        ControlsView(
            isPreviousEnabled: canvas.canReturn && !isPlaying,
            isNextEnabled: canvas.canGoForward && !isPlaying,
            isBinEnabled: sketch.canClear && !isPlaying,
            isAddEnabled: sketch.canAdd && !isPlaying,
            isLayersEnabled: !isPlaying,
            isPauseEnabled: isPlaying,
            isPlayEnabled: !isPlaying,
            onTapPrevious: canvas.back ,
            onTapNext: canvas.forward,
            onTapBin:  { sketch.remove(sketch.currentCanvas) },
            onTapAdd: sketch.add,
            onTapLayers: { isShowingFullScreen = false },
            onTapPause: { isPlaying = false },
            onTapPlay: { isPlaying = true }
        )
    }
    
}

struct ShareSheet: UIViewControllerRepresentable {
    
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void

    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
    
}

//#Preview {
//    
//    @Namespace var animation
//    
//    return DrawingView(
//        canvas: .constant(.init(id: 1)),
//        isShowingFullScreen: .constant(true), animation: animation
//    )
//    .environmentObject(DrawingSettings())
//    .environmentObject(Sketch())
//}
