import SwiftUI
import Combine

struct AnimationView: View {
    
    let canvases: [CanvasData]
    
    @State private var currentFrameIndex: Int = 0
    @State private var isAnimating: Bool = false
    
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    init(canvases: [CanvasData], animationSpeed: CGFloat) {
        self.canvases = canvases
        
        timer =  Timer.publish(every: animationSpeed, on: .main, in: .common).autoconnect()
    }
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for path in canvases[currentFrameIndex].paths {
                    context.stroke(
                        path.path,
                        with: .color(path.color),
                        lineWidth: path.lineWidth
                    )
                }
            }
        }
        .background(
            Image(.paper)
                .resizable()
                .ignoresSafeArea()
        )
        .onReceive(timer) { _ in
            if isAnimating {
                updateFrame()
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    
    private func updateFrame() {
        withAnimation {
            currentFrameIndex = (currentFrameIndex + 1) % canvases.count
        }
    }
    
    private func startAnimation() {
        isAnimating = true
    }
    
    private func stopAnimation() {
        isAnimating = false
    }
}

struct DemonstratetView: View {
    let frames: [CanvasData] = [
        .init(id: 0, paths: [
            .init(path:Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 100, y: 100))
            }, color: .black, lineWidth: 2, drawingTool: .pencil, x: 0, y: 0)
        ]),
        .init(id: 1, paths: [
            .init(path: Path { path in
                path.move(to: CGPoint(x: 100, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 100))
            }, color: .black, lineWidth: 2, drawingTool: .pencil, x: 0, y: 0)
        ])
    ]
    
    var body: some View {
        AnimationView(canvases: frames, animationSpeed: 0.25)
            .frame(width: 200, height: 200)
    }
}

#Preview {
    DemonstratetView()
}
