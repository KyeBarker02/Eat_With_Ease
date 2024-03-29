# -- TESCO WEB SCRAPER -- 
#  Kye Barker
#  01/03/2024
#  sgkbarke@liverpool.ac.uk
#  Below is the code used to access the website Tesco.com
#  It accesses the website, page by page and takes product 
#  data and uploads it to a secure Firebase Data Base


# Make necessary imports
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import random

# Connect to the correct DB using a private key stored in the file
cred = credentials.Certificate("/home/sgkbarke/Web_Scraper/eat-with-ease-firebase-adminsdk-vkgfm-a46b818eb1.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Create the class Product, which contains the
# details surrounding the products I want to scrape
class Product:
    def __init__(self, name, price, price_per_unit, product_status):
        self.name = name
        self.price = price
        self.price_per_unit = price_per_unit
        self.product_status = product_status
        
# Create the function 'fetcher' which does the heavy
# lifting by retrieving the products from the webpage
def fetcher(Tesco_link):
    
    # Initialise the webdriver and start the web session using selenium
    firefox_driver = webdriver.Firefox()
    firefox_driver.get(url=Tesco_Link)

    # Using the webpage accessed, take the HTML from the page
    # so that we are able to compute upon it using BeautifulSoup (BS4)
    data = firefox_driver.page_source
    soup = BeautifulSoup(data, 'html.parser')

    # Create a blank array to populate with products
    product_list = []

    # Source the HTML containing all the cells in which the
    # products are sourced using BS4, it is in its raw format
    raw_item_list = soup.find_all("div", class_="product-details--wrapper")

    # Use a loop to pass through all the product data and exctract the relevant details       
    for item in raw_item_list:
    
        # Find the Name of the Product
        item_name = item.find("h3", class_="styles__H3-oa5soe-0 gbIAbl").get_text(strip=True)
        
        # Check the Product to see if it is In-Stock
        if item.find("p", class_="styled__StyledHeading-sc-119w3hf-2 jWPEtj styled__Text-sc-8qlq5b-1 lnaeiZ beans-price__text") is not None:
        
          # Retrieve all the details surrounding the product
          item_price = item.find("p", class_="styled__StyledHeading-sc-119w3hf-2 jWPEtj styled__Text-sc-8qlq5b-1 lnaeiZ beans-price__text").get_text(strip=True)
          ppu = item.find("p", class_="styled__StyledFootnote-sc-119w3hf-7 icrlVF styled__Subtext-sc-8qlq5b-2 bNJmdc beans-price__subtext").get_text(strip=True)
          product_list.append(Product(name=item_name, price=item_price, price_per_unit = ppu, product_status = "In Stock"))
          
        else: 
          
          # Set the product to Not In Stock
          product_list.append(Product(name=item_name, price = "0", price_per_unit = "0", product_status = "Not In Stock"))
    
    # Find the button that navigates to
    # the next page using the symbol on it      
    button = WebDriverWait(firefox_driver, 50).until(EC.element_to_be_clickable((By.CSS_SELECTOR,"span.icon-icon_whitechevronright")))
    
    # Find the Parent of this button in order to
    # compute upon other properties it contains
    link_parent = button.find_element(By.XPATH, "./parent::a")
    
    # Retrieve the links and lable of the button to test to
    # see if it is the last page and know where to navigate to
    button_status = link_parent.get_attribute("class")
    link_to_next_page = link_parent.get_attribute("href")

    # Close the Web Page and return the list of
    # products and details about the next page
    firefox_driver.quit()
    return product_list, button_status, link_to_next_page

if __name__ == '__main__':
    try:
    
        # Start with feeding Fetcher with the initial link and starting the Web Page session
        Tesco_Link = ("https://www.tesco.com/groceries/en-GB/shop/food-cupboard/all?config=default&page=1&count=48")
        productList, ButtonStatus, NextLink = fetcher(Tesco_Link)
        firefox_driver = webdriver.Firefox()
        
        # Whilst the current page is not the last page in its section...
        while "disabled" not in ButtonStatus:
        
          # Assign the Product data to their database keys
          for product in productList:
              
              data = {
  	              'Product_Name': product.name,
                  'Product_Price': product.price,
  	              'Price per unit': product.price_per_unit
              }
              print(product.name)
              
              # Find a product in the database with the same name
              existing_doc = db.collection('TescoProduct').where('Product_Name', '==', product.name).get()
              
              # If there is already a product in the databse with the same name
              if existing_doc:
                for doc in existing_doc:
                
                  # Update the price of the product, 
                  # and if it is still in stock
                  doc_red = db.collection('TescoProduct').document(doc.id)
                  doc_ref.update({'Product_Price' : product.price, 'Price per unit' : product.price_per_unit, 'In-Stock' : product.product_status})
              else:
              
              #Send the Key-Value pairs to the database
                doc_ref = db.collection('TescoProduct').document()
                doc_ref.set(data)
              
  
  
          firefox_driver.quit()
  
          # Update the relevant information and run Fetcher again
          Tesco_Link = NextLink
          print("MOVING TO NEXT PAGE")
          print(ButtonStatus)
          print(NextLink)
          productList, ButtonStatus, NextLink = fetcher(Tesco_Link)
          
        # The current webpage is the last in this section of the store  
        else:
          print("On the Last Page")
          
          # Run through the updating of the database one last times
          for product in productList:
              
              data = {
  	              'Product_Name': product.name,
                  'Product_Price': product.price,
  	              'Price per unit': product.price_per_unit
              }
              print(product.name)
              doc_ref = db.collection('TescoProduct').document()
              doc_ref.set(data)
              
  
          firefox_driver.quit()
  
    
    
    except Exception as e:
        print("Error:", e)
        
        
        
