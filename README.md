# Node.js DevOps Project 🚀

This project demonstrates deploying a **Node.js application** using **Docker**, **Kubernetes**, **Terraform**, **Jenkins**, and **AWS EKS**.  
It includes **CI/CD automation**, **infrastructure provisioning**, and **production deployment**.

---

## 🖼️ Architecture Diagram

```mermaid
flowchart TD
    Dev[Developer Push Code] -->|Git Push| GitHub[(GitHub Repo)]
    GitHub -->|SCM Polling/Webhook| Jenkins[Jenkins CI/CD]
    Jenkins -->|Build & Test| Docker[Docker Image]
    Docker -->|Push| ECR[(Amazon ECR)]
    Jenkins -->|Terraform Apply| AWSInfra[AWS Infra (VPC, Subnets, EKS, EC2)]
    Jenkins -->|kubectl apply| EKS[(Amazon EKS Cluster)]
    EKS -->|Deploy| Pods[App Pods]
    Pods -->|Expose| ALB[Elastic Load Balancer]
    ALB --> User[User Access via Browser]
1. Infrastructure Setup with Terraform
Clone the Repo
bash
Copy code
git clone https://github.com/PruthvirajPhadatare/Node-js-DevOps-Project.git
cd Node-js-DevOps-Project/terraform
Universal IAM Role
This role provides AdministratorAccess (full EC2, EKS, VPC, etc.).

hcl
Copy code
resource "aws_iam_role" "universal_role" {
  name = "UniversalRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_admin_policy" {
  role       = aws_iam_role.universal_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
👉 Attach this role to Jenkins EC2 instance and/or EKS worker nodes.

2. Jenkins Server Setup
Launch Ubuntu EC2 Instance
OS: Ubuntu 22.04

Size: t3.medium (≥4GB RAM)

Attach: UniversalRole

Install Prerequisites
Run sequentially:

bash
Copy code
# Update system
sudo apt update -y && sudo apt upgrade -y

# Install Java 17
sudo apt install -y openjdk-17-jdk

# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update -y
sudo apt install -y jenkins

# Install Git
sudo apt install -y git

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker jenkins
sudo systemctl enable docker
sudo systemctl start docker

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.29.0/2024-03-14/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
✅ Verify installs:

bash
Copy code
java -version
jenkins --version
git --version
docker --version
aws --version
kubectl version --client
3. Jenkins Plugins Required
Git Plugin

Kubernetes CLI Plugin

AWS Credentials Plugin

4. Configure AWS Credentials in Jenkins
Go to Dashboard → Manage Jenkins → Credentials

Add new credentials:

Kind: AWS Credentials

ID: aws-creds

Access Key ID + Secret Key

5. Jenkins Pipeline Setup
Create new pipeline job → NodeJs-DevOps-Project

Pipeline config:

SCM: Git

Repo URL: https://github.com/PruthvirajPhadatare/Node-js-DevOps-Project.git

Branch: main

Script Path: jenkins/Jenkinsfile

Save and build → Jenkins automates Docker build, push, Terraform infra, and EKS deployment.

6. Local Deployment
Run with Docker
bash
Copy code
# Build
docker build -t devops-app .

# Run
docker run -p 3000:3000 devops-app
Access at 👉 http://localhost:3000

Run with Kubernetes (minikube/kind)
bash
Copy code
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
Check status:

bash
Copy code
kubectl get pods
kubectl get svc
kubectl get ingress
7. AWS Deployment (EKS)
Update kubeconfig

bash
Copy code
aws eks --region ap-south-1 update-kubeconfig --name devops-project-eks
Deploy

bash
Copy code
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
Check rollout

bash
Copy code
kubectl get nodes
kubectl get pods
kubectl get svc
kubectl get ingress
Access app via Load Balancer DNS from kubectl get ingress.

✅ Summary
Local Deployment: Docker / Kubernetes

AWS Deployment: Jenkins CI/CD → Terraform infra → EKS → Ingress → ALB → Browser

Universal IAM Role: Full access for EC2/EKS/VPC

Jenkins Setup: Plugins, prerequisites, credentials, pipeline

👨‍💻 Author
Pruthviraj Phadatare
DevOps | AWS Cloud Engineer