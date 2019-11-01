//
//  ViewController.swift
//  ctavenne-Lab5
//
//  Created by Cody Tavenner on 3/17/19.
//  Copyright © 2019 Cody Tavenner. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var counter = 1
    
    
    @IBOutlet weak var cityTable: UITableView!
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchResults = [CityEntity]()
    
    func fetchRecord() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CityEntity")
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        var x = 0
        fetchResults = ((try? managedObjectContext.fetch(fetchRequest)) as? [CityEntity])!
        
        x = fetchResults.count
        
        print(x)
        
        return x
        
    }
    override func viewDidLoad() {
        // Do any additional setup after loading the view, typically from a nib.
        initCounter()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchRecord()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "city1", for: indexPath)
        cell.layer.borderWidth = 1.0
        cell.textLabel?.text = fetchResults[indexPath.row].name
        cell.detailTextLabel?.text = fetchResults[indexPath.row].details
        
        if let picture = fetchResults[indexPath.row].picture {
            cell.imageView?.image =  UIImage(data: picture  as Data)
        } else {
            cell.imageView?.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    // return the table view style as deletable
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell.EditingStyle { return UITableViewCell.EditingStyle.delete }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        
        if editingStyle == .delete
        {
            
            // delete the selected object from the managed
            // object context
            managedObjectContext.delete(fetchResults[indexPath.row])
            // remove it from the fetch results array
            fetchResults.remove(at:indexPath.row)
            
            do {
                // save the updated managed object context
                try managedObjectContext.save()
            } catch {
                
            }
            // reload the table after deleting a row
            cityTable.reloadData()
        }
        
    }


    

    @IBAction func addRecord(_ sender: UIBarButtonItem) {
        // create a new entity object
        let ent = NSEntityDescription.entity(forEntityName: "CityEntity", in: self.managedObjectContext)
        //add to the manege object context
        let newItem = CityEntity(entity: ent!, insertInto: self.managedObjectContext)
        newItem.name = "City"
        newItem.details = "Details"
        newItem.picture = nil
        
        // one more item added
        updateCounter()
        
        
        
        // show the alert controller to select an image for the row
        let alertController = UIAlertController(title: "Add City", message: "", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Name of the City Here"
        })
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Details of the City Here"
        })
        
        let serachAction = UIAlertAction(title: "Picture", style: .default) { (action) in
           if let name = alertController.textFields?.first?.text{
             newItem.name = name
               let det = alertController.textFields?[1].text
                newItem.details = det
            }
            // load image
            let photoPicker = UIImagePickerController ()
            photoPicker.delegate = self
            photoPicker.sourceType = .photoLibrary
            // display image selection view
            self.present(photoPicker, animated: true, completion: nil)
            
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
           if let name = alertController.textFields?.first?.text{
               newItem.name = name
                let det = alertController.textFields?[1].text
                newItem.details = det
            }
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerController.SourceType.camera
                picker.cameraCaptureMode = .photo
                picker.modalPresentationStyle = .fullScreen
                self.present(picker,animated: true,completion: nil)
            } else {
                print("No camera")
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        alertController.addAction(serachAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        
        
        
        
        // save the updated context
        do {
            try self.managedObjectContext.save()
        } catch _ {
        }
        
        
        print(newItem)
        // reload the table with added row
        // this happens before getting the image, so first we add the row
        // without the image and then add the image
        cityTable.reloadData()
    }
    
    func updateLastRow() {
        let indexPath = IndexPath(row: fetchResults.count - 1, section: 0)
        cityTable.reloadRows(at: [indexPath], with: .automatic)
    }
    
    
    func initCounter() {
        counter = UserDefaults.init().integer(forKey: "counter")
    }
    
    func updateCounter() {
        counter += 1
        UserDefaults.init().set(counter, forKey: "counter")
        UserDefaults.init().synchronize()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        picker .dismiss(animated: true, completion: nil)
        
        // fetch resultset has the recently added row without the image
        // this code ad the image to the row
        if let city = fetchResults.last, let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            city.picture = image.pngData()! as NSData
            //update the row with image
            updateLastRow()
            do {
                try managedObjectContext.save()
            } catch {
                print("Error while saving the new image")
            }
            
        }
        
    }
    
    
    @IBAction func deleteAll(_ sender: UIBarButtonItem) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
        
        //whole fetchRequest object is removed from the managed object context
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
            
            
        }
        catch let _ as NSError {
            // Handle error
        }
        
        cityTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndex: IndexPath = self.cityTable.indexPath(for: sender as! UITableViewCell)!
        
        let city = fetchResults[selectedIndex.row].name
        
        
        
        if(segue.identifier == "cityView"){
            if let viewController: CityViewController = segue.destination as? CityViewController {
                viewController.selectedCity = city;
            }
        }
  
    
}


}
