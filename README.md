# AWS Production Infrastructure via Terraform (IaC)

An enterprise-grade Infrastructure as Code (IaC) repository that provisions a highly available, secure, and fault-tolerant multi-tier cloud environment on AWS using **Terraform**.

This project showcases production-grade cloud architecture blueprints without managing state files manually, focusing on security boundaries, high availability, and loose coupling.

## 📐 Infrastructure Architecture Map

The infrastructure is broken down into clean operational layers to follow AWS best practices:

- **Network Layer (VPC):** Custom VPC configured with a `/16` CIDR block spanning multiple Availability Zones (AZs) to prevent single-point network failure.
- **Public DMZ Subnet Tier:** Houses an Internet Gateway (IGW) and public routing mechanics to manage traffic entering the perimeter safely.
- **Compute Tier (Auto Scaling Group):** Provisions decoupled horizontal instances using an automated Launch Template, configured to dynamically scale instances between thresholds based on application demand spikes.
- **Isolated Private Database Tier (RDS):** Restricts data assets strictly inside dedicated private subnet groups, preventing any direct access vectors from the public internet.

## 📁 Repository Structure

```text
aws-infra-terraform/
├── main.tf           # Core infrastructure declarations (VPC, ASG, RDS)
├── variables.tf      # Parameterization schema blocks 
├── outputs.tf        # Explicit structural network identifiers exported 
├── terraform.tfvars  # Target runtime configuration definitions
└── README.md         # Architecture documentation and layout overview

🛠️ Infrastructure Component Breakdown
1. Network Perimeter
Virtual Private Cloud (VPC): Configured with full DNS hostnames and resolution flags enabled.

Subnet Topography: Segmented into dedicated public segments (10.0.1.0/24) and private backend databases data-tiers (10.0.10.0/24, 10.0.20.0/24).

2. Security Controls & Firewalls
Ingress Protections: Strict port filtering restricts web compute layers to edge traffic protocols over Port 80, while isolating database instance configurations safely from public exposure.

3. Elastic Compute & Resilience
Launch Configurations: Instantiates standard automated base images running shell scripts to bootstrap application runtimes natively.

Auto Scaling Topology: Set up with custom scalability boundaries (min: 1, desired: 2, max: 4) distributed evenly across execution pools.