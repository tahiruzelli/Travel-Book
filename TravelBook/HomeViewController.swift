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
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    @objc func getData(){
        places = []
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(request)
            if !results.isEmpty {
                for result in results as! [NSManagedObject] {
                    
                    let id = result.value(forKey: "id") as? UUID
                    let title = result.value(forKey: "title") as? String
                    let description = result.value(forKey: "subtitle") as? String
                    let latitude = result.value(forKey: "latitude") as? Double
                    let longitude = result.value(forKey: "longitude") as? Double
                    let visitStatus = result.value(forKey: "visitStatus") as? Int
                    let image = result.value(forKey: "image") as? String
                    
                    let place : PlaceModel = PlaceModel(id:id ?? UUID() , title: title ?? "", description: description ?? "", latitude: latitude ?? 0, longitude: longitude ?? 0, image: image ?? "", visitStatus: visitStatus ?? 0)
                    places.append(place)
                }
            }
        }catch{
            
        }
    }
    
    @IBAction func newPlaceButtonAction(_ sender: Any) {
        choosenPlace = nil
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailVC") as? ViewController
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
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailVC") as? ViewController
        vc?.currentPlace = choosenPlace
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
