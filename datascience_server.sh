#!/bin/bash
# Ask the user for their name
echo Name of user you would like to add?
read varname
sudo adduser $varname

gpasswd -a $varname sudo


echo User $varname has been added to the sudo users group. Booyah
###Switch user from root
su - $varname

#Get updates
sudo apt-get update
#Install nginx server
sudo apt-get install nginx

###Install base R
sudo sh -c 'echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" >> /etc/apt/sources.list'
###Add R public keys
gpg --keyserver keyserver.ubuntu.com --recv-key E298A3A825C0D65DFD57CBB651716619E084DAB9
gpg -a --export E298A3A825C0D65DFD57CBB651716619E084DAB9 | sudo apt-key add -

###Update again
sudo apt-get update
###Install base R
sudo apt-get install r-base

##Swap 1GB of Memory to create more space on your server
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1
sudo sh -c 'echo "/var/swap.1 swap swap defaults 0 0 " >> /etc/fstab'

echo "1GB of swapspace has been added to your server"
#Install devtools dependencies                                                                                                                                         

sudo apt-get -y install libcurl4-gnutls-dev libxml2-dev libssl-dev
echo "Devtools dependencies have been installed on your server"

sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"devtools::install_github('daattali/shinyjs')\""

###Install Rstudio Server
#Install gdebi
sudo apt-get -y install gdebi-core

###Install latest version of Rstudio Server
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.3.1056-amd64.deb
sudo gdebi rstudio-server-1.3.1056-amd64.deb
echo "Rstudio-Server has been installed on your server"

###Install R-Shiny dependency needed for Shiny-Server build
sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""                                                                                    
###Install latest verison of R Shiny-Server
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.14.948-amd64.deb
sudo gdebi shiny-server-1.5.14.948-amd64.deb
echo "Shiny-Server had been installed on your server"

###Setup proper permissions for shiny and your user
sudo groupadd shiny-apps
sudo usermod -aG shiny-apps $varname
sudo usermod -aG shiny-apps shiny
cd /srv/shiny-server
sudo chown -R $varname:shiny-apps .
sudo chmod g+w .
sudo chmod g+s .

###Install git on your system and initiliaze it
sudo apt-get -y install git
echo 'What is your github email address? Please place in quotes....'                                                                                                    
read $githubemailaddress
echo 'What is your github user name? Please place in quotes....'
read $githubusername                                                                                                                                                    
git config --global user.email $githubemailaddress
git config --global user.name  $githubusername

###Initialize git on your shiny-server
cd /srv/shiny-server
git init

echo It\'s nice to meet you $varname
