#!/bin/bash

echo "Starting user data script..." | sudo tee -a $LOG_FILE

sudo apt update -y
sudo apt upgrade -y

export LOG_FILE="/var/log/user-data.log"
export HOME=/home/ubuntu
export NVM_DIR="$HOME/.nvm"
export GIT_USERNAME=${git_username}
export GIT_PAT=${git_pat}

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

# Connect to RDS
export PGPASSWORD="postgres"
echo "Connecting to RDS Domain: ${rds_instance_domain}" | sudo tee -a $LOG_FILE
echo "Create role and db" | sudo tee -a $LOG_FILE

psql -h ${rds_instance_domain} -U postgres -d postgres -p 5432 \
    -c "CREATE ROLE swiftext WITH LOGIN PASSWORD 'swiftext';" \
    -c "GRANT rds_superuser TO swiftext;" \
    -c "CREATE DATABASE swiftext;" \
    -c "CREATE DATABASE file_uploads;" 2>&1 | sudo tee -a $LOG_FILE

export PGPASSWORD="swiftext"
psql -h ${rds_instance_domain} -U swiftext -d file_uploads -p 5432 \
    -c "GRANT ALL PRIVILEGES ON DATABASE swiftext TO swiftext" \
    -c "GRANT ALL PRIVILEGES ON DATABASE file_uploads TO swiftext" 2>&1 | sudo tee -a $LOG_FILE

echo "Testing connection through new role" | sudo tee -a $LOG_FILE
psql -h ${rds_instance_domain} -U swiftext -d file_uploads -p 5432 2>&1 | sudo tee -a $LOG_FILE
psql -h ${rds_instance_domain} -U swiftext -d file_uploads -p 5432 \
    -c "\dt" 2>&1 | sudo tee -a $LOG_FILE

# Create a setup-repo.sh file
cat << 'EOF' | sudo tee /home/ubuntu/setup-repo.sh > /dev/null
#!/bin/bash

# Load env variables
export HOME=/home/ubuntu
export NVM_DIR="$HOME/.nvm"
export LOG_FILE="/var/log/setup-repo.log"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

cd /home/ubuntu

echo "Cloning or updating the repository..." | sudo tee -a $LOG_FILE
echo "Git username: $GIT_USERNAME"
git clone https://$GIT_USERNAME:$GIT_PAT@github.com/$GIT_USERNAME/swiftext.git 2>&1 | sudo tee -a $LOG_FILE || true

echo "Installing project dependencies..." | sudo tee -a $LOG_FILE
cd /home/ubuntu/swiftext/backend
npm install 2>&1 | sudo tee -a $LOG_FILE

echo "Installing project level dependencies..." | sudo tee -a $LOG_FILE
sudo apt install libreoffice
npm install libreoffice-convert
npm install jwt-decode@3.1.2
npm install -g nodemon
npm install -g pm2
echo "Libreoffice version: $(libreoffice --version)" | sudo tee -a $LOG_FILE
echo "JWT Decode version: $(npm list jwt-decode | grep jwt-decode)" | sudo tee -a $LOG_FILE
echo "Nodemon version: $(nodemon --version)" | sudo tee -a $LOG_FILE
echo "pm2 version: $(pm2 --version)" | sudo tee -a $LOG_FILE
EOF

# Create a setup-env.sh
export SETUP_TABLES_LOG_FILE="/var/log/setup-tables.log"
echo "Setting up environment variables..." | sudo tee -a $SETUP_TABLES_LOG_FILE
cat << 'EOF' | sudo tee /home/ubuntu/swiftext/db/.env > /dev/null
DB_USER=my_user
DB_HOST=my_host
DB_NAME=my_database
DB_PASSWORD=my_password
DB_PORT=5432

AWS_REGION=us-west-2
EOF

echo ".env file created successfully" | sudo tee -a $SETUP_TABLES_LOG_FILE

# Create a setup-tables.sh
echo "Setting up tables..." | sudo tee -a $SETUP_TABLES_LOG_FILE

cat << 'EOF' | sudo tee /home/ubuntu/setup-tables.sh > /dev/null
#!/bin/bash
echo "Setting up Dynamo table..." | sudo tee -a $SETUP_TABLES_LOG_FILE
node /home/ubuntu/swiftext/db/dynamo.js 2>&1 | sudo tee -a $SETUP_TABLES_LOG_FILE

echo "Setting up PSQL tables..." | sudo tee -a $SETUP_TABLES_LOG_FILE
node /home/ubuntu/swiftext/db/psql.js 2>&1 | sudo tee -a $SETUP_TABLES_LOG_FILE
EOF

# Make scripts executable
sudo chmod +x /home/ubuntu/setup-repo.sh
sudo chmod +x /home/ubuntu/setup-tables.sh

# Create a setup-app.sh
export SETUP_APP_LOG_FILE="/var/log/setup-app.log"
echo "Creating setup-app.sh..." | sudo tee -a $SETUP_APP_LOG_FILE

cat << 'EOF' | sudo tee /home/ubuntu/setup-app.sh > /dev/null
#!/bin/bash

echo "Running setup-repo.sh..." | sudo tee -a $SETUP_TABLES_LOG_FILE
node /home/ubuntu/setup-repo.sh 2>&1 | sudo tee -a $SETUP_TABLES_LOG_FILE
echo "Running setup-tables.sh..." | sudo tee -a $SETUP_TABLES_LOG_FILE
node /home/ubuntu/setup-tables.sh.js 2>&1 | sudo tee -a $SETUP_TABLES_LOG_FILE
EOF

sudo chmod +x /home/ubuntu/setup-app.sh

# Create a systemd service file
cat << 'EOF' | sudo tee /etc/systemd/system/setup-app.service > /dev/null
[Unit]
Description=Setup and run the application
After=network.target

[Service]
ExecStart=/home/ubuntu/setup-app.sh
Restart=on-failure
User=ubuntu

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply changes
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable setup-app.service
sudo systemctl start setup-app.service