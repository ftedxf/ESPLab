import SwiftUI

struct FloatingButton: View {
    @Binding var isOpen: Bool
    @State private var offset: CGSize = .zero
    @GestureState private var drag: CGSize = .zero

    var body: some View {
        ZStack {
            Circle().fill(Theme.gradient)
            Image(systemName: isOpen ? "xmark" : "slider.horizontal.3")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(isOpen ? 90 : 0))
        }
        .frame(width: 56, height: 56)
        .shadow(color: Theme.accent.opacity(0.55), radius: 14, y: 6)
        .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
        .offset(x: offset.width + drag.width, y: offset.height + drag.height)
        .gesture(
            DragGesture()
                .updating($drag) { value, state, _ in state = value.translation }
                .onEnded { value in
                    offset.width += value.translation.width
                    offset.height += value.translation.height
                }
        )
        .onTapGesture {
            Haptics.tap()
            withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) { isOpen.toggle() }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isOpen)
    }
}
