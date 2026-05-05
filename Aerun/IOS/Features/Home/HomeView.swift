//
//  HomeView.swift
//  Aerun
//

import SwiftUI

struct HomeView: View {
    
    // MARK: - ViewModel
    // @StateObject artinya HomeView yang "owning" viewmodel ini — tidak akan di-recreate saat redraw
    @StateObject private var vm = HomeViewModel()
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background hitam full screen
                Color.black.ignoresSafeArea()
                
                // Kalau masih loading data HealthKit, tampilkan spinner dulu
                if vm.isLoading {
                    loadingView
                } else {
                    // Data sudah siap — tampilkan konten utama
                    mainContent
                }
            }
        }
        // Panggil loadData() sekali saat view pertama muncul
        .onAppear {
            vm.loadData()
        }
    }
    
    // MARK: - Loading View
    // Tampilan sementara selagi HealthKit query berjalan
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.2)
            Text("Loading your data...")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }
    
    // MARK: - Main Content
    // Scroll view utama yang berisi semua section
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                
                // "Hello, Yookie!" di kiri atas
                greetingSection
                
                // "Your Safe running Heart Rate range is 147–157 BPM"
                safeZoneHeroSection
                
                // Tab zone selector + detail card
                zoneSection
                
                // Previous exercise — beda tampilan kalau ada/tidak ada workout
                previousExerciseSection
                
                Spacer(minLength: 40) // Padding bawah supaya tidak ketutup home indicator
            }
            .padding(.horizontal, 24) // Margin kiri-kanan konsisten
            .padding(.top, 20)
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        // "Hello, " biasa + nama user tebal
        HStack(spacing: 0) {
            Text("Hello, ")
                .font(.title2)
                .foregroundStyle(.white)
            Text("\(vm.userName)!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
    }
    
    // MARK: - Safe Zone Hero Section
    // Blok besar "Your Safe running Heart Rate range is 147–157 BPM"
    private var safeZoneHeroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Teks multi-style dalam satu baris: sebagian regular, sebagian bold
            // Pakai Group + Text concatenation supaya wrap natural
            VStack(alignment: .leading, spacing: 0) {
                Text("Your ")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                +
                Text("Safe")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                +
                Text(" running")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                
                Text("Heart Rate")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)
                +
                Text(" range is")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
            
            // Angka BPM besar + badge "BPM" di sampingnya
            HStack(alignment: .center, spacing: 12) {
                
                // Angka zona — font besar, italic, hijau
                Text("\(vm.safeZoneLow)–\(vm.safeZoneHigh)")
                    .font(.system(size: 52, weight: .heavy, design: .default))
                    .italic()
                    .foregroundStyle(.green)
                
                // Badge "BPM" — rounded dark green
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
    // "Know your range" + tab selector + detail card zona
    private var zoneSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Label section
            HStack(spacing: 4) {
                Text("Know your ")
                    .font(.body)
                    .foregroundStyle(.white)
                Text("range")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            
            // Tab bar zona: ZONE 1 – ZONE 5
            // ScrollView horizontal supaya muat di semua ukuran layar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(vm.allZones.enumerated()), id: \.offset) { index, zone in
                        
                        // Tombol zona — aktif kalau selectedZoneIndex == index
                        Button {
                            vm.selectedZoneIndex = index // Update pilihan
                        } label: {
                            Text("ZONE \(zone.number)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(vm.selectedZoneIndex == index ? .black : .gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                // Background: warna zona kalau aktif, abu gelap kalau tidak
                                .background(
                                    vm.selectedZoneIndex == index
                                    ? zone.color
                                    : Color.white.opacity(0.12)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
            }
            
            // Detail card untuk zona yang sedang dipilih
            if !vm.allZones.isEmpty {
                zoneDetailCard(zone: vm.allZones[vm.selectedZoneIndex])
            }
        }
    }
    
    // MARK: - Zone Detail Card
    // Kartu hijau gelap yang menampilkan detail zona terpilih
    private func zoneDetailCard(zone: HeartRateZone) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header: nama zona + range BPM
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(zone.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text(zone.intensity)
                        .font(.caption)
                        .foregroundStyle(zone.color.opacity(0.8))
                }
                
                Spacer()
                
                // Range BPM di pojok kanan
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(zone.low)–\(zone.high)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .italic()
                        .foregroundStyle(zone.color)
                    Text("BPM")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            // Judul italic + bullet points
            Text(zone.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .italic()
                .foregroundStyle(.white)
            
            // Bullet points dari array
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(zone.bullets.enumerated()), id: \.offset) { index, bullet in
                    HStack(alignment: .top, spacing: 8) {
                        // Icon berbeda untuk bullet pertama dan seterusnya — sesuai design
                        Image(systemName: index == 0 ? "star.fill" : "info.circle.fill")
                            .font(.caption)
                            .foregroundStyle(zone.color)
                        
                        Text(bullet)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true) // Biar text wrap
                    }
                }
            }
        }
        .padding(16)
        .background(
            // Background card: warna zona gelap transparan
            zone.color.opacity(0.15)
        )
        .overlay(
            // Border tipis sesuai warna zona
            RoundedRectangle(cornerRadius: 16)
                .stroke(zone.color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Previous Exercise Section
    // Tampil beda tergantung ada/tidak workout history
    private var previousExerciseSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Header: "Previous exercise" + "See more" kalau ada data
            HStack {
                HStack(spacing: 4) {
                    Text("Previous ")
                        .font(.body)
                        .foregroundStyle(.white)
                    Text("exercise")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                // "See more" hanya muncul kalau ada workout data
                if vm.lastWorkout != nil {
                    NavigationLink(destination: HistoryView()) {
                        Text("See more")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            // Pilih tampilan berdasarkan ada/tidaknya workout
            if let workout = vm.lastWorkout {
                workoutGrid(workout: workout) // Ada data — tampil grid metrik
            } else {
                emptyWorkoutMessage       // Belum ada — tampil pesan
            }
        }
    }
    
    // MARK: - Empty State
    // Pesan kalau belum ada workout history di HealthKit
    private var emptyWorkoutMessage: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Open ")
                .font(.title2)
                .foregroundStyle(.white)
            +
            Text("\"Aerun\"")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            +
            Text(" on ")
                .font(.title2)
                .foregroundStyle(.white)
            +
            Text("Watch")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            +
            Text(" to record a new exercise.")
                .font(.title2)
                .foregroundStyle(.white)
        }
    }
    
    // MARK: - Workout Grid
    // Grid 3x2 dengan metrik dari workout terakhir
    private func workoutGrid(workout: WorkoutSummary) -> some View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return LazyVGrid(columns: columns, spacing: 12) {
            // HR metrics — pakai optional dengan fallback "--"
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
            
            // Pace, distance, time — warna putih
            CardComponent(
                title: "Avg Pace",
                value: workout.avgPace,
                unit: "/km",
                valueColor: .white
            )
            CardComponent(
                title: "Distance",
                value: String(format: "%.2f", workout.distanceKm), // 2 desimal
                unit: "km",
                valueColor: .white
            )
            CardComponent(
                title: "Total Time",
                value: workout.totalTime,
                unit: "min",
                valueColor: .white
            )
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
