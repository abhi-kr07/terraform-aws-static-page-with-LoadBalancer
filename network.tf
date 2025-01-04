resource "aws_vpc" "my-vpc" {
    cidr_block = var.cidr_block
}

resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my-vpc.id
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.my-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "rt1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "rt2" {
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "my-sg" {
    name = "mysg-server"
    description = "This allow some inbound and outbound traffic"
    vpc_id = aws_vpc.my-vpc.id

    tags = {
        name = "sg-1"
    }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
    security_group_id = aws_security_group.my-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = "22"
    ip_protocol = "tcp"
    to_port = "22"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
    security_group_id = aws_security_group.my-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = "80"
    ip_protocol = "tcp"
    to_port = "80"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
    security_group_id = aws_security_group.my-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = "443"
    ip_protocol = "tcp"
    to_port = "443"
}

resource "aws_vpc_security_group_egress_rule" "internet" {
    security_group_id = aws_security_group.my-sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = -1
}