import SwiftUI

struct AdaptiveBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                Image(colorScheme == .dark ? "background" : "background_light")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(.all)
            )
    }
}

extension View {
    func adaptiveBackground() -> some View {
        modifier(AdaptiveBackgroundModifier())
    }
}