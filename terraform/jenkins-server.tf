###############################
# Security Group for Jenkins
###############################
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH, HTTP, Jenkins"
  vpc_id      = "vpc-0ada18cdb7d97341f"  # Your Project VPC ID

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-SG"
  }
}

###############################
# Jenkins EC2 Instance
###############################
resource "aws_instance" "jenkins" {
  ami                         = "ami-029d77045a5834039"  # Same as EKS nodes
  instance_type               = "t2.micro"
  key_name                    = "mumbai"                 # Your SSH key
  subnet_id                   = "subnet-064ff7d4408b22c85" # Public subnet in Project VPC
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  depends_on = [aws_security_group.jenkins_sg]

  user_data = <<-EOF
              #!/bin/bash
              set -e

              # Update system
              yum update -y

              # Install Java 17
              amazon-linux-extras enable java-openjdk17
              yum install java-17-amazon-corretto -y
              java -version

              # Remove any old Jenkins installation
              systemctl stop jenkins || true
              yum remove jenkins -y
              rm -rf /var/lib/jenkins /etc/jenkins

              # Add Jenkins repo and import key
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum clean all
              yum makecache

              # Install Jenkins (skip GPG check)
              yum install jenkins -y --nogpgcheck

              # Enable and start Jenkins
              systemctl daemon-reload
              systemctl enable jenkins
              systemctl start jenkins

              # Install Git
              yum install git -y

              # Install Docker
              amazon-linux-extras install docker -y
              systemctl enable docker
              systemctl start docker
              usermod -aG docker ec2-user

              # Wait for Jenkins to be fully up
              while ! nc -z localhost 8080; do sleep 5; done

              # Install required Jenkins plugins
              JENKINS_CLI="/usr/lib/jenkins/jenkins-cli.jar"
              wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O $JENKINS_CLI

              # List of plugins to install
              PLUGINS="git docker-workflow kubernetes-cli workflow-aggregator credentials-binding blueocean"

              # Get initial admin password
              ADMIN_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

              for plugin in $PLUGINS; do
                  java -jar $JENKINS_CLI -s http://localhost:8080/ -auth admin:$ADMIN_PASSWORD install-plugin $plugin
              done

              # Restart Jenkins to apply plugins
              java -jar $JENKINS_CLI -s http://localhost:8080/ -auth admin:$ADMIN_PASSWORD safe-restart
              EOF

  tags = {
    Name = "Jenkins-Server"
  }
}

###############################
# Output Jenkins Public IP
###############################
output "jenkins_public_ip" {
  value       = aws_instance.jenkins.public_ip
  description = "Public IP to access Jenkins UI"
}