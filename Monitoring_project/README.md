AWS Cost & Usage Monitoring Dashboard

📌 Project Overview

Cloud costs can quickly spiral out of control without proper visibility. This project builds a Cost & Usage Monitoring Dashboard using Grafana, Prometheus, Docker, and AWS Free Tier services. The goal is to simulate and visualize AWS-like usage metrics (dynamic & mock data), while also integrating real AWS Cost Explorer metrics to demonstrate a realistic DevOps monitoring workflow.

🎯 Problem

AWS bills can be difficult to interpret without dashboards.

Teams often lack a centralized view of cloud usage and costs.

Static reports don’t provide real-time alerts or trends.

💡 Solution

This project provides a dashboard-based monitoring system:

Prometheus scrapes AWS metrics and mock cost/usage data.

Grafana visualizes trends (daily, weekly, monthly) and alerts.

Docker ensures reproducible local setup.

AWS Free Tier provides real service data (Cost Explorer + CloudWatch).

Outcome: A realistic cost & usage monitoring solution that blends local simulation with real AWS metrics, ideal for DevOps portfolios.

🛠️ Tech Stack

AWS Free Tier → Cost Explorer API, CloudWatch metrics

Prometheus → Metric collection & time-series storage

Grafana → Dashboards, alerting, visualization

Docker Compose → Local orchestration

Python/Go (optional) → Data mocking & metric exporters

📊 Key Features

Dynamic cost/usage data (real + mock).

Interactive Grafana dashboards with trends & alerts.

Fully containerized setup → runs locally with zero cost.

AWS integration for realistic cloud cost insights.

