import SwiftUI

struct ESPNPlusView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // ESPN+ Branding
                    VStack(spacing: 16) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("ESPN+")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Stream exclusive live sports and ESPN+ originals")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 40)
                    
                    // Featured Content
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Featured on ESPN+")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<4) { index in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Rectangle()
                                            .fill(LinearGradient(
                                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .aspectRatio(3/4, contentMode: .fit)
                                            .frame(width: 180)
                                            .overlay(alignment: .topTrailing) {
                                                Text("ESPN+")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(
                                                        LinearGradient(
                                                            colors: [Color.blue, Color.purple],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .cornerRadius(4)
                                                    .padding(8)
                                            }
                                        
                                        Text(["30 for 30", "UFC Fight Night", "La Liga", "NHL Games"][index])
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                        
                                        Text("Exclusive Content")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Live Now Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Live Now")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Text("See All")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<3) { _ in
                                HStack(spacing: 12) {
                                    Rectangle()
                                        .fill(LinearGradient(
                                            colors: [Color.red.opacity(0.6), Color.orange.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ))
                                        .aspectRatio(16/9, contentMode: .fit)
                                        .frame(width: 120)
                                        .overlay(alignment: .center) {
                                            Image(systemName: "play.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 8, height: 8)
                                            Text("LIVE")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.red)
                                        }
                                        
                                        Text("UFC 300: Main Card")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                        
                                        Text("ESPN+ Exclusive")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Subscribe Button
                    Button(action: {}) {
                        Text("Subscribe to ESPN+")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.black)
            .navigationTitle("ESPN+")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}