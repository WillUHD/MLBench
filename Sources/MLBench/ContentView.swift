import SwiftUI

struct ContentView: View {
    @StateObject private var benchmarkRunner = BenchmarkRunner()
    
    @State private var frameCount: Double = 120
    @AppStorage("useWarmStart") private var useWarmStart: Bool = true
    
    @State private var isShowingPreferences = false
    @State private var isShowingBenchmarkSheet = false

    var body: some View {
        VStack(spacing: 15) {
            Spacer()
            Spacer()
            
            Text("MLBench")
                .font(.system(size: 48, weight: .bold, design: .default))
            
            VStack(spacing: 20) {
                Text("Choose frame count to benchmark")
                    .font(.headline)
                
                NativeSlider(value: $frameCount, minValue: 60, maxValue: 5060)
                
                Text("\(Int(frameCount))")
                    .font(.title2.bold())
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 40)
            
            Button(action: start) {
                Text("Start Benchmark")
            }
            .buttonStyle(PillButtonStyle(backgroundColor: .accentColor))
            .padding(30)
            .padding([.horizontal, .bottom], 35)
        }
        .frame(width: 400, height: 300)
        .background(VisualEffectView().ignoresSafeArea())
        .sheet(isPresented: $isShowingPreferences) {
            PreferencesView()
        }
        .sheet(isPresented: $isShowingBenchmarkSheet, onDismiss: { }) {
            BenchmarkProgressView(runner: benchmarkRunner)
        }
        .onReceive(NotificationCenter.default.publisher(for: .showPreferences)) { _ in
            isShowingPreferences = true
        }
        .onAppear(perform: setupTitlebar)
        
    }
    
    private func start() {
        isShowingBenchmarkSheet = true
        benchmarkRunner.startBenchmarking(frameCount: Int(frameCount), useWarmStart: useWarmStart)
    }
    
private func setupTitlebar() {
    DispatchQueue.main.async {
        let buttonView = Button(action: { isShowingPreferences = true }) {
            Image(systemName: "gearshape.fill")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)

        let hostingController = NSHostingController(rootView: buttonView)
        hostingController.view.frame.size = CGSize(width: 40, height: 22)

        let accessory = NSTitlebarAccessoryViewController()
        accessory.view = hostingController.view
        accessory.layoutAttribute = .trailing
        
        if let window = NSApp.windows.first {
            window.addTitlebarAccessoryViewController(accessory)
        }
    }
}
}