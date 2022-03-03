//
//  DashboardViewModel.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 02/03/22.
//

import Foundation
import UIKit
import moa

class DashboardViewModel{
    
    private var medData: MedData? {
        didSet {
            guard let m = medData else { return }
            self.scheduleList = m.scheduleList
            ScheduleHelper().initialiseSchedule(scheduleList: m.scheduleList!)
            self.scheduleList = ScheduleHelper().getSchduleBySession(session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
            self.didFinishFetch?()
        }
    }
    var error: Error? {
        didSet { self.showAlertClosure?() }
    }
    var isLoading: Bool = false {
        didSet { self.updateLoadingStatus?() }
    }
    
    var today = Date()
    var currentDate = Date() {
        didSet{
            self.scheduleList = ScheduleHelper().getSchduleBySession(session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
            currentDay = currentDate.get(.day)
            currentMonth = currentDate.month
            self.updateDate?()
        }
    }
    var currentDay = Date().get(.day)
    var currentMonth = Date().month
    var currentSession = "MORNING" {
        didSet {
            self.scheduleList = ScheduleHelper().getSchduleBySession(session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
            self.updateDate?()
        }
    }
    
    var scheduleList : [ScheduleList]?
    
    private var dataService: DataService?
    
    // MARK: - Closures for callback, since we are not using the ViewModel to the View.
    var showAlertClosure: (() -> ())?
    var updateLoadingStatus: (() -> ())?
    var didFinishFetch: (() -> ())?
    var updateDate: (() -> ())?
    var updateTable: (() -> ())?
    
    // MARK: - Constructor
    init(dataService: DataService) {
        self.dataService = dataService
        if UserDefaults.standard.object(forKey: "initDate") == nil {
            UserDefaults.standard.set(Date(), forKey: "initDate")
        }
        
        self.scheduleList = ScheduleHelper().getSchduleBySession(session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
        if(scheduleList!.isEmpty){
            print("offline is not working")
        }
        self.didFinishFetch?()
    }
    
    func onPrevClicked(){
        currentDate = DateUtil().subtractDay(date: currentDate)
        currentDay = currentDate.get(.day)
        currentMonth = currentDate.month
        self.scheduleList = ScheduleHelper().getSchduleBySession(session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
        self.updateDate?()
    }
    
    func onNextClicked(){
        currentDate = DateUtil().addDay(date: currentDate)
        currentDay = currentDate.get(.day)
        currentMonth = currentDate.month
        self.scheduleList = ScheduleHelper().getSchduleBySession(session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
        self.updateDate?()
    }
    
    // MARK: - Network call
    func fetchData() {
        self.scheduleList = ScheduleHelper().getSchduleBySession(session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
        currentDay = currentDate.get(.day)
        currentMonth = currentDate.month
        self.updateDate?()
        self.dataService?.requestFetchMedData(completion: { (medData, error) in
            if let error = error {
                self.error = error
                self.isLoading = false
                return
            }
            self.error = nil
            self.isLoading = false
            self.medData = medData
        })
    }
    
    
    func isTaken(name : String) -> Bool{
        return ScheduleHelper().isTaken(name: name, session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
    }
    
    func setTaken(name : String){
        ScheduleHelper().setTaken(name: name, session: currentSession, date: DateUtil().getDateStringfromDate(date: currentDate))
        self.updateTable?()
    }
    
    func setImageView(imageView : UIImageView , url : String){
        imageView.moa.url = url
        //        imageView.loadImage(urlString: url)
    }
    
    
}
