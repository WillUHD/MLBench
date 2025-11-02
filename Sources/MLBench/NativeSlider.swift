import SwiftUI
import AppKit

struct NativeSlider: NSViewRepresentable {
    @Binding var value: Double
    var minValue: Double
    var maxValue: Double

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider()
        slider.sliderType = .linear
        slider.minValue = minValue
        slider.maxValue = maxValue
        slider.doubleValue = value
        
        slider.tickMarkPosition = .below
        slider.numberOfTickMarks = 11 
        slider.allowsTickMarkValuesOnly = false
        
        slider.target = context.coordinator
        slider.action = #selector(Coordinator.valueChanged(_:))
        
        return slider
    }

    func updateNSView(_ nsView: NSSlider, context: Context) {
        nsView.doubleValue = value
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    class Coordinator: NSObject {
        private var value: Binding<Double>

        init(value: Binding<Double>) {
            self.value = value
        }

        @objc func valueChanged(_ sender: NSSlider) {
            self.value.wrappedValue = round(sender.doubleValue)
        }
    }
}