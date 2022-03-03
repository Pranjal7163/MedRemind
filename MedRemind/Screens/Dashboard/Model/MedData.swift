//
//  MedData.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 02/03/22.
//

import Foundation
import Alamofire

// MARK: - MedData
class MedData: Codable {
    var scheduleList: [ScheduleList]?
    
    init(scheduleList: [ScheduleList]?) {
        self.scheduleList = scheduleList
    }
}

// MARK: - ScheduleList
class ScheduleList: Codable {
    var scheduleCD, type: String?
    var frequency, duration: Int?
    var sessionList: [SessionList]?
    var drug: Drug?
    var video: Video?
    
    enum CodingKeys: String, CodingKey {
        case scheduleCD
        case type, frequency, duration, sessionList, drug, video
    }
    
    init(scheduleCD: String?, type: String?, frequency: Int?, duration: Int?, sessionList: [SessionList]?, drug: Drug?, video: Video?) {
        self.scheduleCD = scheduleCD
        self.type = type
        self.frequency = frequency
        self.duration = duration
        self.sessionList = sessionList
        self.drug = drug
        self.video = video
    }
}

// MARK: - Drug
class Drug: Codable {
    var brandNm, genericNm: String?
    var qty: Int?
    var dosage: Dosage?
    
    init(brandNm: String?, genericNm: String?, qty: Int?, dosage: Dosage?) {
        self.brandNm = brandNm
        self.genericNm = genericNm
        self.qty = qty
        self.dosage = dosage
    }
}

// MARK: - Dosage
class Dosage: Codable {
    var dose: Int?
    var unit: String?
    
    init(dose: Int?, unit: String?) {
        self.dose = dose
        self.unit = unit
    }
}

// MARK: - SessionList
class SessionList: Codable {
    var session: Session?
    var foodContext: FoodContext?
    
    init(session: Session?, foodContext: FoodContext?) {
        self.session = session
        self.foodContext = foodContext
    }
}

enum FoodContext: String, Codable {
    case afterMeals = "AFTER_MEALS"
}

enum Session: String, Codable {
    case evening = "EVENING"
    case morning = "MORNING"
    case night = "NIGHT"
}

// MARK: - Video
class Video: Codable {
    var title: String?
    var hlsUrl: String?
    var thumbnail: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case hlsUrl
        case thumbnail
    }
    
    init(title: String?, hlsUrl: String?, thumbnail: String?) {
        self.title = title
        self.hlsUrl = hlsUrl
        self.thumbnail = thumbnail
    }
}

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try JSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseMedData(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<MedData>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
