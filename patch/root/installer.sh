# Get user
USER=$(ls /home)

echo "deb http://ftp.debian.org/debian stable main contrib non-free" > /etc/apt/sources.list
apt update
apt install -y wget curl git

# DE
apt install -y kde-standard plasma-nm

apt install -y latte-dock

add-apt-repository ppa:papirus/papirus
apt update
apt install -y qt5-style-kvantum qt5-style-kvantum-themes

git clone https://github.com/vinceliuice/Graphite-kde-theme
cd Graphite-kde-theme
./install.sh

# Package managers
dpkg --add-architecture i386
apt update

apt install -y flatpak
apt install -y plasma-discover-backend-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Basic Apps
apt install -y chromium

# Game Apps
apt install -y steam lutris

# Install proton
wget -O /root/proton.tar.gz https://yua.sh/foxxos/proton.tar.gz
mkdir /opt/foxxos.proton
tar -xf /root/proton.tar.gz -C /opt/foxxos.proton

# Merge user data
cp -rT /home_temp/user /home/$USER
chown -R $USER:$USER /home/$USER