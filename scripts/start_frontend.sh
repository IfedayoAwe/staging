#!/bin/bash

cd ${PROJECT_WORKSPACE}/frontend/

# Build and start front-end server.
echo "Building front-end..."
yarn install
yarn build

echo "Starting front-end server..."
sudo systemctl enable frontend
sudo systemctl restart frontend