#!/usr/bin/env bash

# Build containers
docker-compose build

# Spin up containers
docker-compose up -d

# Wait for servers to initialize
echo "Waiting for servers to initialize"
sleep 15

# Establish connection to db
docker-compose exec php bash -c "cd /var/www/html && /wpcli/bin/wp core config --dbname=wordpress --dbuser=wordpress --dbpass=wordpress --dbhost=mariadb --allow-root"

# Install wordpress
docker-compose exec php bash -c "cd /var/www/html && /wpcli/bin/wp core install --url=localhost --title=IntegrationTest --admin_user=admin --admin_password=admin --admin_email=integration.test@joubel.com --skip-email --allow-root"

# Enable H5P
docker-compose exec php bash -c "cd /var/www/html && /wpcli/bin/wp plugin activate h5p --allow-root"

# Run the tests
cd test
npm install
npm test
wordpresstests=$?
cd ..

# Clean up all containers
docker-compose down -v
