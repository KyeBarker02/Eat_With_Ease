//
//  AppDelegate.swift
//  EatWithEase
//
//  Created by Barker, Kye on 12/04/2024.
//

import UIKit

// Set the structure and format of the Products and their details
struct Product {
    let name: String
    let price: String
    let ppu: String
    let store: String
    let match: String?
    let tags: Array<Any>?
    let category: String?
    let stockImage: String?
}

// Function to produce a table of all the products from the database
class ProductTableViewController: UITableViewController, UISearchBarDelegate {

    // Initialises the Search Bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    var products: [Product] = []

    // Loads the screen and the data on it
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadData()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductIdentifier")
    }

    // Function to produce the array of products in the correct format
    func loadData() {

        let (aldiEntries, _) = DataManager.shared.separateStoresAldi()
        let (tescoEntries, _) = DataManager.shared.separateStoresTesco()
        
        // Convert dictionaries to arrays of products
        let aldiProducts = aldiEntries.map { key, value in
            Product(name: value["Product Name"] as! String,
                    price: value["Product Price"] as! String,
                    ppu: value["Price per unit"] as! String,
                    store: "Aldi",
                    match: value["Match"] as? String,
                    tags: value["Tags"] as? [Any],
                    category: value["Category"] as? String,
                    stockImage: value["Stock_Image"] as? String
            )
        }
        let tescoProducts = tescoEntries.map { key, value in
            Product(name: value["Product Name"] as! String,
                    price: value["Product Price"] as! String,
                    ppu: value["Price per unit"] as! String,
                    store: "Tesco",
                    match: value["Match"] as? String,
                    tags: value["Tags"] as? [Any],
                    category: value["Category"] as? String,
                    stockImage: value["Stock_Image"] as? String
            )
        }
        
        // Merge products from both stores
        products = aldiProducts + tescoProducts

        //Updates the table with the collated data
        tableView.reloadData()
    }

    // Readies the Table View to be sent to the Product Details View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Ensures the correct Segue is being used
        if segue.identifier == "ShowProductDetailsSegue" {
            if let indexPath = sender as? IndexPath,
               let destinationVC = segue.destination as? ProductDetailsViewController {
                let product = products[indexPath.row]

                // Passes the correct details over to the next View
                destinationVC.productDetails = [product.name, product.price, product.ppu, product.store, product.match, product.tags, product.category, product.stockImage]
            }
        }
    }
    
    // MARK: - Table view data source

    //Sets the hard coded number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Sets the size of the table to the number of products in the array
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    //Sets the text for each cell in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductIdentifier", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = product.name
        return cell
    }

    // Segues the view into the Product Details View
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowProductDetailsSegue", sender: indexPath)
    }

    // Function to allow the user to earch for products
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        // If the user has not searched anythimg, show the whole array
        if searchText.isEmpty {
            loadData()
        } else {
            // Search through the array for products names that contain the same string
            products = products.filter { $0.name.range(of: searchText, options: .caseInsensitive) != nil }
            tableView.reloadData()
        }
    }
}
