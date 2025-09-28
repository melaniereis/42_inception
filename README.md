# 🐳 Inception - Docker Multi-Container WordPress Infrastructure

<div align="center">
  <img src="https://img.shields.io/badge/School-42-black?style=flat-square&logo=42" alt="42 School"/>
  <img src="https://img.shields.io/badge/Docker-Compose-blue?style=flat-square&logo=docker" alt="Docker"/>
  <img src="https://img.shields.io/badge/WordPress-CMS-blue?style=flat-square&logo=wordpress" alt="WordPress"/>
  <img src="https://img.shields.io/badge/Nginx-Reverse_Proxy-green?style=flat-square&logo=nginx" alt="Nginx"/>
  <img src="https://img.shields.io/badge/MariaDB-Database-orange?style=flat-square&logo=mariadb" alt="MariaDB"/>
  <img src="https://img.shields.io/badge/SSL-TLS_1.3-red?style=flat-square&logo=letsencrypt" alt="SSL/TLS"/>
</div>

## 📖 About

**Inception** is a comprehensive Docker infrastructure project that demonstrates advanced containerization concepts by deploying a complete WordPress website using multiple interconnected containers. This project is part of the 42 School curriculum and focuses on system administration, containerization, and service orchestration.

The project implements a **LEMP stack** (Linux, Nginx, MySQL/MariaDB, PHP) architecture with each component running in its own isolated container, following best practices for microservices architecture and container security.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    🌐 HTTPS Traffic (443)                   │
└─────────────────────────┬───────────────────────────────────┘
                          │
                ┌─────────▼─────────┐
                │     📡 NGINX      │
                │  (Reverse Proxy)  │
                │   TLS Termination │
                └─────────┬─────────┘
                          │ FastCGI
                ┌─────────▼─────────┐
                │   🐘 WordPress    │
                │   (PHP-FPM 7.4)   │
                │    Port 9000      │
                └─────────┬─────────┘
                          │ MySQL Protocol
                ┌─────────▼─────────┐
                │   🗄️ MariaDB      │
                │   (Database)      │
                │    Port 3306      │
                └───────────────────┘
```

## ✨ Features

### Core Infrastructure
- 🐳 **Multi-Container Architecture** - Nginx, WordPress, MariaDB in separate containers
- 🔒 **SSL/TLS Encryption** - HTTPS-only with self-signed certificates
- 🌐 **Custom Domain** - Configured for `meferraz.42.fr`
- 📦 **Docker Compose** - Orchestrated service deployment
- 💾 **Persistent Storage** - Docker volumes for data persistence
- 🔐 **Secrets Management** - Secure credential handling

### Security Features
- 🔒 **HTTPS Only** - No HTTP traffic allowed
- 🗝️ **Secret Management** - Database and WordPress credentials secured
- 🛡️ **Container Isolation** - Each service in its own container
- 🚫 **No Root Access** - Services run with minimal privileges
- 🔥 **Custom Firewall** - Only necessary ports exposed

### Service Components
- **📡 Nginx** - Reverse proxy with SSL termination
- **🐘 WordPress** - PHP-FPM based CMS
- **🗄️ MariaDB** - MySQL-compatible database server

## 🛠️ Installation & Setup

### Prerequisites
- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Make** utility
- **OpenSSL** for certificate generation

### Quick Start
```bash
# Clone the repository
git clone https://github.com/your-username/42_inception.git
cd 42_inception

# Create required directories
sudo mkdir -p ~/data/wordpress ~/data/mariadb

# Build and start all services
make up

# Check service status
make status

# View logs
make logs

# Stop all services
make down

# Complete cleanup
make fclean
```

### Manual Setup
```bash
# Build all images
docker compose -f srcs/docker-compose.yml build

# Start services in detached mode
docker compose -f srcs/docker-compose.yml up -d

# Monitor logs
docker compose -f srcs/docker-compose.yml logs -f
```

## 📋 Makefile Commands

| Command | Description |
|---------|-------------|
| `make up` | Build and start all containers |
| `make down` | Stop and remove all containers |
| `make build` | Build all Docker images |
| `make logs` | View container logs |
| `make status` | Show container status |
| `make clean` | Remove containers and images |
| `make fclean` | Complete cleanup including volumes |
| `make re` | Rebuild everything from scratch |

## 🐳 Container Details

### 📡 Nginx Container
- **Base Image**: `debian:bullseye`
- **Purpose**: Reverse proxy and SSL termination
- **Port**: 443 (HTTPS)
- **Features**:
  - Self-signed SSL certificate
  - FastCGI proxy to WordPress
  - Security headers
  - Custom error pages

### 🐘 WordPress Container
- **Base Image**: `debian:bullseye`
- **Purpose**: WordPress CMS with PHP-FPM
- **Port**: 9000 (internal)
- **Features**:
  - PHP 7.4-FPM
  - WordPress CLI integration
  - MariaDB connection
  - File upload handling

### 🗄️ MariaDB Container
- **Base Image**: `debian:bullseye`
- **Purpose**: Database server
- **Port**: 3306 (internal)
- **Features**:
  - Custom database initialization
  - Secure user creation
  - Data persistence
  - Performance optimization

## 📁 Project Structure

```
inception/
├── 📄 Makefile                         # Build automation
├── 📄 README.md                       # This file
├── 📁 secrets/                        # Credential files (gitignored)
│   ├── db_password.txt               # Database password
│   ├── wp_admin_password.txt         # WordPress admin password
│   └── wp_user_password.txt          # WordPress user password
├── 📁 srcs/                          # Source files
│   ├── 📄 .env                       # Environment variables
│   ├── 📄 docker-compose.yml         # Service orchestration
│   └── 📁 requirements/              # Container definitions
│       ├── 📁 nginx/                 # Nginx configuration
│       │   ├── 📄 Dockerfile         # Nginx image definition
│       │   ├── 📁 conf/              # Nginx config files
│       │   └── 📁 tools/             # Setup scripts
│       ├── 📁 wordpress/             # WordPress configuration
│       │   ├── 📄 Dockerfile         # WordPress image definition
│       │   ├── 📁 conf/              # PHP-FPM config
│       │   └── 📁 tools/             # WordPress setup scripts
│       └── 📁 mariadb/               # MariaDB configuration
│           ├── 📄 Dockerfile         # MariaDB image definition
│           ├── 📁 conf/              # Database config
│           └── 📁 tools/             # Database init scripts
└── 📁 data/                          # Persistent data (auto-created)
    ├── 📁 wordpress/                 # WordPress files
    └── 📁 mariadb/                   # Database files
```

## 🔧 Configuration

### Environment Variables (.env)
```bash
# Domain Configuration
DOMAIN_NAME=meferraz.42.fr

# Database Configuration
MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser

# WordPress Configuration
WORDPRESS_DB_HOST=mariadb:3306
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wpuser
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_EMAIL=admin@meferraz.42.fr
WORDPRESS_USER=regularuser
WORDPRESS_USER_EMAIL=user@meferraz.42.fr
```

### Secrets Management
```bash
# Create secret files
echo "your_secure_db_password" > secrets/db_password.txt
echo "your_wp_admin_password" > secrets/wp_admin_password.txt
echo "your_wp_user_password" > secrets/wp_user_password.txt

# Set proper permissions
chmod 600 secrets/*.txt
```

### Host Configuration
Add to `/etc/hosts`:
```
127.0.0.1 meferraz.42.fr
```

## 🌐 Accessing the Website

Once the containers are running:

1. **Open your browser** and navigate to `https://meferraz.42.fr`
2. **Accept the self-signed certificate** warning
3. **WordPress setup** will complete automatically
4. **Admin login**: Available at `https://meferraz.42.fr/wp-admin`

### Default Credentials
- **Admin User**: `admin` (password from secrets file)
- **Regular User**: `regularuser` (password from secrets file)

## 🔍 Troubleshooting

### Common Issues

#### Containers Won't Start
```bash
# Check container status
docker ps -a

# View container logs
docker logs mariadb
docker logs wordpress
docker logs nginx
```

#### SSL Certificate Issues
```bash
# Regenerate SSL certificate
docker exec nginx openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx.key \
  -out /etc/ssl/certs/nginx.crt
```

#### Database Connection Issues
```bash
# Check MariaDB status
docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# Test WordPress-MariaDB connection
docker exec wordpress php -r "echo 'DB Connection: ';
  mysqli_connect('mariadb', 'wpuser', 'password', 'wordpress') ?
  print 'OK' : print 'FAILED';"
```

#### Volume Permission Issues
```bash
# Fix volume permissions
sudo chown -R www-data:www-data ~/data/wordpress
sudo chown -R mysql:mysql ~/data/mariadb
```

## 📊 Monitoring & Maintenance

### Container Health Checks
```bash
# Monitor resource usage
docker stats

# Check container health
docker inspect --format='{{.State.Health.Status}}' mariadb wordpress nginx

# View detailed container info
docker inspect mariadb | jq '.[0].State'
```

### Backup & Restore
```bash
# Backup database
docker exec mariadb mysqldump -u root -p wordpress > backup.sql

# Backup WordPress files
tar -czf wordpress_backup.tar.gz ~/data/wordpress/

# Restore database
docker exec -i mariadb mysql -u root -p wordpress < backup.sql
```

## 🔒 Security Considerations

### Implementation
- ✅ **No root containers** - All services run as non-root users
- ✅ **Minimal base images** - Using Debian Bullseye slim
- ✅ **Secret management** - Credentials stored securely
- ✅ **Network isolation** - Custom Docker network
- ✅ **HTTPS only** - No plain HTTP connections
- ✅ **Firewall rules** - Only necessary ports exposed

### Best Practices Applied
- 🔒 **Least privilege principle** - Minimal permissions
- 🛡️ **Defense in depth** - Multiple security layers
- 🔐 **Encrypted communication** - TLS 1.3 support
- 📝 **Audit logging** - Container activity logging
- 🔄 **Regular updates** - Base image security patches

## 📚 Learning Objectives

This project teaches:
- **🐳 Docker & Containerization**: Multi-container applications
- **🏗️ Infrastructure as Code**: Reproducible deployments
- **🔧 System Administration**: Service configuration and management
- **🌐 Web Stack Architecture**: LEMP stack implementation
- **🔒 Security**: SSL/TLS, secrets management, container security
- **📦 Service Orchestration**: Docker Compose workflows
- **🛠️ DevOps Practices**: Automation, monitoring, troubleshooting

## 🎯 42 School Requirements

### Mandatory Features
- ✅ Docker Compose with 3 containers
- ✅ Custom Dockerfiles (no ready-made images)
- ✅ HTTPS only (TLS 1.2+)
- ✅ Persistent volumes for database and WordPress
- ✅ Custom network for container communication
- ✅ Environment variables and secrets
- ✅ Container restart policies
- ✅ Domain name configuration

### Technical Constraints
- ✅ Debian Bullseye base images only
- ✅ No latest tags in Dockerfiles
- ✅ No ready-made images (nginx, WordPress, MariaDB)
- ✅ Custom entrypoint scripts
- ✅ PID 1 process handling

## 🔗 Useful Resources

- **[Docker Documentation](https://docs.docker.com/)** - Official Docker guides
- **[Docker Compose Reference](https://docs.docker.com/compose/)** - Compose file specification
- **[WordPress Developer Resources](https://developer.wordpress.org/)** - WordPress development
- **[Nginx Documentation](https://nginx.org/en/docs/)** - Nginx configuration
- **[MariaDB Knowledge Base](https://mariadb.com/kb/en/)** - Database administration

## 👥 Contributors

- **[Your Name](https://github.com/meferraz)** - Infrastructure Architecture & Implementation

## 📄 License

This project is part of the 42 School curriculum. Educational use only.

## 🙏 Acknowledgments

- **42 School** for the comprehensive containerization curriculum
- **Docker Community** for excellent documentation and tools
- **WordPress, Nginx, and MariaDB teams** for robust open-source software
- The DevOps community for containerization best practices

---

<div align="center">
  <strong>🚀 Ready to deploy your containerized infrastructure? Let's go! 🐳</strong>
</div>
