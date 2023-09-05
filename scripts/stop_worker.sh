#!/bin/bash

# Stop worker process before deployment to avoid conflicts
echo "Stopping worker process..."
sudo systemctl stop worker