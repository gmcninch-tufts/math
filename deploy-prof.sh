#!/usr/bin/env bash

echo "deploying prof-site"
cd /home/george/Web-hakyll/prof/
read -p "Commit message: " msg
git add .
git commit -m "$msg"
git push origin master
