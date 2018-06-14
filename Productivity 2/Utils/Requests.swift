//
//  Requests.swift
//  Productivity 2
//
//  Created by SPS on 26/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation

protocol RequestsGenericDelegate:class{
    func onErrorResponse(msg:String)
    func onSuccessResponse(data: Any)
}

public class Request
{
    public static let BASE_URL = "https://vpa-test-backend.mybluemix.net/"
    
    //https://vpa-test-backend.mybluemix.net/
    //http://apabackendrevamp.mybluemix.net/
    
    public static let CIRCUIT_URL = "workPlanMobile/getGFCircuitsByWPId?Id="  + String(Constants.UserID) + "&WPId="
    public static let WORKPLANS_URL = "workPlanMobile/getGFWorkPlans?Id=" + String(Constants.UserID)
    public static let WORKASSIGNMENT_POST_URL = "workPlanMobile/addWorkAssignmentLog"
    public static let LOGIN_URL = "users/login1"

    class func getWorkPlans(delegate:RequestsGenericDelegate)
    {
        guard let url = URL(string: BASE_URL + WORKPLANS_URL) else {return}
        print("getWorkPlans URL: \(url)")
        
        let session = URLSession.shared
       
        session.dataTask(with: url) { (data, response, error) in
            if let response = response
            {
                print(response)
                
                let responseData = String(data: data! , encoding: String.Encoding.utf8)
                print("responseData \(responseData)")
                
                
                if let data = data {
                    do{
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let success = json!["success"]{
                            if(String(describing: success) == "1"){
                                delegate.onSuccessResponse( data: json!["result"])
                            }
                            else{
                                delegate.onErrorResponse( msg: json!["message"] as! String)
                            }
                        }
                        else{
                            print("parsing error!")
                            delegate.onErrorResponse(msg: Constants.genericError)
                        }
                    }catch {
                        print(error)
                        delegate.onErrorResponse(msg: Constants.genericError)
                    }
                }
                else{
                    delegate.onErrorResponse(msg: Constants.genericError)
                }
                
            }
            
            if let error = error
            {
                print("Error occured  \(error)")
            }
        }.resume()
    }
    
    class func getCircuits(delegate:RequestsGenericDelegate , WPId:Int)
    {
//        guard let url = URL(string: "\(BASE_URL + CIRCUIT_URL)") else{
//            return
//        }
        
        guard let url = URL(string: "\(BASE_URL + CIRCUIT_URL + String(WPId))" ) else{
                        return
                    }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let response = response {
               // print("Circuits response \(response)")
                
                let responseData = String(data: data! , encoding: String.Encoding.utf8)
              //  print("Circuits responseData \(responseData)")
                
            }

            
            if let data = data {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let success = json!["success"]{
                        if(String(describing: success) == "1"){
                            delegate.onSuccessResponse( data: json!["result"])
                        }
                        else{
                            delegate.onErrorResponse( msg: json!["message"] as! String)
                        }
                    }
                    else{
                        print("parsing error!")
                        delegate.onErrorResponse(msg: Constants.genericError)
                    }
                }catch {
                    print(error)
                    delegate.onErrorResponse(msg: Constants.genericError)
                }
            }
            else{
                delegate.onErrorResponse(msg: Constants.genericError)
            }
            }.resume()
    }
    
    
    class func postWorkAssignment(forData data:[String: Any], delegate:RequestsGenericDelegate? , session:URLSession?, waPostModel:WAPostModel?)->Bool
    {
        guard let url = URL(string: "\(Request.BASE_URL)\(Request.WORKASSIGNMENT_POST_URL)") else{
            return false
        }
        guard let request = getRequest(forUrl: url, forData: data) else{
            return false
        }
        print("\(Constants.TAG) REQUEST \(request)")
        
        var session = session
        if session == nil{
            session = URLSession.shared
        }
        session!.dataTask(with: request) { (data, response, error) in
            if let response = response{
                
                let responseData = String(data: data! , encoding: String.Encoding.utf8)
             print("\(Constants.TAG) postWorkAssignment responseData \(responseData)")
             }
            
            if let data = data {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print(json)
                    if let success = json!["success"]
                    {
                        if(String(describing: success) == "1"){
                            delegate?.onSuccessResponse(data: json!["result"])
                        }
                        else
                        {
                                delegate?.onErrorResponse(msg: "Error occurred.")
                        }
                      
                    }
                   
                }catch {
                    print(error)
                    delegate?.onErrorResponse(msg: Constants.genericError)
                }
            }
            else{
                delegate?.onErrorResponse( msg: Constants.genericError)
            }
           
            }.resume()
        return true
    }
    
    
    class func loginRequest(forData data:[String: Any], delegate:RequestsGenericDelegate? , session:URLSession?)->Bool
    {
        guard let url = URL(string: "\(Request.BASE_URL)\(Request.LOGIN_URL)") else{
            return false
        }
        guard let request = getRequest(forUrl: url, forData: data) else{
            return false
        }
        print("\(Constants.TAG) REQUEST \(request)")
        
        var session = session
        if session == nil{
            session = URLSession.shared
        }
        session!.dataTask(with: request) { (data, response, error) in
            if let response = response{
                
                let responseData = String(data: data! , encoding: String.Encoding.utf8)
                print("\(Constants.TAG) postWorkAssignment responseData \(responseData)")
            }
            
            if let data = data {
                do{
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print(json)
                    if let success = json!["success"]
                    {
                        if(String(describing: success) == "1"){
                            delegate?.onSuccessResponse(data: json!["result"])
                        }
                        else
                        {
                            
                            delegate?.onErrorResponse(msg: "Username or Password incorrect.")
                        }
                        
                    }
                    
                }catch {
                    print(error)
                    delegate?.onErrorResponse(msg: Constants.genericError)
                }
            }
            else{
                delegate?.onErrorResponse( msg: Constants.genericError)
            }
            
            }.resume()
        
         return true
    }

    class func getRequest(forUrl url:URL, forData data:[String: Any])->URLRequest?{
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonBody:Data!
        do{
            jsonBody = try JSONSerialization.data(withJSONObject: data, options: [])
            print(String(bytes: jsonBody, encoding: String.Encoding.utf8))
            request.httpBody = jsonBody
        }
        catch let error{
            print(error)
            return nil
        }
        return request
    }
    
}

