//
//  HistoryView.swift
//  Aerun
//
//  Menampilkan riwayat semua sesi lari dari HealthKit.
//
//  PENTING: Data bisa berasal dari:
//  ✅ Apple Watch Workout app bawaan Apple
//  ✅ Nike Run Club, Strava, dan app lain yang menyimpan ke HealthKit
//  ✅ Aerun Watch app (ketika sudah bisa di-deploy)
//
//  Semua workout yang tersimpan di HealthKit sebagai HKWorkoutActivityType.running
//  akan muncul di sini secara otomatis — TIDAK perlu Watch app Aerun aktif!
//
//  Mendukung Light & Dark Mode via semantic colors.
//

import SwiftUI
import HealthKit

// MARK: - HistoryView
struct HistoryView: View {

    // @Environment(\.dismiss) = cara dismiss view ini (pop dari navigation stack)
    @Environment(\.dismiss) private var dismiss

    // ViewModel khusus untuk HistoryView — fetch semua workout dari HealthKit
    @StateObject private var vm = HistoryViewModel()

    // Grid 3 kolom untuk stats cards
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background adaptive — putih di light mode, hitam di dark mode
            Color(.systemBackground)
                .ignoresSafeArea()

            if vm.isLoading {
                loadingView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {

                        // Tombol back kustom (karena .navigationBarBackButtonHidden(true))
                        backButton

                        if vm.workouts.isEmpty {
                            // Belum ada workout running di HealthKit user
                            emptyState
                        } else {
                            // Ada data — tampilkan setiap workout dalam card
                            ForEach(vm.workouts) { item in
                                workoutCard(item)
                                    .padding(.horizontal, 25)

                                // Divider antar workout
                                Divider()
                                    .background(Color.secondary.opacity(0.3))
                                    .padding(.horizontal, 25)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 16)
                }
            }
        }
        // Sembunyikan back button bawaan NavigationStack —
        // kita punya tombol kustom sendiri supaya sesuai design
        .navigationBarBackButtonHidden(true)
        // Fetch data saat view muncul
        .onAppear { vm.load() }
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.primary)
                .scaleEffect(1.2)
            Text("Loading history...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Back Button
    // Tombol kustom berbentuk lingkaran dengan icon chevron
    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left")
                .font(.title2)
                .fontWeight(.semibold)
                // Warna icon selalu dark supaya kontras di atas background putih/abu terang
                .foregroundStyle(Color(.systemBackground))
                .frame(width: 54, height: 54)
                // Background: material yang adaptive — abu di dark, abu muda di light
                .background(Color(.label).opacity(0.7))
                .clipShape(Circle())
        }
        .padding(.horizontal, 25)
    }

    // MARK: - Empty State
    // Tampil kalau belum ada data running di HealthKit
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("No runs recorded yet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text("Runs recorded with Apple Watch Workout app, Nike Run Club, Strava, or Aerun Watch will appear here automatically.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Single Workout Card
    // Menampilkan satu sesi lari: header + stats grid + zone breakdown
    @ViewBuilder
    private func workoutCard(_ item: WorkoutHistoryItem) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            // --- Header: judul + tanggal + icon ---
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Outdoor Run")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Spacer()

                    // Icon lari di pojok kanan
                    Image(systemName: "figure.run")
                        .font(.largeTitle)
                        .foregroundStyle(.mint)
                }

                // Tanggal workout (contoh: "Friday, 01 May 2026 at 10:00")
                Text(item.dateString)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            // --- Stats Grid 3×2 ---
            // CardComponent sekarang adaptive — pakai Color(.secondarySystemBackground)
            LazyVGrid(columns: columns, spacing: 14) {
                CardComponent(
                    title: "Min HR",
                    value: item.minHR.map { "\($0)" } ?? "--",
                    unit: "BPM",
                    valueColor: .cyan
                )
                CardComponent(
                    title: "Avg HR",
                    value: item.avgHR.map { "\($0)" } ?? "--",
                    unit: "BPM",
                    valueColor: .green
                )
                CardComponent(
                    title: "Max HR",
                    value: item.maxHR.map { "\($0)" } ?? "--",
                    unit: "BPM",
                    valueColor: .red
                )
                CardComponent(title: "Avg Pace",  value: item.avgPace,  unit: "/km", valueColor: .primary)
                CardComponent(title: "Distance",   value: String(format: "%.2f", item.distanceKm), unit: "km", valueColor: .primary)
                CardComponent(title: "Total Time", value: item.totalTime, unit: "min", valueColor: .primary)
            }

            // --- HR Training Zones Breakdown ---
            // Menampilkan berapa menit user di tiap zona selama workout ini
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 4) {
                    Text("Heart Rate")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text("Training Zones")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                // BarComponent untuk setiap zona (1–5)
                VStack(spacing: 10) {
                    ForEach(item.zoneBreakdown) { zone in
                        BarComponent(
                            zoneNumber: zone.zoneNumber,  // 1–5 (bukan 0–5!)
                            minutes: zone.minutes,
                            percent: zone.percent,
                            progress: zone.progress,
                            color: zone.color
                        )
                    }
                }
            }
        }
    }
}

// MARK: - HistoryViewModel
// Mengambil SEMUA workout lari dari HealthKit (bukan hanya 1 terakhir seperti HomeViewModel)
// Limit 20 workout — cukup untuk tampilan history tanpa terlalu berat

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published var workouts: [WorkoutHistoryItem] = []
    @Published var isLoading = true

    private let healthStore = HKHealthStore()

    // Dipanggil saat HistoryView.onAppear
    func load() {
        Task {
            await fetchWorkouts()
            isLoading = false
        }
    }

    // MARK: - Fetch All Running Workouts
    private func fetchWorkouts() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let workoutType  = HKObjectType.workoutType()
        let runPredicate = HKQuery.predicateForWorkouts(with: .running)
        let sort         = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        // Ambil 20 workout lari terbaru
        let samples: [HKWorkout] = await withCheckedContinuation { cont in
            let q = HKSampleQuery(
                sampleType: workoutType,
                predicate: runPredicate,
                limit: 20,               // Batasi 20 supaya tidak terlalu berat
                sortDescriptors: [sort]
            ) { _, s, _ in
                cont.resume(returning: (s as? [HKWorkout]) ?? [])
            }
            healthStore.execute(q)
        }

        // Build setiap item secara sequential (HR query per workout butuh waktu)
        var items: [WorkoutHistoryItem] = []
        for w in samples {
            let item = await buildItem(from: w)
            items.append(item)
        }
        workouts = items
    }

    // MARK: - Build WorkoutHistoryItem dari HKWorkout
    // Mengambil semua detail satu workout: HR statistik, pace, durasi, zona
    private func buildItem(from workout: HKWorkout) async -> WorkoutHistoryItem {
        // Fetch min/avg/max HR secara parallel tidak aman di aktor, biarkan sequential
        let avgHR = await fetchHR(workout: workout, option: .discreteAverage)
        let minHR = await fetchHR(workout: workout, option: .discreteMin)
        let maxHR = await fetchHR(workout: workout, option: .discreteMax)

        // Hitung jarak dan pace
        let distM  = workout.totalDistance?.doubleValue(for: .meter()) ?? 0
        let distKm = distM / 1000.0
        let dur    = workout.duration

        // Pace: detik per km → format "M'SS\""
        let pace: String
        if distKm > 0 {
            let spk = dur / distKm
            pace    = "\(Int(spk)/60)'\(String(format: "%02d", Int(spk)%60))\""
        } else {
            pace    = "--'--\""
        }

        // Durasi total: "MM:SS"
        let durStr = "\(Int(dur)/60):\(String(format: "%02d", Int(dur)%60))"

        // Format tanggal
        let fmt        = DateFormatter()
        fmt.dateFormat = "EEEE, dd MMM yyyy 'at' HH:mm"
        let dateStr    = fmt.string(from: workout.startDate)

        // Hitung zona breakdown dari HR sample dalam workout
        let zones = await buildZoneBreakdown(workout: workout, totalDuration: dur)

        return WorkoutHistoryItem(
            dateString: dateStr,
            minHR: minHR.map { Int($0) },
            avgHR: avgHR.map { Int($0) },
            maxHR: maxHR.map { Int($0) },
            avgPace: pace,
            distanceKm: distKm,
            totalTime: durStr,
            zoneBreakdown: zones
        )
    }

    // MARK: - Fetch HR Statistic per Workout
    // HKStatisticsQuery = query untuk mendapatkan nilai agregat (min, max, avg)
    private func fetchHR(workout: HKWorkout, option: HKStatisticsOptions) async -> Double? {
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return nil }

        let pred = HKQuery.predicateForSamples(
            withStart: workout.startDate,
            end: workout.endDate,
            options: .strictStartDate
        )

        return await withCheckedContinuation { cont in
            let q = HKStatisticsQuery(
                quantityType: hrType,
                quantitySamplePredicate: pred,
                options: option
            ) { _, stats, _ in
                let unit = HKUnit.count().unitDivided(by: .minute())
                var v: Double? = nil
                switch option {
                case .discreteAverage: v = stats?.averageQuantity()?.doubleValue(for: unit)
                case .discreteMin:     v = stats?.minimumQuantity()?.doubleValue(for: unit)
                case .discreteMax:     v = stats?.maximumQuantity()?.doubleValue(for: unit)
                default: break
                }
                cont.resume(returning: v)
            }
            healthStore.execute(q)
        }
    }

    // MARK: - Build Zone Breakdown
    // Menghitung berapa detik user berada di tiap zona HR selama workout
    // Caranya: ambil semua HR sample → untuk setiap sample, lihat bpm-nya masuk zona mana
    private func buildZoneBreakdown(workout: HKWorkout, totalDuration: Double) async -> [ZoneStat] {

        // Ambil profil user untuk hitung zona
        let age: Int = {
            if let c = try? healthStore.dateOfBirthComponents(), let y = c.year {
                return Calendar.current.component(.year, from: Date()) - y
            }
            return 25  // Default fallback
        }()
        let isMale = (try? healthStore.biologicalSex())?.biologicalSex == .male
        let hrMax  = Double(isMale ? 220 - age : 226 - age)
        let rhr    = 60.0  // Simplified fallback — ideal: fetch RHR terbaru dari HealthKit
        let hrr    = hrMax - rhr

        // Batas zona (lo, hi, warna) — sama dengan HomeViewModel
        let bounds: [(lo: Double, hi: Double, color: Color)] = [
            (hrr * 0.50 + rhr, hrr * 0.60 + rhr, .cyan),
            (hrr * 0.60 + rhr, hrr * 0.70 + rhr, .green),
            (hrr * 0.70 + rhr, hrr * 0.80 + rhr, .yellow),
            (hrr * 0.80 + rhr, hrr * 0.90 + rhr, .orange),
            (hrr * 0.90 + rhr, hrr * 1.00 + rhr, .red),
        ]

        // Fetch semua HR sample dalam workout (sorted ascending by time)
        guard let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return dummyZones(bounds: bounds, totalDuration: totalDuration)
        }
        let pred = HKQuery.predicateForSamples(
            withStart: workout.startDate, end: workout.endDate, options: .strictStartDate
        )
        let unit = HKUnit.count().unitDivided(by: .minute())

        let samples: [HKQuantitySample] = await withCheckedContinuation { cont in
            let q = HKSampleQuery(
                sampleType: hrType,
                predicate: pred,
                limit: HKObjectQueryNoLimit,  // Semua HR sample dalam workout
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, s, _ in cont.resume(returning: (s as? [HKQuantitySample]) ?? []) }
            healthStore.execute(q)
        }

        // Kalau tidak ada HR sample (misal dari simulator), pakai proporsi dummy
        guard !samples.isEmpty else {
            return dummyZones(bounds: bounds, totalDuration: totalDuration)
        }

        // Hitung durasi per zona:
        // Anggap setiap sample HR berlaku dari waktunya sampai sample berikutnya mulai
        var zoneSec = [Double](repeating: 0, count: 5)
        for i in 0..<samples.count {
            let s   = samples[i]
            let bpm = s.quantity.doubleValue(for: unit)
            // Durasi sample = jarak waktu ke sample berikutnya (atau ke akhir workout)
            let dur: Double = i + 1 < samples.count
                ? samples[i + 1].startDate.timeIntervalSince(s.startDate)
                : workout.endDate.timeIntervalSince(s.startDate)

            // Masukkan ke zona yang sesuai
            for z in 0..<5 where bpm >= bounds[z].lo && bpm < bounds[z].hi {
                zoneSec[z] += dur
                break
            }
        }

        // Konversi detik → ZoneStat model
        return (0..<5).map { z in
            let mins = Int(zoneSec[z] / 60)
            let pct  = totalDuration > 0 ? Int(zoneSec[z] / totalDuration * 100) : 0
            let prog = totalDuration > 0 ? min(zoneSec[z] / totalDuration, 1.0) : 0
            return ZoneStat(zoneNumber: z + 1, minutes: mins, percent: pct, progress: prog, color: bounds[z].color)
        }
    }

    // MARK: - Dummy Zones (Simulator / no HR data)
    // Dipakai saat simulator tidak punya HR sample nyata
    private func dummyZones(bounds: [(lo: Double, hi: Double, color: Color)], totalDuration: Double) -> [ZoneStat] {
        let dummyPct = [13, 67, 13, 7, 0]  // Distribusi realistik untuk runner pemula
        return (0..<5).map { z in
            ZoneStat(
                zoneNumber: z + 1,
                minutes: Int(totalDuration / 60 * Double(dummyPct[z]) / 100),
                percent: dummyPct[z],
                progress: Double(dummyPct[z]) / 100.0,
                color: bounds[z].color
            )
        }
    }
}

// MARK: - Data Models

// Model untuk satu item di daftar history
struct WorkoutHistoryItem: Identifiable {
    let id = UUID()
    let dateString: String
    let minHR: Int?
    let avgHR: Int?
    let maxHR: Int?
    let avgPace: String
    let distanceKm: Double
    let totalTime: String
    let zoneBreakdown: [ZoneStat]   // Array 5 zona (Zone 1–5)
}

// Model untuk satu baris zona di BarComponent
struct ZoneStat: Identifiable {
    let id = UUID()
    let zoneNumber: Int   // 1–5 ✅ selalu mulai dari 1, bukan 0
    let minutes: Int
    let percent: Int
    let progress: Double  // 0.0–1.0 untuk lebar bar
    let color: Color
}

// MARK: - Preview
#Preview {
    NavigationStack {
        HistoryView()
    }
}
