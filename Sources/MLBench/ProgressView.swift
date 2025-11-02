import SwiftUI

struct BenchmarkProgressView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var runner: BenchmarkRunner
    
    var body: some View {
        VStack(spacing: 25) {
            if runner.isFinished {
                resultsView
            } else {
                progressView
            }
        }
        .padding(25)
        .frame(width: 325, height: 200)
        .background(VisualEffectView().ignoresSafeArea())
        .interactiveDismissDisabled()
    }
    
    private var progressView: some View {
        VStack(spacing: 15) {
            Text(runner.statusMessage)
                .font(.system(size: 15, weight: .regular))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
            
            ProgressView(value: runner.progress)
                .progressViewStyle(.linear)
            
            Spacer()
            
            Button("Cancel", role: .cancel) {
                runner.cancel()
                dismiss() // Dismiss immediately upon cancellation
            }
            .buttonStyle(PillButtonStyle(backgroundColor: .secondary.opacity(0.5)))
        }
    }
    
    @ViewBuilder
    private var resultsView: some View {
        VStack(spacing: 15) {
            if let result = runner.finalResult {
                Text(String(format: "%.2f FPS", result.fps))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.accentColor)
                
                Text("Completed \(result.count) frames in \(String(format: "%.3f", result.duration)) seconds")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                Text(runner.statusMessage)
                    .font(.system(size: 40, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .buttonStyle(PillButtonStyle(backgroundColor: .accentColor))
            .keyboardShortcut(.defaultAction)
        }
    }
}