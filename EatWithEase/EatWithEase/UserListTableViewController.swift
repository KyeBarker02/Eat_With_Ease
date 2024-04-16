import UIKit

class UserListTableViewController: UITableViewController {

    private let emptyListLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Shopping List is Empty, Let's Go Shopping!"
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "ProductIdentifier")
        tableView.backgroundView = emptyListLabel
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        updateBackgroundView()
        totalPriceCalc()
    }
    
    func updateBackgroundView() {
        let products: [[String: Any]] = ProductDetailsViewController.shared.addedProduct
        let results = productSort(products: products)
        
        if results.aldiProducts.isEmpty && results.tescoProducts.isEmpty {
            tableView.backgroundView = emptyListLabel
        } else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - Table view data source
    func productSort (products: [[String: Any]]) -> (aldiProducts: [[String: Any]], tescoProducts: [[String: Any]]) {
        
        var aldiProducts: [[String: Any]] = []
        var tescoProducts: [[String: Any]] = []
        for product in products {
            if let store = product["productStore"] as? String {
                if store == "Aldi" {
                    aldiProducts.append(product)
                } else if store == "Tesco" {
                    tescoProducts.append(product)
                }
            }
        }
        return (aldiProducts, tescoProducts)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
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

    func configureCell(_ cell: ProductTableViewCell, with product: [String: Any]) {
        if let productName = product["productName"] as? String {
            cell.textLabel?.text = productName
        }
    }

    @IBAction func clearTableAndReloadData() {
        ProductDetailsViewController.shared.addedProduct.removeAll()
        tableView.reloadData()
        updateBackgroundView()
        totalPriceCalc()
    }
    
    @IBOutlet weak var totalPrices: UILabel!
    
    func totalPriceCalc () {
        let products: [[String: Any]] = ProductDetailsViewController.shared.addedProduct
        let results = productSort(products: products)
        var aldiRunningPrice: Float = 0.0
        var tescoRunningPrice: Float = 0.0
        //print(results)
        //print(results.aldiProducts)
        for aldiProduct in results.aldiProducts {
            if let aldiPriceString = aldiProduct["productPrice"] as? String {
                let cleanedPriceString = aldiPriceString.replacingOccurrences(of: "£", with: "")
                
                if let aldiPriceFlt = Float(cleanedPriceString) {
                    aldiRunningPrice += aldiPriceFlt
                } else {
                    print("Failed to convert Aldi price: \(aldiPriceString)")
                }
            }
        }    
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
        totalPrices.text = ("Total Aldi Cost: £\(truncateFloat(aldiRunningPrice, maxLength: 4)) / Total Tesco Cost: £\(truncateFloat(tescoRunningPrice, maxLength: 4))")
    }
    
    func truncateFloat(_ number: Float, maxLength: Int) -> String {
        let numberAsString = String(number)
        
        if numberAsString.count > maxLength {
            let truncatedText = numberAsString.prefix(maxLength) + "..."
            return String(truncatedText)
        }
        
        return numberAsString
    }
}
