//
//  ScheduleHelper.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 03/03/22.
//

import Foundation


class ScheduleHelper{
    
    var mutableScheduleModelDict = NSMutableDictionary();
    
    func initialiseSchedule(scheduleList : [ScheduleList]){
        if let initDate = UserDefaults.standard.object(forKey: "initDate") as? Date{
            for schedule in scheduleList{
                
                let duration = schedule.duration!
                let frequency = schedule.frequency!
                var iteratorDate = initDate
                for _ in 1...duration{
                    if let schduleArray = mutableScheduleModelDict.object(forKey: DateUtil().getDateStringfromDate(date: iteratorDate)) as? [ScheduleList]{
                        var tempSchduleArray = schduleArray
                        tempSchduleArray.append(schedule)
                        mutableScheduleModelDict.setObject(tempSchduleArray, forKey: DateUtil().getDateStringfromDate(date: iteratorDate) as NSCopying)
                        addSchdule(shcduleList: tempSchduleArray, key: DateUtil().getDateStringfromDate(date: iteratorDate))
                    }else{
                        var schduleArray = [ScheduleList]()
                        schduleArray.append(schedule)
                        mutableScheduleModelDict.setObject(schduleArray, forKey: DateUtil().getDateStringfromDate(date: iteratorDate) as NSCopying)
                        addSchdule(shcduleList: schduleArray, key: DateUtil().getDateStringfromDate(date: iteratorDate))
                    }
                    
                    
                    
                    let newDate = DateUtil().addDays(date: iteratorDate,days: frequency)
                    iteratorDate = newDate
                }
            }
            
        }
    }
    
    
    func getSchdule(key : String) -> [ScheduleList]
        {
            var schduleList = [ScheduleList]()
            if let storedObject: Data = UserDefaults.standard.data(forKey: key)
            {
                
                do
                {
                    schduleList = try PropertyListDecoder().decode([ScheduleList].self, from: storedObject)
                    for schdule in schduleList
                    {
                        print(schdule.type!)
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
            return schduleList
        }
    
    func addSchdule(shcduleList : [ScheduleList],key : String)
        {
            
            do
            {
                UserDefaults.standard.set(try PropertyListEncoder().encode(shcduleList), forKey: key)
                UserDefaults.standard.synchronize()
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
    
    func getSchduleBySession(session : String, date : String) -> [ScheduleList]{
        var sessionSchdule = [ScheduleList]()
        let schduleList = getSchdule(key: date)
        for schdule in schduleList{
            for sessionString in schdule.sessionList!{
                if sessionString.session?.rawValue == session{
                    sessionSchdule.append(schdule)
                }
            }
        }
        return sessionSchdule
    }
    
    func setTaken(name : String,session : String,date : String){
        if let arrayName = UserDefaults.standard.object(forKey: date+"taken"+session) as? [String]{
            var lArray = arrayName
            lArray.append(name)
            UserDefaults.standard.set(lArray, forKey: date+"taken"+session)
        }else{
            var arrayName = [String]()
            arrayName.append(name)
            UserDefaults.standard.set(arrayName, forKey: date+"taken"+session)
        }
    }
    
    func isTaken(name : String ,session : String, date : String) -> Bool{
        if let arrayName = UserDefaults.standard.object(forKey: date+"taken"+session) as? [String]{
            return arrayName.contains(name)
        }
        return false
    }
}
