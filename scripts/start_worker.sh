#!/bin/bash

echo "Starting worker process..."
sudo systemctl enable worker
sudo systemctl restart worker