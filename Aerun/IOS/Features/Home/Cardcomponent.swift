//
//  CardComponent.swift
//  Aerun
//

import SwiftUI

// Komponen kartu kecil yang menampilkan satu metrik (HR, pace, distance, dll)
// Dipakai di HomeView dan HistoryView untuk grid 3x2
struct CardComponent: View {
    
    // MARK: - Properties
    let title: String       // Label di atas, contoh: "Min HR"
    let value: String       // Angka utama, contoh: "144"
    let unit: String        // Satuan di bawah value, contoh: "BPM"
    let valueColor: Color   // Warna angka utama (cyan, green, red, atau white)
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            // Label judul di pojok kiri atas
            Text(title)
                .font(.caption)               // Font kecil
                .foregroundStyle(.gray)        // Warna abu sesuai design
            
            // Angka utama — ini yang paling menonjol
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(valueColor)   // Warna dinamis sesuai parameter
            
            // Satuan di bawah angka
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.gray)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Konten rata kiri, kartu full width
        .padding(12)                                      // Padding dalam kartu
        .background(Color.white.opacity(0.08))            // Background gelap transparan
        .clipShape(RoundedRectangle(cornerRadius: 14))    // Sudut rounded sesuai HIG
    }
}

// MARK: - Preview
#Preview {
    HStack {
        CardComponent(title: "Min HR", value: "144", unit: "BPM", valueColor: .cyan)
        CardComponent(title: "Avg HR", value: "162", unit: "BPM", valueColor: .green)
        CardComponent(title: "Max HR", value: "173", unit: "BPM", valueColor: .red)
    }
    .padding()
    .background(Color.black)
}//
//  Cardcomponent.swift
//  Aerun
//
//  Created by Sabilaa on 04/05/26.
//

