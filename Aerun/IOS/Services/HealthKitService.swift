import Foundation

// TODO: Implement HealthKitService

import Foundation
import HealthKit

final class HealthKitService {
    private let healthStore = HKHealthStore()
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        guard
            let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate),
            let restingHeartRate = HKObjectType.quantityType(forIdentifier: .restingHeartRate)
        else {
            completion(false)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            dateOfBirth,
            biologicalSex,
            heartRate,
            restingHeartRate,
            HKObjectType.workoutType()
        ]
        
        let typesToShare: Set<HKSampleType> = []
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { sucess, error in
            if let error = error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
            
            DispatchQueue.main.async {
                completion(sucess)
            }
            
        }
    }
    
    
}
