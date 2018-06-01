//
//  GragAnnotation.swift
//  Productivity 2
//
//  Created by SPS on 26/02/2018.
//  Copyright © 2018 SPS. All rights reserved.
//

import Foundation
import Mapbox
import GoogleMaps

class DraggableAnnotationView: MGLAnnotationView
{
    
    var mapView:MGLMapView?
    var coordinateList:[CLLocationCoordinate2D]?
  //  var pathsList:[CircuitPath]?
    
    var pathsList:[Path]?
    var isDraggedAnnotationDelegate : dragaableAnnotationDelegate?
    
    var traveredPathsList:[TracedPath]?
    var pathIdentifierList:[Int:Bool]?
    var singleTraversedPath : [CLLocationCoordinate2D]?
    var myTracedPathsList:[[CLLocationCoordinate2D]]? = [[CLLocationCoordinate2D]]()
    
    var isOnPath:Bool = false
    
    var isLocked:Bool = false
    
    init(reuseIdentifier: String, size: CGFloat , delegate: dragaableAnnotationDelegate) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        isDraggedAnnotationDelegate = delegate
        
        // `isDraggable` is a property of MGLAnnotationView, disabled by default.
        isDraggable = true
        
        // This property prevents the annotation from changing size when the map is tilted.
        scalesWithViewingDistance = false
        
        // Begin setting up the view.
        frame = CGRect(x: 0, y: 0, width: size, height: size)
        
        backgroundColor = UIColor.green.withAlphaComponent(0.5)
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = size / 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        
        let verticalGuide:UIView = UIView(frame: CGRect(x: self.center.x, y: 0, width: 1, height: self.bounds.height))
        //        let verticalGuide:UIView = UIView()
        verticalGuide.backgroundColor = UIColor.white
        self.addSubview(verticalGuide)
        //        verticalGuide.translatesAutoresizingMaskIntoConstraints = false
        //        verticalGuide.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        //        verticalGuide.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        //        verticalGuide.widthAnchor.constraint(equalToConstant: 2.0).isActive = true
        
        let horizontalGuide:UIView = UIView(frame: CGRect(x: 0, y: self.center.y, width: self.bounds.width, height: 1))
        //        let horizontalGuide:UIView = UIView()
        horizontalGuide.backgroundColor = UIColor.white
        self.addSubview(horizontalGuide)
        //        horizontalGuide.translatesAutoresizingMaskIntoConstraints = false
        //        horizontalGuide.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        //        horizontalGuide.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        //        horizontalGuide.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
    }
    
    // These two initializers are forced upon us by Swift.
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Custom handler for changes in the annotation’s drag state.
    override func setDragState(_ dragState: MGLAnnotationViewDragState, animated: Bool) {
        super.setDragState(dragState, animated: animated)
        
        switch dragState {
        case .starting:
            //print("Starting", terminator: "")
            print("Starting ")
            startDragging()
            
        case .dragging:
            
            if(TracingViewController.isLocked)
            {
                guard let mapView:MGLMapView = mapView else{
                    print("mapView is nil.")
                    return
                }
                let centerPoint:CGPoint = self.center
                let centerCoordinate:CLLocationCoordinate2D =  mapView.convert(centerPoint, toCoordinateFrom: mapView)
                coordinateList?.append(centerCoordinate)
            }
            else{
                print("res: is unlocked")
            }
        case .ending, .canceling:
            print("Ending")
            endDragging()
        case .none:
            return
        }
    }
    
    // When the user interacts with an annotation, animate opacity and scale changes.
    func startDragging() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 0.8
            self.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        }, completion: nil)
        
        coordinateList = [CLLocationCoordinate2D]()
        traveredPathsList = [TracedPath]()
        
        singleTraversedPath = [CLLocationCoordinate2D]()
        
//        for lineId in pathIdentifierList!.keys{
//            pathIdentifierList![lineId] = false
//        }
    }
    
    func endDragging()
    {
        print("\(Constants.TAG) endDragging coordinate list size \(coordinateList?.count)")
        
        transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            self.layer.opacity = 1
            self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }, completion: nil)
        
        if TracingViewController.isLocked
        {
            guard let coordinateList = coordinateList else{
                print("\(Constants.TAG) coordinatelist is nil.")
                return
            }
            
            if coordinateList.isEmpty{
                print("\(Constants.TAG) coordinateList is empty.")
            }
            
            for centerCoordinate in coordinateList
            {
                for path in pathsList!
                {
                    let dragres = GMSGeometryIsLocationOnPathTolerance(centerCoordinate, path.gmsPath , true, 25)
                    
                  //  print("\(Constants.TAG) dragres \(dragres)")
                    
                    if(dragres == true)
                    {
                        
                        singleTraversedPath?.append(centerCoordinate)
                        
                        if let index = traveredPathsList!.index(where: { (traversedPaths) -> Bool in
                            traversedPaths.lineId == path.lineId
                        }) {
                            if pathIdentifierList![path.lineId]! == true{
                                if traveredPathsList?[index].paths != nil{
                                    if traveredPathsList![index].paths.isEmpty {
                                        traveredPathsList?[index].paths.append([centerCoordinate])
                                    }
                                    else{
                                        let count = traveredPathsList![index].paths.count
                                        traveredPathsList![index].paths[count-1].append(centerCoordinate)
                                    }
                                    
                                }
                                else{
                                    traveredPathsList?[index].paths = [[CLLocationCoordinate2D]]()
                                    traveredPathsList?[index].paths.append([centerCoordinate])
                                    pathIdentifierList![path.lineId] = true
                                }
                            }
                            else{
                                traveredPathsList?[index].paths.append([centerCoordinate])
                                pathIdentifierList![path.lineId] = true
                            }
                        }
                        else{
                            let pathStruct = TracedPath(lineId: path.lineId, paths: [[centerCoordinate]])
                            traveredPathsList?.append(pathStruct)
                            pathIdentifierList![path.lineId] = true
                        }
                    }
                    else
                    {
                        pathIdentifierList![path.lineId] = false
                    }
                }
            }
            
            print("\(Constants.TAG) mySingleTraveredPath size \(singleTraversedPath?.count)")
            
            if((singleTraversedPath?.count)! > 0)
            {
                myTracedPathsList?.append((self.singleTraversedPath)!)
            }
           
            print("\(Constants.TAG) myTracedPathsList size \(myTracedPathsList?.count)")
            
            for tracedPath in traveredPathsList!
            {
                
                for path in tracedPath.paths
                {
                    print("\(Constants.TAG) $$$$$$$$$$")
                    let polyline:CustomPolyline = CustomPolyline.drawPolyline(through:path, color: UIColor.green)
                    polyline.title = Constants.annotation_tracd_line
                    mapView?.addAnnotation(polyline)
                }
                
            }
            
            self.isDraggedAnnotationDelegate?.isPathTraced(isTraced: true)
        }
    }
    
    
}

