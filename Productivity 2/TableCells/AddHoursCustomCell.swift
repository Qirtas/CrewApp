//
//  AddHoursCustomCell.swift
//  Productivity 2
//
//  Created by SPS on 24/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import UIKit


protocol CustomCrewTypeCellDelegate: class {
    func pickerValueChanged(_ sender: AddHoursCustomCell , row:Int , selectedCrewID: Int)
    func removeCellClicked(_ sender: AddHoursCustomCell)
    func totalHoursChanged(_ sender: AddHoursCustomCell)
    func nonProdHoursChanged(_ sender: AddHoursCustomCell)
}

class AddHoursCustomCell : UITableViewCell , UIPickerViewDelegate , UIPickerViewDataSource , UITextFieldDelegate
{
    
    @IBOutlet weak var selectCrewTextField: UITextField!
    @IBOutlet weak var prodHoursTextField: UITextField!
    @IBOutlet weak var nonProdHrzTextField: UITextField!
    
    @IBOutlet weak var removeRowButton: UIButton!
    @IBOutlet weak var row_bg_view: UIView!

    
    weak var delegate: CustomCrewTypeCellDelegate?
    var crewTypeModelsList = [CrewModel]()
    
    var dayPicker: UIPickerView?
    var selectedDays = [String]()
    
    
    
//    let days = [
//        "Select a day",
//        "Monday",
//        "Tuesday",
//        "Wed",
//        "Thu",
//        "Fri"
//    ]

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Initialization code
        print("&&&&&&&&&&&")
        self.initCell();
        
     //   self.row_bg_view.backgroundColor = UIColor(patternImage: UIImage(named: "crew_bgshadow")!)
    }
    
    func initCell() {
        parseCrewTypesArray()
        
        createPicker()
        createToolBar()
        
        self.prodHoursTextField.keyboardType = UIKeyboardType.numberPad
        self.nonProdHrzTextField.keyboardType = UIKeyboardType.numberPad
        
        self.prodHoursTextField.delegate = self
        self.prodHoursTextField.tag = 1
        
        self.nonProdHrzTextField.delegate = self
        self.nonProdHrzTextField.tag = 2
    }
    
    
    @IBAction func didTapRemoveRowButton(_ sender: Any) {
        print("removeRowTapped")
        delegate?.removeCellClicked(self)
    }
    
    func createPicker()
    {
        dayPicker = UIPickerView()
        dayPicker?.delegate = self
        
        dayPicker?.selectRow(0, inComponent: 0, animated: true)
        selectCrewTextField.inputView = dayPicker
    }
    
    func createToolBar()
    {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(AddHoursCustomCell.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        selectCrewTextField.inputAccessoryView = toolBar
    }
    
    @objc func dismissKeyboard()
    {
        print("dismissKeyboard")
        if(dayPicker?.selectedRow(inComponent: 0) == 0)
        {
            print("dismissKeyboard \(dayPicker?.selectedRow(inComponent: 0))")
            delegate?.pickerValueChanged(self , row: (self.dayPicker?.selectedRow(inComponent: 0))! , selectedCrewID: -1)
            return
        }
        
        delegate?.pickerValueChanged(self , row: (self.dayPicker?.selectedRow(inComponent: 0))! , selectedCrewID: crewTypeModelsList[(self.dayPicker?.selectedRow(inComponent: 0))!].id)

        
        self.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return crewTypeModelsList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return crewTypeModelsList[row].title
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("didSelectRow \(crewTypeModelsList[row].title)")
        Constants.isCrewOpned = true
        
        self.selectCrewTextField.text = crewTypeModelsList[row].title
        
        selectedDays.append(crewTypeModelsList[row].title)
        
        delegate?.pickerValueChanged(self , row: row , selectedCrewID: crewTypeModelsList[row].id)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing")
        Constants.isHoursFieldActive = true
        textField.text = ""
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        print("shouldChangeCharactersIn \(textField.text?.count)     String is:   \(string)")
        
        if string == "."
        {
            print("<<<<<<")
            return false
        }
        
//        if textField == prodHoursTextField
//        {
//            let textString : NSString = textField.text! as NSString
//            let candidateString : NSString = textString.replacingCharacters(in: range, with: string) as NSString
//          //  let updatedTextString : String = PartialFormatter().formatPartial(candidateString as String)
//            print(candidateString)
//            textField.text = candidateString as! String
//        }
        
        
        guard let text = textField.text else { return true }

        if((textField.text?.count)! > 0)
        {
            if(textField.tag == 1)
            {
                delegate?.totalHoursChanged(self)
                
            }
            else
            {
                delegate?.nonProdHoursChanged(self)
                
            }
        }
        
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 4
        
     //   return true
        

    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        print("text is \(textField.text)  TAG \(textField.tag)")

        if(textField.tag == 1)
        {
            delegate?.totalHoursChanged(self)
        }
        else
        {
            delegate?.nonProdHoursChanged(self)
        }
    }
    
    func parseCrewTypesArray()
    {
        crewTypeModelsList = [CrewModel]()
        
        let crewTypeModel = CrewModel(id: -1 as! Int, title: "Select crew type" as! String)
        crewTypeModelsList.append(crewTypeModel)
        
        for crewType in AddHoursViewController.crewArray
        {
            let id = crewType["Id"]
            let title = crewType["Title"]
            
            print("crew is \(id) and title is \(title)")
            
            let crewTypeModel = CrewModel(id: id as! Int, title: title as! String)
            crewTypeModelsList.append(crewTypeModel)
        }
        
        AddHoursViewController.totalCrewTypesCount = crewTypeModelsList.count-1
    }
    
   
    
}
