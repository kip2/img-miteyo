from diagrams import Cluster, Diagram
from diagrams.aws.network import InternetGateway, NATGateway, RouteTable
from diagrams.aws.network import PublicSubnet, PrivateSubnet

with Diagram("Kore-Miteyo VPC Architecture", show=True, direction="LR"):
    with Cluster("VPC 10.0.0.0/16"):
        igw = InternetGateway("IGW")
        rt_public = RouteTable("Public RT")
        rt_private = RouteTable("Private RT")

        with Cluster("AZ 1a"):
            ingress_1a = PublicSubnet("Ingress-1a\n10.0.0.0/24")
            nat_1a = NATGateway("NAT-1a")
            container_1a = PrivateSubnet("Container-1a\n10.0.8.0/24")
            db_1a = PrivateSubnet("DB-1a\n10.0.16.0/24")

            rt_public >> ingress_1a
            container_1a >> rt_private
            db_1a >> rt_private
            ingress_1a >> nat_1a
            nat_1a >> container_1a
            nat_1a >> db_1a

        with Cluster("AZ 1c"):
            ingress_1c = PublicSubnet("Ingress-1c\n10.0.1.0/24")
            nat_1c = NATGateway("NAT-1c")
            container_1c = PrivateSubnet("Container-1c\n10.0.9.0/24")
            db_1c = PrivateSubnet("DB-1c\n10.0.17.0/24")

            ingress_1c >> nat_1c
            nat_1c >> container_1c
            nat_1c >> db_1c

        igw >> ingress_1a
        igw >> ingress_1c
