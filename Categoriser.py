# -- SPOONACULAR PRODUCT CATEGORISER   -- 
#  Kye Barker
#  28/03/2024
#  sgkbarke@liverpool.ac.uk
#  Below is the code used to utilise the Spoonacular API, more
#  specifically, the Product Categoriser. It opens up the Firestore 
#  Data Base and applies the categorisation to each product within

# Make the nescessary imports
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json
import requests
import time

# Initialsise the access to the database
cred = credentials.Certificate("/home/sgkbarke/Web_Scraper/eat-with-ease-firebase-adminsdk-vkgfm-a46b818eb1.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# Array containing the names of the collections within the database
collections = ['TescoProduct', 'AldiProduct']

# Loop through each of the collections stored in the database
for collection_name in collections:
  collection_ref = db.collection(collection_name)
  
  # Set the data within the databases to docs
  docs = collection_ref.stream()
  
  # Initialise the necessary API variables
  url = "https://api.spoonacular.com/food/products/classify"
  querystring = {"locale":"en_gb"}
  
  # For each product in the document convert the data to a dictionary
  for doc in docs:
      document_data = doc.to_dict()
      
      if 'Match' in document_data or 'Tags' in document_data or 'Category' in document_data or 'Stock_Image' in document_data:
            print(f"Skipping document {document_data['Product_Name']}, already contains some categorization data.")
            continue  # Skip to the next document

      try:
      
        # Save each document data to a JSON file
        with open(f"{document_data['Product_Name']}.json", 'w') as f:
            json.dump(document_data, f, indent=4)
        
        # Set the variables for API computation
        productName = document_data['Product_Name']
        payload = {
            "plu_code": "",
            "title": productName,
            "upc": ""
        }
        
        headers = {
            "content-type": "application/json",
            "x-api-key": "23896d44cfb745d6aad9fa41e9858733"
        }
        
        # Send the Spoonacular request off, and save the response as reponse
        response = requests.post(url, json=payload, headers=headers, params=querystring)
        
        # Format the response in the correct format
        json_response = response.json()
        match = json_response['matched']
        tags = json_response['breadcrumbs']
        category = json_response['category']
        stock_image = json_response['image']
        print(document_data['Product_Name'])
        print(match)
        cat_data = {
          'Match' : match,
          'Tags' : tags,
          'Category' : category,
          'Stock_Image' : stock_image 
        }
        
        # Update the database with the new data
        doc.reference.update(cat_data)
        
        
        # Space out requests to comply with API rate limits
        time.sleep(2)
      
      
      # Stop the program and highlight the error  
      except Exception as e: 
            print(f"Error processing product {document_data['Product_Name']}: {str(e)}")
            
            # Exit the loop
            break  

    
    
