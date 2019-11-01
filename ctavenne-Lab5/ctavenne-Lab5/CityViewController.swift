//
//  CityViewController.swift
//  ctavenne-Lab5
//
//  Created by Cody Tavenner on 3/18/19.
//  Copyright © 2019 Cody Tavenner. All rights reserved.
//

import UIKit
import CoreData

class CityViewController: UIViewController {
    var selectedCity:String?
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var details: UILabel!
    @IBOutlet weak var name: UILabel!
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let entityDescription =
            NSEntityDescription.entity(forEntityName: "CityEntity",
                                       in: managedObjectContext)
        // create a fetch request
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest() as NSFetchRequest<CityEntity>
        
        // associate the request with contact handler
        request.entity = entityDescription
        
        // build the search request predicate (query)
        let pred = NSPredicate(format: "(name = %@)", selectedCity!)
        request.predicate = pred
        
        // perform the query and process the query results
        do {
            var results =
                try managedObjectContext.fetch(request as!
                    NSFetchRequest<NSFetchRequestResult>)
            
            if results.count > 0 {
                let match = results[0] as! NSManagedObject
                
                
                
                name.text = match.value(forKey: "name") as? String
                details.text = match.value(forKey: "details") as? String
                let img = match.value(forKey: "picture") as? NSData
                picture.image = UIImage(data: img! as Data)
            } else {
                details.text = "No Match"
            }
            
        } catch let error {
            details.text = error.localizedDescription
        }
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
