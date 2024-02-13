#A web Scraping Tool using Selinuim and BS4 in to scrap a Tesco Web page

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from webdriver_manager.chrome import ChromeDriverManager
import time

driver = webdriver.Chrome()

URL = ('https://www.tesco.com/groceries/en-GB/shop/fresh-food/all')
request = driver.get(URL)

print(request)
