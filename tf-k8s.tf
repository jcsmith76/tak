provider "aws" {
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
  region     = "us-west-2"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags {
    Name = "tf-kubernetes"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id = "${aws_vpc.tf_vpc.id}"
  cidr_block = "172.16.10.0/24"
  availability_zone = "us-west-2a"
  tags {
    Name = "tf-kubernets"
  }
}

resource "aws_instance" "node" {
  ami = "ami-0411d593eba4708e5" # us-west-2
  key_name = "devtest"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.tf_k8s_allow_all.id}"]
  count = 3
  subnet_id = "${aws_subnet.my_subnet.id}"
  credit_specification {
    cpu_credits = "unlimited"
  }
  tags {
    Name = "tf-kubernets-${count.index}"
  }
}

resource "aws_eip" "eip" {
    count = "3"
    instance = "${element(aws_instance.node.*.id,count.index)}"
    vpc = true
    depends_on = ["aws_instance.node"]
    tags {
      type = "tfk8s"
    }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.tf_vpc.id}"

  tags {
    Name = "tf-k8s vpc gw"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = "${aws_route_table.tfmain.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table" "tfmain" {
    vpc_id = "${aws_vpc.tf_vpc.id}"
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.tf_vpc.id}"
  route_table_id = "${aws_route_table.tfmain.id}"
}

resource "aws_security_group" "tf_k8s_allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.tf_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


