provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "my_key" {
  key_name   = "virginia kp"
  public_key = file("~/.ssh/my_key.pub")
}

resource "aws_security_group" "my_sg" {
  name        = "my_security_group"
  description = "Allow SSH and HTTP"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "global_ami_instance" {
  ami           = "ami-0c4e4b4eb2e11d1d4"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_sg.name]

  tags = {
    Name = "GlobalAMIInstance"
  }
}

resource "aws_ami_from_instance" "global_ami" {
  source_instance_id = aws_instance.global_ami_instance.id
  name               = "GlobalAMI"
  no_reboot          = true
}

### **Nginx Application Setup**

resource "aws_instance" "nginx_instance" {
  ami           = aws_ami_from_instance.global_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_sg.name]

  provisioner "file" {
    source      = "install_nginx.sh"
    destination = "/tmp/install_nginx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/install_nginx.sh"
    ]
  }
}

resource "aws_ami_from_instance" "nginx_ami" {
  source_instance_id = aws_instance.nginx_instance.id
  name               = "GoldenAMI_Nginx"
  no_reboot          = true
}

### **Apache Tomcat Application Setup**

resource "aws_instance" "tomcat_instance" {
  ami           = aws_ami_from_instance.global_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_sg.name]

  provisioner "file" {
    source      = "install_tomcat.sh"
    destination = "/tmp/install_tomcat.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/install_tomcat.sh"
    ]
  }
}

resource "aws_ami_from_instance" "tomcat_ami" {
  source_instance_id = aws_instance.tomcat_instance.id
  name               = "GoldenAMI_Tomcat"
  no_reboot          = true
}

### **Apache Maven Application Setup**

resource "aws_instance" "maven_instance" {
  ami           = aws_ami_from_instance.global_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.my_sg.name]

  provisioner "file" {
    source      = "install_maven.sh"
    destination = "/tmp/install_maven.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /tmp/install_maven.sh"
    ]
  }
}

resource "aws_ami_from_instance" "maven_ami" {
  source_instance_id = aws_instance.maven_instance.id
  name               = "GoldenAMI_Maven"
  no_reboot          = true
}

### **Outputs**

output "nginx_ami_id" {
  value = aws_ami_from_instance.nginx_ami.id
}

output "tomcat_ami_id" {
  value = aws_ami_from_instance.tomcat_ami.id
}

output "maven_ami_id" {
  value = aws_ami_from_instance.maven_ami.id
}
