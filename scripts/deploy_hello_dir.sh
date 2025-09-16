#!/usr/bin/env bash
set -e
INSTALL_DIR="/opt/tomcat"

echo "==> Deploy sample-app/hello to Tomcat"
sudo rm -rf "${INSTALL_DIR}/webapps/hello"
sudo mkdir -p "${INSTALL_DIR}/webapps/hello"
sudo cp -r sample-app/hello/* "${INSTALL_DIR}/webapps/hello/"
sudo chown -R tomcat:tomcat "${INSTALL_DIR}/webapps/hello"

echo "==> Restart Tomcat"
sudo systemctl restart tomcat

echo "==> Test: http://<YOUR_IP>:8080/hello/"
