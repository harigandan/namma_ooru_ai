#!/bin/bash
# ==============================================================================
# Namma Ooru AI — Custom Domain Deployment Script (Linux VPS)
# ==============================================================================

set -e

echo "=================================================="
echo "  நம்ம ஊர் AI • Namma Ooru AI Domain Publishing"
echo "=================================================="

# 1. Prompt for Domain Name if not set
if [ -z "$1" ]; then
    read -p "Enter your custom domain name (e.g. nammaooru.ai or portal.yourcity.gov.in): " DOMAIN_NAME
else
    DOMAIN_NAME=$1
fi

if [ -z "$2" ]; then
    read -p "Enter your admin email for Let's Encrypt SSL notifications: " ADMIN_EMAIL
else
    ADMIN_EMAIL=$2
fi

echo ""
echo ">> Configuring Nginx for domain: $DOMAIN_NAME"
sed -i "s/YOUR_DOMAIN/$DOMAIN_NAME/g" nginx.conf

# 2. Build Flutter Web Release Bundle
echo ""
echo ">> Building Flutter Web Production Bundle..."
flutter build web --release --no-wasm-dry-run --dart-define=API_BASE_URL=/api/v1

# 3. Create required directories
mkdir -p uploads build/web

# 4. Bootstrap SSL Certificate (if certificates don't exist yet)
if [ ! -d "/etc/letsencrypt/live/$DOMAIN_NAME" ]; then
    echo ""
    echo ">> Obtaining initial Let's Encrypt SSL certificate..."
    # Start temporary HTTP server for ACME verification
    docker compose -f docker-compose.prod.yml up -d web
    docker run -it --rm \
        -v "$(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro" \
        -v "namma_ooru_ai_certbot_etc:/etc/letsencrypt" \
        -v "namma_ooru_ai_certbot_var:/var/www/certbot" \
        certbot/certbot certonly --webroot \
        --webroot-path=/var/www/certbot \
        --email "$ADMIN_EMAIL" \
        --agree-tos \
        --no-eff-email \
        -d "$DOMAIN_NAME"
fi

# 5. Launch Full Production Stack
echo ""
echo ">> Starting production containers (PostGIS, FastAPI, Nginx, Certbot)..."
docker compose -f docker-compose.prod.yml up -d --build

echo ""
echo "=================================================="
echo "  Deployment Complete! "
echo "  Your application is live at: https://$DOMAIN_NAME"
echo "  FastAPI Swagger API docs:    https://$DOMAIN_NAME/docs"
echo "=================================================="
