//
//  HomeViewModel.swift
//  Aerun
//

import SwiftUI
import HealthKit
import Contacts

// @MainActor artinya semua update ke @Published otomatis di main thread — aman untuk UI
@MainActor
class HomeViewModel: ObservableObject {
    
    // MARK: - HealthKit Store
    // Satu instance HKHealthStore per app adalah best practice Apple
    private let healthStore = HKHealthStore()
    
    // MARK: - Published State
    // Semua @Published akan trigger UI update otomatis saat nilainya berubah
    
    @Published var userName: String = "Runner"         // Nama dari Contacts
    @Published var isLoading: Bool = true              // Tampilkan loading state
    
    // Data untuk kalkulasi zona HR
    @Published var safeZoneLow: Int = 0                // Batas bawah Zone 2
    @Published var safeZoneHigh: Int = 0               // Batas atas Zone 2
    @Published var allZones: [HeartRateZone] = []      // Semua 5 zona HR
    @Published var selectedZoneIndex: Int = 1          // Default pilih Zone 2 (safe zone)
    
    // Data workout terakhir — nil berarti belum ada history
    @Published var lastWorkout: WorkoutSummary? = nil
    
    // MARK: - Load All Data
    // Fungsi utama yang dipanggil saat HomeView muncul
    func loadData() {
        // Fallback: kalau 5 detik masih loading, paksa tampil UI
        // Ini penting supaya app tidak stuck blank screen
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 detik
            if isLoading { isLoading = false }
        }
        
        // Jalankan semua fetch secara paralel
        Task {
            await fetchUserName()       // Ambil nama dari Contacts
            await fetchHealthData()     // Ambil age, sex, RHR lalu hitung zona
            await fetchLastWorkout()    // Ambil workout terakhir dari HealthKit
            isLoading = false           // Selesai, matikan loading
        }
    }
    
    // MARK: - Fetch User Name
    // Ambil nama depan user dari Contacts framework
    private func fetchUserName() async {
        // Minta akses Contacts — kalau ditolak, pakai "Runner"
        let status = await withCheckedContinuation { continuation in
            CNContactStore().requestAccess(for: .contacts) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
        
        guard status else { return } // Kalau tidak diizinkan, skip
        
        // Fetch kontak dengan predicate nama diri sendiri
        let store = CNContactStore()
        let keys = [CNContactGivenNameKey as CNKeyDescriptor] // Hanya butuh nama depan
        
        do {
            // meContactWithIdentifier: ambil kontak "Me" — yaitu pemilik iPhone
            let meContact = try store.unifiedMeContactWithKeys(keysToFetch: keys)
            let firstName = meContact.givenName
            
            if !firstName.isEmpty {
                userName = firstName // Update nama kalau berhasil
            }
        } catch {
            // Kalau gagal (misalnya belum ada kontak "Me"), biarkan default "Runner"
            print("Contacts fetch error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch Health Data & Calculate Zones
    private func fetchHealthData() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        // --- Ambil umur dari date of birth ---
        var age: Int = 25 // Default kalau tidak bisa diambil
        if let dobComponents = try? healthStore.dateOfBirthComponents(),
           let birthYear = dobComponents.year {
            let currentYear = Calendar.current.component(.year, from: Date())
            age = currentYear - birthYear
        }
        
        // --- Ambil biological sex ---
        var isMale: Bool = true // Default male kalau tidak bisa diambil
        if let bioSex = try? healthStore.biologicalSex() {
            isMale = bioSex.biologicalSex == .male
        }
        
        // --- Ambil Resting Heart Rate terbaru ---
        let rhr = await fetchLatestQuantity(
            typeIdentifier: .restingHeartRate,
            unit: HKUnit.count().unitDivided(by: .minute()) // Satuan BPM
        ) ?? 60.0 // Default 60 BPM kalau tidak ada data
        
        // --- Hitung zona HR berdasarkan formula dari brief ---
        calculateZones(age: age, isMale: isMale, rhr: rhr)
    }
    
    // MARK: - Heart Rate Zone Calculation
    // Formula dari brief: HRR method dengan HRmax berbeda untuk male/female
    private func calculateZones(age: Int, isMale: Bool, rhr: Double) {
        
        // Langkah 1: Hitung HRmax
        // Male: 220 - age | Female: 226 - age
        let hrMax = isMale ? (220 - age) : (226 - age)
        
        // Langkah 2: Hitung Heart Rate Reserve (HRR)
        let hrr = Double(hrMax) - rhr
        
        // Langkah 3: Hitung setiap zona pakai formula: Target HR = (HRR × intensity) + RHR
        let zones = [
            HeartRateZone(
                number: 1,
                name: "Recovery",
                intensity: "50–60% Max Heart Rate",
                low: Int(hrr * 0.50 + rhr),
                high: Int(hrr * 0.60 + rhr),
                color: .cyan,
                title: "Warm Up Zone",
                description: "Light activity, perfect for warm-up and cool-down.",
                bullets: ["Great for active recovery days", "Very comfortable pace", "Builds aerobic base slowly"]
            ),
            HeartRateZone(
                number: 2,
                name: "The Sweet Spot",        // Zone 2 adalah safe zone kamu
                intensity: "60–70% Max Heart Rate",
                low: Int(hrr * 0.60 + rhr),
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
                name: "Moderate",
                intensity: "70–80% Max Heart Rate",
                low: Int(hrr * 0.70 + rhr),
                high: Int(hrr * 0.80 + rhr),
                color: .yellow,
                title: "Aerobic Zone",
                description: "Improves cardiovascular fitness and endurance.",
                bullets: ["Increases aerobic capacity", "Suitable for tempo runs", "Monitor breathing carefully"]
            ),
            HeartRateZone(
                number: 4,
                name: "Hard",
                intensity: "80–90% Max Heart Rate",
                low: Int(hrr * 0.80 + rhr),
                high: Int(hrr * 0.90 + rhr),
                color: .orange,
                title: "Threshold Zone",
                description: "Pushes your lactate threshold higher.",
                bullets: ["Improves speed and power", "Hard but sustainable effort", "Use sparingly — max 2x/week"]
            ),
            HeartRateZone(
                number: 5,
                name: "Maximum",
                intensity: "90–100% Max Heart Rate",
                low: Int(hrr * 0.90 + rhr),
                high: Int(hrr * 1.00 + rhr),
                color: .red,
                title: "Max Effort",
                description: "All-out effort, not sustainable for long.",
                bullets: ["Only for intervals/sprints", "Very high injury risk if sustained", "Requires full recovery after"]
            )
        ]
        
        allZones = zones
        
        // Safe zone = Zone 2 (index 1)
        safeZoneLow = zones[1].low
        safeZoneHigh = zones[1].high
    }
    
    // MARK: - Fetch Last Workout
    // Ambil workout lari terakhir dari HealthKit (termasuk dari Apple Watch built-in Workout app)
    private func fetchLastWorkout() async {
        
        // Filter hanya workout tipe lari (running)
        let workoutType = HKObjectType.workoutType()
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        
        // Sort terbaru dulu, ambil 1 workout saja
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false // Descending = terbaru di atas
        )
        
        // Jalankan query sebagai async dengan withCheckedContinuation
        let workout = await withCheckedContinuation { (continuation: CheckedContinuation<HKWorkout?, Never>) in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: runningPredicate,
                limit: 1,               // Hanya perlu 1 workout terbaru
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Workout fetch error: \(error.localizedDescription)")
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: samples?.first as? HKWorkout)
            }
            healthStore.execute(query)
        }
        
        guard let workout = workout else { return } // Tidak ada workout history
        
        // Ambil statistik HR dari workout ini
        let avgHR = await fetchWorkoutHeartRate(workout: workout, statisticType: .discreteAverage)
        let minHR = await fetchWorkoutHeartRate(workout: workout, statisticType: .discreteMin)
        let maxHR = await fetchWorkoutHeartRate(workout: workout, statisticType: .discreteMax)
        
        // Hitung pace dari distance dan duration
        let distanceMeters = workout.totalDistance?.doubleValue(for: .meter()) ?? 0
        let distanceKm = distanceMeters / 1000.0
        let durationSeconds = workout.duration
        
        // Pace = detik per km, lalu konversi ke format "8'43""
        let paceString: String
        if distanceKm > 0 {
            let secondsPerKm = durationSeconds / distanceKm
            let paceMinutes = Int(secondsPerKm) / 60
            let paceSeconds = Int(secondsPerKm) % 60
            paceString = "\(paceMinutes)'\(String(format: "%02d", paceSeconds))\""
        } else {
            paceString = "--'--\""
        }
        
        // Format durasi total ke "MM:SS"
        let totalMinutes = Int(durationSeconds) / 60
        let totalSeconds = Int(durationSeconds) % 60
        let durationString = "\(totalMinutes):\(String(format: "%02d", totalSeconds))"
        
        // Format tanggal workout
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd MMM yyyy 'at' HH:mm" // contoh: "Friday, 01 May 2026 at 10:00"
        let dateString = formatter.string(from: workout.startDate)
        
        // Simpan semua data ke WorkoutSummary struct
        lastWorkout = WorkoutSummary(
            date: dateString,
            minHR: minHR.map { Int($0) },
            avgHR: avgHR.map { Int($0) },
            maxHR: maxHR.map { Int($0) },
            avgPace: paceString,
            distanceKm: distanceKm,
            totalTime: durationString
        )
    }
    
    // MARK: - Helper: Fetch HR Statistic dari Workout
    // Ambil min/avg/max HR khusus untuk satu workout tertentu
    private func fetchWorkoutHeartRate(workout: HKWorkout, statisticType: HKStatisticsOptions) async -> Double? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return nil }
        
        // Predicate: hanya sample dalam rentang waktu workout
        let predicate = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: predicate,
                options: statisticType
            ) { _, statistics, _ in
                let unit = HKUnit.count().unitDivided(by: .minute()) // BPM
                
                // Ambil nilai sesuai tipe statistik yang diminta
                var value: Double? = nil
                if statisticType == .discreteAverage {
                    value = statistics?.averageQuantity()?.doubleValue(for: unit)
                } else if statisticType == .discreteMin {
                    value = statistics?.minimumQuantity()?.doubleValue(for: unit)
                } else if statisticType == .discreteMax {
                    value = statistics?.maximumQuantity()?.doubleValue(for: unit)
                }
                
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
    
    // MARK: - Helper: Fetch Latest Quantity Sample
    // Generic helper untuk ambil 1 sample terbaru dari HealthKit (RHR, dll)
    private func fetchLatestQuantity(typeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Double? {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            return nil
        }
        
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierStartDate,
            ascending: false // Terbaru dulu
        )
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: nil, // Semua data, tidak difilter
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
    }
}

// MARK: - Data Models

// Model untuk satu zona HR
struct HeartRateZone: Identifiable {
    let id = UUID()
    let number: Int          // 1–5
    let name: String         // "The Sweet Spot", "Recovery", dll
    let intensity: String    // "60–70% Max Heart Rate"
    let low: Int             // Batas bawah BPM
    let high: Int            // Batas atas BPM
    let color: Color         // Warna zona
    let title: String        // Judul di detail card
    let description: String  // Deskripsi singkat
    let bullets: [String]    // Poin-poin di detail card
}

// Model untuk ringkasan workout terakhir
struct WorkoutSummary {
    let date: String
    let minHR: Int?          // Optional — mungkin tidak ada data HR
    let avgHR: Int?
    let maxHR: Int?
    let avgPace: String
    let distanceKm: Double
    let totalTime: String
}
