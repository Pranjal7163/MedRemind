//
//  DashboardViewController.swift
//  MedRemind
//
//  Created by Pranjal Vyas on 02/03/22.
//

import UIKit
import AVKit
import Alamofire

class DashboardViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,AVAssetDownloadDelegate {
    
    
    
    @IBOutlet weak var medTableView: UITableView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var loadingView: UIView!
    
    
    let viewModel = DashboardViewModel(dataService: DataService())
    var scheduleList = [ScheduleList]()
    var selectedURL = ""
    var selectedName = ""
    
    let myPicker: MyDatePicker = {
        let v = MyDatePicker()
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dateLabel.text = String(self.viewModel.currentDay)
        self.monthLabel.text = self.viewModel.currentMonth
        
        setDatePicker()
        setView()
        getData()
        
        // Do any additional setup after loading the view.
    }
    
    func setView(){
        let nibMed = UINib.init(nibName: "MedTableViewCell", bundle: nil)
        let nibWork = UINib.init(nibName: "WorkoutTableViewCell", bundle: nil)
        medTableView.register(nibMed, forCellReuseIdentifier: "medCell")
        medTableView.register(nibWork, forCellReuseIdentifier: "workCell")
        medTableView.rowHeight = UITableView.automaticDimension
        medTableView.estimatedRowHeight = 114
        
        medTableView.dataSource = self
        medTableView.delegate = self
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.dateLabel.isUserInteractionEnabled = true
        self.dateLabel.addGestureRecognizer(labelTap)
        self.medTableView.reloadData()
    }
    
    func setDatePicker(){
        myPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(myPicker)
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            
            // custom picker view should cover the whole view
            myPicker.topAnchor.constraint(equalTo: g.topAnchor),
            myPicker.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            myPicker.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            myPicker.bottomAnchor.constraint(equalTo: g.bottomAnchor),
            
        ])
        
        // hide custom picker view
        myPicker.isHidden = true
        
        // add closures to custom picker view
        myPicker.dismissClosure = { [weak self] in
            guard let self = self else {
                return
            }
            self.myPicker.isHidden = true
        }
        myPicker.changeClosure = { [weak self] val in
            guard let self = self else {
                return
            }
            let dateString = DateUtil().getDateStringfromDate(date: val)
            self.myPicker.isHidden = true
            self.viewModel.currentDate = DateUtil().getDateFromDateString(dateString: dateString)
            // do something with the selected date
        }
    }
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        myPicker.isHidden = false
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            viewModel.currentSession = "MORNING"
        }else if sender.selectedSegmentIndex == 1{
            viewModel.currentSession = "AFTERNOON"
        }else if sender.selectedSegmentIndex == 2{
            viewModel.currentSession = "EVENING"
        }else if sender.selectedSegmentIndex == 3{
            viewModel.currentSession = "NIGHT"
        }
    }
    
    
    @IBAction func onPrevDateClicked(_ sender: Any) {
        self.viewModel.onPrevClicked()
    }
    
    @IBAction func onNextDateClicked(_ sender: Any) {
        self.viewModel.onNextClicked()
    }
    
    private func getData() {
        
        
        viewModel.updateLoadingStatus = {
            //            let _ = self.viewModel.isLoading ? self.loadingView.isHidden = false : self.loadingView.isHidden = true
        }
        
        viewModel.showAlertClosure = {
            if let error = self.viewModel.error {
                print(error.localizedDescription)
            }
        }
        
        viewModel.didFinishFetch = {
            self.scheduleList = self.viewModel.scheduleList!
            self.medTableView.reloadData()
        }
        
        viewModel.updateDate = {
            self.dateLabel.text = String(self.viewModel.currentDay)
            self.monthLabel.text = self.viewModel.currentMonth
            self.scheduleList = self.viewModel.scheduleList!
            self.medTableView.reloadData()
        }
        
        viewModel.updateTable = {
            self.scheduleList = self.viewModel.scheduleList!
            self.medTableView.reloadData()
        }
        
        viewModel.fetchData()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let schedule = scheduleList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "medCell", for: indexPath)
        let medCell = tableView.dequeueReusableCell(withIdentifier: "medCell", for: indexPath) as! MedTableViewCell
        let workCell = tableView.dequeueReusableCell(withIdentifier: "workCell", for: indexPath) as! WorkoutTableViewCell
        if scheduleList[indexPath.row].type == "VOD"{
            workCell.workoutName.text = schedule.video?.title!
            self.viewModel.setImageView(imageView: workCell.thumbnailImage, url: (schedule.video?.thumbnail)!)
            
            if self.viewModel.isTaken(name: (schedule.video?.title!)!){
                workCell.watchButton.isHidden = true
                workCell.doneIcon.isHidden = false
            }else{
                workCell.watchButton.isHidden = false
                workCell.doneIcon.isHidden = true
                workCell.watchButton.setOnClickListener {
                    self.selectedURL = (self.scheduleList[indexPath.row].video?.hlsUrl!)!
                    self.selectedName = (self.scheduleList[indexPath.row].video?.title!)!
                    if let isDownloaded = UserDefaults.standard.bool(forKey: (self.scheduleList[indexPath.row].video?.hlsUrl!)!) as? Bool{
                        if isDownloaded{
                            let savedLink = UserDefaults.standard.string(forKey: self.selectedURL+"saved")
                            let baseUrl = URL(fileURLWithPath: NSHomeDirectory()) //app's home directory
                            let assetUrl = baseUrl.appendingPathComponent(savedLink!)
                            let avAssest = AVAsset(url: assetUrl)
                            let playerItem = AVPlayerItem(asset: avAssest)
                            let player = AVPlayer(playerItem: playerItem)  // video path coming from above function
                            self.viewModel.setTaken(name: (schedule.video?.title!)!)
                            let playerViewController = AVPlayerViewController()
                            playerViewController.player = player
                            self.present(playerViewController, animated: true, completion: {
                                player.play()
                            })
                        }else{
                            self.setupAssetDownload(videoUrl: (self.scheduleList[indexPath.row].video?.hlsUrl!)!)
                        }
                    }else{
                        self.setupAssetDownload(videoUrl: (self.scheduleList[indexPath.row].video?.hlsUrl!)!)
                    }
                    //                    }
                }
            }
            return workCell
        }else if scheduleList[indexPath.row].type == "MEDICINE"{
            medCell.drugName.text = schedule.drug?.brandNm!
            medCell.drugDose.text = String(schedule.drug!.dosage!.dose!)+" "+schedule.drug!.dosage!.unit!
            if self.viewModel.isTaken(name: (schedule.drug?.brandNm!)!){
                medCell.takeButton.isHidden = true
                medCell.doneImage.isHidden = false
            }else{
                medCell.takeButton.isHidden = false
                medCell.doneImage.isHidden = true
                medCell.takeButton.setOnClickListener {
                    self.viewModel.setTaken(name: (schedule.drug?.brandNm!)!)
                }
            }
            
            let sessionList = schedule.sessionList
            for session in sessionList!{
                medCell.drugFoodContext.text = session.foodContext!.rawValue
            }
            return medCell
        }
        
        return cell
    }
    
    
    var configuration: URLSessionConfiguration?
    var downloadSession: AVAssetDownloadURLSession?
    var downloadIdentifier = "\(Bundle.main.bundleIdentifier!).background"
    
    func setupAssetDownload(videoUrl: String) {
        // Create new background session configuration.
        configuration = URLSessionConfiguration.background(withIdentifier: downloadIdentifier)
        
        // Create a new AVAssetDownloadURLSession with background configuration, delegate, and queue
        downloadSession = AVAssetDownloadURLSession(configuration: configuration!,
                                                    assetDownloadDelegate: self,
                                                    delegateQueue: OperationQueue.main)
        
        if let url = URL(string: videoUrl){
            let asset = AVURLAsset(url: url)
            
            // Create new AVAssetDownloadTask for the desired asset
            let downloadTask = downloadSession?.makeAssetDownloadTask(asset: asset,
                                                                      assetTitle: "Title",
                                                                      assetArtworkData: nil,
                                                                      options: nil)
            // Start task and begin download
            downloadTask?.resume()
            self.loadingView.isHidden = false
        }
    }//end method
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        // Do not move the asset from the download location
        UserDefaults.standard.set(location.relativePath, forKey: self.selectedURL+"saved")
        UserDefaults.standard.set(true,forKey: selectedURL)
        self.loadingView.isHidden = true
        
        let baseUrl = URL(fileURLWithPath: NSHomeDirectory()) //app's home directory
        let assetUrl = baseUrl.appendingPathComponent(location.relativePath)
        self.viewModel.setTaken(name: selectedName)
        let avAssest = AVAsset(url: assetUrl)
        let playerItem = AVPlayerItem(asset: avAssest)
        let player = AVPlayer(playerItem: playerItem)  // video path coming from above function
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true, completion: {
            player.play()
        })
    }
    
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
