#!/bin/bash

echo "Starting user data script..." | sudo tee -a $LOG_FILE

sudo apt update -y
sudo apt upgrade -y

export USER_DATA_LOG_FILE="/var/log/user-data.log"
export HOME=/home/ubuntu
export NVM_DIR="$HOME/.nvm"
export RDS_INSTANCE_DOMAIN=${rds_instance_domain}
export GIT_USERNAME=${git_username}
export GIT_PAT=${git_pat}
export DB_PASSWORD=${db_password}
export JWT_SECRET=${jwt_secret}
export EFS_DIR=/home/ubuntu/efs


# Download NodeJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install 22
echo "Node version: $(node -v)" | sudo tee -a $USER_DATA_LOG_FILE
echo "nvm current: $(nvm current)" | sudo tee -a $USER_DATA_LOG_FILE
echo "npm version: $(npm -v)" | sudo tee -a $USER_DATA_LOG_FILE

# Download local Postgresql
sudo apt install postgresql postgresql-contrib libpq-dev -y
sudo service postgresql start
echo "psql version: $(psql --version)" | sudo tee -a $USER_DATA_LOG_FILE

# Download EFS dependencies
# Install cargo and Rust 1.70+
echo 1 | curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
sudo chown -R ubuntu:ubuntu /home/ubuntu/.cargo
echo "Cargo version: $(cargo --version)" | sudo tee -a $USER_DATA_LOG_FILE
echo "Rust version: $(rustc --version)" | sudo tee -a $USER_DATA_LOG_FILE

# Install other dependencies
sudo apt-get install build-essential -y
sudo apt install pkg-config -y

# Install nfs-common
sudo apt-get install nfs-common -y
echo "NFS version: $(nfsstat --version)" | sudo tee -a $USER_DATA_LOG_FILE

# Install OpenSSL-devel
sudo apt-get install libssl-dev -y
echo "OpenSSL version: $(openssl version)" | sudo tee -a $USER_DATA_LOG_FILE

# Check Python version
echo "Python3 version: $(python3 --version)" | sudo tee -a $USER_DATA_LOG_FILE

# Install stunnel
sudo apt-get install stunnel4 -y
echo "Stunnel" | sudo tee -a $USER_DATA_LOG_FILE

# Clone efs-utils github repo and build from source repo
echo "Cloning efs-utils GitHub repo…" | sudo tee -a $USER_DATA_LOG_FILE
sudo apt-get update && sudo apt-get -y install git binutils 2>&1 | sudo tee -a $USER_DATA_LOG_FILE
git clone https://github.com/aws/efs-utils /home/ubuntu/efs-utils 2>&1 | sudo tee -a $USER_DATA_LOG_FILE
echo "Building efs-utils from source repo…" | sudo tee -a $USER_DATA_LOG_FILE
cd /home/ubuntu/efs-utils
./build-deb.sh 2>&1 | sudo tee -a $USER_DATA_LOG_FILE
sudo apt-get -y install ./build/amazon-efs-utils*deb 2>&1 | sudo tee -a $USER_DATA_LOG_FILE

echo "Granting permission to build file…" | sudo tee -a $USER_DATA_LOG_FILE
sudo chmod 644 /home/ubuntu/efs-utils/build/amazon-efs-utils-2.2.0-1_amd64.deb
./build-deb.sh | sudo tee -a $USER_DATA_LOG_FILE
sudo apt-get -y install ./build/amazon-efs-utils*deb | sudo tee -a $USER_DATA_LOG_FILE

# Mount EFS
echo "Mounting EFS (${efs_id}) to $EFS_DIR…" | sudo tee -a $USER_DATA_LOG_FILE
if ! grep -qs "${efs_id}" /proc/mounts; then
    sudo mount -t efs "${efs_id}" "$EFS_DIR" 2>&1 | sudo tee -a $USER_DATA_LOG_FILE
    if [ $? -eq 0 ]; then
        echo "EFS mounted successfully." | sudo tee -a $USER_DATA_LOG_FILE
    else
        echo "Error mounting EFS." | sudo tee -a $USER_DATA_LOG_FILE
    fi
else
    echo "EFS already mounted." | sudo tee -a $USER_DATA_LOG_FILE
fi

# Connect to RDS
export PGPASSWORD="postgres"
echo "Connecting to RDS Domain: $RDS_INSTANCE_DOMAIN" | sudo tee -a $USER_DATA_LOG_FILE
echo "Create role and db" | sudo tee -a $USER_DATA_LOG_FILE

psql -h $RDS_INSTANCE_DOMAIN -U postgres -d postgres -p 5432 \
    -c "CREATE ROLE swiftext WITH LOGIN PASSWORD 'swiftext';" \
    -c "GRANT rds_superuser TO swiftext;" \
    -c "CREATE DATABASE swiftext;" \
    -c "CREATE DATABASE file_uploads;" 2>&1 | sudo tee -a $USER_DATA_LOG_FILE

export PGPASSWORD="swiftext"
psql -h $RDS_INSTANCE_DOMAIN -U swiftext -d file_uploads -p 5432 \
    -c "GRANT ALL PRIVILEGES ON DATABASE swiftext TO swiftext" \
    -c "GRANT ALL PRIVILEGES ON DATABASE file_uploads TO swiftext" 2>&1 | sudo tee -a $USER_DATA_LOG_FILE

echo "Testing connection through new role" | sudo tee -a $USER_DATA_LOG_FILE
psql -h $RDS_INSTANCE_DOMAIN -U swiftext -d file_uploads -p 5432 2>&1 | sudo tee -a $USER_DATA_LOG_FILE
psql -h $RDS_INSTANCE_DOMAIN -U swiftext -d file_uploads -p 5432 \
    -c "\dt" 2>&1 | sudo tee -a $USER_DATA_LOG_FILE

# Create a setup-repo.sh file
echo "Creating setup-repo.sh file" | sudo tee -a $USER_DATA_LOG_FILE
export SETUP_REPO_LOG_FILE="/var/log/setup-repo.log"

cat <<EOF | sudo tee /home/ubuntu/setup-repo.sh >/dev/null
#!/bin/bash

# Load env variables
export HOME=/home/ubuntu
export NVM_DIR="$HOME/.nvm"
export LOG_FILE="/var/log/setup-app.log"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

cd /home/ubuntu

echo "Cloning or updating the repository..." | sudo tee -a $SETUP_REPO_LOG_FILE
git clone https://$GIT_USERNAME:$GIT_PAT@github.com/deeowemez/swiftext.git 2>&1 | sudo tee -a $SETUP_REPO_LOG_FILE || true

echo "Installing project dependencies..." | sudo tee -a $SETUP_REPO_LOG_FILE
sudo chown -R 1000:1000 "/home/ubuntu/.npm"
cd swiftext/backend
npm install 2>&1 | sudo tee -a $SETUP_REPO_LOG_FILE

echo "Installing project level dependencies..." | sudo tee -a $SETUP_REPO_LOG_FILE
sudo apt install -y libreoffice

npm install libreoffice-convert
npm install jwt-decode@3.1.2 | sudo tee -a $SETUP_REPO_LOG_FILE
npm install -g nodemon
npm install -g pm2
npm install dotenv

echo "Libreoffice version: $(libreoffice --version)" | sudo tee -a $SETUP_REPO_LOG_FILE
echo "JWT Decode version: $(npm list jwt-decode | grep jwt-decode)" | sudo tee -a $SETUP_REPO_LOG_FILE
echo "Nodemon version: $(nodemon --version)" | sudo tee -a $SETUP_REPO_LOG_FILE
echo "pm2 version: $(pm2 --version)" | sudo tee -a $SETUP_REPO_LOG_FILE
echo "dotenv version: $(npm list dotenv)" | sudo tee -a $SETUP_REPO_LOG_FILE

# Creating EFS dir and setting permissions
echo "Creating EFS dir and changing ownership to ubuntu…" | sudo tee -a $USER_DATA_LOG_FILE
cd /home/ubuntu/
sudo mkdir -p $EFS_DIR
sudo chown -R ubuntu:ubuntu $EFS_DIR
sudo chmod -R 755 $EFS_DIR
EOF

# Create a setup-db-env.sh
echo "Creating setup-db-env.sh file" | sudo tee -a $USER_DATA_LOG_FILE

export SETUP_TABLES_LOG_FILE="/var/log/setup-tables.log"
echo "Setting up db env file..." | sudo tee -a $SETUP_TABLES_LOG_FILE

cat <<EOF | sudo tee /home/ubuntu/setup-db-env.sh >/dev/null
#!/bin/bash

# Environment configuration for PostgreSQL and AWS
cat << CONFIG > /home/ubuntu/swiftext/db/.env
# PostgreSQL Connection Details
DB_USER=swiftext
DB_HOST=$RDS_INSTANCE_DOMAIN
DB_NAME=file_uploads
DB_PASSWORD=$DB_PASSWORD
DB_PORT=5432

# AWS Configuration
AWS_REGION=ap-southeast-1
CONFIG

echo "Environment file created at /home/ubuntu/swiftext/db/.env"
EOF

# Create a setup-app-env.sh
echo "Creating setup-app-env.sh file" | sudo tee -a $USER_DATA_LOG_FILE

echo "Setting up app env file..." | sudo tee -a $SETUP_TABLES_LOG_FILE

cat <<EOF | sudo tee /home/ubuntu/setup-app-env.sh >/dev/null
#!/bin/bash

# Environment configuration for PostgreSQL and AWS
cat << CONFIG > /home/ubuntu/swiftext/backend/.env
# PSQL CREDS
DB_USER=swiftext
DB_HOST=$RDS_INSTANCE_DOMAIN
DB_NAME=file_uploads
DB_PASSWORD=$DB_PASSWORD
DB_PORT=5432

# JWT SECRET
JWT_SECRET=$JWT_SECRET

# AWS CREDS
AWS_REGION=ap-southeast-1


# STORAGE
STORAGE_PATH=/home/ubuntu/efs
CONFIG

echo "Environment file created at /home/ubuntu/swiftext/backend/.env"
EOF

# Create a setup-tables.sh
echo "Creating setup-tables file" | sudo tee -a $USER_DATA_LOG_FILE

export SETUP_TABLES_LOG_FILE="/var/log/setup-tables.log"
echo "Setting up tables..." | sudo tee -a $SETUP_TABLES_LOG_FILE

cat <<EOF | sudo tee /home/ubuntu/setup-tables.sh >/dev/null
#!/bin/bash

# Load env variables
export HOME=/home/ubuntu
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

echo "Setting up environment variables..." | sudo tee -a $SETUP_TABLES_LOG_FILE
cd /home/ubuntu/swiftext/db
npm install 2>&1 | sudo tee -a $SETUP_TABLES_LOG_FILE

echo "Setting up Dynamo table..." | sudo tee -a $SETUP_TABLES_LOG_FILE
node /home/ubuntu/swiftext/db/dynamo.js 2>&1 | sudo tee -a $SETUP_TABLES_LOG_FILE

echo "Setting up PSQL tables..." | sudo tee -a $SETUP_TABLES_LOG_FILE
node /home/ubuntu/swiftext/db/psql.js 2>&1 | sudo tee -a $SETUP_TABLES_LOG_FILE
EOF

# Make scripts executable
echo "Setting permissions on setup files" | sudo tee -a $USER_DATA_LOG_FILE
sudo chmod +x /home/ubuntu/setup-repo.sh
sudo chmod +x /home/ubuntu/setup-db-env.sh
sudo chmod +x /home/ubuntu/setup-app-env.sh
sudo chmod +x /home/ubuntu/setup-tables.sh
echo "setup-repo permissions: $(ls -l /home/ubuntu/setup-repo.sh)" | sudo tee -a $USER_DATA_LOG_FILE
echo "setup-db-env permissions: $(ls -l /home/ubuntu/setup-db-env.sh)" | sudo tee -a $USER_DATA_LOG_FILE
echo "setup-app-env permissions: $(ls -l /home/ubuntu/setup-app-env.sh)" | sudo tee -a $USER_DATA_LOG_FILE
echo "setup-tables permissions: $(ls -l /home/ubuntu/setup-tables.sh)" | sudo tee -a $USER_DATA_LOG_FILE

# Create a setup-app.sh
echo "Creating setup-app.sh" | sudo tee -a $USER_DATA_LOG_FILE

export SETUP_APP_LOG_FILE="/var/log/setup-app.log"
echo "Creating setup-app.sh..." | sudo tee -a $SETUP_APP_LOG_FILE

cat <<EOF | sudo tee /home/ubuntu/setup-app.sh >/dev/null
#!/bin/bash

echo "Running setup-repo.sh..." | sudo tee -a $SETUP_APP_LOG_FILE
bash /home/ubuntu/setup-repo.sh 2>&1 | sudo tee -a $SETUP_APP_LOG_FILE
echo "Running setup-db-env.sh..." | sudo tee -a $SETUP_APP_LOG_FILE
bash /home/ubuntu/setup-db-env.sh 2>&1 | sudo tee -a $SETUP_APP_LOG_FILE
echo "Running setup-app-env.sh..." | sudo tee -a $SETUP_APP_LOG_FILE
bash /home/ubuntu/setup-app-env.sh 2>&1 | sudo tee -a $SETUP_APP_LOG_FILE
echo "Running setup-tables.sh..." | sudo tee -a $SETUP_APP_LOG_FILE
bash /home/ubuntu/setup-tables.sh 2>&1 | sudo tee -a $SETUP_APP_LOG_FILE

# Start the application using PM2
echo "Starting the application with PM2..." | sudo tee -a $SETUP_APP_LOG_FILE
cd /home/ubuntu/swiftext/backend
pm2 start index.js --name swiftext-app --watch 2>&1 | sudo tee -a $SETUP_APP_LOG_FILE

# Save the PM2 process list so it restarts after reboot
pm2 save 2>&1 | sudo tee -a $SETUP_APP_LOG_FILE
EOF

sudo chmod +x /home/ubuntu/setup-app.sh
echo "setup-app permissions: $(ls -l /home/ubuntu/setup-app.sh)" | sudo tee -a $USER_DATA_LOG_FILE

# Create a systemd service file
echo "Creating setup-app service file" | sudo tee -a $USER_DATA_LOG_FILE
cat <<EOF | sudo tee /etc/systemd/system/setup-app.service >/dev/null
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