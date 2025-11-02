import SwiftUI

struct PreferencesView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("useWarmStart") private var useWarmStart: Bool = true
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Preferences")
                .font(.largeTitle.weight(.bold))
                .padding(.top)
            
            Toggle("Warm start (recommended)", isOn: $useWarmStart)
                .toggleStyle(.switch)
                .padding(.horizontal)

            Spacer()
            
            Text("by [WillUHD](https://www.github.com/willuhd)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(PillButtonStyle(backgroundColor: .accentColor))
            .keyboardShortcut(.defaultAction)
        }
        .padding(15)
        .frame(width: 300, height: 250)
        .background(VisualEffectView().ignoresSafeArea())
    }
}