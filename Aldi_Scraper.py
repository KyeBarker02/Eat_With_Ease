# -- ALDI WEB SCRAPER -- 
#  Kye Barker
#  26/03/2024
#  sgkbarke@liverpool.ac.uk
#  Below is the code used to access the website Aldi.com
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
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import TimeoutException

# Connect to the correct DB using a private key stored in the file
cred = credentials.Certificate("/home/sgkbarke/Web_Scraper/eat-with-ease-firebase-adminsdk-vkgfm-a46b818eb1.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Create the class Product, which contains the
# details surrounding the products I want to scrape
class Product:
    def __init__(self, name, price, price_per_unit):
        self.name = name
        self.price = price
        self.price_per_unit = price_per_unit
        #self.product_status = product_status
        
# Create the function 'fetcher' which does the heavy
# lifting by retrieving the products from the webpage

def fetcher(Aldi_link):
    # Initialise the webdriver and start the web session using selenium
    firefox_driver = webdriver.Firefox()
    firefox_driver.implicitly_wait(10)
    firefox_driver.get(url=Aldi_link)
    
    # Click through the automatic prompt buttons the Aldi pushes upon start up
    cookies_button = WebDriverWait(firefox_driver, 10).until(EC.element_to_be_clickable((By.CSS_SELECTOR, "#onetrust-accept-btn-handler")))
    cookies_button.click()
    time.sleep(5)
    WebDriverWait(firefox_driver, 10).until(EC.invisibility_of_element_located((By.CSS_SELECTOR, "div.onetrust-pc-dark-filter.ot-fade-in")))
    
    # Create a blank array to populate with products
    product_list = []

    try:
        while True:
            # Using the webpage accessed, take the HTML from the page
            # so that we are able to compute upon it using BeautifulSoup (BS4)
            curr_url = firefox_driver.current_url
            firefox_driver.get(url = curr_url)
            data = firefox_driver.page_source
            soup = BeautifulSoup(data, 'html.parser')

            # Find the list of products
            raw_item_list = soup.find_all("div", id="vueSearchResults")
            for item in raw_item_list:
            
                # Loop through the products on the page
                product_names = item.find_all(attrs={'data-qa': "search-results"})
                for product in product_names:
                
                    # Collect the details from the product and add them to 
                    # product_list under the umbrella term Product
                    item_name = product.find(attrs={'data-qa': "search-product-title"}).getText(strip=True)
                    product_price_details = product.find(attrs={'class': "product-tile-price text-center"})
                    item_price = product_price_details.find('span', class_="h4").get_text(strip=True)
                    ppu = product_price_details.find("p", class_="m-0").get_text(strip=True)
                    product_list.append(Product(name=item_name, price=item_price, price_per_unit=ppu))
                    

            

            # Check for next page button within the variable 'page_flipper' which
            # references the bar containing the navigation data for the page. 
            page_flipper = (soup.find("ul", class_="pagination m-0 align-items-center justify-content-end"))
        
            page_arr = []
            for item in page_flipper:  
              page_arr.append(item)
            
            # Save the correct button in the correct variable
            next_button = page_arr[6]
            
            #Click the button to cycle through the pages
            button = WebDriverWait(firefox_driver, 10).until(
                EC.element_to_be_clickable((By.CSS_SELECTOR, "li.page-item.next.ml-2")))
            button.click()

    # When the next button can no longer be found, end the loop
    except TimeoutException:
        print("On last page")

    # If the code encounters any unknown errors, give context
    except Exception as e:
        print("Error:", e)

    #Close the webpage
    finally:
        firefox_driver.quit()
        return(product_list)

#Main function        
if __name__ == '__main__':
    try:
    
        #Conduct the fetching function using the given link and return the list of products
        Aldi_link = ("https://groceries.aldi.co.uk/en-GB/food-cupboard")
        ProductList = fetcher(Aldi_link)
        
        # For every product on the given link through all the pages
        # format the data in a Firebase friendly format 
        for product in ProductList:
          data = {
                  'Product_Price': product.price,
  	              'Price per unit': product.price_per_unit
          }
          
          # Check the database for products with the same name
          doc_ref = db.collection('ALdiProduct').where('Product_Name', '==', product.name).get()
          
          # If it exists in the database
          if doc_ref:
            for doc in doc_ref:
              
              # Update the prices and names
              doc_ref = db.collection('AldiProduct').document(doc.id)
              doc_ref.update(data)
              print(product.name, " updated in the database")
          
          # If it does not exist  
          else:
          
            # Update 'data' and post to the database 
            data['Product_Name'] = product.name
            doc_ref = db.collection('AldiProduct').document()
            doc_ref.set(data)
            print(product.name, " added to the database")
          
          #Add the data to the Firestore database
          doc_ref = db.collection('AldiProduct').document()
          doc_ref.set(data)
        
    except Exception as e:
      
      print("Error:", e)
        
        

        
