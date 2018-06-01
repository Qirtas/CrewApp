//
//  Extensions.swift
//  Productivity 2
//
//  Created by SPS on 23/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

class CustomPolyline: MGLPolyline {
    var color:UIColor?
    
    class func drawPolyline(through coordinates:[CLLocationCoordinate2D], color:UIColor)->CustomPolyline{
        let shape:CustomPolyline = CustomPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        shape.color = color
        return shape
    }
}

class CustomPolygonPolyline: MGLPolyline {
    var color:UIColor?
    var lineID : Int = 0
    
    class func drawPolyline(through coordinates:[CLLocationCoordinate2D], color:UIColor)->CustomPolygonPolyline{
        let shape:CustomPolygonPolyline = CustomPolygonPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        shape.color = color
        return shape
    }
}

extension MGLMapView{
    
    func drawPolyLine(through coordinates:[CLLocationCoordinate2D])->CustomPolyline{
        let shape:CustomPolyline = CustomPolyline(coordinates: coordinates, count: UInt(coordinates.count))
        shape.color = UIColor.red
        self.addAnnotation(shape)
        return shape
    }
}

extension MGLPointAnnotation{
    class func drawMarker(at coordinate:CLLocationCoordinate2D, title:String)->MGLPointAnnotation{
        let annotation = MGLPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        return annotation
    }
}

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension UIColor{
    convenience init(rgb: UInt, alphaVal: CGFloat)
    {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alphaVal
        )
    }
    
    func colorFromHex(_ hex :String) -> UIColor
    {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexString.hasPrefix("#")
        {
            hexString.remove(at: hexString.startIndex)
        }
        
        if hexString.count != 6
        {
            return UIColor.blue
        }
        
        var rgb: UInt32 = 0
        Scanner(string: hexString).scanHexInt32(&rgb)
        
        return UIColor.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                            blue: CGFloat(rgb & 0x0000FF) / 255.0,
                            alpha: 1.0)
        
        
    }
}

@IBDesignable
extension UIView{
    func loadViewFromNib()->UIView{
        let bundle = Bundle(for: type(of: self) as! AnyClass)
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let newView:UIView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return newView
    }
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismisssKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismisssKeyboard() {
        view.endEditing(true)
    }}
