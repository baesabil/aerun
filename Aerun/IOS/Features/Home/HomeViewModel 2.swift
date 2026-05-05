//
//  HomeViewModel.swift
//  Aerun
//
//  ViewModel untuk HomeView — mengambil semua data dari HealthKit
//  dan menghitung zona Heart Rate berdasarkan algoritma Karvonen (HRR method).
//
//  POLA MVVM (Model-View-ViewModel):
//  - Model     = HeartRateZone, WorkoutSummary (struct di bawah file ini)
//  - View      = HomeView.swift
//  - ViewModel = HomeViewModel (file ini) — jembatan antara data dan tampilan
//
//  @MainActor artinya semua update @Published otomatis di main thread,
//  aman langsung update UI tanpa DispatchQueue.main.async manual.
//
//  UPDATE v2:
//  - Sekarang ambil workout .running DAN .walking dari HealthKit
//  - Data bisa dari Apple Watch Workout bawaan, Nike Run Club, Strava, dll
//

import SwiftUI
import HealthKit

@MainActor
class HomeViewModel: ObservableObject {

    // MARK: - HealthKit Store
    // HKHealthStore = pintu masuk ke semua data HealthKit.
    // Best practice Apple: buat SATU instance per app — jangan buat baru tiap query.
    private let healthStore = HKHealthStore()

    // MARK: - Published State
    // @Published = properti yang kalau berubah, otomatis trigger redraw di SwiftUI View
    // yang subscribe ke ViewModel ini (melalui @StateObject atau @ObservedObject).

    @Published var userName: String = "Runner"      // Nama dari UserDefaults (set di onboarding)
    @Published var isLoading: Bool = true            // Kontrol tampil/sembunyi loading spinner

    // Zona HR hasil kalkulasi
    @Published var safeZoneLow: Int  = 0            // Batas bawah Zone 2 (BPM)
    @Published var safeZoneHigh: Int = 0            // Batas atas Zone 2 (BPM)
    @Published var allZones: [HeartRateZone] = []   // Array 5 zona HR (Zone 1–5)
    @Published var selectedZoneIndex: Int = 1        // Tab zona aktif (default: Zone 2 = safe zone)

    // Workout terakhir — nil berarti user belum pernah lari/jalan
    @Published var lastWorkout: WorkoutSummary? = nil

    // MARK: - Load All Data
    // Dipanggil oleh HomeView.onAppear — menginisiasi semua fetch
    func loadData() {

        // Fallback timer: paksa tampilkan UI setelah 5 detik
        // Mencegah layar blank/stuck kalau HealthKit lambat atau permission denied
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 detik
            if isLoading { isLoading = false }
        }

        // Sequential fetch — satu per satu dalam satu Task
        Task {
            await fetchUserName()       // 1. Nama dari UserDefaults
            await fetchHealthData()     // 2. Age/sex/RHR → hitung 5 zona HR
            await fetchLastWorkout()    // 3. Workout lari/jalan terbaru dari HealthKit
            isLoading = false           // 4. Selesai → matikan loading
        }
    }

    // MARK: - Fetch User Name
    // Nama disimpan ke UserDefaults saat onboarding (GreetingView).
    // UserDefaults cocok untuk data kecil non-sensitif seperti nama panggilan.
    private func fetchUserName() async {
        let saved = UserDefaults.standard.string(forKey: "aerun_user_name") ?? ""
        if !saved.isEmpty {
            userName = saved
        }
        // Kalau kosong, tetap pakai default "Runner"
    }

    // MARK: - Fetch Health Data & Calculate Zones
    // Mengambil 3 data dari HealthKit: umur, jenis kelamin, resting heart rate.
    // Ketiganya dipakai untuk kalkulasi zona HR dengan formula Karvonen.
    private func fetchHealthData() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        // Simulator lama / iPad tanpa HealthKit → skip (tidak crash)

        // --- Ambil UMUR ---
        // dateOfBirthComponents() melempar error kalau user belum isi di Health app
        // try? = kalau error, hasilnya nil (tidak crash)
        var age: Int = 25
        if let components = try? healthStore.dateOfBirthComponents(),
           let birthYear  = components.year {
            let currentYear = Calendar.current.component(.year, from: Date())
            age = currentYear - birthYear
        }

        // --- Ambil BIOLOGICAL SEX ---
        // Rumus HRmax berbeda: laki-laki 220-age, perempuan 226-age
        var isMale: Bool = true
        if let bioSex = try? healthStore.biologicalSex() {
            isMale = bioSex.biologicalSex == .male
        }

        // --- Ambil RESTING HEART RATE terbaru ---
        // Generic helper fetchLatestQuantity supaya tidak duplikasi kode query
        let rhr = await fetchLatestQuantity(
            typeIdentifier: .restingHeartRate,
            unit: HKUnit.count().unitDivided(by: .minute()) // BPM = count/minute
        ) ?? 60.0 // Default 60 BPM

        // --- Hitung 5 zona ---
        calculateZones(age: age, isMale: isMale, rhr: rhr)
    }

    // MARK: - Heart Rate Zone Calculation (Karvonen / HRR Method)
    //
    // Formula: Target HR = (HRR × intensity%) + RHR
    //
    // HRR (Heart Rate Reserve) = HRmax - RHR
    // Kenapa HRR? Karena memperhitungkan kebugaran dasar seseorang.
    // Dua orang dengan HRmax sama tapi RHR berbeda → zona HR-nya juga BERBEDA.
    //
    // Contoh:
    //   - Umur 25, laki-laki: HRmax = 220 - 25 = 195
    //   - RHR = 60 → HRR = 135
    //   - Zone 2 low = (135 × 0.60) + 60 = 141
    //   - Zone 2 high = (135 × 0.70) + 60 = 154.5 ≈ 154
    private func calculateZones(age: Int, isMale: Bool, rhr: Double) {
        let hrMax = isMale ? (220 - age) : (226 - age)
        let hrr   = Double(hrMax) - rhr

        let zones = [
            HeartRateZone(
                number: 1,
                name: "Warm Up",
                intensity: "50–60% Max Heart Rate",
                low:  Int(hrr * 0.50 + rhr),
                high: Int(hrr * 0.60 + rhr),
                color: .cyan,
                title: "Very Light Aerobic",
                description: "Best for re-run prep & active recovery.",
                bullets: [
                    "Best for re-run prep & active recovery",
                    "Start your run here to gently wake your body up."
                ]
            ),
            HeartRateZone(
                number: 2,
                name: "The Sweet Spot",
                intensity: "60–70% Max Heart Rate",
                low:  Int(hrr * 0.60 + rhr),
                high: Int(hrr * 0.70 + rhr),
                color: .green,
                title: "Light Aerobic",
                description: "Best for building stamina safely & steady runs.",
                bullets: [
                    "Best for building stamina safely & steady runs",
                    "Keep your heart rate here for a comfortable, enjoyable, and nausea-free run!"
                ]
            ),
            HeartRateZone(
                number: 3,
                name: "Cardio Push",
                intensity: "70–80% Max Heart Rate",
                low:  Int(hrr * 0.70 + rhr),
                high: Int(hrr * 0.80 + rhr),
                color: .yellow,
                title: "Moderate Aerobic",
                description: "Best for improving cardiovascular fitness.",
                bullets: [
                    "Best for improving cardiovascular fitness.",
                    "You will breathe heavier here. Pace yourself and step back to Zone 2 if you feel too tired."
                ]
            ),
            HeartRateZone(
                number: 4,
                name: "Threshold",
                intensity: "80–90% Max Heart Rate",
                low:  Int(hrr * 0.80 + rhr),
                high: Int(hrr * 0.90 + rhr),
                color: .orange,
                title: "Anaerobic",
                description: "Best for speed training (for advanced runners).",
                bullets: [
                    "Best for speed training (for advanced runners)",
                    "Heavy breathing zone! If you are a beginner, slow down or walk to avoid overexertion."
                ]
            ),
            HeartRateZone(
                number: 5,
                name: "Max Effort",
                intensity: "90–100% Max Heart Rate",
                low:  Int(hrr * 0.90 + rhr),
                high: Int(hrr * 1.00 + rhr),
                color: .red,
                title: "Extreme Anaerobic",
                description: "Best for short, intense sprints.",
                bullets: [
                    "Best for short, intense sprints",
                    "Danger zone for beginners. Slow down, breathe, and rest immediately to prevent blackout or severe nausea."
                ]
            )
        ]

        allZones     = zones
        safeZoneLow  = zones[1].low    // Zone 2 = safe zone untuk pemula
        safeZoneHigh = zones[1].high
    }

    // MARK: - Fetch Last Workout (Running + Walking)
    //
    // UPDATE: Sekarang ambil workout .running DAN .walking
    // Kedua tipe ini muncul di Apple Watch Workout app bawaan.
    //
    // Kenapa bisa baca data dari Apple Workout app?
    // Karena Apple Watch Workout app MENYIMPAN data ke HealthKit — database terpusat.
    // App apapun yang punya izin HealthKit bisa baca data itu, termasuk Aerun!
    //
    // Flow: Apple Watch Workout app → HealthKit → Aerun iOS app
    //
    private func fetchLastWorkout() async {
        let workoutType = HKObjectType.workoutType()

        // NSCompoundPredicate = kombinasi beberapa predicate dengan OR / AND
        // Kita pakai OR: ambil kalau tipe running ATAU walking
        let runPred  = HKQuery.predicateForWorkouts(with: .running)
        let walkPred = HKQuery.predicateForWorkouts(with: .walking)
        let combinedPredicate = NSCompoundPredicate(
            orPredicateWithSubpredicates: [runPred, walkPred]
        )

        // Sort descending: workout terbaru di posisi pertama
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // withCheckedContinuation = wrapper untuk callback API jadi async/await
        // Karena HKSampleQuery pakai completion handler, bukan async natively
        let workout = await withCheckedContinuation { (cont: CheckedContinuation<HKWorkout?, Never>) in
            let q = HKSampleQuery(
                sampleType: workoutType,
                predicate: combinedPredicate,
                limit: 1,                  // Cukup 1 workout terbaru untuk HomeView
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error { print("[Aerun] Workout fetch error: \(error.localizedDescription)") }
                cont.resume(returning: samples?.first as? HKWorkout)
            }
            healthStore.execute(q)
        }

        // Kalau nil → user belum punya workout running/walking di HealthKit
        guard let workout else { return }

        // Ambil HR statistik dari rentang waktu workout ini
        let avgHR = await fetchWorkoutHeartRate(workout: workout, statisticType: .discreteAverage)
        let minHR = await fetchWorkoutHeartRate(workout: workout, statisticType: .discreteMin)
        let maxHR = await fetchWorkoutHeartRate(workout: workout, statisticType: .discreteMax)

        // Hitung jarak dan pace
        let distM  = workout.totalDistance?.doubleValue(for: .meter()) ?? 0
        let distKm = distM / 1000.0
        let dur    = workout.duration

        // Pace: detik per km → format "M'SS\""
        let paceString: String
        if distKm > 0 {
            let spk = dur / distKm
            paceString = "\(Int(spk)/60)'\(String(format: "%02d", Int(spk)%60))\""
        } else {
            paceString = "--'--\""
        }

        // Durasi: "MM:SS"
        let durString = "\(Int(dur)/60):\(String(format: "%02d", Int(dur)%60))"

        lastWorkout = WorkoutSummary(
            date: "",  // HomeView tidak menampilkan tanggal di kartu mini
            minHR: minHR.map { Int($0) },   // Optional map: Double? → Int?
            avgHR: avgHR.map { Int($0) },
            maxHR: maxHR.map { Int($0) },
            avgPace: paceString,
            distanceKm: distKm,
            totalTime: durString
        )
    }

    // MARK: - Helper: Fetch HR Statistic dari satu Workout
    // HKStatisticsQuery = query khusus agregat (min, max, avg, sum)
    // Dipakai untuk dapat min/avg/max HR dalam rentang satu sesi workout
    private func fetchWorkoutHeartRate(workout: HKWorkout, statisticType: HKStatisticsOptions) async -> Double? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return nil }

        // Predicate: hanya sample HR yang ada DALAM rentang waktu workout ini
        let pred = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate  // Sample harus mulai setelah startDate workout
        )

        return await withCheckedContinuation { cont in
            let q = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: pred,
                options: statisticType
            ) { _, stats, _ in
                let unit = HKUnit.count().unitDivided(by: .minute())
                var value: Double? = nil
                // Switch untuk memilih nilai yang sesuai tipe statistik
                switch statisticType {
                case .discreteAverage: value = stats?.averageQuantity()?.doubleValue(for: unit)
                case .discreteMin:     value = stats?.minimumQuantity()?.doubleValue(for: unit)
                case .discreteMax:     value = stats?.maximumQuantity()?.doubleValue(for: unit)
                default: break
                }
                cont.resume(returning: value)
            }
            healthStore.execute(q)
        }
    }

    // MARK: - Helper: Fetch Latest Quantity Sample
    // Generic helper — bisa dipakai untuk metric apapun (RHR, VO2Max, dll).
    // Limit 1 + sort descending = ambil sample paling baru saja.
    private func fetchLatestQuantity(typeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else { return nil }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        return await withCheckedContinuation { cont in
            let q = HKSampleQuery(
                sampleType: quantityType,
                predicate: nil,  // nil = ambil semua, tidak difilter
                limit: 1,
                sortDescriptors: [sort]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                cont.resume(returning: value)
            }
            healthStore.execute(q)
        }
    }
}

// MARK: - HeartRateZone Model
// Struct untuk satu zona HR. Identifiable supaya bisa dipakai di ForEach SwiftUI.
// Disimpan di file ini supaya HomeViewModel dan data modelnya satu sumber kebenaran.
struct HeartRateZone: Identifiable {
    let id          = UUID()         // Auto UUID — wajib untuk Identifiable
    let number:      Int             // 1–5
    let name:        String          // Contoh: "The Sweet Spot"
    let intensity:   String          // Contoh: "60–70% Max Heart Rate"
    let low:         Int             // Batas bawah BPM
    let high:        Int             // Batas atas BPM
    let color:       Color           // Warna zona di UI
    let title:       String          // Judul italic di detail card
    let description: String          // Deskripsi singkat
    let bullets:     [String]        // Poin-poin di detail card (maks 2)
}

// MARK: - WorkoutSummary Model
// Model ringkasan satu sesi workout — dipakai di HomeView (kartu mini)
// dan bisa diakses dari HistoryView untuk workout pertama
struct WorkoutSummary {
    let date:       String    // Format: "Friday, 01 May 2026 at 10:00"
    let minHR:      Int?      // Optional: mungkin tidak ada HR data
    let avgHR:      Int?
    let maxHR:      Int?
    let avgPace:    String    // Format: "8'43\""
    let distanceKm: Double
    let totalTime:  String    // Format: "30:12"
}
