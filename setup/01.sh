#!/bin/bash
# setup script for Ubuntu 20.04 on AWS EC2

# raise an error and exit the shell if an unset parameter is used
set -eu

# --- VARIABLES ---
TIMEZONE=Africa/Lagos

# prompt for admin username and database details
read -p "Enter project user: " USERNAME
echo "DATABASE SETUP"
read -p "Enter project database name: " DB_NAME
read -p "Enter project database admin username: " DB_ADMIN
read -p "Enter project database admin password: " DB_PASSWORD
read -p "Enter project database host: " DB_HOST

# force all output to be presented in en_US for the duration of this script
export LC_ALL=en_US.UTF-8

# --- SCRIPT LOGIC ---
# enable the universe repository
sudo add-apt-repository --yes universe

# update all packages
sudo apt update
sudo apt --yes -o Dpkg::Options::="--force-confnew" upgrade

# set timezone and install all locales
sudo timedatectl set-timezone ${TIMEZONE}
sudo apt install --yes locales-all

# create new user with root privileges and ensure password is required on login
sudo useradd --create-home --shell "/bin/bash" --groups sudo "${USERNAME}"
sudo passwd --delete "${USERNAME}"
sudo chage --lastday 0 "${USERNAME}"

# copy SSH keys from the root to the new user
sudo rsync --archive --chown=${USERNAME}:{USERNAME} /home/ubuntu/.ssh /home/${USERNAME}

# --- FIREWALL ---
# configure and enable firewall
sudo ufw allow 22/tcp # SSH
sudo ufw allow 80/tcp # HTTP
sudo ufw allow 443/tcp # HTTPS
sudo ufw --force enable

# install nginx
sudo apt install --yes nginx

# install Fail2Ban to temporarily block IPs with multiple failed SSH login attempts
sudo apt install --yes fail2ban

# install database migrate tool (https://github.com/golang-migrate/migrate)
curl -L https://github.com/golang-migrate/migrate/releases/download/v4.15.2/migrate.linux-amd64.deb --output migrate.deb
sudo dpkg -i migrate.deb
rm migrate.deb

# --- DATABASE ---
# install PostgreSQL (https://www.postgresql.org/download/linux/ubuntu/)
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install --yes postgresql

# set up database and admin user
sudo -i -u postgres psql -c "CREATE DATABASE ${DB_NAME}"
sudo -i -u postgres psql -d ${DB_NAME} -c "CREATE ROLE ${DB_ADMIN} WITH LOGIN PASSWORD '${DB_PASSWORD}'"
sudo -i -u postgres psql -d ${DB_NAME} -c "REVOKE ALL ON schema public FROM public"
sudo -i -u postgres psql -d ${DB_NAME} -c "GRANT ALL ON schema public TO ${DB_ADMIN}"

# add database DSN with admin user to environment variables
echo "DB_DSN_ADMIN='postgres://${DB_ADMIN}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}'" | sudo tee -a /etc/environment
echo "PROJECT_WORKSPACE='/home/${USERNAME}/project"

echo "Script complete. Rebooting..."
sudo reboot