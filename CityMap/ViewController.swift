//
//  ViewController.swift
//  CityMap
//
//  Created by otet_tud on 1/10/20.
//  Copyright © 2020 otet_tud. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var coordinates = Array<Array<Double>>()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Define Latitude and Longitude of a specific location ex. Ontario
        let latidude : CLLocationDegrees = 43.64//51.25//43.64
        let longitude: CLLocationDegrees = -79.38//-85.32//-79.38

        // Define the Deltas of Latitude and Longitude
        let latDelta : CLLocationDegrees = 1.0
        let longDelta : CLLocationDegrees = 1.0
        
        // Define the Span
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        
        // Define the location
        let location = CLLocationCoordinate2D(latitude: latidude, longitude: longitude)
        
        // Define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // Set MapView with the set region
        mapView.setRegion(region, animated: true)
        
        // Add a long press gesture
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        mapView.addGestureRecognizer(uilpgr)
        
    }
    
    @objc func longPress(gestureRecognizer : UIGestureRecognizer) {
        guard let longPress = gestureRecognizer as? UILongPressGestureRecognizer else
          { return }

          if longPress.state == .ended { // When gesture end
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            // PIN Location: Add annotation
            let annotation = MKPointAnnotation()
            annotation.title = "Pinned Location"
            annotation.coordinate = coordinate
            
            let newCoordinate : Array<Double> = [ Double(round(1000*coordinate.latitude)/1000), Double(round(1000*coordinate.longitude)/1000)]
            print("Pressed \(newCoordinate)")
            
            if !coordinateExists(coordinate: coordinate) {
                if mapView.annotations.count < 3 {
                    mapView.addAnnotation(annotation)
                    
                    if mapView.annotations.count == 3 {
                        mapView.delegate = self
                        addPolyLine()
                        addPolygon()
                    }
                }
            }
          }
    }
    
    // This function will create lines between location
    func addPolyLine() {
        let locations = mapView.annotations.map {$0.coordinate}
        let polyLine = MKPolyline(coordinates: locations, count: locations.count)
        print("1 Locations count \(locations.count)")
        for idx in locations {
            print ("\(idx.latitude) \(idx.longitude)")
        }
        mapView.addOverlay(polyLine)
    }
    
    func addPolygon() {
        let locations = mapView.annotations.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: locations, count: locations.count)
        print("2 Locations count \(locations.count)")
        for idx in locations {
            print ("\(idx.latitude) \(idx.longitude)")
        }
        mapView.addOverlay(polygon)
    }
    
    func coordinateExists(coordinate : CLLocationCoordinate2D) -> Bool {
        for annotation in self.mapView.annotations {
            if ((annotation.coordinate.latitude - 0.05)...(annotation.coordinate.latitude + 0.05)).contains(coordinate.latitude) && ((annotation.coordinate.longitude - 0.05)...(annotation.coordinate.longitude + 0.05)).contains(coordinate.longitude){
                print("Removing annotation")
                // remove existing annotation
                self.mapView.removeAnnotation(annotation)
                if mapView.annotations.count < 3 {
                    // Clear overlays
                    mapView.removeOverlays(mapView.overlays)
                }
                return true
            }
        }
       return false
    }
}

extension ViewController: MKMapViewDelegate {
    
    // This function is needed to add overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            print("Called poly line")
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 2
            return renderer
        } else if overlay is MKPolygon {
            print("called poygon")
            let renderer = MKPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.5)
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
}
