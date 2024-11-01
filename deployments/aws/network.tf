data "aws_availability_zones" "default" {
  # Filter out Local Zones. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones#by-filter
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_vpc" "workshop" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "workshop"
  }
}

resource "aws_subnet" "workshop" {
  count                   = 3
  vpc_id                  = aws_vpc.workshop.id
  cidr_block              = cidrsubnet(aws_vpc.workshop.cidr_block, 4, count.index)
  availability_zone       = data.aws_availability_zones.default.names[count.index]
  map_public_ip_on_launch = true // Ugh
  tags = {
    Name = "workshop-${count.index}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.workshop.id
}

resource "aws_route_table" "workshop" {
  vpc_id = aws_vpc.workshop.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "workshop"
  }
}

resource "aws_route_table_association" "workshop" {
  count          = length(aws_subnet.workshop)
  subnet_id      = aws_subnet.workshop[count.index].id
  route_table_id = aws_route_table.workshop.id
}
