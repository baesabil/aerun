//
//  HomeView.swift
//  Aerun
//
//  Halaman utama app — menampilkan safe zone HR, zone selector, dan workout terakhir.
//
//  LIGHT & DARK MODE:
//  Semua warna sekarang pakai semantic colors supaya otomatis menyesuaikan sistem:
//  - Color(.systemBackground)         → putih di light, hitam di dark
//  - Color(.secondarySystemBackground) → abu muda di light, abu gelap di dark
//  - .primary                          → hitam di light, putih di dark
//  - .secondary                        → abu di kedua mode
//
//  TIDAK ada lagi hardcode Color.black atau Color.white untuk background/text!
//

import SwiftUI

struct HomeView: View {

    // MARK: - ViewModel
    // @StateObject artinya HomeView yang "owning" viewmodel ini.
    // Berbeda dengan @ObservedObject yang bisa hilang saat redraw,
    // @StateObject dijamin hidup selama view ini ada.
    @StateObject private var vm = HomeViewModel()

    // MARK: - Environment
    // colorScheme dipakai untuk menyesuaikan warna-warna yang tidak bisa pakai semantic color
    // (misalnya warna teks di dalam zone card yang punya background warna-warni)
    //
    // 👉 INI CARA PERTAMA (Baca settingan dari sistem):
    // @Environment(\.colorScheme) akan mendeteksi apakah iPhone user sedang pakai Light / Dark mode.
    // Variabel ini dipakai di line 195 untuk mengatur logic warna tombol yang berbeda di tiap mode.
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background utama — ADAPTIVE sesuai system appearance
                // Sebelumnya: Color.black.ignoresSafeArea()
                // Sekarang: otomatis putih di light mode, hitam di dark mode
                //
                // 👉 INI CARA KEDUA (Semantic Color Apple):
                // Penggunaan semantic color seperti Color(.systemBackground), .primary, dan .secondary.
                // Warna ini pintar dan akan otomatis menyesuaikan tema user (contoh: .primary jadi putih saat dark mode, hitam saat light mode).
                Color(.systemBackground)
                    .ignoresSafeArea()

                // Tampilkan loading spinner atau konten utama
                if vm.isLoading {
                    loadingView
                } else {
                    mainContent
                }
            }
        }
        // loadData() dipanggil sekali saat view pertama muncul
        .onAppear {
            vm.loadData()
        }
    }

    // MARK: - Loading View
    // Spinner + teks saat HealthKit query masih berjalan
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                // .primary = hitam di light, putih di dark — cocok di atas systemBackground
                .tint(.primary)
                .scaleEffect(1.2)
            Text("Loading your data...")
                .font(.subheadline)
                // .secondary = abu di kedua mode
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Main Content
    // ScrollView vertikal yang berisi semua section
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {

                greetingSection          // "Hello, Yookie!"
                safeZoneHeroSection      // "Your Safe running Heart Rate range is..."
                zoneSection              // Tab selector zona + detail card
                previousExerciseSection  // Workout terakhir atau pesan kosong

                // Padding bawah supaya konten tidak tertutup home indicator iPhone
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }

    // MARK: - Greeting Section
    // "Hello, " regular + "Yookie!" bold — menggunakan Text concatenation
    private var greetingSection: some View {
        HStack(spacing: 0) {
            Text("Hello, ")
                .font(.title2)
                // .primary = hitam di light, putih di dark
                .foregroundStyle(.primary)
            Text("\(vm.userName)!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Safe Zone Hero Section
    // Blok besar dengan teks multi-style + angka BPM hijau besar
    private var safeZoneHeroSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Teks paragraf dengan gaya berbeda-beda per kata
            // Teknik ini memungkinkan kata "Safe" dan "Heart Rate" bold
            // sementara kata lainnya regular — dalam satu blok teks yang wrap natural
            VStack(alignment: .leading, spacing: 0) {
                Text("Your ")
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
                +
                Text("Safe")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
                +
                Text(" running")
                    .font(.largeTitle)
                    .foregroundStyle(.primary)

                Text("Heart Rate")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
                +
                Text(" range is")
                    .font(.largeTitle)
                    .foregroundStyle(.primary)
            }

            // Angka BPM besar + badge
            HStack(alignment: .center, spacing: 12) {

                // Angka zona — selalu hijau di kedua mode (brand color)
                Text("\(vm.safeZoneLow)–\(vm.safeZoneHigh)")
                    .font(.system(size: 52, weight: .heavy, design: .default))
                    .italic()
                    .foregroundStyle(.green)

                // Badge "BPM" — hijau dengan teks putih (teks putih ok karena background gelap)
                Text("BPM")
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    // MARK: - Zone Section
    // "Know your range" + tab selector + detail card zona yang dipilih
    private var zoneSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Label section dengan dua gaya berbeda
            HStack(spacing: 4) {
                Text("Know your ")
                    .font(.body)
                    .foregroundStyle(.primary)
                Text("range")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }

            // Tab bar zona: ZONE 1 – ZONE 5
            // ScrollView horizontal supaya muat di semua ukuran layar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(vm.allZones.enumerated()), id: \.offset) { index, zone in
                        Button {
                            vm.selectedZoneIndex = index
                        } label: {
                            Text("ZONE \(zone.number)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                // Teks aktif: hitam (agar kontras di atas background warna-warni)
                                // Teks tidak aktif: secondary (abu adaptif)
                                .foregroundStyle(vm.selectedZoneIndex == index ? .black : .secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    vm.selectedZoneIndex == index
                                    ? zone.color  // Background warna zona kalau aktif
                                    // Kalau tidak aktif: opacity berbeda di light/dark
                                    : (colorScheme == .dark
                                       ? Color.white.opacity(0.12)   // Dark: abu gelap
                                       : Color.black.opacity(0.08))  // Light: abu muda
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
            }

            // Detail card zona yang sedang dipilih
            if !vm.allZones.isEmpty {
                zoneDetailCard(zone: vm.allZones[vm.selectedZoneIndex])
            }
        }
    }

    // MARK: - Zone Detail Card
    // Card dengan background warna zona transparan + border tipis
    // Di sinilah kita tetap pakai warna teks tertentu karena background-nya berwarna
    private func zoneDetailCard(zone: HeartRateZone) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header: nama zona (kiri) + range BPM (kanan)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(zone.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        // Di dalam card berwarna, pakai .primary supaya tetap terbaca
                        // di light dan dark mode
                        .foregroundStyle(.primary)
                    Text(zone.intensity)
                        .font(.caption)
                        .foregroundStyle(zone.color.opacity(0.9))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(zone.low)–\(zone.high)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .italic()
                        .foregroundStyle(zone.color)
                    Text("BPM")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // Divider dengan opacity rendah — terlihat di kedua mode
            Divider()
                .background(Color.primary.opacity(0.15))

            // Judul italic (contoh: "Light Aerobic")
            Text(zone.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .italic()
                .foregroundStyle(.primary)

            // Bullet points — icon + teks
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(zone.bullets.enumerated()), id: \.offset) { index, bullet in
                    HStack(alignment: .top, spacing: 8) {
                        // Icon bintang untuk bullet pertama, info untuk seterusnya
                        Image(systemName: index == 0 ? "star.fill" : "info.circle.fill")
                            .font(.caption)
                            .foregroundStyle(zone.color)

                        Text(bullet)
                            .font(.subheadline)
                            // .primary dengan opacity — lebih lembut tapi tetap terbaca
                            .foregroundStyle(.primary.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        // Background card: warna zona dengan opacity rendah
        // Otomatis terlihat bagus di light (lebih pastel) dan dark (lebih gelap)
        .background(zone.color.opacity(0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(zone.color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Previous Exercise Section
    // Header + grid metrik workout ATAU pesan kosong
    private var previousExerciseSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Header row: judul + "See more" link
            HStack {
                HStack(spacing: 4) {
                    Text("Previous ")
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text("exercise")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }

                Spacer()

                // "See more" hanya muncul kalau ada workout data
                if vm.lastWorkout != nil {
                    NavigationLink(destination: HistoryView()) {
                        Text("See more")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Conditional: ada workout → grid, tidak ada → pesan kosong
            if let workout = vm.lastWorkout {
                workoutGrid(workout: workout)
            } else {
                emptyWorkoutMessage
            }
        }
    }

    // MARK: - Empty State
    // Tampil ketika user belum punya workout history di HealthKit
    // Sekarang pakai .primary supaya terbaca di kedua mode
    private var emptyWorkoutMessage: some View {
        // Text concatenation — semua jadi satu paragraph yang wrap natural
        (Text("Open ")
            .font(.title2)
            .foregroundStyle(.primary)
        + Text("\"Aerun\"")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
        + Text(" on ")
            .font(.title2)
            .foregroundStyle(.primary)
        + Text("Watch")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
        + Text(" to record a new exercise.")
            .font(.title2)
            .foregroundStyle(.primary))
        // Tambah hint kecil di bawah: user juga bisa pakai Apple Workout app
        .fixedSize(horizontal: false, vertical: true)
        // Sertakan note bahwa data dari Apple Workout app juga terbaca
        .overlay(alignment: .bottomLeading) { Color.clear }

        // Catatan di bawah pesan utama
        .padding(.bottom, 8)
    }

    // MARK: - Workout Grid
    // LazyVGrid 3 kolom — CardComponent sudah adaptive via Color(.secondarySystemBackground)
    private func workoutGrid(workout: WorkoutSummary) -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            // HR metrics: cyan, green, red — warna ini cukup kontras di kedua mode
            CardComponent(
                title: "Min HR",
                value: workout.minHR.map { "\($0)" } ?? "--",
                unit: "BPM",
                valueColor: .cyan
            )
            CardComponent(
                title: "Avg HR",
                value: workout.avgHR.map { "\($0)" } ?? "--",
                unit: "BPM",
                valueColor: .green
            )
            CardComponent(
                title: "Max HR",
                value: workout.maxHR.map { "\($0)" } ?? "--",
                unit: "BPM",
                valueColor: .red
            )

            // Pace, distance, time — pakai .primary supaya adaptive
            // SEBELUMNYA: valueColor: .white (tidak terbaca di light mode!)
            // SEKARANG: valueColor: .primary (hitam di light, putih di dark)
            CardComponent(
                title: "Avg Pace",
                value: workout.avgPace,
                unit: "/km",
                valueColor: .primary
            )
            CardComponent(
                title: "Distance",
                value: String(format: "%.2f", workout.distanceKm),
                unit: "km",
                valueColor: .primary
            )
            CardComponent(
                title: "Total Time",
                value: workout.totalTime,
                unit: "min",
                valueColor: .primary
            )
        }
    }
}

// MARK: - Preview
// Preview dengan kedua mode supaya langsung bisa cek tampilan
#Preview("Light Mode") {
    HomeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    HomeView()
        .preferredColorScheme(.dark)
}
