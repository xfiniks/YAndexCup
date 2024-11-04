import SwiftUI
import ImageIO
import MobileCoreServices

final class CanvasGif {
    
    static func createGIF(
        canvasDatas: [CanvasData],
        size: CGSize,
        drawingSettings: DrawingSettings
    ) -> URL? {
        
        var data: [CanvasData] = []
        
        for i in 0..<min(canvasDatas.count, 100) {
            data.append(canvasDatas[i])
        }
            
        let fileProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFLoopCount: 1
            ]
        ]
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: drawingSettings.animationSpeed
            ]
        ]
        
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        let url = documentsDirectory.appendingPathComponent("draw.gif")
        
        guard let destination = CGImageDestinationCreateWithURL(
            url as CFURL,
            kUTTypeGIF,
            data.count,
            nil
        ) else {
            return nil
        }
        
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
        
        for canvasData in data {
            if let cgImage = renderCanvasData(
                canvasData,
                size: size,
                drawingSettings: drawingSettings
            )?.cgImage {
                CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
            }
        }
        
        if CGImageDestinationFinalize(destination) {
            return url
        } else {
            return nil
        }
    }
    
    private static func renderCanvasData(
        _ canvasData: CanvasData,
        size: CGSize,
        drawingSettings: DrawingSettings
    ) -> UIImage? {
        
        let canvasView = CanvasView(
            shouldShowFiguresView: false,
            canvasData: canvasData,
            lastCanvas: nil,
            isDrawingEnabled: false,
            needBackground: true
        ).environmentObject(drawingSettings)
        
        let controller = UIHostingController(rootView: canvasView)
        let view = controller.view!
        
        view.bounds = CGRect(origin: .zero, size: size)
        view.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
