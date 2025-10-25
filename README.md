# 🚀 MyDaily SaaS

Welcome to **MyDaily SaaS** – a **multi-tenant, cloud-native microservices project** that’s packed with DevOps magic, Kubernetes wizardry, and a sprinkle of chaos management! 🎩✨  

Two apps, one cluster, infinite possibilities:  
- 📝 **Notes App** – Keep your thoughts safe and sound  
- 💰 **Expense Tracker** – Track your money before it tracks you  

---

## 🌟 Project Overview

**Objective:** Build a portfolio-worthy SaaS project showcasing:  
- CI/CD pipeline with **GitHub Actions**  
- Multi-tenant deployment on **AWS EKS**  
- Persistent storage per app (PV/PVC)  
- Observability with **Prometheus + Grafana**  
- Reproducible infrastructure using **Terraform**

**Key Achievements:**  
- ✅ Multi-tenant namespaces (`tenant-a` & `tenant-b`) with isolated apps  
- ✅ Each app has its own PV/PVC storage 🗄️  
- ✅ Full observability: Prometheus scrapes metrics, Grafana dashboards visualize everything  
- ✅ CI/CD pipeline: push → build → deploy → success 🎉  
- ✅ Infrastructure as Code: EKS cluster, storage, and apps deployed using Terraform  

---

## 🏗️ Architecture (Text Version)
1. GitHub Actions (CI/CD) triggers on code push
2. Docker images are built and pushed to AWS ECR
3. EKS Cluster deploys apps per tenant:
    - tenant-a
        • Notes App → PV/PVC → Metrics → Grafana
        • Expense Tracker → PV/PVC → Metrics → Grafana
    - tenant-b
        • Notes App → PV/PVC → Metrics → Grafana
        • Expense Tracker → PV/PVC → Metrics → Grafana
4. Prometheus collects metrics from all apps
5. Grafana visualizes metrics in dashboards

---


Flow: **Code push → Docker image build → Image push → Deployment → Metrics visualization**

---

## 📦 Tech Stack

- **Cloud:** AWS (EKS, ECR) ☁️  
- **Containers:** Docker 🐳  
- **Orchestration:** Kubernetes (multi-tenant) ☸️  
- **CI/CD:** GitHub Actions ⚙️  
- **Observability:** Prometheus 📊 + Grafana 📈  
- **Infrastructure as Code:** Terraform 🔧  
- **Languages:** Python / Flask 🐍  

---

## 🛠️ Phase-wise Highlights

**Phase 1:** Planning & Project Setup 📝  
**Phase 2:** App Development (Notes App + Expense Tracker) 💻  
**Phase 3:** Containerization with Docker 🐳  
**Phase 4:** Kubernetes Deployment with multi-tenancy ☸️  
**Phase 5:** CI/CD pipeline with GitHub Actions ⚙️  
**Phase 6:** Observability & Monitoring (Prometheus + Grafana) 📊  

**Overall Result:** A fully functional, multi-tenant SaaS project ready to impress recruiters and friends alike. 🎯  




