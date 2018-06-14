//
//  LoginViewController.swift
//  Productivity 2
//
//  Created by SPS on 27/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import Mapbox

class LoginViewController: UIViewController , RequestsGenericDelegate , ReachabilityDelegate
{
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var PinTextField: UITextField!
    var reachabilityManager:ReachabilityManager?
    
    var loadingNotif:MBProgressHUD! = nil
    var userID:Int?
    var isNetworkAvailable:Bool = true

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        reachabilityManager = ReachabilityManager(delegate: self)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        let strVar:String = "2."
        let floatVar:Float = Float(strVar)!
        
        print("floatVar \(floatVar)")
        
        self.navigationController?.isNavigationBarHidden = true
        
//        P: CLLocationCoordinate2D(latitude: 41.589016090385485, longitude: -87.553995147699879)
//        P2: CLLocationCoordinate2D(latitude: 41.589005551951345, longitude: -87.553950528685789)
//        Q: CLLocationCoordinate2D(latitude: 41.588979668080469, longitude: -87.553985877818263)
//        Q2: CLLocationCoordinate2D(latitude: 41.589025796834051, longitude: -87.553965236891372)
        
        let isIntersect:Bool = Constants.doLineSegmentsIntersect(p: CLLocationCoordinate2D(latitude: 41.589016090385485, longitude: -87.553995147699879),
                                                                 p2: CLLocationCoordinate2D(latitude: 41.589005551951345, longitude: -87.553950528685789),
                                                                 q: CLLocationCoordinate2D(latitude: 41.588979668080469, longitude: -87.553985877818263),
                                                                 q2: CLLocationCoordinate2D(latitude: 41.589025796834051, longitude: -87.553965236891372))
        
        print("isIntersect \(isIntersect)")
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        reachabilityManager?.startMonitoring()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("^^^^^")
        self.navigationController?.setViewControllers([self], animated: true)
        self.navigationController?.isNavigationBarHidden = true

    }
    
    @IBAction func loginBtnPressed(_ sender: Any)
    {
        if(!self.isNetworkAvailable)
        {
            showNetworkErrorDialog(withMessage: "Network not available.")
            return
        }
        
        print("name \(self.userNameTextField.text)")
        print("name \(self.PinTextField.text)")
        
        let PostDict = createJson(username: self.userNameTextField.text, password: self.PinTextField.text)
        print("\(Constants.TAG) PostDict \(PostDict)")
        
        showLoading()
        
        Request.loginRequest(forData: PostDict, delegate: self, session: nil)
    }
    
    func createJson(username:Any , password:Any) -> [String:Any]
    {
        var PostDictionary = [String:Any]()
        
        PostDictionary["username"] = username
        PostDictionary["password"] = password
        
        return PostDictionary
    }
    
    func showLoading()
    {
        loadingNotif = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotif.mode = MBProgressHUDMode.indeterminate
        loadingNotif.label.text = "Processing"
    }
    
    func showErrorDialog(withMessage message:String)
    {
        loadingNotif.hide(animated: true)
        let alert = UIAlertController(title:message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNetworkErrorDialog(withMessage message:String)
    {
        let alert = UIAlertController(title:message, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func onErrorResponse(msg: String)
    {
         print("onSuccessResponse \(msg)")
        
        DispatchQueue.main.sync
        {
                loadingNotif.hide(animated: true)
            showErrorDialog(withMessage: msg)
        }
        
    }
    
    func onSuccessResponse(data: Any)
    {
         print("onSuccessResponse")
        
        DispatchQueue.main.sync
        {
                loadingNotif.hide(animated: true)
            
            if let dict = data as? [String: Any]
            {
                let userDataArray = dict["UserData"] as! [[String : Any]]
                print("onSuccessResponse userDataArray \(userDataArray)")
             
                for user in userDataArray
                {
                    let userID = user["Id"] as! Int
                    self.userID = userID
                    Constants.UserID = 14
                }
                
            }
            
            performSegue(withIdentifier: Constants.segueShowWorkPlansIdentifier, sender: nil)

        }
        
    }
    
    //MARK: Keyboard functions
    
    @objc func dismissKeyboard() -> Bool {
        self.userNameTextField.resignFirstResponder()
        self.PinTextField.resignFirstResponder()
        return false
    }
    
    func networkAvailable()
    {
        isNetworkAvailable = true
        print("networkAvailable")
    }
    
    func networkNotAvailable()
    {
        isNetworkAvailable = false
        print("networkNotAvailable")
    }
    
}
