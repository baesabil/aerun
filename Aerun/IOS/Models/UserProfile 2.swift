import Foundation

// MARK: - UserProfile
// Model untuk data profil user yang diambil dari HealthKit + UserDefaults

struct UserProfile {
    let name: String        // Diambil dari UserDefaults ("aerun_user_name")
    let age: Int            // Dihitung dari dateOfBirth HealthKit
    let isMale: Bool        // Dari biologicalSex HealthKit
    let restingHeartRate: Double  // BPM — dari HealthKit

    // Computed: HRmax sesuai brief
    var hrMax: Int {
        isMale ? (220 - age) : (226 - age)
    }

    // Computed: Heart Rate Reserve
    var hrr: Double {
        Double(hrMax) - restingHeartRate
    }
}
