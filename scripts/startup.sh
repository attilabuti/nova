#!/usr/bin/env bash

echo "--- Start Project ---"
sudo su vagrant -c "pm2 start app/app.js"