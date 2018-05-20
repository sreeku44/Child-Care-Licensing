//
//  ChildCareMapViewController.swift
//  Child Care Licensing
//
//  Created by Sreekala Santhakumari on 5/19/18.
//  Copyright © 2018 Spotlight LLC. All rights reserved.
//

import UIKit
import MapKit

//protocol MKMapViewDelegate {
//    func mapView (MV : Childcare)
//}


class ChildCareMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    //var delegate : MKMapViewDelegate?
    var locationManager = CLLocationManager()
    var annotations = [MKAnnotation]()
    var selectedAnnotation : MKPointAnnotation!
    var childcareSelected = " childcare"

    
    @IBOutlet weak var mapView: MKMapView!
    
    var isFirstUse : Bool = true
   
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
//    func mapView(MV: Childcare) {
//        <#code#>
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
           self.title = "Child Care Center violations"
        
        
        self.locationManager = CLLocationManager ()
          self.locationManager.delegate = self
           self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
           self.locationManager.distanceFilter = kCLDistanceFilterNone
           self.locationManager.requestWhenInUseAuthorization()
        
            self.mapView.showsUserLocation = true
            self.mapView.userTrackingMode = .follow
            self.mapView.delegate = self

            DispatchQueue.main.async {
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.startUpdatingLocation()
                }
            }
        }
    
    
    
                
        func childCareSearch()  {
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = childcareSelected
            request.region  = self.mapView.region
            let search = MKLocalSearch(request: request)
            search.start { (response : MKLocalSearchResponse?, error :Error?) in
                for mapItem in (response?.mapItems)! {

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.placemark.name



                 if
                        //subtitle for address
                        let city = mapItem.placemark.locality,
                        let state = mapItem.placemark.administrativeArea,
                        let postalcode = mapItem.placemark.postalCode {
                        annotation.subtitle = "  \(city) , \(state) \(postalcode) "

                        self.mapView.addAnnotation(annotation)
                        let span = MKCoordinateSpanMake(0.5 , 0.5)
                        let region = MKCoordinateRegionMake(mapItem.placemark.coordinate, span)
                        self.mapView.setRegion(region, animated: true)
                        self.mapView.showsUserLocation = true

                    }
              }

                }
      }
        // optional - setting location manager delegate for self.locationManager.delegate = self
        func locationManager(_manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse {
                locationManager.requestLocation()
            }
       }
        // optional - setting location manager delegate for self.locationManager.delegate = self

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

            if isFirstUse == true {
                let location = locations[0]
                let span = MKCoordinateSpanMake(0.5 , 0.5)
                let userLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                let region = MKCoordinateRegionMake(userLocation, span)
                self.mapView.setRegion(region, animated: true)
                self.mapView.showsUserLocation = true;
                isFirstUse = false
                childCareSearch()
            }

        }


//        // optional - setting location manager delegate for self.locationManager.delegate = self
//
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("error:: (error)")
        }

        // Alert
        func showAlert(message: String) {
            let alert = UIAlertController (title: "Childcare", message: message, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default)

            alert.addAction(alertAction)
            present(alert, animated: true)
        }

        // Alert if map access denied
        override func viewDidAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if CLLocationManager.authorizationStatus() == .notDetermined {

                locationManager.requestAlwaysAuthorization()
            }

            else if CLLocationManager.authorizationStatus() == .denied {

                showAlert (message: " Location service were previously denied. Please enable location services for this app in Settings")
            }
            else if CLLocationManager.authorizationStatus() == .authorizedAlways{

                locationManager.startUpdatingLocation()

            }

        }

        //AnnotationView
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

            if annotation is MKUserLocation {
                return nil
            }

            let annotaion =  annotation as! MKPointAnnotation
            let annotationView = MKPinAnnotationView(annotation: annotaion, reuseIdentifier: "MyAnnotation")
            annotationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            annotationView.canShowCallout = true

            //adding  button for deatails & map
            let button = UIButton(type: .detailDisclosure) as UIButton
            button.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)

            annotationView.rightCalloutAccessoryView = button

            return annotationView
        }

        //user location
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

            if view.annotation is MKUserLocation {
                return
            }

            self.selectedAnnotation = view.annotation as! MKPointAnnotation
        }

       // @objc func infoButtonPressed() {

            @objc func infoButtonPressed() {

                let url: String = "http://maps.apple.com/?saddr=\(mapView.userLocation.coordinate.latitude),\(mapView.userLocation.coordinate.longitude)&daddr=\( self.selectedAnnotation.coordinate.latitude),\(self.selectedAnnotation.coordinate.longitude)"

                UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)

            }




        }

    


