#!/usr/bin/env bash
set -e
INSTALL_DIR="/opt/tomcat"
WAR="$1"

if [[ -z "$WAR" ]]; then
  echo "Usage: $0 /path/to/app.war"
  exit 1
fi
if [[ ! -f "$WAR" ]]; then
  echo "WAR not found: $WAR"
  exit 1
fi

echo "==> Copy $(basename "$WAR") to webapps/"
sudo cp "$WAR" "${INSTALL_DIR}/webapps/"
sudo chown tomcat:tomcat "${INSTALL_DIR}/webapps/$(basename "$WAR")"

echo "==> Tail Tomcat logs (Ctrl+C to quit)"
sudo tail -f "${INSTALL_DIR}/logs/catalina.out"
