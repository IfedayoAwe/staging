#!/bin/bash

# Stop API server before deployment to avoid conflicts
echo "Stopping API server..."
sudo systemctl stop api