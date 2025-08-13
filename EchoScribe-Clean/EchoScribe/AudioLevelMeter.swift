import SwiftUI

struct AudioLevelMeter: View {
    let audioLevel: Float
    let isRecording: Bool
    
    @State private var animatedLevel: Float = 0.0
    
    var body: some View {
        VStack(spacing: 8) {
            // Audio Level Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.Colors.borderLight)
                        .frame(height: 8)
                    
                    // Level Indicator
                    RoundedRectangle(cornerRadius: 4)
                        .fill(audioLevelGradient)
                        .frame(width: geometry.size.width * CGFloat(animatedLevel), height: 8)
                        .animation(.easeInOut(duration: 0.1), value: animatedLevel)
                }
            }
            .frame(height: 8)
            
            // Level Text
            HStack {
                Text("Audio Level")
                    .font(DesignSystem.Typography.caption1())
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                
                Spacer()
                
                Text("\(Int(animatedLevel * 100))%")
                    .font(DesignSystem.Typography.caption1(.medium))
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
        }
        .onAppear {
            animatedLevel = audioLevel
        }
        .onChange(of: audioLevel) { newValue in
            withAnimation(.easeInOut(duration: 0.1)) {
                animatedLevel = newValue
            }
        }
    }
    
    private var audioLevelGradient: LinearGradient {
        let colors: [Color]
        
        if animatedLevel < 0.3 {
            colors = [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.8)]
        } else if animatedLevel < 0.7 {
            colors = [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.8)]
        } else {
            colors = [DesignSystem.Colors.error, DesignSystem.Colors.error.opacity(0.8)]
        }
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

struct CircularAudioLevelMeter: View {
    let audioLevel: Float
    let isRecording: Bool
    let size: CGFloat
    
    @State private var animatedLevel: Float = 0.0
    
    init(audioLevel: Float, isRecording: Bool, size: CGFloat = 120) {
        self.audioLevel = audioLevel
        self.isRecording = isRecording
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(DesignSystem.Colors.borderLight, lineWidth: 8)
                .frame(width: size, height: size)
            
            // Level Circle
            Circle()
                .trim(from: 0, to: CGFloat(animatedLevel))
                .stroke(audioLevelGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.1), value: animatedLevel)
            
            // Center Content
            VStack(spacing: 4) {
                Text("\(Int(animatedLevel * 100))%")
                    .font(DesignSystem.Typography.title3(.bold))
                    .foregroundColor(DesignSystem.Colors.primaryText)
                
                Text("Level")
                    .font(DesignSystem.Typography.caption1())
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }
        .onAppear {
            animatedLevel = audioLevel
        }
        .onChange(of: audioLevel) { newValue in
            withAnimation(.easeInOut(duration: 0.1)) {
                animatedLevel = newValue
            }
        }
    }
    
    private var audioLevelGradient: AngularGradient {
        let colors: [Color]
        
        if animatedLevel < 0.3 {
            colors = [DesignSystem.Colors.success, DesignSystem.Colors.success.opacity(0.6)]
        } else if animatedLevel < 0.7 {
            colors = [DesignSystem.Colors.warning, DesignSystem.Colors.warning.opacity(0.6)]
        } else {
            colors = [DesignSystem.Colors.error, DesignSystem.Colors.error.opacity(0.6)]
        }
        
        return AngularGradient(
            gradient: Gradient(colors: colors),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360)
        )
    }
}

struct WaveformAudioMeter: View {
    let audioLevel: Float
    let isRecording: Bool
    let barCount: Int
    
    @State private var animatedLevel: Float = 0.0
    
    init(audioLevel: Float, isRecording: Bool, barCount: Int = 20) {
        self.audioLevel = audioLevel
        self.isRecording = isRecording
        self.barCount = barCount
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(
                    audioLevel: animatedLevel,
                    barIndex: index,
                    totalBars: barCount,
                    isRecording: isRecording
                )
            }
        }
        .onAppear {
            animatedLevel = audioLevel
        }
        .onChange(of: audioLevel) { newValue in
            withAnimation(.easeInOut(duration: 0.1)) {
                animatedLevel = newValue
            }
        }
    }
}

struct WaveformBar: View {
    let audioLevel: Float
    let barIndex: Int
    let totalBars: Int
    let isRecording: Bool
    
    @State private var barHeight: CGFloat = 0.1
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(barColor)
            .frame(width: 4, height: maxHeight * barHeight)
            .animation(.easeInOut(duration: 0.1), value: barHeight)
            .onAppear {
                updateBarHeight()
            }
            .onChange(of: audioLevel) { _ in
                updateBarHeight()
            }
    }
    
    private var maxHeight: CGFloat {
        return 60
    }
    
    private var barColor: Color {
        let normalizedIndex = Float(barIndex) / Float(totalBars)
        
        if audioLevel > normalizedIndex {
            if audioLevel < 0.3 {
                return DesignSystem.Colors.success
            } else if audioLevel < 0.7 {
                return DesignSystem.Colors.warning
            } else {
                return DesignSystem.Colors.error
            }
        } else {
            return DesignSystem.Colors.borderLight
        }
    }
    
    private func updateBarHeight() {
        let normalizedIndex = Float(barIndex) / Float(totalBars)
        let baseHeight = CGFloat(audioLevel)
        
        // Add some randomness for more natural waveform appearance
        let randomFactor = CGFloat.random(in: 0.8...1.2)
        let targetHeight = baseHeight * randomFactor
        
        if audioLevel > normalizedIndex {
            barHeight = min(targetHeight, 1.0)
        } else {
            barHeight = 0.1
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AudioLevelMeter(audioLevel: 0.7, isRecording: true)
            .padding()
        
        CircularAudioLevelMeter(audioLevel: 0.5, isRecording: true)
            .padding()
        
        WaveformAudioMeter(audioLevel: 0.8, isRecording: true)
            .padding()
    }
    .background(DesignSystem.Colors.background)
}
