import SwiftUI

/// Example view demonstrating ESPN's Liquid Glass design system
@available(iOS 17.0, *)
struct LiquidGlassExamples: View {
    @State private var isGlassEnabled = true
    @State private var selectedDensity: ESPNGlassDensity = .medium
    
    var body: some View {
        NavigationStack {
            ScrollView (.vertical, showsIndicators: true){
                VStack(spacing: 24) {
                    // MARK: - Basic Glass Effect
                    GroupBox("Basic Glass Effect") {
                        Text("Hello, Liquid Glass!")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .espnGlassEffect(
                                density: selectedDensity,
                                isEnabled: isGlassEnabled
                            )
                    }
                    // MARK: - Interactive Glass Button
                    GroupBox("Glass Button Style") {
                        HStack(spacing: 16) {
                            Button("Cancel") {
                                print("Cancel tapped")
                            }
                            .espnGlassButtonStyle()
                            
                            Button("Confirm") {
                                print("Confirm tapped")
                            }
                            .espnGlassButtonStyle(density: .heavy)
                            .tint(.blue)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - Glass Effect Container
                    GroupBox("Glass Effect Container") {
                        if #available(iOS 18.0, *) {
                            ESPNGlassContainer(density: selectedDensity) {
                                VStack(spacing: 12) {
                                    Image(systemName: "star.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.yellow)
                                    
                                    Text("Morphable Glass")
                                        .font(.headline)
                                    
                                    Text("This container can morph between shapes")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                            }
                        } else {
                            // Fallback for iOS 17
                            VStack(spacing: 12) {
                                Image(systemName: "star.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.yellow)
                                
                                Text("Morphable Glass")
                                    .font(.headline)
                                
                                Text("This container can morph between shapes")
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .espnGlassCard(density: selectedDensity)
                        }
                    }
                    
                    // MARK: - Custom Glass Card
                    GroupBox("Custom Glass Card") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sportscourt")
                                    .font(.title2)
                                Spacer()
                                Text("LIVE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.red)
                            }
                            
                            Text("Lakers vs Warriors")
                                .font(.headline)
                            
                            Text("Q4 • 2:34 remaining")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Label("LAL", systemImage: "circle.fill")
                                    .foregroundColor(.purple)
                                Text("108")
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Text("102")
                                    .fontWeight(.bold)
                                Label("GSW", systemImage: "circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .font(.title3)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .espnGlassCard(density: selectedDensity)
                    }
                    
                    // MARK: - ESPN Glass Card Component
                    GroupBox("ESPN Glass Card Component") {
                        GlassCard(density: selectedDensity) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Game Highlights")
                                    .font(.headline)
                                Text("Top plays from tonight's game")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.blue)
                                    Spacer()
                                    Text("3:42")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Controls
                    GroupBox("Glass Effect Controls") {
                        VStack(spacing: 16) {
                            Toggle("Enable Glass Effects", isOn: $isGlassEnabled)
                                .tint(.blue)
                            
                            Picker("Glass Density", selection: $selectedDensity) {
                                Text("Light").tag(ESPNGlassDensity.light)
                                Text("Medium").tag(ESPNGlassDensity.medium)
                                Text("Heavy").tag(ESPNGlassDensity.heavy)
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // MARK: - Performance Optimized Glass (iOS 18+)
                    if #available(iOS 18.0, *) {
                        GroupBox("Performance Optimized Glass") {
                            VStack(spacing: 12) {
                                Text("Complex View with GPU Acceleration")
                                    .font(.headline)
                                
                                ForEach(0..<5) { _ in
                                    HStack {
                                        Circle()
                                            .fill(.blue.gradient)
                                            .frame(width: 40, height: 40)
                                        VStack(alignment: .leading) {
                                            Text("Optimized Item")
                                                .font(.subheadline)
                                            Text("Using GPU acceleration")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .espnOptimizedGlass(density: selectedDensity)
                        }
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("ESPN Glass Effects")
            .navigationBarTitleDisplayMode(.large)
            .espnGlassToolbar()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Info", systemImage: "info.circle") {
                        print("Info tapped")
                    }
                    .espnGlassButtonStyle(density: .light)
                }
            }
        }
    }
}

// MARK: - Fallback for iOS < 17
struct LiquidGlassExamplesFallback: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
                Text("iOS 17 Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("This example requires iOS 17 or later to demonstrate Liquid Glass effects.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                Text("Current iOS: \(UIDevice.current.systemVersion)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .navigationTitle("Glass Effects")
        }
    }
}

// MARK: - Main View with Version Check
struct iOS26GlassDemo: View {
    var body: some View {
        if #available(iOS 17.0, *) {
            LiquidGlassExamples()
        } else {
            LiquidGlassExamplesFallback()
        }
    }
}

// MARK: - Previews
#Preview("Liquid Glass Effects") {
    iOS26GlassDemo()
}

#Preview("Dark Mode") {
    iOS26GlassDemo()
        .preferredColorScheme(.dark)
}
