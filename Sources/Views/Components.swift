import SwiftUI

struct MenuCard<Content: View>: View {
    var title: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
            }
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(.white.opacity(0.07), lineWidth: 1))
    }
}

struct MenuToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                Text(title).font(.system(size: 14, weight: .medium, design: .rounded))
            } icon: {
                Image(systemName: icon).foregroundStyle(Theme.gradient).frame(width: 20)
            }
        }
        .tint(Theme.accent)
        .onChange(of: isOn) { _ in Haptics.tap() }
    }
}

struct MenuSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    var format = "%.1f"

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title).font(.system(size: 13, weight: .medium, design: .rounded))
                Spacer()
                Text(String(format: format, value))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.accent2)
            }
            Slider(value: $value, in: range).tint(Theme.accent)
        }
    }
}

struct RGBEditor: View {
    let title: String
    @Binding var color: RGBAColor

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(title).font(.system(size: 13, weight: .semibold, design: .rounded))
                Spacer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.color)
                    .frame(width: 36, height: 20)
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.white.opacity(0.3)))
            }
            channel("R", $color.r, .red)
            channel("G", $color.g, .green)
            channel("B", $color.b, .blue)
        }
    }

    private func channel(_ label: String, _ value: Binding<Double>, _ tint: Color) -> some View {
        HStack(spacing: 8) {
            Text(label).font(.system(size: 11, weight: .bold, design: .monospaced)).frame(width: 12)
            Slider(value: value, in: 0...1).tint(tint)
            Text("\(Int(value.wrappedValue * 255))")
                .font(.system(size: 11, design: .monospaced))
                .frame(width: 30, alignment: .trailing)
        }
    }
}
