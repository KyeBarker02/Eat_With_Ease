# Kye Barker
# 29/02/24
# A snippit of code used to switch from the first page of tesco to the second

from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import random



def Next_Page():
  firefox_driver = webdriver.Firefox()
  
  firefox_driver.get("https://www.tesco.com/groceries/en-GB/shop/food-cupboard/all?config=default&page=1&count=48")
  
  button = WebDriverWait(firefox_driver, 50).until(EC.element_to_be_clickable((By.CSS_SELECTOR,"#product-list > div.product-list-view.has-trolley > div.pagination-component.grid > nav > ul > li:nth-child(7) > a")))
  
  button_status = button.get_attribute("class")
  print(button_status)
  
  if 'disabled' not in button_status:
    print("Button is enabled")
  
  
    link_to_next_page = button.get_attribute("href")
  
    print(link_to_next_page)
  
  
    firefox_driver.quit()
  
    firefox_driver = webdriver.Firefox()
    firefox_driver.get(url = link_to_next_page)
  
  else:
    print("Button is disabled")
    
  return button, button_status
  
if __name__ == '__main__':
  Next_Page()
