#!/usr/bin/env bash
set -e
TOMCAT_VERSION="9.0.91"
INSTALL_DIR="/opt/tomcat"

echo "==> Install Java & tools"
sudo apt update
sudo apt install -y openjdk-17-jdk wget curl

echo "==> Create tomcat user & install dir"
sudo useradd -m -U -d "$INSTALL_DIR" -s /bin/false tomcat || true
sudo mkdir -p "$INSTALL_DIR"

echo "==> Download Tomcat ${TOMCAT_VERSION}"
cd /tmp
wget -O tomcat.tar.gz "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

echo "==> Extract to $INSTALL_DIR"
sudo tar -xzf tomcat.tar.gz -C "$INSTALL_DIR" --strip-components=1
sudo chown -R tomcat:tomcat "$INSTALL_DIR"
sudo sh -c 'chmod +x /opt/tomcat/bin/*.sh'

echo "==> Detect JAVA_HOME"
JAVA_HOME_PATH=$(dirname "$(dirname "$(readlink -f "$(which java)")")")
echo "JAVA_HOME=${JAVA_HOME_PATH}"

echo "==> Write systemd service"
sudo tee /etc/systemd/system/tomcat.service >/dev/null <<SERVICE
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=${JAVA_HOME_PATH}"
Environment="CATALINA_HOME=${INSTALL_DIR}"
Environment="CATALINA_BASE=${INSTALL_DIR}"
Environment="CATALINA_PID=${INSTALL_DIR}/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms256M -Xmx512M -server -XX:+UseG1GC"
ExecStart=${INSTALL_DIR}/bin/startup.sh
ExecStop=${INSTALL_DIR}/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
SERVICE

echo "==> Enable & start tomcat"
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo systemctl status --no-pager tomcat || true

echo "==> (Optional) allow firewall 8080"
sudo ufw allow 8080/tcp || true
