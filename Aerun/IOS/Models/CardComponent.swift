//
//  CardComponent.swift
//  Aerun
//
//  Komponen reusable untuk menampilkan satu metrik workout
//  (contoh: Min HR = 144 BPM, Distance = 3.12 km)
//
//  Cara pakai:
//  CardComponent(title: "Min HR", value: "144", unit: "BPM", valueColor: .cyan)
//

import SwiftUI

struct CardComponent: View {

    // MARK: - Properties

    let title: String       // Label atas kecil, contoh: "Min HR"
    let value: String       // Angka besar di tengah, contoh: "144"
    let unit: String        // Label bawah kecil, contoh: "BPM"
    let valueColor: Color   // Warna angka — tiap metrik punya warna beda sesuai design

    // MARK: - Environment
    // colorScheme dipakai untuk menyesuaikan warna background card di light/dark mode
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Label kecil di atas (contoh: "Min HR")
            // Pakai .secondary supaya otomatis jadi abu di kedua mode
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Angka utama — besar dan bold dengan warna khas masing-masing metrik
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(valueColor)

            // Satuan di bawah (contoh: "BPM", "km", "min")
            Text(unit)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Isi penuh lebar kolom grid
        .padding()
        // Background card: adaptive — gelap di dark mode, abu muda di light mode
        // Color(.secondarySystemBackground) adalah system color yang otomatis menyesuaikan
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Preview
#Preview {
    // Contoh penggunaan dalam grid seperti di HomeView dan HistoryView
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        CardComponent(title: "Min HR",   value: "144", unit: "BPM", valueColor: .cyan)
        CardComponent(title: "Avg HR",   value: "162", unit: "BPM", valueColor: .green)
        CardComponent(title: "Max HR",   value: "173", unit: "BPM", valueColor: .red)
        CardComponent(title: "Avg Pace", value: "8'43\"", unit: "/km", valueColor: .primary)
        CardComponent(title: "Distance", value: "3.12", unit: "km",  valueColor: .primary)
        CardComponent(title: "Total Time", value: "30:12", unit: "min", valueColor: .primary)
    }
    .padding()
    .background(Color(.systemBackground))
}
