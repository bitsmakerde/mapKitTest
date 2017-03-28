//
//  ViewController.swift
//  mapKit
//
//  Created by Andre Bongartz on 25.03.17.
//  Copyright © 2017 Andre Bongartz. All rights reserved.
//

import UIKit
import MapKit
import CoreGraphics

//MARK: Global Declarations
let chicagoCoordinate = CLLocationCoordinate2DMake(49.0537455, 9.289637699999957)// 0,0 Chicago street coordinates

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        let newLoctaion = locations.first
        
        guard let coordiantens = newLoctaion?.coordinate else {
            return
        }
        
        self.outputCurrentLocationCoordinates.text = "Koordinaten: \(coordiantens.latitude) \(coordiantens.longitude)"
         mapView.centerCoordinate = coordiantens
    }
}

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var outputLocationIn: UILabel!
    @IBOutlet weak var outputCurrentLocationCoordinates: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var points = [CLLocationCoordinate2D]()
    
    required init?(coder aDecoder: NSCoder) {
        locationManager = CLLocationManager()
        super.init(coder: aDecoder)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        resetRegion()
        //mapView.showsUserLocation = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Map setup
    func resetRegion(){
        let region = MKCoordinateRegionMakeWithDistance(chicagoCoordinate,200, 200)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func currentLocation(_ sender: Any) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func overlay(_ sender: Any) {
        mapView.add(MKPolygon(coordinates: points, count: points.count))
        print("overlay")
    }
    
    @IBAction func removeOverlays(_ sender: Any) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        points.removeAll()
        let anninotations = mapView.annotations
        mapView.removeAnnotations(anninotations)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polygonView = MKPolygonRenderer(overlay: overlay)
        polygonView.fillColor = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 0.5)
        
        return polygonView
    }
    
    @IBAction func checkPoint(_ sender: Any) {
        let polygonRenderer = MKPolygonRenderer(polygon: MKPolygon(coordinates: &points, count: points.count))
        let currentMapPoint: MKMapPoint = MKMapPointForCoordinate(chicagoCoordinate)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        
        if polygonRenderer.path.contains(polygonViewPoint) {
            outputLocationIn.text = "IN"
        } else {
            outputLocationIn.text = "OUT"
        }
    }
    
    @IBAction func longPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        // Daten ins Array schreiben
        points.append(CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude))
        mapView.addAnnotation(createAnnotationPin(coors: locationCoordinate))
    }
    
    func createAnnotationPin(coors: CLLocationCoordinate2D) -> MKAnnotation {
        let annotationPin = MKPointAnnotation()
        annotationPin.coordinate = coors
        return annotationPin
    }
}

