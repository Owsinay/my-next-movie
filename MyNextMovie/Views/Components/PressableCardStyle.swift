import SwiftUI

private let pressedScale: CGFloat = 0.96
private let pressAnimation = Animation.spring(duration: 0.25, bounce: 0.3)

/// Shrinks a tappable card a little while the finger is on it,
/// so the tap feels physical without the default highlight.
struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(.rect)
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(pressAnimation, value: configuration.isPressed)
    }
}
