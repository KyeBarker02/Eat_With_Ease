import UIKit


// Code to create the screen that allows users to see
// the details for individual products
class ProductDetailsViewController: UIViewController {
    
    static let shared = ProductDetailsViewController()
    
    


    // Initialise the label variables that are going to be shown on screen
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productPPULabel: UILabel!
    @IBOutlet weak var productStoreLabel: UILabel!
    @IBOutlet weak var productMatchLabel: UILabel!
    
    // Initialise the Table view that will be shown on screen
    @IBOutlet weak var SimilarProducts: UITableView!
    
    // Set the relevant variables
    
    // Array Variable for the details attatched to the product
    var productDetails: [Any]?
    
    // Array of dictionaries variable that users have added to their list
    var addedProduct: [[String: Any]] = []
    
    // Array of dictionaries variable that are similar to the product on screen
    var similarProducts: [[String: Any]] = []
    
    
    // Funtion to load and reload the creen with the correct views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Protects the screen if the details have not been carriedd over correctly
        guard let productDetails = productDetails, productDetails.count >= 5 else {
            print("Error: productDetails is nil or has insufficient elements")
            return
        }
        
        // Populates the labels with the correct data
        productNameLabel.text = ("Name: \(productDetails[0] as? String ?? "")")
        productPriceLabel.text = ("Price: \(productDetails[1] as? String ?? "")")
        productPPULabel.text = ("Price Per Unit: \(productDetails[2] as? String ?? "")")
        productStoreLabel.text = ("Store: \(productDetails[3] as? String ?? "")")
        productMatchLabel.text = ("Category: \(productDetails[4] as? String ?? "")")
        
        // Registering the cell class for the table view
        SimilarProducts.register(ProductTableViewCell.self, forCellReuseIdentifier: "ProductCell")
        SimilarProducts.delegate = self
        SimilarProducts.dataSource = self
        similarProducts = getSimilarProducts()
        SimilarProducts.reloadData()
    }

    // Function to update the details on screen
    func updateProductDetails(with details: [Any]) {
        self.productDetails = details
        self.viewDidLoad()
    }

    // Function to handle the pressing of the "Add to List"
    // button, to allow useers to add products to their personal lists
    @IBAction func addButtonPressed(_ sender: Any) {
        guard let productDetails = productDetails else {
            print("Error: Product Details is Nil")
            return
        }
        
        // Creates a Key-Value array to store the product details in
        var productDictionary: [String: Any] = [:]
        
        // Mapping product details to the keys specified
        productDictionary["productName"] = productDetails[0]
        productDictionary["productPrice"] = productDetails[1]
        productDictionary["productPricePerUnit"] = productDetails[2]
        productDictionary["productStore"] = productDetails[3]
        productDictionary["productMatch"] = productDetails[4]
        productDictionary["productTags"] = productDetails[5]
        productDictionary["productCategories"] = productDetails[6]
        productDictionary["productImageURL"] = productDetails[7]
        
        //Ensures there are no repeats in the addedProduct array, to ensure
        // users do not accidentally add multiple of the same product
        if let productName = productDetails[0] as? String {
            if !ProductDetailsViewController.shared.addedProduct.contains(where: { $0["productName"] as? String == productName }) {
                ProductDetailsViewController.shared.addedProduct.append(productDictionary)
                SimilarProducts.reloadData()
            } else {
                print("Product with name \(productName) already exists in addedProduct array.")
            }
        }
        //print(ProductDetailsViewController.shared.addedProduct)
        
    }

    // Function that allows the retrieval of products with
    // similarities to the chosen product
    func getSimilarProducts() -> [[String: Any]] {
        
        // Sets the variables for the comparison, retrieved from Spoonacular,
        // using the same structure as the products on the page
        guard let productDetails = productDetails,
              productDetails.count > 6,
              let productCategory = productDetails[6] as? String,
              let productMatch = productDetails[4] as? String else {
            
            print("Invalid product details or missing values.")
            print("productDetails: \(String(describing: productDetails))")
            return []
        }
        
        print("Product Category: \(productCategory)")
        print("Product Match: \(productMatch)")
        
        // Retrieves all the documents from the globalDocument array, where all the
        // Firestore documents are being held on the users side
        let docs = DataManager.shared.globalDocuments.map {$0.value}
        
        // Filters the results of 'docs' based on whether they have
        // matching Category and Match values
        let catMatch = docs.filter {value in
            guard let prodCat = value["Category"] as? String,
                  let prodMatch = value["Match"] as? String else {
                return false
            }
            return prodCat == productCategory && prodMatch == productMatch
        }
        
        // Sets a blank array to populate with the correct format
        var updatedCatMatch: [[String: Any]] = []
        
        // Loops through each of the products in the matched category array
        for product in catMatch {
            
            //Takes the products price and strips it of the '£' symbol
            if let priceString = product["Product Price"] as? String {
                let cleanedPriceString = priceString.replacingOccurrences(of: "£", with: "")
                
                // Converts the string value to a floating point number
                if let priceFlt = Float(cleanedPriceString) {
                    var updatedProduct = product
                    updatedProduct["Product Price"] = priceFlt
                    updatedCatMatch.append(updatedProduct)
                }
            }
        }
        
        // Ensures there are no multiple entries in the array to ensurre efficiency and clarity
        let uniqueProducts = updatedCatMatch.reduce(into: [String: [String: Any]]()) { (result, product) in
            if let productName = product["Product Name"] as? String {
                result[productName] = product
            }
        // Sorts the values by price, cheapest to most expensive, to promote cheapeer eating
        }.values.sorted { (dict1, dict2) -> Bool in
            guard let price1 = dict1["Product Price"] as? Float,
                  let price2 = dict2["Product Price"] as? Float else {
                return false
            }
            return price1 < price2
        }
        
        print("Unique Products based on product name: \(uniqueProducts)")
        
        return Array(uniqueProducts)
    }

    
    
}

extension ProductDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return similarProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductTableViewCell

        let productName = similarProducts[indexPath.row]["Product Name"] as? String ?? "Product Unknown"
        let productPrice = similarProducts[indexPath.row]["Product Price"] as? Float ?? 0.0


        let truncatedProductName = truncateText(productName, maxLength: 27)
        let truncatedText = "\(truncatedProductName)  :    £\(productPrice)"
        
        cell.textLabel?.text = truncatedText
        return cell
    }
    
    func truncateText(_ text: String, maxLength: Int) -> String {
        if text.count > maxLength {
            let truncatedText = text.prefix(maxLength) + "..."
            return String(truncatedText)
        }
        return text
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let productName = similarProducts[indexPath.row]["Product Name"] as? String ?? "Product Unknown"
        let productPrice = similarProducts[indexPath.row]["Product Price"] as? Float ?? 0.0

        let truncatedProductName = truncateText(productName, maxLength: 27) 
        let truncatedText = "\(truncatedProductName):    \(productPrice)"
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 32, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.text = truncatedText
        label.sizeToFit()

        return label.frame.height + 16  // Adjust padding as needed
    }

    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 1500
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.row < similarProducts.count else {
            print("Invalid index path")
            return
        }
        
        let selectedProduct = similarProducts[indexPath.row]
        
        productNameLabel.text = ("Name: \(selectedProduct["Product Name"] as? String ?? "Unknown")")
        productPriceLabel.text = ("Price: £\(selectedProduct["Product Price"] as? Float ?? 0.0)")
        productPPULabel.text = ("Price Per Unit: \(selectedProduct["Price per unit"] as? String ?? "Unknown")")
        productStoreLabel.text = ("Store: \(selectedProduct["Store"] as? String ?? "Unknown")")
        productMatchLabel.text = ("Category: \(selectedProduct["Category"] as? String ?? "Unknown")")
        
        productDetails = [
            selectedProduct["Product Name"] ?? "",
            "£\(selectedProduct["Product Price"] as? Float ?? 0.0)",
            selectedProduct["Price per unit"] ?? "",
            selectedProduct["Store"] ?? "",
            selectedProduct["Category"] ?? "",
            selectedProduct["Tags"] ?? [],
            selectedProduct["Categories"] ?? [],
            selectedProduct["Image URL"] ?? ""
        ]
    }

    
    



}

class ProductTableViewCell: UITableViewCell {
    
    let productLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    } ()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(productLabel)
        
        
        NSLayoutConstraint.activate([
            productLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
            productLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32),
            productLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            productLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
}
