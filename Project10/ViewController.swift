//
//  ViewController.swift
//  Project10
//
//  Created by Olha Pylypiv on 11.03.2024.
//

import UIKit

class ViewController: UICollectionViewController {
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: Person.self, from: savedPeople) {
                people = decodedPeople
            } else {
                print("Unable to load from UserDefaults.")
            }
        } else {
            print("Unable to convert to Data")
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            //we failed  to get a PersonCell; typecasting failed
            fatalError("Unable to dequeue a PersonCell.")
        }
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(picker.sourceType) {
            // picker.sourceType = .camera
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
        }
    }
    
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: true) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        save()
        
        dismiss(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        
        let ac1 = UIAlertController(title: "Select option", message: nil, preferredStyle: .actionSheet)
        
        ac1.addAction(UIAlertAction(title: "Rename person", style: .default) {
            [weak self]_ in
            let ac2 = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            ac2.addTextField()
            
            ac2.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac2.addAction(UIAlertAction(title: "OK", style: .default) {
                [weak self, weak ac2] _ in
                guard let newName = ac2?.textFields?[0].text else {return}
                person.name = newName
                
                self?.collectionView.reloadData()
                self?.save()
            })
            self?.present(ac2, animated: true)
        })
        
        ac1.addAction(UIAlertAction(title: "Delete", style: .default){
            [weak self] _ in
            let ac3 = UIAlertController(title: "Delete this person?", message: nil, preferredStyle: .alert)
            ac3.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            ac3.addAction(UIAlertAction(title: "Delete", style: .default) {
                [weak self] _ in
                self?.people.remove(at: indexPath.item)
                self?.collectionView.reloadData()
            })
            self?.present(ac3, animated: true)
        })
        
        ac1.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac1, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension ViewController: UINavigationControllerDelegate {
}
