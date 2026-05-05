//
//  BarComponent.swift
//  Aerun
//

import SwiftUI

// Komponen satu baris zona HR — menampilkan nomor zona, nama, menit, persen, dan progress bar
// Dipakai di HistoryView untuk section "Heart Rate Training Zones"
struct BarComponent: View {
    
    // MARK: - Properties
    let zoneNumber: Int     // Nomor zona: 0–5
    let minutes: Int        // Berapa menit user ada di zona ini
    let percent: Int        // Persentase waktu di zona ini (0–100)
    let progress: Double    // Nilai progress bar (0.0–1.0)
    let color: Color        // Warna zona (cyan, green, orange, red)
    
    // MARK: - Zone Labels
    // Mapping nomor zona ke nama yang ditampilkan
    private var zoneName: String {
        switch zoneNumber {
        case 0: return "Zone 1 · Recovery"
        case 1: return "Zone 2 · Light Aerobic"
        case 2: return "Zone 3 · Moderate"
        case 3: return "Zone 4 · Hard"
        case 4: return "Zone 5 · Maximum"
        default: return "Zone \(zoneNumber)"
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 6) {
            
            // Baris atas: nama zona + menit & persen di kanan
            HStack {
                Text(zoneName)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Menit dan persen — teks kecil di kanan
                Text("\(minutes) min · \(percent)%")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            
            // Progress bar — background abu + fill berwarna
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    
                    // Background bar (track)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    // Fill bar — lebar proporsional dengan progress (0.0–1.0)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8) // GeometryReader perlu height eksplisit
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 12) {
        BarComponent(zoneNumber: 0, minutes: 4,  percent: 13, progress: 0.13, color: .cyan)
        BarComponent(zoneNumber: 1, minutes: 20, percent: 67, progress: 0.67, color: .green)
        BarComponent(zoneNumber: 2, minutes: 4,  percent: 13, progress: 0.13, color: .orange)
        BarComponent(zoneNumber: 3, minutes: 2,  percent: 7,  progress: 0.07, color: .orange)
        BarComponent(zoneNumber: 4, minutes: 0,  percent: 0,  progress: 0.0,  color: .red)
    }
    .padding()
    .background(Color.black)
}//
//  Barcomponent.swift
//  Aerun
//
//  Created by Sabilaa on 04/05/26.
//

