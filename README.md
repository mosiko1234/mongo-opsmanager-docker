# MongoDB Ops Manager Local Infrastructure

Complete local development infrastructure with MongoDB, MinIO, and Ops Manager using Docker Compose.

## 🎯 Purpose

Set up a local development environment for testing MongoDB Ops Manager with clean and structured infrastructure.

## 📋 Prerequisites

- Docker & Docker Compose installed
- At least 8GB RAM available (for Ops Manager)
- Available ports: `8080`, `9000`, `9001`, `27017`
- **MongoDB Ops Manager .deb package** (must be downloaded separately)

### 📥 Download MongoDB Ops Manager

1. Go to [MongoDB Download Center](https://www.mongodb.com/docs/ops-manager/current/installation/)
2. Download the `.deb` file for MongoDB Ops Manager (version 8.0+)
3. Place the file in the project directory with name: `mongodb-mms-8.0.12.500.20250804T2000Z.amd64.deb`
   (or update the name in `docker-compose.yml`)

⚠️ **Important**: 
- The .deb file is larger than 2GB and not included in Git repository
- Installation uses Docker emulation (amd64 on arm64) - may be slow
- Requires 8GB RAM available for Ops Manager

## 🚀 Quick Start

```bash
# Start all services
docker-compose up -d

# Monitor logs
docker-compose logs -f

# Check service status
docker-compose ps

# Or use Makefile (optional convenience)
make up
make logs-follow
make status
```

## 🔗 Service Access

| Service | URL | Username | Password |
|---------|-----|----------|----------|
| **Ops Manager** | http://localhost:8080 | Create first user | - |
| **MinIO Console** | http://localhost:9001 | minioadmin | minioadmin123 |
| **MongoDB** | localhost:27017 | admin | admin123 |

## 🛠 Useful Commands

### Basic Docker Compose Commands
```bash
# Start infrastructure
docker-compose up -d

# Stop infrastructure  
docker-compose down

# Restart
docker-compose restart

# View logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# Check status
docker-compose ps
```

### Makefile Commands (Additional Convenience)
```bash
# Start infrastructure with colored output
make up

# Check service health
make health

# Connect to MongoDB shell
make mongo-shell

# Open MinIO console
make minio-console

# Full cleanup (⚠️ deletes all data!)
make clean
```

### Manual Verification
```bash
# Check MongoDB
docker exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# Check Ops Manager
curl http://localhost:8080/account/login

# Check MinIO
curl http://localhost:9000/minio/health/live
```

## 📁 Project Structure

```
mongo-opsmanager/
├── docker-compose.yml                              # Main service configuration
├── Makefile                                       # Management commands (optional)
├── README.md                                      # This guide
├── .gitignore                                     # Files to ignore in git
├── mongodb-mms-8.0.12.500.20250804T2000Z.amd64.deb # Ops Manager installer (download separately)
├── init-scripts/
│   └── mongodb/
│       └── 01-init-users.js                       # MongoDB initialization script
└── scripts/
    └── install-ops-manager-deb.sh                 # Ops Manager installation script
```

### 🔧 Main Components

1. **docker-compose.yml** - The central file that defines:
   - MongoDB 7.0 with authentication
   - MinIO for backup storage
   - Ubuntu container with Ops Manager installation

2. **.deb file** - MongoDB Ops Manager 8.0.12 (download separately)

3. **Scripts** - Automatic initialization of all components

## ⚡ Real Usage

### Quick Start (without Makefile)
```bash
# Step 1: Download Ops Manager .deb file
# Step 2: Start infrastructure
docker-compose up -d

# Step 3: Monitor installation
docker-compose logs -f ops-manager

# Step 4: Check status
docker-compose ps
```

### Using Makefile (more convenient)
```bash
# Start with colored output and browser opening
make up

# Quick system check
make health

# Complete system information
make info
```

### What Actually Happens
1. **MongoDB** starts in 30 seconds
2. **MinIO** starts in 1 minute and creates bucket
3. **Ops Manager** takes 5-10 minutes for full installation (emulation is slow)
4. **Java process** starts with 8GB RAM
5. **Web interface** available at http://localhost:8080

## 🔧 First Access to Ops Manager

### After Startup
1. After starting services (about 5-10 minutes), go to http://localhost:8080
2. You'll be automatically redirected to `/account/login`  
3. Create first user (First User Registration)
4. Configure organization and project

### Connect Existing MongoDB
```
Connection String: mongodb://admin:admin123@mongodb:27017
Database Name: opsmanager (already exists with collections)
```

## 🐛 Troubleshooting

### Ops Manager Not Starting
```bash
# Check detailed logs
docker logs ops-manager -f

# Verify MongoDB is available
docker exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# Check Java processes
docker exec ops-manager ps aux | grep java

# Verify .deb file exists
ls -la mongodb-mms-*.deb
```

### MongoDB Connection Issues
```bash
# Test direct connection
docker exec mongodb mongosh --eval "db.adminCommand('ping')"

# Check users
docker exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin --eval "db.getUsers()"
```

### MinIO Issues
```bash
# Check MinIO health
curl -f http://localhost:9000/minio/health/live

# Check buckets
docker exec minio-setup mc ls myminio/
```

### Network Issues
```bash
# Check Docker network
docker network ls
docker network inspect mongo-opsmanager_opsmanager-network

# Check occupied ports
lsof -i :8080
lsof -i :9000
lsof -i :27017
```

### Complete Reset
```bash
# Stop and clean everything
make clean
# or
docker-compose down -v

# Start fresh
make up
# or  
docker-compose up -d

# Verify functionality
make verify
```

## 📊 Monitoring and Tracking

### Important Logs
```bash
# Ops Manager logs
docker logs ops-manager --tail=50

# MongoDB logs
docker logs mongodb --tail=50

# MinIO logs
docker logs minio --tail=50
```

### Performance Check
```bash
# Resource usage
docker stats

# Disk space
docker system df
```

## 🔒 Security

⚠️ **Important**: This infrastructure is for development only!
- Passwords are simple defaults
- No encryption in transit
- No advanced network restrictions

## 🤝 Development and Contribution

The code is structured modularly:
- Each service clearly separated
- Automatic health checks
- Persistent data through volumes
- Isolated network for secure communication

## 🔗 Git Repository

Project available on GitHub:
```bash
git clone https://github.com/mosiko1234/mongo-opsmanager-docker.git
cd mongo-opsmanager-docker
```

### 🔄 Update Project
```bash
git pull origin main
```

### 🤝 Contribute to Project
```bash
# Create new branch
git checkout -b feature/my-improvement

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push changes
git push origin feature/my-improvement
```

## 📞 Help

If you encounter issues:
1. Run `make health` to check service health
2. Check logs with `make logs-follow`
3. Try reset with `make clean && make up`
4. Check [documentation on GitHub](https://github.com/mosiko1234/mongo-opsmanager-docker)