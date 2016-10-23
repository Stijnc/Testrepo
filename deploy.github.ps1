


# create a folder
New-Item -ItemType Directory -Path ..\relGithub -Force
Push-Location
cd ..\relGithub
# pull in github repo
git init

git remote add origin https://github.com/Stijnc/Testrepo.git
git pull 
#add release content
Pop-Location
Copy-Item -Path . -Destination ..\relGithub
cd ..\relGithub
#git add files
git add .
#git commit files
git commit -m  "test"

#upload to github
git push -u origin master