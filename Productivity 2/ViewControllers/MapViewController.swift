//
//  MapViewController.swift
//  Productivity 2
//
//  Created by SPS on 26/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import UIKit
import Mapbox
import GoogleMaps
import MBProgressHUD

class MapViewController: UIViewController, MGLMapViewDelegate,
RequestsGenericDelegate{

    @IBOutlet weak var mapView: UIView!
    
    var map:MGLMapView?
    
    var pathsList = [CircuitPath] ()
    var pathIdentifierList:[Int:Bool] = [Int:Bool]()
    
    var remainingPaths = [LineModel]()
    var donePaths = [LineModel]()
    var WPCircuit:Int! = 0
    var WPId:Int! = 0
    var WorkAssignmentId:Int! = 0
    var crewArray:[[String:Any]] = [[String:Any]]()

    
    var coordinateList:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var polygonPoints:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
    var polygonsList:[[CLLocationCoordinate2D]] = [[CLLocationCoordinate2D]]()
    
    var polygonAnnotationsList:[MGLAnnotation] = [MGLAnnotation]()
    
    var loadingNotif:MBProgressHUD?
    var isAllPathMode:Bool = false
    var noTrace:Bool = false

    
    @IBOutlet weak var btn_startPolygon: UIButton!
    var isPolygonStarted:Bool = false
    

    @IBOutlet weak var btn_undo_polygon: UIButton!
    
    
    @IBOutlet weak var startPolygonBtnLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var startPolygonBtnBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var polygon_undoDone_View: UIView!
    
    
    @IBOutlet weak var lay_lock_done: UIView!
    @IBOutlet weak var btn_lock_map: UIButton!
  //  @IBOutlet weak var btn_done_FingerTrace: UIButton!
    
    
    @IBOutlet weak var btn_trace_polygon: UIButton!
    
    @IBOutlet weak var btn_trace_finger: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("WPCIRCUTID \(WPCircuit)")
        
        
        initMap()
    }
    
    func initMap(){
        map = MGLMapView(frame: mapView.bounds, styleURL: MGLStyle.streetsStyleURL(withVersion: 9))
        map!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map!.tintColor = UIColor.gray
        map!.delegate = self
        mapView.addSubview(map!)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(tap:)))
        
        for recognizer in (map?.gestureRecognizers!)! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        map?.addGestureRecognizer(singleTap)
        
    }
    
    @objc func handleSingleTap(tap: UITapGestureRecognizer)
    {
        if(isPolygonStarted)
        {
            print("tapped on map")
            
            let tapPoint: CGPoint = tap.location(in: map)
            let tapCoordinate: CLLocationCoordinate2D = map!.convert(tapPoint, toCoordinateFrom: nil)
            print("You tapped at: \(tapCoordinate.latitude), \(tapCoordinate.longitude)")
            
           // btn_undo_polygon.isHidden = false
            
            // Create an array of coordinates for our polyline, starting at the center of the map and ending at the tap coordinate.
            var coordinates: [CLLocationCoordinate2D] = [map!.centerCoordinate, tapCoordinate]
            
            var circuitMarker = MGLPointAnnotation.drawMarker(at: tapCoordinate, title: "polygon marker")
            let annotation = map?.addAnnotation(circuitMarker)
           
            polygonPoints.append(tapCoordinate)
        }
    }
    
    //MARK: Mapbox delegate functions
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
     //   showLoading()
        
        print("remaing path size \(remainingPaths.count)")
        print("done path size \(donePaths.count)")
        
        drawCircuit()

       // Request.getCircuits(delegate: self , WPId: 8)
    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if let polyline:CustomPolyline = annotation as? CustomPolyline {
            return polyline.color ?? mapView.tintColor
        }
        return mapView.tintColor
    }
    
    
    func fixateCamera(){
        print("fixateCamera()")
        print("No. of coordinates: \(coordinateList.count)")
        if coordinateList.count > 1 {
            let shape:MGLPolygon = MGLPolygon(coordinates: coordinateList, count: UInt(coordinateList.count))
            let coordinatebounds:MGLCoordinateBounds = shape.overlayBounds
            map?.setVisibleCoordinateBounds(coordinatebounds, edgePadding: UIEdgeInsets.init(top: 20, left: 20, bottom: 20, right: 20), animated: true)
        }
    }
    
    //MARK: Request delegate functions
    func onErrorResponse(msg: String) {
        DispatchQueue.main.sync {
            loadingNotif?.hide(animated: true)
            showAlert(withMessage: Constants.genericError, goBack: true)
        }
    }
    
    func drawCircuit()
    {
        //drawing remaining paths
        
        for line:LineModel in remainingPaths
        {
           let path = line.Path as [PointModel]
             var circuitCoordinateList:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
            
            for point in path
            {
                print("lat \(point.lat)")
                print("lat \(point.lng)")
                
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng)
                circuitCoordinateList.append(coordinate)
                coordinateList.append(coordinate)
            }
            
            let polyline:CustomPolyline = CustomPolyline.drawPolyline(through: circuitCoordinateList, color: UIColor.blue)
            map?.addAnnotation(polyline)
        }
        
        //drawing done paths
        
        for line:LineModel in donePaths
        {
            let path = line.Path as [PointModel]
            var circuitCoordinateList:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
            
            for point in path
            {
                print("lat \(point.lat)")
                print("lat \(point.lng)")
                
                let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: point.lat, longitude: point.lng)
                circuitCoordinateList.append(coordinate)
                coordinateList.append(coordinate)
            }
            
            let polyline:CustomPolyline = CustomPolyline.drawPolyline(through: circuitCoordinateList, color: UIColor.red)
            map?.addAnnotation(polyline)
        }
        
        fixateCamera()
    }
    
    func onSuccessResponse(data: Any) {
        
        guard let circuits = data as? [String: Any] else{
            return
        }
        
        guard let circuit1 = circuits["circuit1"] as? [[String : Any]] else
        {
            return
        }
        
        for obj in circuit1
        {
            var pathArray = [CLLocationCoordinate2D]()
            var pathPolyline = GMSMutablePath()
            
            let id = obj["Id"] as! Int
            pathIdentifierList[id] = false
            
            if let path = obj["Path"] as? [[String : Any]]
            {
                
                for point in path
                {
                    let lat = point["lat"]
                    let lng = point["lng"]
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat as! Double , longitude: lng as! Double)
                    
                    pathArray.append(coordinate)
                    pathPolyline.add(coordinate)
                    coordinateList.append(coordinate)
                }
                
                pathsList.append(CircuitPath(lineId: id, path: pathArray, gmsPath: pathPolyline))
                
                DispatchQueue.main.sync {
                    let polyline = MGLPolyline(coordinates: pathArray, count: UInt(pathArray.count))
                    polyline.title = "polyline"
                    map?.addAnnotation(polyline)
                }
                
            }
        }
        DispatchQueue.main.sync {
            loadingNotif?.hide(animated: true)
            fixateCamera()
        }
    }
    
    //MARK: Alert dialogs
    func showAlert(withMessage message:String, goBack:Bool){
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
    
    //MARK: Helper functions
    
    func showLoading(){
        loadingNotif = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotif!.mode = MBProgressHUDMode.indeterminate
        loadingNotif!.label.text = "Loading"
    }
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func drawPolygon()
    {
        let polygon = MGLPolygon(coordinates: polygonPoints, count: UInt(polygonPoints.count))
        map?.addAnnotation(polygon)
        
        isPolygonStarted = false
        polygon_undoDone_View.isHidden = true
        btn_startPolygon.isHidden = false
        
    }
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
   
    func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
    }
    
    @IBAction func btn_startPolygon_Clicked(_ sender: Any)
    {
        btn_startPolygon.isHidden = true
        polygon_undoDone_View.isHidden = false
        isPolygonStarted = true
    }
    
    
//    @IBAction func btnDone_Pressed(_ sender: Any)
//    {
//        drawPolygon()
//
//        var polygonPointsList:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
//
//        for coordinate in polygonPoints
//        {
//            polygonPointsList.append(coordinate)
//        }
//        polygonPointsList.append(polygonPoints[0])
//
//        polygonsList.append(polygonPointsList)
//
//        polygonPoints = [CLLocationCoordinate2D]()
//
//        for annotation in (map?.annotations)!
//        {
//
//            if (annotation.title! == "polygon marker")
//            {
//                map?.removeAnnotation(annotation as! MGLAnnotation)
//            }
//
//        }
//
//        self.btn_trace_polygon.isHidden = false
//        self.btn_trace_finger.isHidden = false
//
//        self.btn_startPolygon.isHidden = true
//
//    }
    
    
    @IBAction func btn_undoPolygon_Pressed(_ sender: Any)
    {
        let annotations:[MGLAnnotation] = (map?.annotations)!
        var markerAnnotations:[MGLAnnotation] = [MGLAnnotation]()
        
        for markerAnnotation in annotations
        {
            if (markerAnnotation.title! == "polygon marker")
            {
                markerAnnotations.append(markerAnnotation)
            }
        }
        
        
        let annotationsCount = markerAnnotations.count
        
        let lastAnnotation = annotations[annotationsCount - 1]
        map?.removeAnnotation(lastAnnotation as! MGLAnnotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("segueeee")
        
        if(segue.identifier == Constants.segueMapToAddHoursIdentifier)
        {
             print("segueMapToAddHoursIdentifier")
            let AddHoursVC = segue.destination as! FinalViewController
            
            let DataToPass = [
                Constants.WPId : self.WPId,
                Constants.WPCircuitID :WPCircuit,
                Constants.polygonsList : polygonsList,
                Constants.isAllPathMode : self.isAllPathMode,
                Constants.isNoTrace : self.noTrace,
                Constants.WorkAssignmentId : self.WorkAssignmentId
                
                ] as [String: Any]
            
        
            AddHoursVC.WPId = DataToPass[Constants.WPId] as! Int
            AddHoursVC.WPCircuitID = DataToPass[Constants.WPCircuitID] as! Int
            AddHoursVC.polygonsList = DataToPass[Constants.polygonsList] as! [[CLLocationCoordinate2D]]
            AddHoursVC.isAllPathMode = DataToPass[Constants.isAllPathMode] as! Bool
            AddHoursVC.isNoTrace = DataToPass[Constants.isNoTrace] as! Bool
            AddHoursVC.WorkAssignmentId = DataToPass[Constants.WorkAssignmentId] as! Int
            AddHoursVC.crewArray = self.crewArray as! [[String:Any]]
        }
    }

    @IBAction func btn_finish_pressed(_ sender: Any) {
        print("btn_finish_pressed")
    }
    
    
//    @IBAction func btn_done_pressed(_ sender: Any) {
//        print("btn_done_pressed")
//    }
    
    
    @IBAction func btn_trace_polygon_pressed(_ sender: Any)
    {
        self.btn_startPolygon.isHidden = false
        self.btn_trace_finger.isHidden = true
        self.btn_trace_polygon.isHidden = true
     //   self.btn_lock_map.isHidden = true
        
    }
    
    
    @IBAction func btn_trace_finger_pressed(_ sender: Any)
    {
        self.lay_lock_done.isHidden = false
        self.btn_startPolygon.isHidden = true
        self.btn_trace_polygon.isHidden = true
        self.btn_trace_finger.isHidden = true
        
      //  lockBtnBottomConstraint.priority = UILayoutPriority(rawValue: 1000)
      //  lockBtnLeadingConstraint.priority = UILayoutPriority(rawValue: 1000)

     //   startPolygonBtnBottomConstraint.priority = UILayoutPriority(rawValue: 999)
     //   startPolygonBtnLeadingConstraint.priority = UILayoutPriority(rawValue: 999)
        

    }
    
    
    @IBAction func btn_lockMap_pressed(_ sender: Any)
    {
      //  btn_done_FingerTrace.isHidden = false
    }
    
    
    @IBAction func btn_doneFinger_Pressed(_ sender: Any)
    {
        lay_lock_done.isHidden = true
        self.btn_trace_polygon.isHidden = false
        self.btn_trace_finger.isHidden = false
        
    }
}
