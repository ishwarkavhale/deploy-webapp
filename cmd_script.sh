#!/bin/bash

echo 'Hello from the remote instance'
sudo apt update -y
sudo apt-get install -y python3-pip
cd /home/ubuntu && sudo apt install python3-flask -y
cd /home/ubuntu && sudo nohup python3 app.py > app.log 2>&1 &
