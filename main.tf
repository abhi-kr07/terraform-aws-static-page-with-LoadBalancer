resource "aws_instance" "instance-1" {
    ami = "ami-053b12d3152c0cc71"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    subnet_id = aws_subnet.sub1.id
    user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "instance-2" {
    ami = "ami-053b12d3152c0cc71"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    subnet_id = aws_subnet.sub2.id
    user_data = base64encode(file("userdata1.sh"))
}

resource "aws_s3_bucket" "example" {
    bucket = "my-demo-bucket-abhi-07"
}

resource "aws_alb" "my-alb" {
    name = "myalb"
    internal = false
    load_balancer_type = "application"

    security_groups = [aws_security_group.my-sg.id]
    subnets = [aws_subnet.sub1.id , aws_subnet.sub2.id]
}

resource "aws_lb_target_group" "alb-target" {
    name = "MyTg"
    port = "80"
    protocol = "HTTP"
    vpc_id = aws_vpc.my-vpc.id

    health_check {
      path = "/"
      port = "traffic-port"
    }
}

resource "aws_lb_target_group_attachment" "attach1" {
    target_group_arn = aws_lb_target_group.alb-target.arn
    target_id = aws_instance.instance-1.id
    port = "80"
}

resource "aws_lb_target_group_attachment" "attach2" {
    target_group_arn = aws_lb_target_group.alb-target.arn
    target_id = aws_instance.instance-2.id
    port = "80"
}

resource "aws_lb_listener" "my-listner" {
    load_balancer_arn = aws_alb.my-alb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
      target_group_arn = aws_lb_target_group.alb-target.arn
      type = "forward"
    }
}

output "loadbalancerdns" {
    value = aws_alb.my-alb.dns_name
}