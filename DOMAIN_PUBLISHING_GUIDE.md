# Namma Ooru AI — Custom Domain Publishing & Production Deployment Guide
**தமிழ்நாடு நகராட்சி நிர்வாகம் • Tamil Nadu Municipal Administration Portal**

This guide provides complete, production-ready instructions for publishing **Namma Ooru AI** on your custom domain name (e.g., `nammaooru.gov.in`, `nammaooru.ai`, or `yourcity.com`) with automated Let's Encrypt SSL/HTTPS encryption.

---

## Architecture Overview

```
                      Internet / Browser / Mobile App
                                    │
                                    ▼ [HTTPS :443 / HTTP :80]
                ┌───────────────────────────────────────┐
                │          Nginx Reverse Proxy          │
                │        (SSL Termination / Gzip)       │
                └───────────────┬───────────────────────┘
                                │
        ┌───────────────────────┴───────────────────────┐
        ▼                                               ▼
┌──────────────────────────────┐        ┌──────────────────────────────┐
│  Flutter Web SPA             │        │  FastAPI ASGI Backend        │
│  (/build/web static assets)  │        │  (Uvicorn on :8000)          │
│  - Citizen Portal            │        │  - RBAC Authentication       │
│  - Officer Workstation       │        │  - AI Classification Engine  │
│  - Admin Command Center      │        │  - PostGIS Geo Clustering    │
└──────────────────────────────┘        └───────────────┬──────────────┘
                                                        │
                                                        ▼
                                        ┌──────────────────────────────┐
                                        │  PostgreSQL 16 + PostGIS     │
                                        │  Spatial Database (:5432)    │
                                        └──────────────────────────────┘
```

---

## Step 1: Configure Your Domain DNS Records

Log in to your domain registrar (GoDaddy, Namecheap, Cloudflare, Google Domains, etc.):

1. Add an **A Record**:
   - **Type**: `A`
   - **Name / Host**: `@` (or subdomain like `portal`)
   - **Value / Points to**: Your VPS Public IP Address (e.g., `203.0.113.50`)
   - **TTL**: `300` (or Auto)
2. Add a **CNAME Record**:
   - **Type**: `CNAME`
   - **Name / Host**: `www`
   - **Value / Points to**: `@` (or `yourdomain.com`)
   - **TTL**: `300`

> [!NOTE]
> DNS propagation typically takes 5 to 30 minutes. You can verify it with `nslookup yourdomain.com` or `dig yourdomain.com`.

---

## Step 2: Provision a Cloud VPS Server

Select any standard Linux cloud VPS provider:
- **DigitalOcean**: Basic Droplet (2 vCPU, 4GB RAM)
- **AWS EC2**: `t3.medium` or `t4g.medium` (Ubuntu 22.04 LTS or 24.04 LTS)
- **Hetzner Cloud**: `CPX21` / `CX22`
- **Google Cloud (GCP)**: `e2-medium`
- **Hostinger / Linode**: 4GB RAM plan

Ensure Firewall ports are open:
- Port `80` (HTTP)
- Port `443` (HTTPS)
- Port `22` (SSH)

---

## Step 3: Install Docker & Docker Compose on the Server

SSH into your server:
```bash
ssh root@YOUR_SERVER_IP
```

Run the standard Docker installation:
```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh

# Enable Docker service
sudo systemctl enable --now docker

# Verify Docker Compose
docker compose version
```

---

## Step 4: Transfer Project Files to Server

From your local machine, copy the project directory to your remote VPS:
```powershell
# In Windows PowerShell:
scp -r . root@YOUR_SERVER_IP:/var/www/namma_ooru
```

Or clone your Git repository directly onto the server:
```bash
git clone https://github.com/your-org/namma-ooru-ai.git /var/www/namma_ooru
cd /var/www/namma_ooru
```

---

## Step 5: Configure Environment & Domain Name

1. Open `.env` and set your production secrets:
```bash
cp .env.example .env
nano .env
```
Fill in:
```env
PROJECT_NAME="Namma Ooru AI"
SECRET_KEY="generate-a-random-64-character-production-key"
POSTGRES_USER=namma_user
POSTGRES_PASSWORD="choose-a-strong-database-password"
POSTGRES_DB=namma_ooru_db
```

2. Run the deployment script with your domain:
```bash
chmod +x deploy_domain.sh
./deploy_domain.sh yourdomain.com admin@yourdomain.com
```

The script automatically:
1. Replaces `YOUR_DOMAIN` in `nginx.conf` with your actual domain name.
2. Compiles Flutter Web in release mode with relative `/api/v1` proxying.
3. Obtains a free, trusted Let's Encrypt SSL certificate.
4. Starts the PostgreSQL PostGIS database, FastAPI backend, and Nginx reverse proxy containers.
5. Sets up automated SSL renewal via Certbot.

---

## Step 6: Verify Your Live Deployment

Open your browser and navigate to:
- **Application Portal**: `https://yourdomain.com`
- **Interactive API Docs (Swagger UI)**: `https://yourdomain.com/docs`
- **Redoc Documentation**: `https://yourdomain.com/redoc`

### Test Default Seeded Accounts:
| Role | Email / Phone | Password |
| :--- | :--- | :--- |
| **Citizen** | `citizen@nammaooru.ai` | `citizen123` |
| **Municipal Administrator** | `admin@gcc.gov.in` | `admin123` |
| **Field Officer** | `officer.sivakumar@gcc.gov.in` | `officer123` |

---

## Step 7: Ongoing Maintenance & Management

### View Container Logs:
```bash
# All logs
docker compose -f docker-compose.prod.yml logs -f

# Backend API logs only
docker compose -f docker-compose.prod.yml logs -f backend

# Nginx access & error logs
docker compose -f docker-compose.prod.yml logs -f web
```

### Restart the Application Stack:
```bash
docker compose -f docker-compose.prod.yml restart
```

### Database Backup (PostgreSQL PostGIS):
```bash
docker exec -t namma_ooru_postgis pg_dump -U namma_user namma_ooru_db > backup_$(date +%Y%m%d).sql
```

### Updating to a New Version:
```bash
# Pull latest code
git pull origin main

# Rebuild web & backend
flutter build web --release --no-wasm-dry-run --dart-define=API_BASE_URL=/api/v1
docker compose -f docker-compose.prod.yml up -d --build
```
