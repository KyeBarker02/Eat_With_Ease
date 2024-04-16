//
//  AppDelegate.swift
//  EatWithEase
//
//  Created by Barker, Kye on 09/04/2024.
//

import Foundation
import FirebaseCore
import FirebaseFirestore


var globalDocuments:[String: [String: Any]] = [:]

// Sets the global variable used to compute over the database data
class DataManager {
    static let shared = DataManager()
    
    // Initialises the variables used to store the
    // database data and the document access queue link
    public var globalDocuments: [String: [String: Any]] = [:]
    private let documentsAccessQueue = DispatchQueue(label: "com.example.documentsAccessQueue")
    
    // A function to load all of the daata into the above global variable
    func loadDBData(completion: @escaping () -> Void) {
        
        // Initialises the database, much like with python
        let db = Firestore.firestore()
        
        // Sets the array for the names of the collections for
        // both stores used
        let docRefs = ["TescoProduct", "AldiProduct"]
        
        let group = DispatchGroup()
        
        // Loops through the different stores
        for docRef in docRefs {
            group.enter()
            print("Fetching documents from collection: \(docRef)")
            
            // Uses the documentation provided by Firebase to
            // retrieve all data present in a collection
            
            //Ensure that the reference to self is weak to prevent strong reference cycles
            db.collection(docRef).getDocuments { [weak self] (querySnapshot, error) in
                
                // Notify the group that this task is complete
                defer {
                    group.leave()
                }
                
                // Unwrap safely
                guard let self = self else { return }
                
                // Check for errors during document retrieval
                if let error = error {
                    print("Error getting documents from collection \(docRef): \(error)")
                    return
                }
                
                // Unwrap quereSnapshot safely
                guard let querySnapshot = querySnapshot else { return }
                
                //Access the globalDocunments Dictionary in a safe manner
                self.documentsAccessQueue.async {
                    
                    //Iterate over the documents in the querySnapshot and populate globalDocuments
                    for document in querySnapshot.documents {
                        self.globalDocuments[document.documentID] = document.data()
                    }
                }
            }
        }
        // Once all tasks are complete, notify the completion group
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    // Separate the stores so that the products can be counted in order
    // to initialise the upcoming tables
    
    // Function to return the products stored in the
    // Aldi collection, and how many there are
    func separateStoresAldi() -> ([String: [String: Any]], Int){
        
        // Filter the global variable by the "Store" value
        let aldiEntries = globalDocuments.filter { _, value in
            guard let store = value["Store"] as? String else {
                return false
            }
            return store == "Aldi"
        }

        // Take the number of products in the array
        let aldiLength = aldiEntries.count
        
        //Return rrelevant values
        return(aldiEntries, aldiLength)
        
    }
    
    // Repeat the code for the Tesco Products
    func separateStoresTesco() -> ([String: [String: Any]], Int){
        let TescoEntries = globalDocuments.filter { _, value in
            guard let store = value["Store"] as? String else {
                return false
            }
            return store == "Tesco"
        }

        let tescoLength = TescoEntries.count
        
        return (TescoEntries, tescoLength)
    }
}
