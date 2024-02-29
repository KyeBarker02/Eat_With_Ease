# Kye Barker
# 29/02/24
# Refined code designed to scrape the TEsco website and commit the data scraped to a DB

from selenium import webdriver
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.Certificate("/home/sgkbarke/Web_Scraper/eat-with-ease-firebase-adminsdk-vkgfm-a46b818eb1.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

class Product:
    def __init__(self, name, price, price_per_unit, product_status):
        self.name = name
        self.price = price
        self.price_per_unit = price_per_unit
        self.product_status = product_status
        

def fetcher():
    firefox_driver = webdriver.Firefox()
    firefox_driver.get("https://www.tesco.com/groceries/en-GB/shop/food-cupboard/all?config=default&page=1&count=48")

    data = firefox_driver.page_source
    soup = BeautifulSoup(data, 'html.parser')

    product_list = []

    raw_item_list = soup.find_all("div", class_="product-details--wrapper")
    
    
    for item in raw_item_list:
        item_name = item.find("h3", class_="styles__H3-oa5soe-0 gbIAbl").get_text(strip=True)
        if item.find("p", class_="styled__StyledHeading-sc-119w3hf-2 jWPEtj styled__Text-sc-8qlq5b-1 lnaeiZ beans-price__text") is not None:
          item_price = item.find("p", class_="styled__StyledHeading-sc-119w3hf-2 jWPEtj styled__Text-sc-8qlq5b-1 lnaeiZ beans-price__text").get_text(strip=True)
          ppu = item.find("p", class_="styled__StyledFootnote-sc-119w3hf-7 icrlVF styled__Subtext-sc-8qlq5b-2 bNJmdc beans-price__subtext").get_text(strip=True)
          product_list.append(Product(name=item_name, price=item_price, price_per_unit = ppu, product_status = "In Stock"))
        else: 
          product_list.append(Product(name=item_name, price = "0", price_per_unit = "0", product_status = "Not In Stock"))

    firefox_driver.quit()
    return product_list

if __name__ == '__main__':
    try:
        productList = fetcher()
        for product in productList:
            #print(f"Name: {product.name}, Price: {product.price}, Price per Unit: {product.price_per_unit}")
            data = {
	              'Product_Name': product.name,
                'Product_Price': product.price,
	              'Price per unit': product.price_per_unit
            }
            print(product.name)
            doc_ref = db.collection('TescoProduct').document()
            doc_ref.set(data)#Need to find a way of placing 'data' in here to send to firestore
    except Exception as e:
        print("Error:", e)
        
        

