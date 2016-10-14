#!/bin/bash

sudo apt-get update -y
sudo apt-get install -y apache2

sudo systemctl enable apache2
sudo systemctl start apache2

sudo apt-get install -y git
git clone https://github.com/zjaks/boostrap-website.git

sudo rm -rf /var/www/html/index.html 
sudo mv /boostrap-website/* /var/www/html/
sudo rm -rf /boostrap-website
