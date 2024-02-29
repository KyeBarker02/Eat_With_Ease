#Kye Barker
#29/02/24
# Initial code designed to scrape data from Tescos Website

from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup
import codecs
import re

driver = webdriver.Firefox()

driver.get("https://www.tesco.com/groceries/en-GB/shop/fresh-food/all")

page_source = driver.page_source

soup = BeautifulSoup(page_source, features="html.parser")


title = soup.title.text

#print(soup.prettify())

print(title)


s = soup.find('div', class_="product-details--wrapper")


 
name = s.find_all('span')
price = s.find_all('p')


prod_name = []
prod_price = []

for line in name:
  prod_name.append(line.text)
  
for line in price:
  prod_price.append(line.text)
  
  
print(prod_name[0])
print(prod_price[0])
print(prod_price[1])

descend = soup.find('ul', class_="product-list grid")
current_descendant = []



for descendant in descend.descendants:
  if str(type(descendant)) == ("<class 'bs4.element.NavigableString'>"):
    print(descendant)
    current_descendant.append(descendant)
    if descendant == ("Add"):
      print(current_descendant)
      print(len(current_descendant))
      current_descendant = []
      
      
