//
//  BottomViewController.swift
//  Productivity 2
//
//  Created by SPS on 26/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import UIKit
import Mapbox
import MBProgressHUD

class FinalViewController: UIViewController, MGLMapViewDelegate , UIPickerViewDelegate , UIPickerViewDataSource , RequestsGenericDelegate  {
   
    @IBOutlet weak var mapView: UIView!
    
    let types = ["type1" , "type2" , "typw3" , "type4" , "type5"]

    var crewArray:[[String:Any]] = [[String:Any]]()
    var crewTypeModelsList = [CrewModel]()

    var map:MGLMapView?
    
    var waPostModel:WAPostModel!
    
    var WPId:Int = 0
    var WorkAssignmentId:Int = 0
    var WPCircuitID:Int = 0
    var isAllPathMode : Bool = false
    var isNoTrace : Bool = false
    var loadingNotif:MBProgressHUD! = nil
    
    @IBOutlet weak var noteTextField: UITextField!
    
    @IBOutlet weak var crewTypePicker: UIPickerView!
    @IBOutlet weak var note_textField: UILabel!
    @IBOutlet weak var nonProdHours_textField: UITextField!
    @IBOutlet weak var prodHours_textField: UITextField!
    var polygonsList:[[CLLocationCoordinate2D]] = [[CLLocationCoordinate2D]]()
    var tracedPathsList:[[CLLocationCoordinate2D]] = [[CLLocationCoordinate2D]]()
    var crewInfoList:[CrewInfoModel] = [CrewInfoModel]()
    
    var selectedCrewTypeId:Int = 0
    var enteredTotalHours:Float = 0
    var enteredNonProdHours:Float = 0
    var enteredNote:String = "note"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(Constants.TAG) WPId \(WPId)")
        print("\(Constants.TAG) CircuitID \(WPCircuitID)")
        print("\(Constants.TAG) Polygons list size \(polygonsList.count)")
        print("\(Constants.TAG) Traced paths list size \(tracedPathsList.count)")
        print("\(Constants.TAG) CREWS ARRAY size \(crewArray.count)")
        print("\(Constants.TAG) isNoTrace \(isNoTrace)")
        print("\(Constants.TAG) isAllPathMode \(isAllPathMode)")

        
        self.prodHours_textField.keyboardType = UIKeyboardType.numberPad
        self.nonProdHours_textField.keyboardType = UIKeyboardType.numberPad

        self.hideKeyboardWhenTappedAround()
        crewTypePicker.delegate = self

        parseCrewTypesArray()
        
       // initMap()
    }
    
    @IBAction func btn_submitAssignment_Pressed(_ sender: Any)
    {
        print("Note: \(self.note_textField.text)")
        print("ProdHours: \(self.prodHours_textField.text)")
        print("NonProdHours: \(self.nonProdHours_textField.text)")
        
        
        if(validateFields())
        {
            showLoading()
            
            if(self.prodHours_textField.text == "")
            {
                enteredNonProdHours = 0
            }
            else
            {
                enteredNonProdHours = Float(prodHours_textField.text!)!
            }
            
            enteredTotalHours = Float(nonProdHours_textField.text!)!
            enteredNote = noteTextField.text!
            
            crewInfoList = getCrewInfoList()
            
            waPostModel = WAPostModel(GFId: Constants.UserID, WPCId: self.WPCircuitID, WAId: self.WorkAssignmentId, note: enteredNote, crewInfo: self.crewInfoList, tracedPaths: self.tracedPathsList, polygons: self.polygonsList, isTraceAll: self.isAllPathMode, isNoTrace: self.isNoTrace)
            
            let WAPostDict = waPostModel.createJson()
            print("\(Constants.TAG) WAPostDict \(WAPostDict)")
            
            Request.postWorkAssignment(forData: WAPostDict, delegate: self , session: nil, waPostModel: nil)
        }
        
    }
    
    func validateFields() -> Bool
    {
        var isValid:Bool = true
        
        if(self.selectedCrewTypeId == 0)
        {
            isValid = false
            showErrorDialog(withMessage: "Please select a crew type.", goBack: false)
        }
        
        else if(self.nonProdHours_textField.text == "")
        {
            isValid = false
            showErrorDialog(withMessage: "Please enter productive hours.", goBack: false)
        }
    
        
        return isValid
    }
    
    func getCrewInfoList() -> [CrewInfoModel]
    {
        var crewInfoList:[CrewInfoModel] = [CrewInfoModel]()
        
        var crewInfo = CrewInfoModel(crewTypeId: selectedCrewTypeId, hours: enteredTotalHours, nonProdHours: enteredNonProdHours)
        crewInfoList.append(crewInfo)
        
        return crewInfoList;
    }
    
    func parseCrewTypesArray()
    {
        crewTypeModelsList = [CrewModel]()
        
        for crewType in crewArray
        {
            let id = crewType["Id"]
            let title = crewType["Title"]
            
            print("crew is \(id) and title is \(title)")
            
            let crewTypeModel = CrewModel(id: id as! Int, title: title as! String)
            crewTypeModelsList.append(crewTypeModel)
        }
    }
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return crewTypeModelsList.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return crewTypeModelsList[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("crew type selected \(row)  \(crewTypeModelsList[row].title)")
        
        selectedCrewTypeId = crewTypeModelsList[row].id
        
    }
    
    func showLoading(){
        loadingNotif = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotif.mode = MBProgressHUDMode.indeterminate
        loadingNotif.label.text = "Submitting"
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
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == Constants.segueshowAddHoursToCircuitIdentifier)
        {
            let circuitVC = segue.destination as! CircuitViewController

            if let circuitData = sender as? [String: Any]
            {
                circuitVC.WPId = self.WPId as! Int
            }

        }
    }
    
    func onErrorResponse(msg: String) {
        print("onSuccessResponse SUBMIT")
        
        DispatchQueue.main.sync {
           // loadingNotif.hide(animated: true)
            showDialog(withMessage: Constants.assignmentSubmitSuccessful)
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
    
    func goBack(){
        guard let vcList = self.navigationController?.viewControllers else{
            return
        }
        if vcList[vcList.count - 3] is CircuitViewController {
            self.navigationController?.popToViewController(vcList[vcList.count - 3], animated: true)
        }
    }
    
    func showErrorDialog(withMessage message:String, goBack:Bool)
    {
        let alert = UIAlertController(title:message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        if goBack {
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                self.goBack()
            }))
        }
        else{
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
}













