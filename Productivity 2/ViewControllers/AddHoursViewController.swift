//
//  AddHoursViewController.swift
//  Productivity 2
//
//  Created by SPS on 24/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import MBProgressHUD


class AddHoursViewController: UIViewController , CustomCrewTypeCellDelegate , RequestsGenericDelegate, UIScrollViewDelegate , ReachabilityDelegate
{
    
    @IBOutlet weak var totalHoursBGView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalProdHoursTextField: UILabel!
    @IBOutlet weak var totalNonProdHrzTextField: UILabel!
    
    @IBOutlet weak var note_TextField: UITextField!

    @IBOutlet weak var dateTextField: UITextField!
    let datePicker = UIDatePicker()
    var logDate:String! = ""
    
    var loadingNotif:MBProgressHUD! = nil

    var rowCount:Int = 1
    var crewRowModelList:[CrewRowModel] = [CrewRowModel]()
    
    var selectedCrewInfoList:[Int:CrewInfoModel] = [Int:CrewInfoModel]()
    
    static var selectedCrewRows:[Int:Int] = [Int:Int]()
    
    static var totalCrewTypesCount:Int = 0

    var WPId:Int = 0
    var WorkAssignmentId:Int = 0
    var WPCircuitID:Int = 0
    var isAllPathMode : Bool = false
    var isNoTrace : Bool = false
    var polygonsList:[[CLLocationCoordinate2D]] = [[CLLocationCoordinate2D]]()
    var tracedPathsList:[[CLLocationCoordinate2D]] = [[CLLocationCoordinate2D]]()
    var crewInfoList:[CrewInfoModel] = [CrewInfoModel]()
    static var crewArray:[[String:Any]] = [[String:Any]]()
    var enteredNote:String? = ""
    
    var isNetworkAvailable:Bool = true
    var reachabilityManager:ReachabilityManager?
    
        
    override func viewDidLoad()
    {
        super.viewDidLoad()
        

        print("\(Constants.TAG) WPId \(WPId)")
        print("\(Constants.TAG) CircuitID \(WPCircuitID)")
        print("\(Constants.TAG) Polygons list size \(polygonsList.count)")
        print("\(Constants.TAG) Traced paths list size \(tracedPathsList.count)")
        print("\(Constants.TAG) CREWS ARRAY size \(AddHoursViewController.crewArray.count)")
        print("\(Constants.TAG) isNoTrace \(isNoTrace)")
        print("\(Constants.TAG) isAllPathMode \(isAllPathMode)")
        
        reachabilityManager = ReachabilityManager(delegate: self)

       // let FinishButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitButtontapped))
        let SubmitButton = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitButtontapped))

        SubmitButton.title = "Submit"
        self.navigationItem.rightBarButtonItem = SubmitButton
        
        self.totalHoursBGView.layer.cornerRadius = 24
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorColor = UIColor.clear
        
        let crewRowModel = CrewRowModel(crewType: "" as! String, totalHrz : "" as! String, nonProdHours : "" as! String)
        crewRowModelList.append(crewRowModel)
        
        let selectedCrewModel = CrewInfoModel(crewTypeId: -1, hours: 0, nonProdHours: 0)
        self.selectedCrewInfoList[rowCount-1] = selectedCrewModel
        
        AddHoursViewController.selectedCrewRows = [Int:Int]()
        AddHoursViewController.selectedCrewRows[0] = -1
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        setCurrentDateOnDatePicker()
        createDatePicker()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        reachabilityManager?.startMonitoring()
    }
    
    @IBAction func addNewCrewButtonPressed(_ sender: Any)
    {
        if(rowCount == AddHoursViewController.totalCrewTypesCount)
        {
            showDialogNoMoreCrews()
            return
        }
        
        
        print("crewRowModelList Size \(crewRowModelList.count)")
        
        rowCount = rowCount + 1
      //  let crewRowModel = CrewRowModel(crewType: "Select crew type" as! String, totalHrz : "0" as! String, nonProdHours : "0" as! String)
        let crewRowModel = CrewRowModel(crewType: "" as! String, totalHrz : "" as! String, nonProdHours : "" as! String)

        crewRowModelList.append(crewRowModel)
        
        let selectedCrewModel = CrewInfoModel(crewTypeId: -1, hours: 0, nonProdHours: 0)
        self.selectedCrewInfoList[rowCount-1] = selectedCrewModel
        
        AddHoursViewController.selectedCrewRows[rowCount-1] = -1
        
        
        self.tableView.reloadData()
        scrollToBottom()
        setRemoveButtonVisiblity()
    }
    
    func scrollToBottom()
    {
        let indexPath = IndexPath(row: rowCount-1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func scrollToRow(row: Int)
    {
        let indexPath = IndexPath(row: row-1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        print("dismissKeyboard")
        var isValid = true
        
//        for selectedCrewRow in AddHoursViewController.selectedCrewRows
//        {
//            print("selected crew row is \(selectedCrewRow.key) : \(selectedCrewRow.value)")
//
//            if(selectedCrewRow.value == -1)
//            {
//               isValid = false
//                showErrorDialog(withMessage: "Select some other crew type")
//
//                return
//                break
//            }
//
//        }
//
        if(Constants.isHoursFieldActive)
        {
            Constants.isHoursFieldActive = false
            view.endEditing(true)
        }
        
    }
    
    func pickerValueChanged(_ sender: AddHoursCustomCell, row: Int , selectedCrewID:Int)
    {
        if(row == 0)
        {
            showErrorDialog(withMessage: "Select crew type")
            return
        }
        
        print("Selected crew Ids size \(AddHoursViewController.selectedCrewRows.count)")
        
        guard let cellIndex = tableView.indexPath(for: sender) else { return }

        for selectedCrewRow in AddHoursViewController.selectedCrewRows
        {
            print("selected crew row is \(selectedCrewRow.key) : \(selectedCrewRow.value)")
            
            if(row == selectedCrewRow.value && cellIndex.row != selectedCrewRow.key)
            {
                showErrorDialog(withMessage: "Select some other crew type")
                return
                break
            }
        }
        
       // guard let cellIndex = tableView.indexPath(for: sender) else { return }
        
        var selectedCrewModel:CrewInfoModel? = selectedCrewInfoList[cellIndex.row]
        selectedCrewModel?.crewTypeID = selectedCrewID
        selectedCrewInfoList[cellIndex.row] = selectedCrewModel
        
        AddHoursViewController.selectedCrewRows[cellIndex.row] = row
        
        print("pickerValueChanged at \(cellIndex)   \(cellIndex.row)  \(cellIndex.item)  Value id is: \(selectedCrewID) )")
        
        let crewModel:CrewRowModel = self.crewRowModelList[cellIndex.row]
        crewModel.crewType = sender.selectCrewTextField.text
        
    }
    
    func removeCellClicked(_ sender: AddHoursCustomCell)
    {
        guard let cellIndex = tableView.indexPath(for: sender) else { return }
        
        print("removeCellClicked at \(cellIndex)")
        
        self.rowCount = rowCount - 1
        tableView.deleteRows(at: [cellIndex], with: .automatic)
        
        self.crewRowModelList.remove(at: cellIndex.row)
        self.selectedCrewInfoList.removeValue(forKey: cellIndex.row)
        
        AddHoursViewController.selectedCrewRows.removeValue(forKey: cellIndex.row)
        
        calculateTotalHours()
        calculateNonProdHours()
        
        setRemoveButtonVisiblity()
    }
    
    func totalHoursChanged(_ sender: AddHoursCustomCell)
    {
        guard let cellIndex = tableView.indexPath(for: sender) else { return }
        
      //  scrollToRow(row: cellIndex.row)
        
        let prodHoursText:String = sender.prodHoursTextField.text!
        print("\(Constants.TAG) prodHoursText \(prodHoursText)")
        
        print("totalHoursChanged at \(cellIndex) \(sender.prodHoursTextField.text)")
        
        let crewModel:CrewRowModel = self.crewRowModelList[cellIndex.row]
        crewModel.totalHours = sender.prodHoursTextField.text!
        
        var prodhours:Float = 0
        if(sender.prodHoursTextField.text != "")
        {
            prodhours = Float(prodHoursText)!
        }
        
        do
        {
            var selectedCrewModel:CrewInfoModel? = selectedCrewInfoList[cellIndex.row]
            
            selectedCrewModel?.hours = prodhours
            selectedCrewInfoList[cellIndex.row] = selectedCrewModel
            
            calculateTotalHours()
        }
        catch
        {
            print("EXCEPTION")
        }
    
    }
    
    func nonProdHoursChanged(_ sender: AddHoursCustomCell)
    {
        guard let cellIndex = tableView.indexPath(for: sender) else { return }
        print("nonProdHoursChanged at \(cellIndex) \(sender.nonProdHrzTextField.text)")

        let crewModel:CrewRowModel = self.crewRowModelList[cellIndex.row]
        crewModel.nonProdHours = sender.nonProdHrzTextField.text!
        
        var nonProdHours:Float = 0
        
        if(sender.nonProdHrzTextField.text! != "")
        {
            nonProdHours = Float(sender.nonProdHrzTextField.text!)!
        }
        
        var selectedCrewModel:CrewInfoModel? = selectedCrewInfoList[cellIndex.row]
        
       
            selectedCrewModel?.nonProdHours = nonProdHours
            selectedCrewInfoList[cellIndex.row] = selectedCrewModel
            
            calculateNonProdHours()
        
    }
    
    func setRemoveButtonVisiblity()
    {
        let cells = self.tableView.visibleCells as! Array<AddHoursCustomCell>
        
        if(cells.count == 1)
        {
            cells[0].removeRowButton.isHidden = true
        }
        else
        {
            for cell in cells
            {
                cell.removeRowButton.isHidden = false
            }
        }
        
        self.tableView.reloadData()
    }
    
    func calculateTotalHours()
    {
//        let cells = self.tableView.visibleCells as! Array<AddHoursCustomCell>
//
//        var totalprodHours:Int = 0
//
//
//        for cell in cells
//        {
//            let prodHours = Int(cell.prodHoursTextField.text!)
//
//            if(prodHours != nil)
//            {
//                totalprodHours = totalprodHours + prodHours!
//            }
//
//        }
//
//        print("Total hrz \(totalprodHours)")
//        self.totalProdHoursTextField.text = String(totalprodHours)
        
        var totalHrz:Int = 0
        
        print("\(Constants.TAG) crewRowModelList size: \(crewRowModelList.count)")
        
        for crewRow in crewRowModelList
        {
            print("\(Constants.TAG) total hrz in crew \(crewRow.totalHours)")
            
            if ((Int(crewRow.totalHours) as? Int) != nil)
            {
                totalHrz = totalHrz + Int(crewRow.totalHours)!
            }
            
        }
        self.totalProdHoursTextField.text = String(totalHrz)
        print("\(Constants.TAG) TOTAL HRZZ: \(totalHrz)")
    }
    
    
    func calculateNonProdHours()
    {
//        let cells = self.tableView.visibleCells as! Array<AddHoursCustomCell>
//
//        var totalNonProdHours:Int = 0
//
//        for cell in cells
//        {
//            let nonProdHours = Int(cell.nonProdHrzTextField.text!)
//
//            if(nonProdHours != nil)
//            {
//                totalNonProdHours = totalNonProdHours + nonProdHours!
//            }
//        }
//
//        print("Total Non prod hrz \(totalNonProdHours)")
//        self.totalNonProdHrzTextField.text = String(totalNonProdHours)
        
        
        var totalNonProdHrz:Int = 0
        
        print("\(Constants.TAG) crewRowModelList size: \(crewRowModelList.count)")
        
        for crewRow in crewRowModelList
        {
            print("\(Constants.TAG) total hrz in crew \(crewRow.nonProdHours)")
            
            if ((Int(crewRow.nonProdHours) as? Int) != nil)
            {
                totalNonProdHrz = totalNonProdHrz + Int(crewRow.nonProdHours)!
            }
            
        }
        self.totalNonProdHrzTextField.text = String(totalNonProdHrz)
        print("\(Constants.TAG) TOTAL NON PROD HRZZ: \(totalNonProdHrz)")
        
    }
    
     @objc func submitButtontapped()
    {
        print("submitButtontapped")
        
        if(!self.isNetworkAvailable)
        {
            showNetworkErrorDialog()
            return
        }
        
        for selectedCrewRow in AddHoursViewController.selectedCrewRows
        {
            print("selected crew row is \(selectedCrewRow.key) : \(selectedCrewRow.value)")
            
            if(selectedCrewRow.value == -1)
            {
               
                showErrorDialog(withMessage: "Select crew type")
                
                return
                break
            }
            
        }
        
        let cells = self.tableView.visibleCells as! Array<AddHoursCustomCell>
        
        if(validate())
        {
            self.view.isUserInteractionEnabled = false
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.hidesBackButton = true
            
            for cell in cells
            {
                cell.nonProdHrzTextField.resignFirstResponder()
                cell.prodHoursTextField.resignFirstResponder()
            }
            
            showLoading()
            
            let crewList:[CrewInfoModel] = getCrewInfoList()
            print("crewList size \(crewList.count)")
            
            self.enteredNote = self.note_TextField.text
            
            let waPostModel:WAPostModel = WAPostModel(GFId: Constants.UserID, WPCId: self.WPCircuitID, WAId: self.WorkAssignmentId, note: self.enteredNote!, crewInfo: crewList, tracedPaths: self.tracedPathsList, polygons: self.polygonsList, isTraceAll: self.isAllPathMode, isNoTrace: self.isNoTrace , logDate: self.logDate)
            
            let WAPostDict = waPostModel.createJson()
            print("\(Constants.TAG) WAPostDict \(WAPostDict)")
            
            Request.postWorkAssignment(forData: WAPostDict, delegate: self , session: nil, waPostModel: nil)

        }
        
        print("selectedCrewInfoList size \(selectedCrewInfoList.count)")
        
        for (rowIndex , crewInfoModel) in selectedCrewInfoList
        {
            print("submitButtontapped selectedCrewId \(rowIndex): \(crewInfoModel.crewTypeID)  \(crewInfoModel.hours) \(crewInfoModel.nonProdHours))")
        }
        
        
    }
    
    func validate() -> Bool
    {
        var isValid = true
        let cells = self.tableView.visibleCells as! Array<AddHoursCustomCell>
        
        var totalprodHours:Int = 0
        
        for cell in cells
        {
            let crewType = cell.selectCrewTextField.text!
            if(crewType == "Select crew type" || crewType == "")
            {
                isValid = false
                print("Invalid")
                showErrorDialog(withMessage: "Please select a crew type.")
                return isValid
                break
            }
            
            let prodHours = cell.prodHoursTextField.text!
            
            if(prodHours == "" || prodHours == "0")
            {
                isValid = false
                print("Invalid")
                showErrorDialog(withMessage: "Please enter productive hours.")
                return isValid
                break
            }
            
        }
        
        return isValid
    }
    
    func showLoading(){
        loadingNotif = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotif.mode = MBProgressHUDMode.indeterminate
        loadingNotif.label.text = "Submitting"
    }
    
    func getCrewInfoList() -> [CrewInfoModel]
    {
        var crewInfoListToSend:[CrewInfoModel] = [CrewInfoModel]()
        
        for crew in self.selectedCrewInfoList
        {
            let crewTypeId:Int = crew.value.crewTypeID
            let totalHours:Float = crew.value.hours
            let nonProdHours:Float = crew.value.nonProdHours
            
            var crewInfo = CrewInfoModel(crewTypeId: crewTypeId, hours: totalHours, nonProdHours: nonProdHours)
            crewInfoListToSend.append(crewInfo)
        }
        
        return crewInfoListToSend;
    }
    
    func onSuccessResponse(data: Any)
    {
        print("onSuccessResponse SUBMIT")
        
        DispatchQueue.main.sync
            {
                loadingNotif.hide(animated: true)
                
                print("sending WPId is \(self.WPId)")
                
                let circuitData = [
                    Constants.WPId : self.WPId
                ]
                
                showDialog(withMessage: "Assignment submitted successfully.")
                
                //  self.performSegue(withIdentifier: Constants.segueshowAddHoursToCircuitIdentifier, sender: circuitData)
                
        }
    }
    
    func onErrorResponse(msg: String)
    {
        print("onErrorResponse SUBMIT")
        
        DispatchQueue.main.sync {
             loadingNotif.hide(animated: true)
            showDialog(withMessage: "An error occured please try again.")
        }
    }
    
    func showDialog(withMessage message:String){
        loadingNotif.hide(animated: true)
        let alert = UIAlertController(title:message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            self.goBack()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDialogNoMoreCrews()
    {
        let alert = UIAlertController(title:"Cannot add more crew types.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
           
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func goBack(){
        guard let vcList = self.navigationController?.viewControllers else{
            return
        }
        if vcList[vcList.count - 3] is CircuitViewController {
            self.navigationController?.popToViewController(vcList[vcList.count - 3], animated: true)
        }
    }
    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.view.resignFirstResponder();
//    }
}

extension AddHoursViewController : UITableViewDelegate , UITableViewDataSource
{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 150
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addHoursCustomCell") as! AddHoursCustomCell
        cell.delegate = self
        cell.initCell();
        
        let crewRowModel = self.crewRowModelList[indexPath.row]
        
        if(crewRowModel.crewType != nil)
        {
            cell.selectCrewTextField.text = crewRowModel.crewType
            cell.prodHoursTextField.text = crewRowModel.totalHours
            cell.nonProdHrzTextField.text = crewRowModel.nonProdHours
        }
        else
        {
            cell.selectCrewTextField.text = "Select crew type"
            cell.prodHoursTextField.text = ""
            cell.nonProdHrzTextField.text = ""


        }
        
        return cell
    }
    
    func showErrorDialog(withMessage message:String){
        let alert = UIAlertController(title:message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    func createDatePicker()
    {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([done], animated: false)
        
        dateTextField.inputAccessoryView = toolBar
        dateTextField.inputView = datePicker
        
        datePicker.datePickerMode = .date
        
    }
    
    func setCurrentDateOnDatePicker()
    {
        let date = Data()
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd/yyyy"
        let dateString = dateFormatterPrint.string(from: datePicker.date)

        dateTextField.text = "\(dateString)"
        self.logDate = "\(dateString)"
        
    }
    
    @objc func donePressed()
    {
        let formatter = DateFormatter()
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "M/dd/yy"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MM/dd/yyyy"

        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let dateString = dateFormatterPrint.string(from: datePicker.date)
        
        self.logDate = dateString
        dateTextField.text = "\(dateString)"
        self.view.endEditing(true)
    }
}
























