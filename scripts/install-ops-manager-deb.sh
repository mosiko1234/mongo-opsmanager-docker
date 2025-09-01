#!/bin/bash

# MongoDB Ops Manager Real Installation Script using provided .deb file
# This script installs the actual MongoDB Ops Manager from the provided package

set -e

echo "🚀 Installing MongoDB Ops Manager from provided .deb package..."

# Update system
echo "📦 Updating system packages..."
apt-get update
apt-get install -y wget curl gnupg lsb-release software-properties-common default-jre-headless

# Create mongodb-mms user and group
echo "👤 Creating mongodb-mms user and directories..."
groupadd -r mongodb-mms 2>/dev/null || true
useradd -r -g mongodb-mms -s /bin/false -d /opt/mongodb/mms mongodb-mms 2>/dev/null || true

# Create necessary directories
mkdir -p /opt/mongodb/mms/{logs,backup,conf}
mkdir -p /var/log/mongodb-mms
mkdir -p /var/lib/mongodb-mms

# Install the provided .deb package
echo "📦 Installing MongoDB Ops Manager from .deb package..."
cd /opt/mongodb

# The .deb file should be mounted in the container
if [ -f "mongodb-mms-8.0.12.500.20250804T2000Z.amd64.deb" ]; then
    echo "✅ Found Ops Manager package: mongodb-mms-8.0.12.500.20250804T2000Z.amd64.deb"
    
    # Remove any conflicting files first
    rm -f /opt/mongodb/mms/bin/mongodb-mms 2>/dev/null || true
    
    # Install the package with force-confold to keep existing configs
    DEBIAN_FRONTEND=noninteractive dpkg -i --force-confold mongodb-mms-8.0.12.500.20250804T2000Z.amd64.deb || \
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y
    
    # Fix any dependency issues
    DEBIAN_FRONTEND=noninteractive apt-get install -f -y
    
    echo "✅ MongoDB Ops Manager package installed successfully!"
else
    echo "❌ Ops Manager .deb package not found!"
    ls -la /opt/mongodb/
    exit 1
fi

# Create configuration file
echo "⚙️ Creating Ops Manager configuration..."
cat > /opt/mongodb/mms/conf/conf-mms.properties << 'EOF'
# MongoDB Ops Manager Configuration

# Database Settings
mongo.mongoUri=mongodb://admin:admin123@mongodb:27017/mmsdbconfig?authSource=admin
mongo.ssl=false

# Central URL - this is where Ops Manager will be accessible
mms.centralUrl=http://localhost:8080

# Email settings (required for Ops Manager)
mms.fromEmailAddr=admin@opsmanager.local
mms.replyToEmailAddr=admin@opsmanager.local
mms.adminEmailAddr=admin@opsmanager.local
mms.bounceEmailAddr=admin@opsmanager.local

# Mail transport settings (disabled for development)
mms.mail.transport=smtp
mms.mail.hostname=localhost
mms.mail.port=587

# Backup settings
backup.filesystem.directory=/opt/mongodb/mms/backup
backup.s3.bucketName=opsmanager-backups

# Security settings
mms.security.allowCORS=true
mms.ignoreInitialUiSetup=false

# Logging configuration
mms.logLevel=INFO

# JVM settings
mms.jvmArgs=-Xmx4096m -Xms2048m

# User management
mms.userManagement.enabled=true
EOF

# Set proper permissions
echo "🔒 Setting permissions..."
chown -R mongodb-mms:mongodb-mms /opt/mongodb/mms
chown -R mongodb-mms:mongodb-mms /var/log/mongodb-mms
chown -R mongodb-mms:mongodb-mms /var/lib/mongodb-mms

# Make sure the service directories exist
mkdir -p /etc/systemd/system

# Start Ops Manager
echo "🌐 Starting MongoDB Ops Manager..."

# Check if systemd is available (it might not be in Docker)
if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
    echo "Using systemd to start Ops Manager..."
    systemctl enable mongodb-mms
    systemctl start mongodb-mms
    systemctl status mongodb-mms
else
    echo "Starting Ops Manager manually (no systemd in container)..."
    # Start Ops Manager manually
    su - mongodb-mms -s /bin/bash -c "/opt/mongodb/mms/bin/mongodb-mms start" || \
    /opt/mongodb/mms/bin/mongodb-mms start &
fi

echo "✅ MongoDB Ops Manager installation completed!"
echo "🌐 Ops Manager should be starting up..."
echo "📍 Access at: http://localhost:8080"
echo "⏳ Please wait 3-5 minutes for the service to fully initialize"

# Keep container running and monitor the service
echo "📊 Monitoring Ops Manager startup..."

# Wait for the service to be ready
for i in {1..60}; do
    if curl -s http://localhost:8080/api/public/v1.0/unauth/version > /dev/null 2>&1; then
        echo "✅ Ops Manager is ready and responding!"
        break
    fi
    echo "⏳ Waiting for Ops Manager to start... ($i/60)"
    sleep 10
done

# Show final status
echo "🎉 MongoDB Ops Manager setup completed!"
echo "📊 Final status check:"
curl -s http://localhost:8080/api/public/v1.0/unauth/version || echo "API not yet ready"

# Keep the container running
tail -f /var/log/mongodb-mms/mms0.log 2>/dev/null || tail -f /opt/mongodb/mms/logs/mms0.log 2>/dev/null || tail -f /dev/null
