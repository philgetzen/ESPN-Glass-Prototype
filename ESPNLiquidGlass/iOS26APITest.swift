import SwiftUI

// Liquid Glass API Discovery Test File
// Use Xcode's autocomplete to see what's really available
// 
// NOTE: Apple's Liquid Glass design system is documented at:
// https://developer.apple.com/documentation/SwiftUI/View/glassEffect(_:in:isEnabled:)
// The actual implementation may vary based on iOS version and availability.

struct iOS26APITest: View {
    var body: some View {
        VStack {
            Text("Liquid Glass Effect Test")
                .padding()
                // Try typing .glassEffect to see if it's available in your iOS version
                
            
            // Test Material types
            Rectangle()
                .fill(.ultraThinMaterial)
                // Try .glassEffect or similar modifiers
                
            
            // Test button styles
            Button("Test Button") {
                print("Tapped")
            }
            // Try different button styles
            
        }
        .padding()
        // Try background modifiers here
        
    }
}

// Test available types and modifiers
extension View {
    func testModifiers() -> some View {
        self
            // Type . here and see what glass/liquid related modifiers appear
            
    }
}

#Preview {
    iOS26APITest()
}
