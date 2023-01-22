//
//  ViewController.swift
//  TravelBook
//
//  Created by Tahir Uzelli on 20.01.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    
    var currentPlace : PlaceModel?
    
    var locationManager = CLLocationManager()
    var choosenLat = Double()
    var choosenLong = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        
        if currentPlace != nil {
            descriptionTextField.text = currentPlace?.description  ?? ""
            descriptionTextField.isEnabled = false
            titleTextField.text = currentPlace?.title ?? ""
            titleTextField.isEnabled = false
            
            let annotation = MKPointAnnotation()
            annotation.title = currentPlace?.title ?? ""
            annotation.subtitle = currentPlace?.description ?? ""
            let coordinate = CLLocationCoordinate2D(latitude: currentPlace?.latitude ?? 0, longitude: currentPlace?.longitude ?? 0)
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            let location = CLLocationCoordinate2D(latitude: currentPlace?.latitude ?? 0, longitude: currentPlace?.longitude ?? 0)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            saveButton.isHidden = true
            
        }else{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gesture:)))
            gesture.minimumPressDuration = 2
            mapView.addGestureRecognizer(gesture)
            saveButton.isHidden = false
        }
    }
    
    @objc func chooseLocation(gesture: UILongPressGestureRecognizer){
        if gesture.state == .began{
            let touchedPoint = gesture.location(in: self.mapView)
            let touchedCoordinates = self.mapView.convert(touchedPoint,toCoordinateFrom: self.mapView)
            choosenLat = touchedCoordinates.latitude
            choosenLong = touchedCoordinates.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = titleTextField.text
            annotation.subtitle = descriptionTextField.text
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor  = .systemGreen
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations.first?.coordinate.latitude ?? 0, longitude: locations.first?.coordinate.longitude ?? 0)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func onSaveButtonPressed(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(titleTextField.text, forKey: "title")
        newPlace.setValue(descriptionTextField.text, forKey: "subtitle")
        newPlace.setValue(UUID(), forKey: "id")
        newPlace.setValue(choosenLat, forKey: "latitude")
        newPlace.setValue(choosenLong, forKey: "longitude")
        
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        navigationController?.popViewController(animated: true)
    }
}

