import Foundation
import WatchConnectivity

// MARK: - WatchConnectivityService (iOS)
// Menerima data Heart Rate real-time dari Apple Watch via WCSession.
// Catatan: Karena Watch belum bisa live deploy, service ini siap dipakai
// saat WatchOS target aktif. Saat ini @Published latestBPM bisa dipakai
// untuk testing dengan simulator.

final class WatchConnectivityService: NSObject, ObservableObject {

    static let shared = WatchConnectivityService()

    /// BPM terakhir yang diterima dari Watch. nil = belum ada data.
    @Published var latestBPM: Double? = nil

    /// True kalau iPhone dan Watch saat ini terhubung dan bisa bertukar pesan.
    @Published var isReachable: Bool = false

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
}

// MARK: - WCSessionDelegate
extension WatchConnectivityService: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
        if let error { print("WCSession activation error: \(error.localizedDescription)") }
    }

    // Terima pesan real-time dari Watch (sendMessage)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        guard
            let bpm = message["bpm"] as? Double
        else { return }

        DispatchQueue.main.async {
            self.latestBPM = bpm
        }
    }

    // iOS-only — wajib ada untuk WCSessionDelegate di iOS
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate setelah switch Apple Watch
        WCSession.default.activate()
    }
}
