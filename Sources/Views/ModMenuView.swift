import SwiftUI

enum MenuTab: String, CaseIterable, Identifiable {
    case esp = "ESP", visual = "Visual", profiles = "Perfiles", settings = "Ajustes"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .esp: return "eye.fill"
        case .visual: return "paintpalette.fill"
        case .profiles: return "person.2.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ModMenuView: View {
    @EnvironmentObject private var store: SettingsStore
    @State private var tab: MenuTab = .esp
    @Namespace private var tabNS
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            tabBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    switch tab {
                    case .esp: espTab
                    case .visual: visualTab
                    case .profiles: ProfilesTab()
                    case .settings: SettingsTab()
                    }
                }
                .padding(14)
                .id(tab)
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .frame(maxWidth: 360)
        .frame(height: 540)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous)
            .strokeBorder(LinearGradient(colors: [Theme.accent.opacity(0.7), .white.opacity(0.05), Theme.accent2.opacity(0.6)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2))
        .shadow(color: .black.opacity(0.5), radius: 30, y: 16)
        .padding(.horizontal, 16)
    }

    // MARK: Cabecera y pestañas

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("ESP Lab")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.gradient)
                Text("Entorno de pruebas · datos simulados")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .padding(9)
                    .background(.white.opacity(0.08), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 10)
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(MenuTab.allCases) { t in
                Button {
                    Haptics.tap()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) { tab = t }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: t.icon).font(.system(size: 14))
                        Text(t.rawValue).font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundStyle(tab == t ? Color.white : Color.secondary)
                    .background {
                        if tab == t {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Theme.gradient)
                                .matchedGeometryEffect(id: "tab", in: tabNS)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding(.horizontal, 14)
    }

    // MARK: Pestañas

    @ViewBuilder private var espTab: some View {
        MenuCard(title: "General") {
            MenuToggle(title: "ESP activado", icon: "power", isOn: $store.config.masterEnabled)
        }
        MenuCard(title: "Indicadores") {
            MenuToggle(title: "Boxes", icon: "square.dashed", isOn: $store.config.showBoxes)
            MenuToggle(title: "Snaplines", icon: "line.diagonal", isOn: $store.config.showSnaplines)
            MenuToggle(title: "Distancia", icon: "ruler", isOn: $store.config.showDistance)
            MenuToggle(title: "Nombres", icon: "textformat", isOn: $store.config.showNames)
        }
        MenuCard(title: "Equipos") {
            MenuToggle(title: "Enemigos", icon: "exclamationmark.triangle.fill", isOn: $store.config.showEnemies)
            MenuToggle(title: "Aliados", icon: "shield.fill", isOn: $store.config.showAllies)
        }
    }

    @ViewBuilder private var visualTab: some View {
        MenuCard(title: "Colores") {
            RGBEditor(title: "Enemigos", color: $store.config.enemyColor)
            Divider().overlay(.white.opacity(0.08))
            RGBEditor(title: "Aliados", color: $store.config.allyColor)
        }
        MenuCard(title: "Estilo") {
            MenuSlider(title: "Grosor de boxes", value: $store.config.boxLineWidth, range: 0.5...5)
            MenuSlider(title: "Grosor de líneas", value: $store.config.snaplineWidth, range: 0.5...5)
            MenuSlider(title: "Tamaño de texto", value: $store.config.indicatorSize, range: 8...22, format: "%.0f")
            MenuSlider(title: "Esquinas", value: $store.config.boxCornerRadius, range: 0...16, format: "%.0f")
            VStack(alignment: .leading, spacing: 6) {
                Text("Origen de snaplines").font(.system(size: 13, weight: .medium, design: .rounded))
                Picker("", selection: $store.config.snaplineOrigin) {
                    ForEach(SnaplineOrigin.allCases) { Text($0.title).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

// MARK: - Perfiles

private struct ProfilesTab: View {
    @EnvironmentObject private var store: SettingsStore
    @State private var newName = ""

    var body: some View {
        MenuCard(title: "Nuevo perfil") {
            HStack {
                TextField("Nombre del perfil", text: $newName)
                    .padding(10)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                Button {
                    store.saveCurrentAsProfile(named: newName)
                    newName = ""
                    Haptics.success()
                } label: {
                    Image(systemName: "plus").font(.system(size: 15, weight: .bold))
                        .frame(width: 40, height: 40)
                        .background(Theme.gradient, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(newName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            if store.activeProfileID != nil {
                Button("Actualizar perfil activo con los ajustes actuales") {
                    store.updateActiveProfile()
                    Haptics.success()
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.accent2)
            }
        }
        MenuCard(title: "Mis perfiles") {
            ForEach(store.profiles) { p in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(p.name).font(.system(size: 14, weight: .semibold, design: .rounded))
                        if p.id == store.activeProfileID {
                            Text("Activo").font(.system(size: 10, weight: .bold)).foregroundStyle(Theme.accent2)
                        }
                    }
                    Spacer()
                    Button("Aplicar") { store.apply(p); Haptics.success() }
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Theme.accent.opacity(0.3), in: Capsule())
                    Button(role: .destructive) { store.delete(p) } label: {
                        Image(systemName: "trash").font(.system(size: 13))
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Ajustes

private struct SettingsTab: View {
    @EnvironmentObject private var store: SettingsStore
    @State private var confirmReset = false

    var body: some View {
        MenuCard(title: "Overlay") {
            MenuSlider(title: "Opacidad", value: $store.config.overlayOpacity, range: 0.2...1, format: "%.2f")
        }
        MenuCard(title: "Datos") {
            Text("Los cambios se guardan automáticamente.")
                .font(.system(size: 12, design: .rounded)).foregroundStyle(.secondary)
            Button(role: .destructive) { confirmReset = true } label: {
                Label("Restablecer configuración", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(Color.red.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .confirmationDialog("¿Restablecer todos los ajustes?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Restablecer", role: .destructive) { store.resetConfig(); Haptics.success() }
            }
        }
    }
}
