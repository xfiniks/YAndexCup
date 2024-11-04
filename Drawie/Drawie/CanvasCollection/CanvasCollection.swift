import SwiftUI

struct CanvasMenu: View {
    
    @EnvironmentObject var sketch: Sketch
    @State var isShowingFullScreen = true
    
    @Namespace private var animation
    
    var body: some View {
        NavigationStack {
            content
        }
        .animation(.easeInOut, value: isShowingFullScreen)
    }
    
    @ViewBuilder
    private var content: some View {
        if isShowingFullScreen {
            DrawingView(
                canvas: $sketch.currentCanvas,
                isShowingFullScreen: $isShowingFullScreen,
                animation: animation
            )
        }
        else {
            tabsGridView
                .navigationTitle("Все кадры (\(sketch.canvasDatas.count))")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
        
    private var tabsGridView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(sketch.canvasDatas) { canvasData in
                        CanvasPreviewCell(
                            canvasData: canvasData,
                            namespace: animation,
                            onTap: {
                                withAnimation(.spring(duration: 0.25)) {
                                    sketch.currentCanvas = canvasData
                                    isShowingFullScreen = true
                                }
                            }
                        )
                        .id(canvasData.id)
                    }
                }
                .padding()
            }
            .onAppear {
                proxy.scrollTo(sketch.currentCanvas.id)
            }
        }
    }
}

struct CanvasPreviewCell: View {
    
    let canvasData: CanvasData
    var namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                CanvasView(shouldShowFiguresView: false, canvasData: canvasData, lastCanvas: nil, isDrawingEnabled: false)
//                    .matchedGeometryEffect(id: "background_\(canvasData.id)", in: namespace)
                    .aspectRatio(3/4, contentMode: .fill)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Кадр: \(canvasData.id + 1)")
//                    .matchedGeometryEffect(id: "title_\(canvasData.id)", in: namespace)
                    .font(.headline)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .contentShape(Rectangle())
        .highPriorityGesture(
        TapGesture()
            .onEnded(onTap)
        )
    }
    
}

#Preview {
    CanvasMenu()
        .environmentObject(DrawingSettings())
        .environmentObject(Sketch())
}
