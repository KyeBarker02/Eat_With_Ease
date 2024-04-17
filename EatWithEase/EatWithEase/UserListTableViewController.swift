//
//  AppDelegate.swift
//  EatWithEase
//
//  Created by Barker, Kye on 12/04/2024.
//

import UIKit

class UserListTableViewController: UITableViewController {

    // Set the label for the blank list, before it has been appended
    private let emptyListLabel: UILabel = {
        
        // Sets the text for the placeholder label
        let label = UILabel()
        label.text = "Your Shopping List is Empty, Let's Go Shopping!"

        // Sets the graphic format of the placeholder label
        label.textAlignment = .center
        label.textColor = .gray

        // Disable autoresizing mask to allow manual constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register custom UITableViewCell subclass for reuse
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "ProductIdentifier")

         // Set the empty list label as the background view initially
        tableView.backgroundView = emptyListLabel

        // Hide table view separators
        tableView.separatorStyle = .none
    }

    // Called just before the view controller's view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Reload the table view data to reflect any changes
        tableView.reloadData()

        // Update the background view based on the list content
        updateBackgroundView()

        // Calculate and display the total price of the products
        totalPriceCalc()
    }

    // Update the background view based on the list content
    func updateBackgroundView() {

        // Get the list of added products from the shared instance of ProductDetailsViewController
        let products: [[String: Any]] = ProductDetailsViewController.shared.addedProduct

        //Sorts the products by the stores
        let results = productSort(products: products)

        ?? If both lists, based on the stores, are empty, show the Empty List Label
        if results.aldiProducts.isEmpty && results.tescoProducts.isEmpty {
            tableView.backgroundView = emptyListLabel
        } else {

            // If The are not empty, remove the background View
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - Table view data source

    // Function to split the categories into their sepateate stores
    func productSort (products: [[String: Any]]) -> (aldiProducts: [[String: Any]], tescoProducts: [[String: Any]]) {
        
        var aldiProducts: [[String: Any]] = []
        var tescoProducts: [[String: Any]] = []

        //Iterate through each product
        for product in products {
            if let store = product["productStore"] as? String {

                // Sort products based on their stores
                if store == "Aldi" {
                    aldiProducts.append(product)
                } else if store == "Tesco" {
                    tescoProducts.append(product)
                }
            }
        }
        return (aldiProducts, tescoProducts)
    }

    // Table View Methods

    // Define the number of Sections, two for two stores
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // Define the number of rows per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let products: [[String: Any]] = ProductDetailsViewController.shared.addedProduct
        let results = productSort(products: products)
        switch section {
        case 0:
            let numberOfAldiProducts = results.aldiProducts.count
            return numberOfAldiProducts
        case 1:
            let numberOfTescoProducts = results.tescoProducts.count
            return numberOfTescoProducts
        default:
            return 0
        }
    }

    // Define section headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Aldi"
        case 1:
            return "Tesco"
        default:
            return ""
        }

    }

    // Configure each cell in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductIdentifier", for: indexPath) as! ProductTableViewCell
        
        let products: [[String: Any]] = ProductDetailsViewController.shared.addedProduct
        let results = productSort(products: products)
        
        switch indexPath.section {
        case 0:
            let product = results.aldiProducts[indexPath.row]
            configureCell(cell, with: product)
        case 1:
            let product = results.tescoProducts[indexPath.row]
            configureCell(cell, with: product)
        default:
            break
        }
        
        return cell
    }

    // COfnigure cell with product details
    func configureCell(_ cell: ProductTableViewCell, with product: [String: Any]) {
        if let productName = product["productName"] as? String {
            cell.textLabel?.text = productName
        }
    }

    // Action to clear data and reload
    @IBAction func clearTableAndReloadData() {
        ProductDetailsViewController.shared.addedProduct.removeAll()
        tableView.reloadData()
        updateBackgroundView()
        totalPriceCalc()
    }

    // Label outlet for total prices
    @IBOutlet weak var totalPrices: UILabel!

    // Ca;lculate total prices for Aldi and Tesco products
    func totalPriceCalc () {
        let products: [[String: Any]] = ProductDetailsViewController.shared.addedProduct
        let results = productSort(products: products)
        var aldiRunningPrice: Float = 0.0
        var tescoRunningPrice: Float = 0.0
        //print(results)
        //print(results.aldiProducts)

        // Calculate total price for Aldi Products
        for aldiProduct in results.aldiProducts {
            if let aldiPriceString = aldiProduct["productPrice"] as? String {

                //Strip the '£' symbol from the string and convert to float value
                let cleanedPriceString = aldiPriceString.replacingOccurrences(of: "£", with: "")
                
                if let aldiPriceFlt = Float(cleanedPriceString) {

                    // Increment the running total by the price of the next product
                    aldiRunningPrice += aldiPriceFlt
                } else {
                    print("Failed to convert Aldi price: \(aldiPriceString)")
                }
            }
        }    

        // Calculate total prices for Tesco Products
        for tescoProduct in results.tescoProducts {
            if let tescoPriceString = tescoProduct["productPrice"] as? String {
                let cleanedPriceString = tescoPriceString.replacingOccurrences(of: "£", with: "")
                
                if let tescoPriceFlt = Float(cleanedPriceString) {
                    tescoRunningPrice += tescoPriceFlt
                } else {
                    print("Failed to convert Tesco price: \(tescoPriceString)")
                }
            }
        }

        print("Aldi Running : ", truncateFloat(aldiRunningPrice, maxLength: 4))
        print("Tesco Running: ", truncateFloat(tescoRunningPrice, maxLength: 4))

        // Place the total values in the label to output to the screen
        totalPrices.text = ("Total Aldi Cost: £\(truncateFloat(aldiRunningPrice, maxLength: 4)) / Total Tesco Cost: £\(truncateFloat(tescoRunningPrice, maxLength: 4))")
    }

    // Truncate the float number so it remains in punds and pennies
    func truncateFloat(_ number: Float, maxLength: Int) -> String {

        // Return the float to a string and truncate by the maximum length
        let numberAsString = String(number)
        
        if numberAsString.count > maxLength {
            let truncatedText = numberAsString.prefix(maxLength) + "..."
            return String(truncatedText)
        }
        
        return numberAsString
    }
}
