import SwiftUI

struct SnapshotView<Content: View>: UIViewRepresentable {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIView {
        let controller = UIHostingController(rootView: content)
        let view = controller.view
        
        view?.backgroundColor = .clear
        view?.bounds = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        return view!
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
    
    static func renderAsImage(view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
