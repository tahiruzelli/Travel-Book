//
//  HomeViewController.swift
//  TravelBook
//
//  Created by Tahir Uzelli on 22.01.2023.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var places : [PlaceModel] = []
    var choosenPlace : PlaceModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(AppKeys().newPlaceNotification), object: nil)
    }
    
    @objc func getData(){
        places = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: AppKeys().placesEntityKey)
        request.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(request)
            if !results.isEmpty {
                for result in results as! [NSManagedObject] {
                    
                    let id = result.value(forKey: AppKeys().placeIdKey) as? UUID
                    let title = result.value(forKey: AppKeys().placeTitleKey) as? String
                    let description = result.value(forKey: AppKeys().placeDescriptionKey) as? String
                    let latitude = result.value(forKey: AppKeys().placeLatitudeKey) as? Double
                    let longitude = result.value(forKey: AppKeys().placeLongitudeKey) as? Double
                    let visitStatus = result.value(forKey: AppKeys().placeVisitStatusKey) as? Int
                    let image = result.value(forKey: AppKeys().placeImageKey) as? String
                    
                    let place : PlaceModel = PlaceModel(id:id ?? UUID() , title: title ?? "", description: description ?? "", latitude: latitude ?? 0, longitude: longitude ?? 0, image: image ?? "", visitStatus: visitStatus ?? 0)
                    places.append(place)
                }
                places.reverse();
                collectionView.reloadData()
            }
        }catch{
            
        }
    }
    
    @IBAction func newPlaceButtonAction(_ sender: Any) {
        choosenPlace = nil
        let vc = UIStoryboard.init(name: AppKeys().mainVCKey, bundle: Bundle.main).instantiateViewController(withIdentifier: AppKeys().detailVCKey) as? MapViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceCollectionViewCell.identifier, for: indexPath) as! PlaceCollectionViewCell
        let place = places[indexPath.row]
        cell.titleLabel.text = place.title
        cell.descriptionLabel.text = place.description
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        choosenPlace = places[indexPath.row]
        let vc = UIStoryboard.init(name: AppKeys().mainVCKey, bundle: Bundle.main).instantiateViewController(withIdentifier: AppKeys().detailVCKey) as? MapViewController
        vc?.currentPlace = choosenPlace
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
