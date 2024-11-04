import SwiftUI

struct ControlsView: View {
    
    typealias Action = () -> Void
    
    let isPreviousEnabled: Bool
    let isNextEnabled: Bool
    let isBinEnabled: Bool
    let isAddEnabled: Bool
    let isLayersEnabled: Bool
    let isPauseEnabled: Bool
    let isPlayEnabled: Bool
    
    let onTapPrevious: Action
    let onTapNext: Action
    let onTapBin: Action
    let onTapAdd: Action
    let onTapLayers: Action
    let onTapPause: Action
    let onTapPlay: Action
    
    init(
        isPreviousEnabled: Bool,
        isNextEnabled: Bool,
        isBinEnabled: Bool,
        isAddEnabled: Bool,
        isLayersEnabled: Bool,
        isPauseEnabled: Bool,
        isPlayEnabled: Bool,
        onTapPrevious: @escaping Action,
        onTapNext: @escaping Action,
        onTapBin: @escaping Action,
        onTapAdd: @escaping Action,
        onTapLayers: @escaping Action,
        onTapPause: @escaping Action,
        onTapPlay: @escaping Action
    ) {
        self.isPreviousEnabled = isPreviousEnabled
        self.isNextEnabled = isNextEnabled
        self.isBinEnabled = isBinEnabled
        self.isAddEnabled = isAddEnabled
        self.isLayersEnabled = isLayersEnabled
        self.isPauseEnabled = isPauseEnabled
        self.isPlayEnabled = isPlayEnabled
        
        self.onTapPrevious = onTapPrevious
        self.onTapNext = onTapNext
        self.onTapBin = onTapBin
        self.onTapAdd = onTapAdd
        self.onTapLayers = onTapLayers
        self.onTapPause = onTapPause
        self.onTapPlay = onTapPlay
    }
    
    var body: some View {
        HStack {
            HStack(spacing: 16) {
                Button {
                    onTapPrevious()
                } label: {
                    Image(.previousArrow)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .foregroundStyle(isPreviousEnabled ? .pink : .gray)
                .disabled(!isPreviousEnabled)
                
                Button {
                    onTapNext()
                } label: {
                    Image(.nextArrow)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .foregroundStyle(isNextEnabled ? .pink : .gray)
                .disabled(!isNextEnabled)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button {
                    onTapBin()
                } label: {
                    Image(.bin)
                }
                .foregroundStyle(isBinEnabled ? .pink : .gray)
                .disabled(!isBinEnabled)
                
                Button {
                    onTapAdd()
                } label: {
                    Image(.addPage)
                }
                .foregroundStyle(isAddEnabled ? .pink : .gray)
                .disabled(!isAddEnabled)
                
                Button {
                    onTapLayers()
                } label: {
                    Image(.layers)
                }
                .foregroundStyle(isLayersEnabled ? .pink : .gray)
                .disabled(!isLayersEnabled)
            }
            
            Spacer()
            
            if isPlayEnabled {
                Button {
                    onTapPlay()
                } label: {
                    Image(.play)
                }
                .foregroundStyle(.pink)
            }
            else {
                Button {
                    onTapPause()
                } label: {
                    Image(.pause)
                }
                .foregroundStyle(.pink)
                .disabled(!isPauseEnabled)
            }
            
//            HStack(spacing: 16) {
//                Button {
//                    onTapPause()
//                } label: {
//                    Image(.pause)
//                }
//                .foregroundStyle(isPauseEnabled ? .pink : .gray)
//                .disabled(!isPauseEnabled)
//                
//                Button {
//                    onTapPlay()
//                } label: {
//                    Image(.play)
//                }
//                .foregroundStyle(isPlayEnabled ? .pink : .gray)
//                .disabled(!isPlayEnabled)
//            }
        }
    }
    
}

#Preview {
    ControlsView(
        isPreviousEnabled: true,
        isNextEnabled: true,
        isBinEnabled: true,
        isAddEnabled: true,
        isLayersEnabled: true,
        isPauseEnabled: true,
        isPlayEnabled: true,
        onTapPrevious: {},
        onTapNext: {},
        onTapBin: {},
        onTapAdd: {},
        onTapLayers: {},
        onTapPause: {},
        onTapPlay: {}
    )
}
