import UIKit

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

class ProductTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var products: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadData()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductIdentifier")
    }
    
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
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowProductDetailsSegue" {
            if let indexPath = sender as? IndexPath,
               let destinationVC = segue.destination as? ProductDetailsViewController {
                let product = products[indexPath.row]
                destinationVC.productDetails = [product.name, product.price, product.ppu, product.store, product.match, product.tags, product.category, product.stockImage]
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductIdentifier", for: indexPath)
        let product = products[indexPath.row]
        cell.textLabel?.text = product.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowProductDetailsSegue", sender: indexPath)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadData()
        } else {
            products = products.filter { $0.name.range(of: searchText, options: .caseInsensitive) != nil }
            tableView.reloadData()
        }
    }
}
