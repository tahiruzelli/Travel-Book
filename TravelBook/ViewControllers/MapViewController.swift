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

class MapViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage]
        self.dismiss(animated: true,completion: nil)
    }

    @IBAction func onSaveButtonPressed(_ sender: Any) {
        var alertTitle : String = ""
        if titleTextField.text!.isEmpty {
            alertTitle = "Title can not be empty"
        }
        if descriptionTextField.text!.isEmpty{
            alertTitle = "Description can not be empty"
        }
        if choosenLat == 0 || choosenLong == 0 {
            alertTitle = "You have to choose a location"
        }
        
        if !alertTitle.isEmpty{
            let alert = UIAlertController(title: "Warning", message: alertTitle, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let newPlace = NSEntityDescription.insertNewObject(forEntityName: AppKeys().placesEntityKey, into: context)
            
            newPlace.setValue(titleTextField.text, forKey: AppKeys().placeTitleKey)
            newPlace.setValue(descriptionTextField.text, forKey: AppKeys().placeDescriptionKey)
            newPlace.setValue(UUID(), forKey: AppKeys().placeIdKey)
            newPlace.setValue(choosenLat, forKey: AppKeys().placeLatitudeKey)
            newPlace.setValue(choosenLong, forKey: AppKeys().placeLongitudeKey)
            
            do{
                try context.save()
            }catch{
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(AppKeys().newPlaceNotification), object: nil)
            navigationController?.popViewController(animated: true)
        }
    }
}

