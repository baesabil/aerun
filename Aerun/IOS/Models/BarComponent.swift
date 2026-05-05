//
//  BarComponent.swift
//  Aerun
//
//  Komponen reusable untuk baris progress bar zona HR di HistoryView.
//  Menampilkan: nomor zona | progress bar | durasi (menit) | persentase
//
//  Cara pakai:
//  BarComponent(zoneNumber: 2, minutes: 20, percent: 67, progress: 0.67, color: .green)
//

import SwiftUI

struct BarComponent: View {

    // MARK: - Properties

    let zoneNumber: Int    // Angka zona: 1–5
    let minutes: Int       // Berapa menit user di zona ini
    let percent: Int       // Persentase dari total durasi (0–100)
    let progress: Double   // Nilai 0.0–1.0 untuk lebar bar (percent / 100)
    let color: Color       // Warna zona (cyan, green, yellow, orange, red)

    // MARK: - Environment
    // Dipakai untuk menyesuaikan warna track bar di light/dark mode
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Body
    var body: some View {
        HStack(spacing: 14) {

            // --- Nomor Zona (kotak kecil berwarna) ---
            // Background pakai opacity 25% dari warna zona supaya tidak terlalu terang
            Text("\(zoneNumber)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // --- Progress Bar ---
            // GeometryReader dipakai supaya bar bisa mengisi sisa ruang secara dinamis
            GeometryReader { geometry in
                ZStack(alignment: .leading) {

                    // Track (background bar) — warna berbeda di light/dark mode
                    Capsule()
                        // Dark mode: putih transparan | Light mode: hitam transparan
                        .fill(colorScheme == .dark
                              ? Color.white.opacity(0.18)
                              : Color.black.opacity(0.10))
                        .frame(height: 10)

                    // Fill bar — hanya tampil kalau ada progress
                    if progress > 0 {
                        Capsule()
                            .fill(color)
                            // Lebar bar = total lebar × progress (0.0–1.0)
                            .frame(width: geometry.size.width * progress, height: 10)
                    }
                }
            }
            .frame(height: 10) // GeometryReader butuh explicit height

            // --- Durasi (menit) ---
            // Kalau 0 menit, tampilkan dengan warna abu supaya jelas tidak aktif
            Text("\(minutes) min")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(minutes == 0 ? .secondary : .primary)
                .frame(width: 52, alignment: .trailing)

            // --- Persentase ---
            Text("\(percent)%")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 10) {
        BarComponent(zoneNumber: 1, minutes: 4,  percent: 13, progress: 0.13, color: .cyan)
        BarComponent(zoneNumber: 2, minutes: 20, percent: 67, progress: 0.67, color: .green)
        BarComponent(zoneNumber: 3, minutes: 4,  percent: 13, progress: 0.13, color: .yellow)
        BarComponent(zoneNumber: 4, minutes: 2,  percent: 7,  progress: 0.07, color: .orange)
        BarComponent(zoneNumber: 5, minutes: 0,  percent: 0,  progress: 0.0,  color: .red)
    }
    .padding()
    .background(Color(.systemBackground))
}
