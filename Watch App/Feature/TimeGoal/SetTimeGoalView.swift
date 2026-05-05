import SwiftUI

struct SetTimeGoalView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    // state untuk nilai picker yang dipilih user
    @State private var selectedHours: Int = 0        // jam (0-23)
    @State private var selectedMinutes: Int = 35     // menit (0-59)
    @State private var navigateToCountdown: Bool = false // trigger navigasi ke countdown

    // range pilihan jam dan menit
    private let hours = Array(0...23)
    private let minutes = Array(0...59)

    var body: some View {
        VStack(spacing: 0) {

            Spacer() // ← dorong picker ke tengah/bawah

            // baris picker jam & menit
            HStack(spacing: 0) { // ← JARAK antara picker dan titik dua → ubah angka ini

                // picker JAM
                Picker("", selection: $selectedHours) {
                    ForEach(hours, id: \.self) { h in
                        Text(String(format: "%02d", h)) // format 2 digit
                            .font(.system(size: 22, weight: .semibold, design: .monospaced)) // ← UKURAN FONT ANGKA
                            .foregroundColor(.white)
                            .tag(h)
                    }
                }
                .frame(width: 55, height: 90) // ← LEBAR & TINGGI kotak picker jam

                // pemisah titik dua
                Text(":")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4) // ← JARAK titik dua ke kiri/kanan

                // picker MENIT
                Picker("", selection: $selectedMinutes) {
                    ForEach(minutes, id: \.self) { m in
                        Text(String(format: "%02d", m)) // format 2 digit
                            .font(.system(size: 22, weight: .semibold, design: .monospaced)) // ← UKURAN FONT ANGKA
                            .foregroundColor(.white)
                            .tag(m)
                    }
                }
                .frame(width: 55, height: 90) // ← LEBAR & TINGGI kotak picker menit
            }

            Spacer() // ← dorong tombol Done ke bawah
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // full screen
        .background(Color.black) // background hitam
        .navigationTitle("Time Goal")           // judul di kanan atas
        .navigationBarTitleDisplayMode(.inline) // inline dengan back button
        .navigationDestination(isPresented: $navigateToCountdown) {
            CountdownView() // navigasi ke countdown setelah Done
        }
        // tombol Done pinned ke bawah — HIG "pinned pill button"
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Done") {
                    let total = (selectedHours * 3600) + (selectedMinutes * 60) // hitung total detik
                    appState.timeGoalSeconds = total > 0 ? total : nil // simpan ke AppState
                    navigateToCountdown = true // trigger navigasi ke countdown
                }
                .tint(Color(red: 0.0, green: 0.75, blue: 0.72)) // ← WARNA tombol Done
                .buttonStyle(.borderedProminent) // style pill bawaan watchOS
                .foregroundColor(.black)         // warna teks
                .fontWeight(.semibold)           // ketebalan font
            }
        }
    }
}
