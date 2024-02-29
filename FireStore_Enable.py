# Kye Barker
#29/02/24
#A snippet of Code designed to commit sample data to a Firestore DB


import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

cred = credentials.Certificate("/home/sgkbarke/Web_Scraper/eat-with-ease-firebase-adminsdk-vkgfm-a46b818eb1.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

data = {
    'Product_Name': 'Limes',
    'Product_Price': '24p',
    'Price per unit': '2.40 per kilo'
}

doc_ref = db.collection('TescoProduct').document()

doc_ref.set(data)

print('Document ID: ', doc_ref.id)
