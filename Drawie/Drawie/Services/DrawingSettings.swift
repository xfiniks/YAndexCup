import SwiftUI

class DrawingSettings: ObservableObject {
    
    @Published var drawingTool: DrawingTool = .pencil
    @Published var color: Color = .black
    @Published var lineWidth: CGFloat = 1
    @Published var animationSpeed: CGFloat = 0.25
    
}
