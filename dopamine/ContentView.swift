import SwiftUI

private enum DopaminePalette {
    static let background = Color(red: 0.035, green: 0.035, blue: 0.055)
    static let panel = Color(red: 0.085, green: 0.075, blue: 0.12)
    static let purple = Color(red: 0.62, green: 0.36, blue: 0.98)
    static let pink = Color(red: 0.91, green: 0.36, blue: 0.77)
    static let muted = Color.white.opacity(0.52)
}

private enum JailbreakStage: String, CaseIterable, Identifiable {
    case developer0 = "Developer Beta 0"
    case developer1 = "Developer Beta 1"
    case developer2 = "Developer Beta 2"
    case developer3 = "Developer Beta 3"
    case developer4 = "Developer Beta 4"
    case public1 = "Public Beta 1"
    case public2 = "Public Beta 2"

    var id: String { rawValue }
}

private enum RunState {
    case idle, running, completed
}

struct MainView: View {
    @State private var selectedVersion: JailbreakStage = .developer4
    @State private var runState: RunState = .idle
    @State private var progress = 0.0
    @State private var currentStatus = "Your device is ready"
    @State private var logs = [
        "Welcome to Dopamine",
        "This is a demo."
    ]
    @State private var showRespring = false
    @State private var showAbout = false
    @State private var showSettings = false

    private let process: [(String, String)] = [
        ("Checking compatibility", "Checking selected iOS build…"),
        ("Preparing exploit", "Simulating exploit preparation…"),
        ("Exploiting kernel", "Simulating kernel exploit stage…"),
        ("Initializing bootstrap", "Preparing simulated bootstrap…"),
        ("Installing bootstrap", "Simulating bootstrap installation…"),
        ("Configuring package manager", "Simulating package manager configuration…"),
        ("Finalizing", "Finishing visual demonstration…")
    ]

    var body: some View {
        ZStack {
            DopaminePalette.background.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 17) {
                    topBar
                    hero
                    versionCard
                    actionCard
                    logCard
                    footer
                }
                .padding(.horizontal, 19)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }

            if showRespring {
                RespringOverlay {
                    showRespring = false
                    appendLog("Visual respring screen dismissed.")
                }
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .sheet(isPresented: $showAbout) { InfoSheet(title: "About Dopamine Simulator", message: "A visual interface inspired by jailbreak utilities. It does not exploit iOS, install a bootstrap, modify system files, or restart SpringBoard.") }
        .sheet(isPresented: $showSettings) { InfoSheet(title: "Settings", message: "Simulator mode is enabled. System modifications are unavailable by design.") }
        .animation(.easeInOut(duration: 0.25), value: showRespring)
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DopaminePalette.purple)
                Text("dopamine")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("SIMULATOR")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1.1)
                    .foregroundStyle(DopaminePalette.pink)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(DopaminePalette.pink.opacity(0.13), in: Capsule())
            }
            Spacer()
            Button { showSettings = true } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.06), in: Circle())
            }
        }
    }

    private var hero: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(colors: [DopaminePalette.purple.opacity(0.35), .clear],
                                       center: .center, startRadius: 10, endRadius: 90)
                    )
                    .frame(width: 180, height: 180)
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 67, weight: .light))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, DopaminePalette.purple)
                    .shadow(color: DopaminePalette.purple.opacity(0.6), radius: 22)
            }
            .frame(height: 150)

            Text("Dopamine")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Jailbreak experience simulator")
                .font(.system(size: 14))
                .foregroundStyle(DopaminePalette.muted)

            HStack(spacing: 6) {
                Circle().fill(.green).frame(width: 7, height: 7)
                Text("SIMULATION MODE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.green.opacity(0.10), in: Capsule())
            .padding(.top, 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var versionCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            sectionHeader("DEVICE COMPATIBILITY", icon: "iphone")
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("iOS version")
                        .font(.system(size: 12))
                        .foregroundStyle(DopaminePalette.muted)
                    Text(selectedVersion.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                }
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(DopaminePalette.muted)
            }
            .padding(13)
            .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 12))

            Menu {
                ForEach(JailbreakStage.allCases) { version in
                    Button(version.rawValue) { selectedVersion = version }
                }
            } label: {
                HStack {
                    Text("Change simulated version")
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DopaminePalette.purple)
            }
        }
        .panel()
    }

    private var actionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("JAILBREAK", icon: "bolt.fill")
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(currentStatus)
                        .font(.system(size: 15, weight: .semibold))
                    Text(runState == .running ? "Please wait…" : "No changes will be made to iOS")
                        .font(.system(size: 12))
                        .foregroundStyle(DopaminePalette.muted)
                }
                Spacer()
                Image(systemName: runState == .completed ? "checkmark.seal.fill" : "shield.lefthalf.filled")
                    .font(.system(size: 25))
                    .foregroundStyle(runState == .completed ? .green : DopaminePalette.purple)
            }

            ProgressView(value: progress)
                .tint(DopaminePalette.purple)

            HStack {
                Text("Progress")
                Spacer()
                Text("\\(Int(progress * 100))%")
                    .monospacedDigit()
            }
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(DopaminePalette.muted)

            Button {
                Task { await startSimulation() }
            } label: {
                HStack(spacing: 9) {
                    if runState == .running {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: runState == .completed ? "arrow.clockwise" : "bolt.fill")
                    }
                    Text(runState == .running ? "Running…" : runState == .completed ? "Run Again" : "Jailbreak")
                }
                .font(.system(size: 16, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(LinearGradient(colors: [DopaminePalette.purple, DopaminePalette.pink],
                                           startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
            }
            .disabled(runState == .running)

            Button {
                showRespring = true
                appendLog("SIMULATED RESPRING — SpringBoard was not restarted.")
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Respring")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.88))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 13))
                .overlay(RoundedRectangle(cornerRadius: 13).stroke(.white.opacity(0.07)))
            }
            .disabled(runState == .running)
        }
        .panel()
    }

    private var logCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader("CONSOLE", icon: "terminal")
                Spacer()
                Text("LIVE")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1)
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(logs.enumerated()), id: \.offset) { _, line in
                    HStack(alignment: .top, spacing: 8) {
                        Text("›")
                            .foregroundStyle(DopaminePalette.purple)
                        Text(line)
                            .foregroundStyle(line.contains("SIMULATED") ? .green : .white.opacity(0.70))
                    }
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(13)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
        }
        .panel()
    }

    private var footer: some View {
        VStack(spacing: 7) {
            Text("DOPAMINE SIMULATOR")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.35))
            Text("Visual demo only • No jailbreak • No system changes")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.35))
            Button("About") { showAbout = true }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DopaminePalette.purple)
        }
        .padding(.top, 5)
    }

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon).foregroundStyle(DopaminePalette.purple)
            Text(title)
                .font(.system(size: 10, weight: .heavy))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    @MainActor
    private func startSimulation() async {
        guard runState != .running else { return }
        runState = .running
        progress = 0
        currentStatus = "Starting simulated process"
        logs = ["Starting visual-only sequence for \\(selectedVersion.rawValue)…"]
        for (index, item) in process.enumerated() {
            currentStatus = item.0
            logs.append(item.1)
            try? await Task.sleep(for: .seconds(0.85))
            progress = Double(index + 1) / Double(process.count)
        }
        currentStatus = "Simulation completed"
        logs.append("SIMULATED — no system changes were made.")
        runState = .completed
    }

    private func appendLog(_ line: String) {
        logs.append(line)
    }
}

private struct RespringOverlay: View {
    let onClose: () -> Void
    @State private var rotate = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 19) {
                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    .font(.system(size: 55, weight: .light))
                    .foregroundStyle(DopaminePalette.purple)
                    .rotationEffect(.degrees(rotate ? 180 : 0))
                    .onAppear {
                        withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                            rotate = true
                        }
                    }
                Text("Respring")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                Text("Your simulated SpringBoard session has restarted.")
                    .font(.system(size: 13))
                    .foregroundStyle(DopaminePalette.muted)
                    .multilineTextAlignment(.center)
                Text("DEMO — iOS was not restarted")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(.green)
                    .padding(.top, 5)
                Button(action: onClose) {
                    Text("Continue")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(DopaminePalette.purple, in: RoundedRectangle(cornerRadius: 13))
                }
                .padding(.top, 8)
            }
            .padding(30)
        }
    }
}

private struct InfoSheet: View {
    let title: String
    let message: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DopaminePalette.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(title).font(.title2.bold())
                Text(message)
                    .font(.body)
                    .foregroundStyle(DopaminePalette.muted)
                    .multilineTextAlignment(.center)
                Button("Close") { dismiss() }
                    .foregroundStyle(DopaminePalette.purple)
            }
            .padding(28)
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }
}

private extension View {
    func panel() -> some View {
        self
            .padding(16)
            .background(DopaminePalette.panel, in: RoundedRectangle(cornerRadius: 19))
            .overlay(RoundedRectangle(cornerRadius: 19).stroke(.white.opacity(0.055), lineWidth: 1))
    }
}
