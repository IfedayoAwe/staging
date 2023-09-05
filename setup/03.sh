# create swap file of 4GB
sudo dd if=/dev/zero of=/swapfile bs=128M count=32

sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# enable swapfile to be started at boot
echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab