//
//  CircuitViewController.swift
//  Productivity 2
//
//  Created by SPS on 23/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import UIKit
import Mapbox
import Foundation
import MBProgressHUD


class CircuitViewController: UIViewController,
UITableViewDelegate, UITableViewDataSource,
UISearchBarDelegate, MGLMapViewDelegate,
CircuitTableCellDelegate,
RequestsGenericDelegate , ReachabilityDelegate
{
   
    public enum circuitViewMode{
        case listMode
        case mapMode
    }
    
    let selectedColor:UInt = 0x7887C1
    let deselectedColor:UInt = 0x3A539E

//    @IBOutlet weak var listModeButton: UIButton!
//    @IBOutlet weak var listLine: UIView!
//    @IBOutlet weak var mapModeButton: UIButton!
//    @IBOutlet weak var mapLine: UIView!
    
    var viewMode:circuitViewMode = circuitViewMode.listMode
    
//    @IBOutlet weak var mapViewTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var mapViewTopToBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var listViewTopToBottomContraint: NSLayoutConstraint!
//    @IBOutlet weak var listViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
//    @IBOutlet weak var mapBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var listSearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var mapView: UIView!
//    @IBOutlet weak var mapSearchBar: UISearchBar!
//    @IBOutlet weak var map: UIView!
    var loadingNotif:MBProgressHUD! = nil
    
    var WPId: Int?
    
    var mglMap:MGLMapView?
    
    var circuitsList:[CircuitModel] = [CircuitModel]()
    var currentList:[CircuitModel] = [CircuitModel]()
    
    let refreshControl = UIRefreshControl()
    var crewsArray = [[String:Any]]()
    
    var isNetworkAvailable:Bool = true
    var reachabilityManager:ReachabilityManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        setupSearchBar()
//        setUpMap()
        
        reachabilityManager = ReachabilityManager(delegate: self)

        
        print("WPID on circuitVC \(WPId)")
        
//        if #available(iOS 10, *){
//            self.tableView.refreshControl = refreshControl
//        }
//        else{
//            self.tableView.addSubview(refreshControl)
//        }
//        refreshControl.addTarget(self, action: #selector(refreshList(_:)), for: .valueChanged)
        
        let tableViewTapped:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        listView.addGestureRecognizer(tableViewTapped)
    }
    
    func setupSearchBar(){
        listSearchBar.searchBarStyle = .prominent
        listSearchBar.isTranslucent = false
        listSearchBar.barTintColor = UIColor(rgb: 0xededed, alphaVal: 1.0)
        listSearchBar.backgroundColor = UIColor(rgb: 0xededed, alphaVal: 1.0)
        listSearchBar.backgroundImage = UIImage()
        listSearchBar.delegate = self
        
//        mapSearchBar.searchBarStyle = .prominent
//        mapSearchBar.isTranslucent = true
//        mapSearchBar.barTintColor = UIColor.clear
//        mapSearchBar.backgroundColor = UIColor.clear
//        mapSearchBar.backgroundImage = UIImage()
//        mapSearchBar.delegate = self
    }
    
//    func setUpMap(){
//        mglMap = MGLMapView(frame: mapView.bounds, styleURL: MGLStyle.streetsStyleURL(withVersion: 9))
//        mglMap!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        mglMap!.tintColor = UIColor.gray
//        mglMap!.delegate = self
//        map.addSubview(mglMap!)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        reachabilityManager?.startMonitoring()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardUp(notification :)), name:  NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDown(notification :)), name:  NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        getList()
    }
    
    //MARK: List loading functions
    
    @objc private func refreshList(_ sender: Any) {
        getList()
    }
    
    func getList()
    {
        showLoading()
        circuitsList = [CircuitModel]()
        
//        circuitsList = [
//            CircuitModel(title: "Circuit 1", isShowingDescription: false),
//            CircuitModel(title: "Circuit 2", isShowingDescription: false),
//            CircuitModel(title: "Circuit 3", isShowingDescription: false),
//            CircuitModel(title: "Circuit 4", isShowingDescription: false),
//            CircuitModel(title: "Circuit 5", isShowingDescription: false),
//            CircuitModel(title: "Circuit 6", isShowingDescription: false),
//            CircuitModel(title: "Circuit 7", isShowingDescription: false),
//            CircuitModel(title: "Circuit 8", isShowingDescription: false),
//            CircuitModel(title: "Circuit 9", isShowingDescription: false),
//            CircuitModel(title: "Circuit 10", isShowingDescription: false)
//        ]
//        currentList = circuitsList
        
        print("WPId in getList \(WPId)")
        
        tableView.reloadData()
        self.refreshControl.endRefreshing()
        Request.getCircuits(delegate: self , WPId: (self.WPId)!)
    }
    
    
    //MARK: View actions
    @IBAction func setListMode(_ sender: Any) {
        if viewMode != circuitViewMode.listMode {
//            mapView.isHidden = true
            listView.isHidden = false
//            mapLine.backgroundColor = listLine.backgroundColor
//            listLine.backgroundColor = UIColor(rgb: selectedColor, alphaVal: 1.0)
//            mapViewTopConstraint.priority = UILayoutPriority(500)
//            mapViewTopToBottomConstraint.priority = UILayoutPriority(999)
//            listViewTopConstraint.priority = UILayoutPriority(999)
//            listViewTopToBottomContraint.priority = UILayoutPriority(500)
            
            viewMode = circuitViewMode.listMode
        }
    }
    @IBAction func setMapMode(_ sender: Any) {
        if viewMode != circuitViewMode.mapMode {
            listView.isHidden = true
//            mapView.isHidden = false
//            listLine.backgroundColor = mapLine.backgroundColor
//            mapLine.backgroundColor = UIColor(rgb: selectedColor, alphaVal: 1.0)
//            mapViewTopConstraint.priority = UILayoutPriority(999)
//            mapViewTopToBottomConstraint.priority = UILayoutPriority(500)
//            listViewTopConstraint.priority = UILayoutPriority(500)
//            listViewTopToBottomContraint.priority = UILayoutPriority(999)
            
            viewMode = circuitViewMode.mapMode
        }
    }
    
    //MARK: Map delegate functions
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        
    }
    
    //MARK: TableCell delegate functions
    func updateCell(atIndexPath indexPath: IndexPath) {
        var listIndex = 0
        for (index, main) in circuitsList.enumerated(){
            if main.title == currentList[indexPath.row].title {
                listIndex = index
                break
            }
        }
        circuitsList[listIndex].isShowingDescription = !circuitsList[listIndex].isShowingDescription
        currentList[indexPath.row] = circuitsList[listIndex]
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
    
    func runForward(atIndexPath indexPath: IndexPath)
    {
        
        if(!self.isNetworkAvailable)
        {
            showNetworkErrorDialog()
            return
        }
        
        self.listSearchBar.resignFirstResponder()
        
        if let circuit:CircuitModel = currentList[indexPath.row]
        {
            let circuitData = [
                Constants.WPCircuitID : circuit.WPCircuitID,
                Constants.WorkAssignmentId : circuit.workAssignmentID,
                Constants.remainingPath : circuit.remainingPath,
                Constants.donePath : circuit.donePath,
                Constants.WPId : self.WPId,
                Constants.circuitFullObj : circuit.circuitFullObj,
                Constants.notesList : circuit.notesList
                
            ] as [String: Any]
            performSegue(withIdentifier: Constants.segueCircuitToTracingIdentifier, sender: circuitData)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.segueCircuitToTracingIdentifier)
        {
            let MapVC = segue.destination as! TracingViewController
            
            if let circuitData = sender as? [String: Any]
            {
                MapVC.WPCircuit = circuitData[Constants.WPCircuitID] as! Int
                MapVC.WorkAssignmentId  = circuitData[Constants.WorkAssignmentId] as! Int
                MapVC.remainingPaths = circuitData[Constants.remainingPath] as! [LineModel]
                MapVC.donePaths = circuitData[Constants.donePath] as! [LineModel]
                MapVC.WPId = circuitData[Constants.WPId] as! Int
                MapVC.crewArray = self.crewsArray as! [[String:Any]]
                MapVC.circuitFullObj = circuitData[Constants.circuitFullObj] as! [String:Any]
                MapVC.notesList = circuitData[Constants.notesList] as! [NoteModel]
            }
            
        }
    }
    
    //MARK: Table delegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.circuitTableCellIdentifier, for: indexPath) as! CircuitTableViewCell
        
        if indexPath.row == 0 {
            cell.viewTopConstraint.constant = 0
        }
        else{
            cell.viewTopConstraint.constant = 5
        }
        
        cell.mainView.layer.shadowColor = UIColor.gray.cgColor
        cell.mainView.layer.shadowOpacity = 0.2
        cell.mainView.layer.shadowRadius = 2.0
        cell.mainView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cell.mainView.masksToBounds = false
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.title.text = currentList[indexPath.row].title
        cell.statusLabel.text = currentList[indexPath.row].statusName
        
        cell.startLabel.text = "Starts: \(currentList[indexPath.row].startDate!)"
        cell.endLabel.text = "Ends: \(currentList[indexPath.row].endDate!)"
        
        cell.totalHoursLabel.text = "Productive Hours: \(String(currentList[indexPath.row].hours))"
        
//        if let hours = currentList[indexPath.row].hours! as? Int
//        {
//            cell.totalHoursLabel.text = "Productive Hours: \(String(currentList[indexPath.row].hours))"
//
//        }
        
        cell.nonProdHoursLabel.text = "Non-productive Hours: \(String(currentList[indexPath.row].nonProdHours))"
        cell.milagelabel.text = "Mileage: \(String(currentList[indexPath.row].mileage))"
        
        
        cell.statusView.backgroundColor = .black
        
        let statusColor = UIColor().colorFromHex(currentList[indexPath.row].statusColor)
        cell.statusView.backgroundColor = statusColor
        
//        if(currentList[indexPath.row].isShowingDescription){
//            cell.showDescription()
//        }
//        else{
//            cell.hideDescription()
//        }
        
        return cell
    }
    
    //MARK: Search delegate functions
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
//        if viewMode == circuitViewMode.listMode{
//            guard !searchBar.text!.isEmpty else {
//                currentList = circuitsList
//                tableView.reloadData()
//                return
//            }
//            currentList = circuitsList.filter({ mainModel -> Bool in
//                let result:Bool = mainModel.title.lowercased().contains(searchBar.text!.lowercased())
//                return mainModel.title.lowercased().contains(searchBar.text!.lowercased())
//            })
//            if currentList.count > 0{
//                currentList.sort { (circuit1, circuit2) -> Bool in
//                    return circuit1.title.lowercased()<circuit2.title.lowercased()
//                }
//            }
//            else{
//                showErrorDialog(withMessage: Constants.noCircuitsFound)
//            }
//            tableView.reloadData()
//        }
//        else{
//            
//        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if viewMode == circuitViewMode.listMode{
//            guard !searchText.isEmpty else {
//                currentList = circuitsList
//                tableView.reloadData()
//                return
//            }
//        }
//        else{
//
//        }
        
        
        if viewMode == circuitViewMode.listMode{
            guard !searchBar.text!.isEmpty else {
                currentList = circuitsList
                tableView.reloadData()
                return
            }
            currentList = circuitsList.filter({ mainModel -> Bool in
                let result:Bool = mainModel.title.lowercased().contains(searchBar.text!.lowercased())
                return mainModel.title.lowercased().contains(searchBar.text!.lowercased())
            })
            if currentList.count > 0{
                currentList.sort { (circuit1, circuit2) -> Bool in
                    return circuit1.title.lowercased()<circuit2.title.lowercased()
                }
            }
            else{
                showErrorDialog(withMessage: Constants.noCircuitsFound)
            }
            tableView.reloadData()
        }
        else{
            
        }
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK: Dialogs
    
    func showErrorDialog(withMessage message:String){
        let alert = UIAlertController(title:message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: Constants.ok, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Keyboard functions
    
    @objc func dismissKeyboard() -> Bool {
        listSearchBar.resignFirstResponder()
//        mapSearchBar.resignFirstResponder()
        return false
    }
    
    @objc func keyBoardUp(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if viewMode == circuitViewMode.listMode{
            tableBottomConstraint.constant = keyboardSize.height
            }
            else{
//                mapBottomConstraint.constant = keyboardSize.height
            }
        }
    }
    
    @objc func keyBoardDown(notification: NSNotification){
        if viewMode == circuitViewMode.listMode{
            tableBottomConstraint.constant = 0
        }
        else{
//            mapBottomConstraint.constant = 0
        }
    }
    
    deinit {
        // Remove offline pack observers.
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func onErrorResponse(msg: String) {
        print("onErrorResponse")
    }
    
    func onSuccessResponse(data: Any)
    {
       // let responseData = String(data: data as! Data , encoding: String.Encoding.utf8)
        // print("onSuccessResponse \(data)")
        
       // let crews = data["Crews"]
        
        if let dict = data as? [String: Any]
        {
            
           // print("onSuccessResponse dict \(dict)")
            
            crewsArray = dict["Crews"] as! [[String : Any]]
            let circuitsArray = dict["Circuits"] as! [[String : Any]]
            
          //  data as! [[String : Any]]
            
//            for crew in crewsArray
//            {
//                let title = crew["Title"]
//                print("onSuccessResponse dict \(title)")
//            }
            
            for circuit in circuitsArray
            {
                let id = circuit["Id"] as! Int
                let title = circuit["Title"]
                let startdate = circuit["StartDate"]
                let enddate = circuit["EndDate"]
                let hours = circuit["Hours"] as! Float
                let nonProdHours = circuit["NonProductiveHours"] as! Float

                let progress = circuit["Progress"]
                let mileage = circuit["Milage"]
                let statusName = circuit["StatusName"]
                let statusColor = circuit["StatusColor"]
                let workAssignId = circuit["WorkAssignmentId"]
                let WPCircuitId = circuit["WPCircuitId"]

                //Remaining path
                
                let remainingPath = circuit["RemainingPath"] as! [[String : Any]]
                
                var remainingPathList = [LineModel]()
                
                for line in remainingPath
                {
                    let Id = line["Id"]
                    let path = line["Path"] as! [[String : Any]]
                    var pointsList = [PointModel]()
                    
                    for point in path
                    {
                        let lat = point["lat"]
                        let lng = point["lng"]
                        
                        let pointModel = PointModel(lat: lat as! Double, lng: lng as! Double)
                        pointsList.append(pointModel)
                    }
                    
                    let lineModel = LineModel(id: Id as! Int, path: pointsList as! [PointModel])
                    remainingPathList.append(lineModel)
                    
                    
                   // print("LineID \(line["Id"])")
                }
                
                print("Circuits remaiing path size \(remainingPathList.count)")
                
                
                //done path
                
                let donePath = circuit["DonePath"] as! [[String : Any]]
                var donePathList = [LineModel]()
                
                for line in donePath
                {
                    let Id = line["Id"]
                    let Path = line["Path"] as! [[String: Any]]
                    
                    var pointsList = [PointModel]()
                    
                    for point in Path
                    {
                        let lat = point["lat"]
                        let lng = point["lng"]
                        
                        let pointModel = PointModel(lat: lat as! Double, lng: lng as! Double)
                        pointsList.append(pointModel)
                    }
                    
                    let lineModel = LineModel(id: Id as! Int, path: pointsList as! [PointModel])
                    donePathList.append(lineModel)
                }
                
                var notesList:[NoteModel] = [NoteModel]()
                
                //Survey data
                let surveyData = circuit["SurveyData"] as? [String:Any]
                print("surveyData \(surveyData)")

                let notesArray =  surveyData!["Notes"] as! [[String : Any]]
                print("notesArray size \(notesArray.count)")

                for note in notesArray
                {
                    let id = note["Id"] as! Int
                    let text = note["Text"] as! String
                    let time = note["Time"] as! String
                    let fName = note["FirstName"] as! String
                    let lName = note["LastName"] as! String
                    let lat = note["lat"] as! Double
                    let lng = note["lng"] as! Double

                    let noteModel = NoteModel(id: id as! Int, text: text as! String, time: time, fName: fName, lName: lName, lat: lat, lng: lng)
                    notesList.append(noteModel)
                }
                
                let hoursStr = String(hours)
                let nonProdStr = String(nonProdHours)
                
                let circuitModel = CircuitModel(id: id as! Int, title: title as! String, startDate: startdate as! String, endDate: enddate as! String, hours: hoursStr as! String, mileage: mileage as! String, statusName: statusName as! String, statusColor: statusColor as! String , remainingPath: remainingPathList as! [LineModel] , donePath: donePathList as! [LineModel] , workAssignmentID:workAssignId as! Int , workPlanCircuitID: WPCircuitId as! Int , circuitFullObj: circuit as! [String:Any] , nonProdHours: nonProdStr as! String , notesList: notesList as! [NoteModel])
                
                circuitsList.append(circuitModel)
                
//                print("circuit dict id \(id) \(title)  start \(startdate)  end \(enddate)  progress \(progress)")
            }
            
            currentList = circuitsList
            
            if(currentList.count == 0)
            {
                print("\(Constants.TAG) NO PLANS FOUND")
                
                DispatchQueue.main.sync
                    {
                        showErrorDialog(withMessage: Constants.noCircuitsFound)
                        
                }
            }
            
            DispatchQueue.main.sync {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                loadingNotif.hide(animated: true)
            }
        }
        
        
      //  let resJsonObj = try? JSONSerialization.jsonObject(with: data, options: [])
       // print("onSuccessResponse \(crews)")
    }
    
    func showLoading(){
        loadingNotif = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotif.mode = MBProgressHUDMode.indeterminate
        loadingNotif.label.text = "Loading"
    }
    
    func showNetworkErrorDialog()
    {
        let alert = UIAlertController(title:"Network not available.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func networkAvailable()
    {
        isNetworkAvailable = true
    }
    
    func networkNotAvailable()
    {
        isNetworkAvailable = false
    }
}
