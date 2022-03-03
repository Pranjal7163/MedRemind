//
//  DashboardService.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 02/03/22.
//

import Foundation
import Alamofire

struct DataService {
    
    // MARK: - Singleton
    static let shared = DataService()
    
    // MARK: - URL
    private var medDataUrl = "https://38rhabtq01.execute-api.ap-south-1.amazonaws.com/"
    
    // MARK: - Services
    func requestFetchMedData(completion: @escaping (MedData?, Error?) -> ()) {
        let url = medDataUrl+"dev/remind/schedule"
        Alamofire.request(url).responseMedData { response in
            if let error = response.error {
                completion(nil, error)
                return
            }
            if let photo = response.result.value {
                completion(photo, nil)
                return
            }
        }
    }
    
}
