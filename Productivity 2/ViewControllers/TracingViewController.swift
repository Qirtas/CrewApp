//
//  TracingViewController.swift
//  Productivity 2
//
//  Created by SPS on 18/04/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import UIKit
import Mapbox
import GoogleMaps
import MBProgressHUD

public struct Path
{
    let lineId:Int
    let path:[CLLocationCoordinate2D]
    let gmsPath:GMSMutablePath
}

class MyCustomPointAnnotation: MGLPointAnnotation
{
    var annotationID : Int = 0
    var willUseImage: Bool = false
}

class MyPolygonAnnotation: MGLPolygon
{
    var annotationID : Int = 0
    var willUseImage: Bool = false
}


class TracingViewController: UIViewController  ,MGLMapViewDelegate , RequestsGenericDelegate , dragaableAnnotationDelegate , UIGestureRecognizerDelegate , ReachabilityDelegate
{
    
    
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var tracingOptionsSelectionView: UIView!
    
    //Tracing options
    
    @IBOutlet weak var btn_trace_by_polygon: UIButton!
    @IBOutlet weak var btn_trace_by_finger: UIButton!
    @IBOutlet weak var btn_trace_all_path: UIButton!
    
    //Active views
    
    //Polygon active
    @IBOutlet weak var trace_polygon_active_view: UIView!
    @IBOutlet weak var trace_polygon_active_label: UILabel!
    
    //Finger active
    
    @IBOutlet weak var trace_finger_active_view: UIView!
    @IBOutlet weak var trace_finger_active_label: UILabel!
    
    //Polygon functions view
    @IBOutlet weak var polygonsBtnsView: UIView!
    @IBOutlet weak var btn_undo_polygon: UIButton!
    @IBOutlet weak var btn_start_done_polygon: UIButton!
    @IBOutlet weak var start_polygon_image: UIImageView!
    @IBOutlet weak var undo_image_view: UIImageView!
    
    //Trace by finger functions
    
    @IBOutlet weak var traceFingerBtnsView: UIView!
    @IBOutlet weak var btn_lock_map: UIButton!
    @IBOutlet weak var btn_done_finger_tracing: UIButton!
    @IBOutlet weak var done_trace_imageview: UIImageView!
    
    
    @IBOutlet weak var locked_imageView_constraint: NSLayoutConstraint!
    
    var map: MGLMapView!
    
    var pathsList = [CircuitPath] ()
    var pathIdentifierList:[Int:Bool] = [Int:Bool]()
    var circuitFullObj : [String:Any] = [String:Any]()
    
    var remainingPaths = [LineModel]()
    var donePaths = [LineModel]()
    var WPCircuit:Int! = 0
    var WPId:Int! = 0
    var WorkAssignmentId:Int! = 0
    var crewArray:[[String:Any]] = [[String:Any]]()
    
    var coordinateList:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    var polygonPoints:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
    var polygonsList:[[CLLocationCoordinate2D]] = [[CLLocationCoordinate2D]]()
    var isPolygonStarted:Bool = false
    var polygonAnnotationsList:[MGLAnnotation] = [MGLAnnotation]()
    var polygonAnnotationIdCounter:Int = 0
    var polygonLineIdCounter:Int = 0
    
    var polygonPointsCounter:Int = 0
    var polygonLinesList:[CustomPolyline] = [CustomPolyline]()
    
    var loadingNotif:MBProgressHUD?
    var isAllPathMode:Bool = false
    var noTrace:Bool = true
    
    //Trace finger stuff
    static public var isLocked = false
    var isDraggableAnnotationAdded:Bool = false
    var draggablePoint:DraggableAnnotationView?
    var tracedPathsList:[[CLLocationCoordinate2D]]? = [[CLLocationCoordinate2D]]()
    var centerCoordinate:CLLocationCoordinate2D?
    var allPathsList = [Path] ()
    
    var isPolygonBeingDrawn:Bool = false
    var isTracingBeingDrawn:Bool = false
    
    var notesList:[NoteModel] = [NoteModel]()

    var isNetworkAvailable:Bool = true
    var reachabilityManager:ReachabilityManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("TracingViewController")
        print("WPCIRCUTID \(WPCircuit)")
        print(" \(Constants.TAG) fullCircuitObj \(circuitFullObj.count)")
        print(" \(Constants.TAG) notes list size \(notesList.count)")

        
        reachabilityManager = ReachabilityManager(delegate: self)
        
        TracingViewController.isLocked = false
        
        //  let FinishButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(tapnavigationbarButon))
        
        let FinishButton = UIBarButtonItem(title: "Finish", style: .plain, target: self, action: #selector(tapnavigationbarButon))
        self.navigationItem.rightBarButtonItem = FinishButton
        
        btn_trace_by_polygon.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        btn_trace_by_finger.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        btn_trace_all_path.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        
        trace_polygon_active_label.clipsToBounds = true
        trace_polygon_active_label.font = UIFont.boldSystemFont(ofSize: 13)
        
        trace_finger_active_label.clipsToBounds = true
        trace_polygon_active_label.font = UIFont.boldSystemFont(ofSize: 13)
        
        btn_start_done_polygon.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15)
        
        
        initMap()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        reachabilityManager?.startMonitoring()
        
        self.isAllPathMode = false
        //        self.noTrace = false
    }
    
    func initMap()
    {
        
        map = MGLMapView(frame: mapView.bounds, styleURL: MGLStyle.streetsStyleURL(withVersion: 9))
        map!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map!.tintColor = UIColor.gray
        map!.delegate = self
        mapView.addSubview(map!)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(tap:)))
        
        
                singleTap.delegate = self
//                for recognizer in (map?.gestureRecognizers!)! where recognizer is UITapGestureRecognizer {
//                    singleTap.require(toFail: recognizer)
//                }
        
        map?.addGestureRecognizer(singleTap)
        map?.isUserInteractionEnabled = true

        let marker1 = MGLPointAnnotation.drawMarker(at: CLLocationCoordinate2D(latitude: 33.676521, longitude: 73.030338), title: "intersecting point")
        marker1.subtitle = "dsfdhfkldhfkjldfhd"
        map?.addAnnotation(marker1)

        drawNotesMarkers()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        print("*********")
        return true
    }
    
//    @objc func handleSingleTap(tap: UITapGestureRecognizer)
//    {
//        print("@@@@@@")
//    }
    
    @objc func handleSingleTap(tap: UITapGestureRecognizer)
    {
        print("@@@@@@")

        if(isPolygonStarted)
        {
            print("tapped on map")

            var tapPoint: CGPoint = tap.location(in: self.view)
            let tapCoordinate: CLLocationCoordinate2D = map!.convert(tapPoint, toCoordinateFrom: self.view)
            print("You tapped at: \(tapCoordinate.latitude), \(tapCoordinate.longitude)")

            if(checkIntersection(q2: tapCoordinate))
            {
                print("Intersection")
                showErrorDialog(withMessage: "Invalid point.", goBack: false)
                return
            }

            self.isPolygonBeingDrawn = true

            polygonAnnotationIdCounter = polygonAnnotationIdCounter + 1
            polygonPointsCounter = polygonPointsCounter + 1

            //  var tapPoint: CGPoint = tap.location(in: map)


            btn_undo_polygon.isHidden = false
            self.undo_image_view.isHidden = false

            let point = MyCustomPointAnnotation()
            point.title = Constants.annotation_polygon_dot
            point.coordinate = tapCoordinate
            point.willUseImage = true
            point.annotationID = polygonAnnotationIdCounter
            map?.addAnnotation(point)

            polygonPoints.append(tapCoordinate)

            if(polygonPoints.count > 1)
            {
                self.drawPolyLine()
            }
        }
    }

    
    
    
    @IBAction func btnUndoPolygonPressed(_ sender: Any)
    {
        let annotationsList:[MGLAnnotation] = (map?.annotations)! as! [MGLAnnotation]
        print("\(Constants.TAG) annotationsList size \(annotationsList.count)")
        
        for annotation in annotationsList
        {
            let ann = annotation as? MyCustomPointAnnotation
            
            if(annotation.title != nil && annotation.title! == Constants.annotation_polygon_dot)
            {
                if(ann?.annotationID == polygonPointsCounter)
                {
                    print("\(Constants.TAG) Annotation ID \(ann?.annotationID)")
                    map?.removeAnnotation(annotation)
                    let polygonpointsCount = polygonPoints.count
                    polygonPoints.remove(at: polygonpointsCount - 1)
                    
                    polygonPointsCounter = polygonPointsCounter - 1
                    polygonAnnotationIdCounter = polygonAnnotationIdCounter - 1
                    
                    print("\(Constants.TAG) polygonpointsCount \(polygonpointsCount)")
                    
                    
                    if(polygonpointsCount == 2)
                    {
                        self.btn_undo_polygon.isHidden = true
                        self.undo_image_view.isHidden = true
                        self.isPolygonBeingDrawn = false
                        self.btn_start_done_polygon.setTitle("Start", for: UIControlState.normal)
                        isPolygonStarted = false
                        
                        // polygonAnnotationIdCounter = 0
                        polygonPoints = [CLLocationCoordinate2D]()
                        
                        for annotation in annotationsList
                        {
                            let ann = annotation as? MyCustomPointAnnotation
                            
                            if(annotation.title != nil && annotation.title! == Constants.annotation_polygon_dot)
                            {
                                if(ann?.annotationID == polygonPointsCounter)
                                {
                                    map?.removeAnnotation(annotation)
                                }
                            }
                        }
                        
                    }
                    
                    if(polygonpointsCount == 1)
                    {
                        self.btn_undo_polygon.isHidden = true
                        self.undo_image_view.isHidden = true
                        self.isPolygonBeingDrawn = false
                        self.btn_start_done_polygon.setTitle("Start", for: UIControlState.normal)
                        isPolygonStarted = false
                        
                        // polygonAnnotationIdCounter = 0
                        polygonPoints = [CLLocationCoordinate2D]()
                    }
                    break
                }
                
            }
            
            let lineAnn = annotation as? CustomPolygonPolyline
            
            if(lineAnn?.title != nil && lineAnn?.title! == Constants.annotation_polygon_line)
            {
                if(lineAnn?.lineID == polygonLineIdCounter)
                {
                    print("\(Constants.TAG) LINE ID MATCHED \(lineAnn?.lineID)")
                    
                    map?.removeAnnotation(annotation)
                    polygonLineIdCounter = polygonLineIdCounter - 1
                    
                }
            }
        }
    }

    
    //MARK: Mapbox delegate functions
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView)
    {
        //   showLoading()
        
        print("remaing path size \(remainingPaths.count)")
        print("done path size \(donePaths.count)")
        
        drawCircuit()
        
        // Request.getCircuits(delegate: self , WPId: 8)
    }
    
//    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
//        if let polyline:CustomPolyline = annotation as? CustomPolyline {
//            return polyline.color ?? mapView.tintColor
//        }
//        return mapView.tintColor
//    }
//
//    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//        return true
//    }
//
//    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
//        print("@@@didSelect annotation@@")
//    }
//
//    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
//        print("@@@didSelect annotationView")
//    }
//
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage?
    {

        if let castAnnotation = annotation as? MyCustomPointAnnotation {
            if (!castAnnotation.willUseImage) {
                return nil;
            }
        }

        if let annotation:MGLAnnotation = annotation
        {
            if(annotation.title != nil && annotation.title! == Constants.annotation_polygon_dot)
            {
                var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "pisa")

                if annotationImage == nil
                {
                    // Leaning Tower of Pisa by Stefan Spieler from the Noun Project.
                    var image = UIImage(named: "gree_dot_small")!

                    // The anchor point of an annotation is currently always the center. To
                    // shift the anchor point to the bottom of the annotation, the image
                    // asset includes transparent bottom padding equal to the original image
                    // height.
                    //
                    // To make this padding non-interactive, we create another image object
                    // with a custom alignment rect that excludes the padding.
                    image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))

                    // Initialize the ‘pisa’ annotation image with the UIImage we just loaded.
                    annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "gree_dot_small")
                }
                return annotationImage
            }
            else if(annotation.title != nil && annotation.title! == Constants.noteMarker)
            {
                var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "notes_marker")
                
                if annotationImage == nil {
                    var image = UIImage(named: "notes_marker")!
                    
                    image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                    annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "notes_marker")
                }
                return annotationImage
            }
                
            else
            {

                var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "default")

                if annotationImage == nil {
                    var image = UIImage(named: "gree_dot_small")!

                    image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                    annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "default")
                }
                return annotationImage
            }
            // return annotationImage
        }

    }
    
    //    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation)
    //    {
    //        print("&&&&&&&&&&&&&&&&&&&&&&&&&&")
    //
    ////        var tapPoint: CGPoint = tap.location(in: self.view)
    ////        let tapCoordinate: CLLocationCoordinate2D = map!.convert(tapPoint, toCoordinateFrom: self.view)
    ////        print("You tapped at: \(tapCoordinate.latitude), \(tapCoordinate.longitude)")
    //    }
    
    
    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat
    {
        return 0.5
        // return 1.0
    }
    
        func mapView(_ mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
            return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha: 1)
        }
    
        func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView?
        {
    
            if let castAnnotation = annotation as? MyCustomPointAnnotation {
                if (castAnnotation.willUseImage) {
                    return nil;
                }
            }
    
            // For better performance, always try to reuse existing annotations. To use multiple different annotation views, change the reuse identifier for each.
            if let annotationView:DraggableAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "draggablePoint") as? DraggableAnnotationView {
                annotationView.mapView = mapView
                self.draggablePoint = annotationView
                return annotationView
            } else {
                let annotationView:DraggableAnnotationView = DraggableAnnotationView(reuseIdentifier: "draggablePoint", size: 50 , delegate:self)
                annotationView.mapView = mapView
                self.draggablePoint = annotationView
                return annotationView
            }
        }
    
    
    
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool)
    {
        centerCoordinate = mapView.centerCoordinate
        //  print("\(Constants.TAG) map delegate: regionDidChange() \(centerCoordinate)")
    }
    
    
    ///////////////////////////
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        print("@@@didSelect annotation@@")
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotationView: MGLAnnotationView) {
        print("@@@didSelect annotationView")
    }
    
//    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
//        return 0.5
//    }
    
    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        if let annotation = annotation as? CustomPolyline{
            return annotation.color ?? UIColor.black
        }
        return mapView.tintColor
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
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
    
    @objc func goBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func drawPolygon()
    {
        let polygon = MGLPolygon(coordinates: polygonPoints, count: UInt(polygonPoints.count))
        polygon.title = Constants.annotation_polygon
        map?.addAnnotation(polygon)
        
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("segueeee")
        
        if(segue.identifier == Constants.segueShowAddHoursScreenIdentifier)
        {
            print("segueTracingToAddHoursIdentifier")
            let AddHoursVC = segue.destination as! FinalViewController
            
            let DataToPass = [
                Constants.WPId : self.WPId,
                Constants.WPCircuitID :WPCircuit,
                Constants.polygonsList : polygonsList,
                Constants.isAllPathMode : self.isAllPathMode,
                Constants.isNoTrace : self.noTrace,
                Constants.WorkAssignmentId : self.WorkAssignmentId,
                Constants.tracedPathsList : self.tracedPathsList
                ] as [String: Any]
            
            
            AddHoursVC.WPId = DataToPass[Constants.WPId] as! Int
            AddHoursVC.WPCircuitID = DataToPass[Constants.WPCircuitID] as! Int
            AddHoursVC.polygonsList = DataToPass[Constants.polygonsList] as! [[CLLocationCoordinate2D]]
            AddHoursVC.isAllPathMode = DataToPass[Constants.isAllPathMode] as! Bool
            AddHoursVC.isNoTrace = DataToPass[Constants.isNoTrace] as! Bool
            AddHoursVC.WorkAssignmentId = DataToPass[Constants.WorkAssignmentId] as! Int
            AddHoursVC.crewArray = self.crewArray as! [[String:Any]]
            AddHoursVC.tracedPathsList = DataToPass[Constants.tracedPathsList] as! [[CLLocationCoordinate2D]]
        }
        else if(segue.identifier == Constants.segueOpenAddHoursScreenIdentifier)
        {
            print("segueOpenAddHoursScreenIdentifier")
            let AddHoursVC = segue.destination as! AddHoursViewController
            
            let DataToPass = [
                Constants.WPId : self.WPId,
                Constants.WPCircuitID :WPCircuit,
                Constants.polygonsList : polygonsList,
                Constants.isAllPathMode : self.isAllPathMode,
                Constants.isNoTrace : self.noTrace,
                Constants.WorkAssignmentId : self.WorkAssignmentId,
                Constants.tracedPathsList : self.tracedPathsList
                ] as [String: Any]
            
            AddHoursVC.WPId = DataToPass[Constants.WPId] as! Int
            AddHoursVC.WPCircuitID = DataToPass[Constants.WPCircuitID] as! Int
            AddHoursVC.polygonsList = DataToPass[Constants.polygonsList] as! [[CLLocationCoordinate2D]]
            AddHoursVC.isAllPathMode = DataToPass[Constants.isAllPathMode] as! Bool
            AddHoursVC.isNoTrace = DataToPass[Constants.isNoTrace] as! Bool
            AddHoursVC.WorkAssignmentId = DataToPass[Constants.WorkAssignmentId] as! Int
            AddHoursViewController.crewArray = self.crewArray as! [[String:Any]]
            AddHoursVC.tracedPathsList = DataToPass[Constants.tracedPathsList] as! [[CLLocationCoordinate2D]]
            
        }
    }
    
    
    @IBAction func traceByPolygonPressed(_ sender: Any)
    {
        self.tracingOptionsSelectionView.isHidden = true
        self.polygonsBtnsView.isHidden = false
        self.btn_undo_polygon.isHidden = true
        self.undo_image_view.isHidden = true
        
        self.trace_polygon_active_view.isHidden = false
        self.trace_finger_active_view.isHidden = true
    }
    
    
    @IBAction func traceByFingerPressed(_ sender: Any)
    {
        print("traceByFingerPressed")
        self.tracingOptionsSelectionView.isHidden = true
        self.traceFingerBtnsView.isHidden = false
        
        self.trace_polygon_active_view.isHidden = true
        self.trace_finger_active_view.isHidden = false
        
        removeDraggableAnnotation()
        drawDraggableAnnotation()
        
    }
    
    
    
    @IBAction func btnStartDonePolygonPressed(_ sender: Any)
    {
        if(!isPolygonStarted)
        {
            self.btn_start_done_polygon.setTitle("Done", for: UIControlState.normal)
            
            if let image = UIImage(named: "done_ic.png")
            {
                //self.btn_start_done_polygon.setImage(image, for: .normal)
                self.start_polygon_image.image = image
                
            }
            
            isPolygonStarted = true
            
            
            //   polygonAnnotationIdCounter = 0
            return
        }
        
        let isValidPolygon = validatePolygon()
        
        if(!isValidPolygon)
        {
            showErrorDialog(withMessage: "Polygon is not valid.", goBack: false)
            return
        }

        
        
        if(isPolygonStarted && polygonPoints.count > 2 && self.btn_start_done_polygon.currentTitle == "Done")
        {
            drawPolygon()
            noTrace = false
            
            var polygonPointsList:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
            
            for coordinate in polygonPoints
            {
                polygonPointsList.append(coordinate)
            }
            
            polygonPointsList.append(polygonPoints[0])
            
            polygonsList.append(polygonPointsList)
            polygonPoints = [CLLocationCoordinate2D]()
            
            for annotation in (map?.annotations)!
            {
                
                if (annotation.title != nil && annotation.title! == "polygon marker")
                {
                    map?.removeAnnotation(annotation as! MGLAnnotation)
                }
                
            }
            
            isPolygonStarted = false
            self.polygonsBtnsView.isHidden = true
            self.tracingOptionsSelectionView.isHidden = false
            self.trace_polygon_active_view.isHidden = true
            self.trace_finger_active_view.isHidden = true
            self.isPolygonBeingDrawn = false
            
            self.btn_start_done_polygon.setTitle("Start", for: .normal)
            
            //  polygonAnnotationIdCounter = 0
            
        }
        else
        {
            print("ELse part is polygon started")
            showErrorDialog(withMessage: "Polygon should have at least 3 points.", goBack: false)
        }
    }
    
    
    @IBAction func FinishButtonPressed(_ sender: Any)
    {
        
        
        print("\(Constants.TAG) tracedPathsList size \(tracedPathsList?.count)")
        
        //        if(draggablePoint?.myTracedPathsList != nil)
        //        {
        //            self.tracedPathsList = (draggablePoint?.myTracedPathsList)
        //
        //            if((tracedPathsList?.count)! > 0)
        //            {
        //                noTrace = false
        //            }
        //
        ////            for path in (self.tracedPathsList)!
        ////            {
        ////                for coordinate in path
        ////                {
        ////                    print("\(Constants.TAG) path lat \(coordinate.latitude)")
        ////                    print("\(Constants.TAG) path lng \(coordinate.longitude)")
        ////                }
        ////            }
        //        }
        //
    }
    
    
    @IBAction func lockMapBtnPressed(_ sender: Any)
    {
        if (TracingViewController.isLocked)
        {
            map?.isScrollEnabled = true
            map?.isZoomEnabled = true
            
            TracingViewController.isLocked = false
            
            btn_lock_map.setTitle("Lock Map" , for: UIControlState.normal)
            self.locked_imageView_constraint.constant = -40
            
        }
        else
        {
            if(map!.zoomLevel > 16.0)
            {
                map?.isScrollEnabled = false
                map?.isZoomEnabled = false
                btn_lock_map.setTitle("UnLock map" , for: UIControlState.normal)
                
                TracingViewController.isLocked = true
                self.locked_imageView_constraint.constant = -30
                
                
                
                // self.isDraggableAnnotationAdded = true
                
                
            }
            else
            {
                print("zoom level is less than 13")
                
                showErrorDialog(withMessage: "Please increase zoom level and then trace.", goBack: false)
                
            }
            
        }
    }
    
    
    @IBAction func doneFingerTracingPressed(_ sender: Any)
    {
        map?.isScrollEnabled = true
        map?.isZoomEnabled = true
        
        TracingViewController.isLocked = false
        removeDraggableAnnotation()
        
        self.isTracingBeingDrawn = false
        
        self.btn_done_finger_tracing.isHidden = true
        self.done_trace_imageview.isHidden = true
        self.trace_finger_active_view.isHidden = true
        
        btn_lock_map.setTitle("Lock Map" , for: UIControlState.normal)
        
        self.tracingOptionsSelectionView.isHidden = false
        self.traceFingerBtnsView.isHidden = true
        
        if(draggablePoint?.myTracedPathsList != nil)
        {
            for path in (draggablePoint?.myTracedPathsList)!
            {
                self.tracedPathsList?.append(path)
            }
            
            //  self.tracedPathsList = (draggablePoint?.myTracedPathsList)
            
            if((tracedPathsList?.count)! > 0)
            {
                noTrace = false
            }
            
            //            for path in (self.tracedPathsList)!
            //            {
            //                for coordinate in path
            //                {
            //                    print("\(Constants.TAG) path lat \(coordinate.latitude)")
            //                    print("\(Constants.TAG) path lng \(coordinate.longitude)")
            //                }
            //            }
        }
    }
    
    func drawDraggableAnnotation()
    {
        
        let point = MyCustomPointAnnotation()
        point.coordinate = centerCoordinate!
        point.title = Constants.annotation_dragable_view
        point.willUseImage = false
        
        map!.addAnnotation(point)
        
        getAllPathsList()
    }
    
    func removeDraggableAnnotation()
    {
        let annotationsList:[MGLAnnotation] = (map?.annotations)!
        print("\(Constants.TAG) annotationsList size \(annotationsList.count)")
        
        for annotation in annotationsList
        {
            if(annotation.title != nil){
                if(annotation.title! == Constants.annotation_dragable_view )
                {
                    print("\(Constants.TAG) ********")
                    map?.removeAnnotation(annotation)
                }
            }
        }
    }
    
    
    
    func getAllPathsList()
    {
        guard let remainingPaths = self.circuitFullObj["RemainingPath"] as? [[String : Any]] else
        {
            return
        }
        
        for obj in remainingPaths
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
                    
                    pathArray.append(CLLocationCoordinate2D(latitude: lat as! Double , longitude: lng as! Double))
                    pathPolyline.add(CLLocationCoordinate2D(latitude: lat as! Double , longitude: lng as! Double))
                }
                
                allPathsList.append(Path(lineId: id, path: pathArray, gmsPath: pathPolyline))
            }
            
        }
        
        print("\(Constants.TAG) allPathsList list size \(allPathsList.count)")
        
        guard let donePaths = self.circuitFullObj["DonePath"] as? [[String : Any]] else
        {
            return
        }
        
        for obj in donePaths
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
                    
                    pathArray.append(CLLocationCoordinate2D(latitude: lat as! Double , longitude: lng as! Double))
                    pathPolyline.add(CLLocationCoordinate2D(latitude: lat as! Double , longitude: lng as! Double))
                }
                
                allPathsList.append(Path(lineId: id, path: pathArray, gmsPath: pathPolyline))
            }
            
        }
        
        draggablePoint?.pathsList = allPathsList
        draggablePoint?.pathIdentifierList = pathIdentifierList
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
    
    func isPathTraced(isTraced: Bool)
    {
        if(self.btn_done_finger_tracing.isHidden)
        {
            self.btn_done_finger_tracing.isHidden = false
            self.done_trace_imageview.isHidden = false
            self.isTracingBeingDrawn = true
        }
    }
    
    @objc func tapnavigationbarButon()
    {
        if(!self.isNetworkAvailable)
        {
            showNetworkErrorDialog()
            return
        }
        
        print("tapnavigationbarButon")
        
        //        let circuitData = [
        //            Constants.WPId : self.WPId
        //        ]
        
        if(self.isPolygonBeingDrawn == true)
        {
            print("SHOW DISCARD CHANGES DIALOG isPolygonBeingDrawn")
            showDiscardChangesDialog()
            return
        }
        
        if(self.isTracingBeingDrawn == true)
        {
            print("SHOW DISCARD CHANGES DIALOG isTracingBeingDrawn")
            showDiscardChangesDialog()
            return
        }
        
        let DataToPass = [
            Constants.WPId : self.WPId,
            Constants.WPCircuitID :WPCircuit,
            Constants.polygonsList : polygonsList,
            Constants.isAllPathMode : self.isAllPathMode,
            Constants.isNoTrace : self.noTrace,
            Constants.WorkAssignmentId : self.WorkAssignmentId,
            Constants.tracedPathsList : self.tracedPathsList
            ] as [String: Any]
        
        
        self.performSegue(withIdentifier: Constants.segueOpenAddHoursScreenIdentifier, sender: DataToPass)
        
    }
    
    
    @IBAction func trace_all_path_pressed(_ sender: Any)
    {
        print("trace_all_path_pressed")
        let NECoordinates = map?.visibleCoordinateBounds.ne
        let SWCoordinates = map?.visibleCoordinateBounds.sw
        
        fixateCamera()
        showConfirmationDialog()
        
        print("\(Constants.TAG) NECoordinates \(NECoordinates) SWCoordinates \(SWCoordinates)")
    }
    
    func showConfirmationDialog()
    {
        var confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you want to trace all paths?", preferredStyle: UIAlertControllerStyle.alert)
        
        confirmAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            
            self.removePolygonPointsAnnotations()
            
            self.isAllPathMode = true
            self.noTrace = false
            
            let DataToPass = [
                Constants.WPId : self.WPId,
                Constants.WPCircuitID :self.WPCircuit,
                Constants.polygonsList : self.polygonsList,
                Constants.isAllPathMode : self.isAllPathMode,
                Constants.isNoTrace : self.noTrace,
                Constants.WorkAssignmentId : self.WorkAssignmentId,
                Constants.tracedPathsList : self.tracedPathsList
                ] as [String: Any]
            
            
            self.performSegue(withIdentifier: Constants.segueOpenAddHoursScreenIdentifier, sender: DataToPass)
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(confirmAlert, animated: true, completion: nil)
        
    }
    
    func removePolygonPointsAnnotations()
    {
        let annotationsList:[MGLAnnotation] = (self.map?.annotations)! as! [MGLAnnotation]
        print("\(Constants.TAG) annotationsList size \(annotationsList.count)")
        
        for annotation in annotationsList
        {
            let ann = annotation as? MyCustomPointAnnotation
            
            if(annotation.title != nil && annotation.title! == Constants.annotation_polygon_dot)
            {
                
                print("\(Constants.TAG) Annotation ID \(ann?.annotationID)")
                self.map?.removeAnnotation(annotation)
                
                self.isPolygonStarted = false
                self.polygonPoints = [CLLocationCoordinate2D]()
                self.polygonPointsCounter = 0
                self.polygonAnnotationIdCounter = 0
            }
            
            
            // let polygonAnn = annotation as? MGLPolygon
            
            if(annotation.title != nil && annotation.title! == Constants.annotation_polygon)
            {
                self.map?.removeAnnotation(annotation)
            }
            
            // let polygonLineAnn = annotation as? CustomPolyline
            
            if(annotation.title != nil && annotation.title! == Constants.annotation_polygon_line)
            {
                self.map?.removeAnnotation(annotation)
            }
            
            if(annotation.title != nil && annotation.title! == Constants.annotation_tracd_line)
            {
                self.map?.removeAnnotation(annotation)
            }
            
        }
        
        self.isPolygonBeingDrawn = false
        isPolygonStarted = false
        self.polygonsList = [[CLLocationCoordinate2D]]()
        self.tracedPathsList = [[CLLocationCoordinate2D]]()
        
    }
    
    func showDiscardChangesDialog()
    {
        var confirmAlert = UIAlertController(title: "Confirm", message: "You have unsaved changes. Proceeding will discard your changes. Do you wish to continue?", preferredStyle: UIAlertControllerStyle.alert)
        
        confirmAlert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            
            let DataToPass = [
                Constants.WPId : self.WPId,
                Constants.WPCircuitID :self.WPCircuit,
                Constants.polygonsList : self.polygonsList,
                Constants.isAllPathMode : self.isAllPathMode,
                Constants.isNoTrace : self.noTrace,
                Constants.WorkAssignmentId : self.WorkAssignmentId,
                Constants.tracedPathsList : self.tracedPathsList
                ] as [String: Any]
            
            
            self.performSegue(withIdentifier: Constants.segueOpenAddHoursScreenIdentifier, sender: DataToPass)
        }))
        
        
        present(confirmAlert, animated: true, completion: nil)
        
    }
    
    func drawPolyLine()
    {
        let polygonPointsSize = self.polygonPoints.count
        let fPoint = self.polygonPoints[polygonPointsSize - 2]
        let lPoint = self.polygonPoints[polygonPointsSize - 1]
        
        polygonLineIdCounter = polygonLineIdCounter + 1
        
        var linePoints:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        linePoints.append(fPoint)
        linePoints.append(lPoint)
        
        
        let polyline:CustomPolygonPolyline = CustomPolygonPolyline.drawPolyline(through: linePoints, color: UIColor.green)
        polyline.title = Constants.annotation_polygon_line
        polyline.lineID = polygonLineIdCounter
        map?.addAnnotation(polyline)
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
    
    func validatePolygon() -> Bool
    {
        let q:CLLocationCoordinate2D = getFirstPoint(point: self.polygonPoints[0])
        // let q:CLLocationCoordinate2D = self.polygonPoints[0]
        let q2:CLLocationCoordinate2D = self.polygonPoints[polygonPoints.count - 1]
        
        for (index , point) in self.polygonPoints.enumerated()
        {
            if(index < polygonPoints.count - 2)
            {
                let p:CLLocationCoordinate2D = polygonPoints[index]
                let p2:CLLocationCoordinate2D = polygonPoints[index + 1]
                
                let isIntersect:Bool = Constants.doLineSegmentsIntersect(p: p, p2: p2, q: q, q2: q2)
                print("isIntersect \(isIntersect)")
                
                if(isIntersect)
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    func getFirstPoint(point:CLLocationCoordinate2D) -> CLLocationCoordinate2D
    {
        let lat:Double = point.latitude
        let lng:Double = point.longitude
        
        let beforeStr = String(lat)
        var charArray = Array(beforeStr)
        
        charArray[charArray.count - 1] = "4"
        let afterStr = String(charArray)
        
        let after:Double = Double(afterStr)!
        
        var fPoint:CLLocationCoordinate2D = CLLocationCoordinate2D()
        fPoint.latitude = after
        fPoint.longitude = lng
        
        return fPoint
    }
    
    func checkIntersection(q2:CLLocationCoordinate2D) -> Bool
    {
        if(self.polygonPoints.count >= 3)
        {
            let q:CLLocationCoordinate2D = self.polygonPoints[polygonPoints.count - 1]
            
            for (index, point) in self.polygonPoints.enumerated()
            {
                if(index < polygonPoints.count - 2)
                {
                    let p:CLLocationCoordinate2D = polygonPoints[index]
                    let p2:CLLocationCoordinate2D = polygonPoints[index + 1]
                    
                    print("checkIntersection P: \(p) P2: \(p2)  Q: \(q)  Q2: \(q2)")
                    
                    let isIntersect:Bool = Constants.doLineSegmentsIntersect(p: p, p2: p2, q: q, q2: q2)
                    print("isIntersect \(isIntersect)")
                    
                    if(isIntersect)
                    {
                        return true
                    }
                }
                
            }
        }
        
        return false
    }
    
    func drawNotesMarkers()
    {
        for note in self.notesList
        {
            var coordinate = CLLocationCoordinate2D()
            coordinate.latitude = note.lat
            coordinate.longitude = note.lng
            
            let note_marker = MyCustomPointAnnotation()
            note_marker.title = Constants.noteMarker
            note_marker.subtitle = note.text
            note_marker.coordinate = coordinate
            note_marker.willUseImage = true
            map?.addAnnotation(note_marker)
            
            // map?.showAnnotations((map?.annotations)!, animated: true)
            // map?.selectAnnotation(note_marker, animated: true)
            
        }
    }

}















