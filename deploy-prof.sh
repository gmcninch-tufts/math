#!/usr/bin/env bash

echo "rebuilding CV"
/home/george/.local/bin/make-cv.py

echo "deploying prof-site"
cd /home/george/Web-hakyll/prof/
read -p "Commit message: " msg
git add .
git commit -m "$msg"
git push origin master
