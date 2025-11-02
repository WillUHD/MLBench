import Foundation
import CoreML
import QuartzCore
import SwiftUI

struct BenchmarkResult {
    let fps: Double
    let count: Int
    let duration: Double
}

@MainActor
class BenchmarkRunner: ObservableObject {
    @Published var statusMessage: String = "Ready"
    @Published var progress: Double = 0.0
    @Published var isBenchmarking: Bool = false
    @Published var isFinished: Bool = false
    @Published var finalResult: BenchmarkResult?

    private let modelName = "resnet50Int8LUT"
    private let side = 672
    private let chs = 3
    
    private var benchmarkTask: Task<Void, Error>?

    func startBenchmarking(frameCount: Int, useWarmStart: Bool) {
        // Reset state
        isBenchmarking = true
        isFinished = false
        progress = 0.0
        finalResult = nil
        statusMessage = "Starting up..."
        
        benchmarkTask = Task.detached(priority: .userInitiated) {
            do {
                let setupProgressMax: Double = 0.1
                
                await self.updateStatus("Loading model...", progress: 0.02)
                guard let resourceBundleURL = Bundle.main.url(
                    forResource: "MLBench_MLBench",
                    withExtension: "bundle"
                ) else {
                    throw NSError(domain: "MLBench", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find the resource bundle (MLBench_MLBench.bundle) inside the main app bundle."])
                }
                
                guard let resourceBundle = Bundle(url: resourceBundleURL) else {
                    throw NSError(domain: "MLBench", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not create a Bundle instance from the resource bundle URL."])
                }
                guard let modelURL = resourceBundle.url(
                    forResource: self.modelName,
                    withExtension: "mlmodelc",
                    subdirectory: "Resources"
                ) else {
                    throw NSError(domain: "MLBench", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not find \(self.modelName).mlmodelc in the Resources subdirectory of the bundle."])
                }
                
                let model = try MLModel(contentsOf: modelURL)
                await self.updateStatus("Model loaded", progress: 0.04)
                
                await self.updateStatus("Preparing input...", progress: 0.06)
                let inputFeature = try self.createInputFeature()
                let featureProvider = try MLDictionaryFeatureProvider(dictionary: ["image": inputFeature])
                let options = MLPredictionOptions()
                
                let startProgress = setupProgressMax
                
                if useWarmStart {
                    await self.updateStatus("Warming up...", progress: 0.08)
                    _ = try model.prediction(from: featureProvider, options: options)
                    await self.updateStatus("Warm-up complete", progress: setupProgressMax)
                } else {
                    await self.updateProgress(setupProgressMax)
                }
                
                let progressRange = 1.0 - startProgress
                
                await self.updateStatus("Benchmarking \(frameCount) frames...", progress: startProgress)
                let startTime = CACurrentMediaTime()
                
                for i in 0..<frameCount {
                    try Task.checkCancellation()
                    _ = try model.prediction(from: featureProvider, options: options)
                    
                    let loopProgress = Double(i + 1) / Double(frameCount)
                    await self.updateProgress(startProgress + (loopProgress * progressRange))
                }
                
                let duration = CACurrentMediaTime() - startTime
                let fps = Double(frameCount) / duration
                let result = BenchmarkResult(fps: fps, count: frameCount, duration: duration)
                
                await MainActor.run {
                    self.finalResult = result
                    self.isFinished = true
                    self.isBenchmarking = false
                }
                
            } catch {
                await MainActor.run {
                    if error is CancellationError {
                        self.statusMessage = "Benchmark Cancelled"
                    } else {
                        self.statusMessage = "Error: \(error.localizedDescription)"
                    }
                    self.isFinished = true
                    self.isBenchmarking = false
                }
            }
        }
    }
    
    func cancel() {
        benchmarkTask?.cancel()
    }
    
    private nonisolated func createInputFeature() throws -> MLMultiArray {
        let inputShape: [NSNumber] = [chs, side, side].map { NSNumber(value: $0) }
        let multiArray = try MLMultiArray(shape: inputShape, dataType: .float32)
        let pointer = multiArray.dataPointer.bindMemory(to: Float32.self, capacity: multiArray.count)
        for i in 0..<multiArray.count {
            pointer[i] = 0.0
        }
        return multiArray
    }
    
    private func updateStatus(_ message: String, progress: Double) async {
        await MainActor.run {
            self.statusMessage = message
            self.progress = progress
        }
    }
    
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            self.progress = progress
        }
    }
}