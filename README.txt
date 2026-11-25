1) Short Bio:

Intro: As a AWS DevOps Engineer designing CI/CD pipelines for applications or web applications and providing the infrusructure via AWS IaC.

Skills: AWS (EC2, EKS, ECS, Lambda, IAM, VPC, CloudWatch, S3), Terraform, CloudFormation, GitHub Actions/CodePipeline, Docker, Linux, Python/Bash.

Experience: Desining CI/CD pipelines via Infra-as-Code(IaC) and combining apps with API integration.

Certifications: AWS Technical Essentials Certificate

2) Projects:

Creating a complete AWS environment infrastructure provisioned entirely with Terraform, 
   1.) Skills Demonstrated: Terraform, AWS, VPC networking, databases, application loadbalancer.
   
3) Architecture:

   aws-terraform-lab/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   ├── rds/
│   └── alb/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       └── terraform.tfvars
└── README.md





 Execution is done on the main.tf files for both dev and prod. The goal is to create a whole AWS environment using Iac terraform that includes VPC networking, Postgres RDS, EC2 instances, S3 buckect for app storage, Security Group with least-privilage rule.

 The whole infrastructure can be cloned/downloaded fro the repo for your own use.
 

   



   
    # AWS-Terraform-Infrastructure-as-Code
