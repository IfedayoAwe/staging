#!/bin/bash

# Stop front-end server before deployment to avoid conflicts
echo "Stopping front-end server..."
sudo systemctl stop frontend