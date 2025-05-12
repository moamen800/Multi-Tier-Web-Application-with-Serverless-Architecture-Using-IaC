#!/bin/bash -e

# Prometheus Server Installation
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.35.0/prometheus-2.35.0.linux-amd64.tar.gz
tar -xzf prometheus-2.35.0.linux-amd64.tar.gz

sudo useradd --no-create-home --shell /bin/false prometheus
sudo mv prometheus-2.35.0.linux-amd64/{prometheus,promtool} /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}

sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo chown prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo mv prometheus-2.35.0.linux-amd64/{console*,prometheus.yml} /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus

# Add Prometheus rules.yml
sudo tee /etc/prometheus/rules.yml > /dev/null <<EOF
---
groups:

  - name: Node_exporters
    rules:

    - record: Status_Nodes_Exporters
      expr: up{job="EC2_discover"}
      labels:
        node: "node_exporter"

    - alert: NodeDown
      expr: Status_Nodes_Exporters == 0
      labels:
        node: "NodeDown"
      for: 0s

  - name: CPU_Alerts
    rules:
    
    - alert: HighCpuLoad
      expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 40
      labels:
        node: "HighCPU"
      annotations:
        summary: "High CPU load detected on {{ \$labels.instance }}"
        description: "CPU load is over 40% (current value: {{ \$value }}%)."
EOF

sudo chown prometheus:prometheus /etc/prometheus/rules.yml

# Overwrite Prometheus Config
sudo tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
---
global:
  scrape_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093

rule_files:
  - "rules.yml"

scrape_configs:
  - job_name: "localhost_node_exporter"
    static_configs:
      - targets: ["localhost:9100"]
      
  - job_name: "EC2_discover"
    ec2_sd_configs:
      - region: "eu-west-1"
        port: 9100
        filters:
          - name: "tag:Title"
            values:
              - "prometheus"
EOF

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Prometheus Systemd Service
sudo tee /etc/systemd/system/prometheus.service > /dev/null <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Start and Enable Prometheus
sudo systemctl daemon-reload
sudo systemctl enable --now prometheus

# Node Exporter Installation
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar -xzf node_exporter-1.3.1.linux-amd64.tar.gz
sudo useradd --no-create-home --shell /bin/false node_exporter
sudo mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Node Exporter Systemd Service
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Start and Enable Node Exporter
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

# Alertmanager Installation
wget https://github.com/prometheus/alertmanager/releases/download/v0.24.0/alertmanager-0.24.0.linux-amd64.tar.gz
tar -xzf alertmanager-0.24.0.linux-amd64.tar.gz

sudo useradd --no-create-home --shell /bin/false alertmanager
sudo mv alertmanager-0.24.0.linux-amd64/{alertmanager,amtool} /usr/local/bin/
sudo chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}

sudo mkdir -p /etc/alertmanager
sudo tee /etc/alertmanager/alertmanager.yml > /dev/null <<EOF
---
global:
  resolve_timeout: 15s

route:
  receiver: 'default'
  group_wait: 10s
  group_interval: 15s
  routes:
    - match:
        node: 'HighCPU'
      receiver: 'HighCPU'
    - match:
        node: 'NodeDown'
      receiver: 'NodeDown'

receivers:
  - name: 'default'
    slack_configs:
      - channel: "#default"
        send_resolved: true
        api_url: '<SLACK_WEBHOOK_URL_DEFAULT>'  # 🔒 Add your default Slack webhook URL here

  - name: 'HighCPU'
    slack_configs:
      - channel: "#highcpu-app"
        send_resolved: true
        api_url: '<SLACK_WEBHOOK_URL_HIGH_CPU>'  # 🔒 Add Slack webhook for High CPU alerts

  - name: 'NodeDown'
    slack_configs:
      - channel: "#nodedown-app"
        send_resolved: true
        api_url: '<SLACK_WEBHOOK_URL_NODE_DOWN>'  # 🔒 Add Slack webhook for NodeDown alerts
    email_configs:
      - to: '<ALERT_RECEIVER_EMAIL>'  # 🔒 Email to receive alerts
        from: '<GMAIL_ADDRESS>'       # 🔒 Your Gmail address
        smarthost: smtp.gmail.com:587
        auth_username: '<GMAIL_ADDRESS>'  # 🔒 Must match sender
        auth_identity: '<GMAIL_ADDRESS>'
        auth_password: '<EMAIL_APP_PASSWORD>'  # 🔒 Gmail app password only, not normal password
        send_resolved: true
EOF


sudo chown -R alertmanager:alertmanager /etc/alertmanager

# Alertmanager Systemd Service
sudo tee /etc/systemd/system/alertmanager.service > /dev/null <<EOF
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --web.external-url http://0.0.0.0:9093

[Install]
WantedBy=multi-user.target
EOF

# Start and Enable Alertmanager
sudo systemctl daemon-reload
sudo systemctl enable --now alertmanager

# Grafana Installation (from Official Repository)
sudo apt-get install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana

# Start and Enable Grafana
sudo systemctl enable --now grafana-server

# Final restarts to apply all configs
sudo systemctl restart prometheus.service
sudo systemctl restart alertmanager.service
sudo systemctl restart grafana-server.service

echo "✅ Prometheus, Node Exporter, Alertmanager, and Grafana have been installed and configured successfully!"
