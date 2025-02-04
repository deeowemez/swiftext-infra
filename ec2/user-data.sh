#!/bin/bash
LOG_FILE="/var/log/user-data.log"

echo "Starting user data script..." | sudo tee -a $LOG_FILE

sudo apt update -y
sudo apt upgrade -y

export HOME=/home/ubuntu
export NVM_DIR="$HOME/.nvm"

# Download NodeJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 22
echo "Node version: $(node -v)" | sudo tee -a $LOG_FILE
echo "nvm current: $(nvm current)" | sudo tee -a $LOG_FILE
echo "npm version: $(npm -v)" | sudo tee -a $LOG_FILE

# Download local Postgresql
sudo apt install postgresql postgresql-contrib libpq-dev -y
sudo service postgresql start
echo "psql version: $(psql --version)" | sudo tee -a $LOG_FILE

# Download EFS dependencies
# Install cargo and Rust 1.70+
echo 1 | curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
sudo chown -R ubuntu:ubuntu /home/ubuntu/.cargo
echo "Cargo version: $(cargo --version)" | sudo tee -a $LOG_FILE
echo "Rust version: $(rustc --version)" | sudo tee -a $LOG_FILE

# Install other dependencies
sudo apt-get install build-essential -y
sudo apt install pkg-config -y

# Install nfs-common
sudo apt-get install nfs-common -y
echo "NFS version: $(nfsstat --version)" | sudo tee -a $LOG_FILE

# Install OpenSSL-devel
sudo apt-get install libssl-dev -y
echo "OpenSSL version: $(openssl version)" | sudo tee -a $LOG_FILE

# Check Python version
echo "Python3 version: $(python3 --version)" | sudo tee -a $LOG_FILE

# Install stunnel
sudo apt-get install stunnel4 -y
echo "Stunnel" | sudo tee -a $LOG_FILE

# Clone efs-utils github repo and build from source repo
echo "Cloning efs-utils GitHub repo…" | sudo tee -a $LOG_FILE
sudo apt-get update && sudo apt-get -y install git binutils 2>&1 | sudo tee -a $LOG_FILE
git clone https://github.com/aws/efs-utils /home/ubuntu/efs-utils 2>&1 | sudo tee -a $LOG_FILE
echo "Building efs-utils from source repo…" | sudo tee -a $LOG_FILE
cd /home/ubuntu/efs-utils
./build-deb.sh 2>&1 | sudo tee -a $LOG_FILE
sudo apt-get -y install ./build/amazon-efs-utils*deb 2>&1 | sudo tee -a $LOG_FILE

echo "Granting permission to build file…" | sudo tee -a $LOG_FILE
sudo chmod 644 /home/ubuntu/efs-utils/build/amazon-efs-utils-2.2.0-1_amd64.deb
./build-deb.sh | sudo tee -a $LOG_FILE
sudo apt-get -y install ./build/amazon-efs-utils*deb | sudo tee -a $LOG_FILE

# Creating EFS dir and setting permissions
EFS_DIR="/home/ubuntu/efs"
echo "Creating EFS dir and changing ownership to ubuntu…" | sudo tee -a $LOG_FILE
cd ..
sudo mkdir -p $EFS_DIR
sudo chmod 775 $EFS_DIR
sudo chown ubuntu:ubuntu $EFS_DIR

# Mount EFS
echo "Mounting EFS (${efs_id}) to $EFS_DIR…" | sudo tee -a $LOG_FILE
if ! grep -qs "${efs_id}" /proc/mounts; then
    sudo mount -t efs "${efs_id}" "$EFS_DIR" 2>&1 | sudo tee -a $LOG_FILE
    if [ $? -eq 0 ]; then
        echo "EFS mounted successfully." | sudo tee -a $LOG_FILE
    else
        echo "Error mounting EFS." | sudo tee -a $LOG_FILE
    fi
else
    echo "EFS already mounted." | sudo tee -a $LOG_FILE
fi

