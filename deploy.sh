read -p "Commit message: " msg

echo "Adding to source repo"
git add .
git commit -m "$msg"
git push origin master

# echo "deploying prof-site"
# cd /home/george/Web-hakyll/prof-site/
# git add .
# git commit -m "$msg"
# git push origin master
