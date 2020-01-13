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
                        //addPolyLine()
                        addPolygon()
                        
                        let d1 = getDistance(from: mapView.annotations[0].coordinate, to: mapView.annotations[1].coordinate)
                        let d2 = getDistance(from: mapView.annotations[1].coordinate, to: mapView.annotations[2].coordinate)
                        let d3 = getDistance(from: mapView.annotations[2].coordinate, to: mapView.annotations[0].coordinate)
                        
                        
                        print("Distance 1 : \(d1)")
                        print("Distance 2 : \(d2)")
                        print("Distance 3 : \(d3)")
                        
                        print("\(mapView.overlays.count)")
                        
                        // Set 1st route
                        setRoute(source: mapView.annotations[0].coordinate, destination: mapView.annotations[1].coordinate)
                        // Set 2nd route
                        setRoute(source: mapView.annotations[1].coordinate, destination: mapView.annotations[2].coordinate)
                        // Set 3rd route
                        setRoute(source: mapView.annotations[2].coordinate, destination: mapView.annotations[0].coordinate)
                        
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
    
    func getDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    func setRoute(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        // 1st route
        let sourcePlacemark = MKPlacemark(coordinate: source, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
                             
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                             
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
                             
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
                                 
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                    return
            }
                                 
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
                                 
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    // This function is needed to add overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            print("Called poly line")
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4
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
