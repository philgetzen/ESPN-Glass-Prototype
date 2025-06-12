import SwiftUI

struct WatchView: View {
    @State private var selectedCategory = "Also Live"
    let categories = ["Also Live", "Upcoming", "Top Videos", "Leagues", "Sports", "Recently Added"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Hero Content
                    VStack(spacing: 16) {
                        Rectangle()
                            .fill(LinearGradient(
                                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .aspectRatio(16/9, contentMode: .fit)
                            .overlay(alignment: .bottomLeading) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("LIVE")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.red)
                                            .cornerRadius(4)
                                        
                                        Text("ESPN+")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue)
                                            .cornerRadius(4)
                                    }
                                    
                                    Text("The Pat McAfee Show")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text("ESPN+ • THE PAT MCAFEE SHOW")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.black.opacity(0.9), Color.clear],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                            }
                            .overlay(alignment: .center) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                            }
                        
                        // Secondary Content Row
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<3) { index in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Rectangle()
                                            .fill(LinearGradient(
                                                colors: [Color.orange.opacity(0.6), Color.red.opacity(0.4)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .aspectRatio(16/9, contentMode: .fit)
                                            .frame(width: 200)
                                            .overlay(alignment: .topLeading) {
                                                Text(index == 0 ? "LIVE" : "UPCOMING")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(index == 0 ? Color.red : Color.gray)
                                                    .cornerRadius(4)
                                                    .padding(8)
                                            }
                                        
                                        Text(index == 0 ? "SportsCenter" : index == 1 ? "NBA Today" : "First Take")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                        
                                        Text("ESPN • SPORTSCENTER")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Category Sections
                    ForEach(categories, id: \.self) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(category)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(0..<5) { _ in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Rectangle()
                                                .fill(LinearGradient(
                                                    colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ))
                                                .aspectRatio(16/9, contentMode: .fit)
                                                .frame(width: 160)
                                                .overlay(alignment: .center) {
                                                    Image(systemName: "play.circle.fill")
                                                        .font(.system(size: 40))
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
                                            
                                            Text("Game Highlights")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .lineLimit(2)
                                            
                                            Text("5 min")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("ESPN_Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 24)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.primary)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
    }
}
