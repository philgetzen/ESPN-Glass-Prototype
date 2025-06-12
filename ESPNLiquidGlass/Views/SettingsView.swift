import SwiftUI

struct SettingsView: View {
    @Binding var colorScheme: ColorScheme?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        
                        Text("Light")
                        
                        Spacer()
                        
                        if colorScheme == .light {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        colorScheme = .light
                    }
                    
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Dark")
                        
                        Spacer()
                        
                        if colorScheme == .dark {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        colorScheme = .dark
                    }
                    
                    HStack {
                        Image(systemName: "circle.lefthalf.filled")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        
                        Text("System")
                        
                        Spacer()
                        
                        if colorScheme == nil {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        colorScheme = nil
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}