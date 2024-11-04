import SwiftUI

struct ToolsView: View {
    
    let isPlaying: Bool
    
    @EnvironmentObject var drawingSettings: DrawingSettings
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                drawingSettings.drawingTool = .pencil
            } label: {
                Image(.pencil)
                    .foregroundStyle(
                        isPlaying
                        ? .gray
                        : drawingSettings.drawingTool == .pencil
                            ? .pink
                            : .secondary
                    )
            }
            
            Button {
                drawingSettings.drawingTool = .eraser
            } label: {
                Image(.eraser)
                    .foregroundStyle(
                        isPlaying
                        ? .gray
                        : drawingSettings.drawingTool == .eraser
                            ? .pink
                            : .secondary
                    )
            }
            
            ColorPicker("", selection: $drawingSettings.color)
                .labelsHidden()
            
            Slider(value: $drawingSettings.lineWidth, in: 1...10, step: 1)
        }
    }
    
}

#Preview {
    ToolsView(isPlaying: false)
        .environmentObject(DrawingSettings())
}
