# Lab 3 - Using Auto Scaling

In this lab, you will create a new Amazon Machine Image (AMI) from an existing Amazon Elastic Compute Cloud (Amazon EC2) instance. You will use that AMI as the basis for defining a system that will scale automatically under increasing loads.

## AWS architecture

[AWS architecture](https://drive.google.com/file/d/1PITusPg7J8LdktomP0X7bv0lMrsppOi3/view?usp=sharing)

## Steps

1- Create a New EC2 Instance

- start creat a new instance with the following command:

```bash
aws ec2 run-instances --key-name vockey --instance-type t2.micro --image-id <AmiId> --user-data file:///home/ec2-user/UserData.txt --security-group-ids <HTTPAccess> --subnet-id <SubnetId> --associate-public-ip-address --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=WebServerBaseImage}]' --output text --query 'Instances[*].InstanceId
```

- Use the aws ec2 wait instance-running command to monitor this instance's status.

``` bash
aws ec2 wait instance-running --instance-ids <InstanceId>
```

- Use the aws ec2 wait instance-running command to monitor this instance's status.

``` bash
aws ec2 describe-instances --instance-id <NEW-INSTANCE-ID> --query 'Reservations[0].Instances[0].NetworkInterfaces[0].Association.PublicDnsName
```

2- Create an AMI from the New Instance
```
- Use the aws ec2 create-image AWS CLI

``` bash
aws ec2 create-image --name WebServer --instance-id <NEW-INSTANCE-ID>
```

### 3. Create an Auto Scaling Environment

In this section, you'll create a load balancer that pools a group of EC2 instances under a single DNS address, using Auto Scaling to dynamically adjust the number of EC2 instances based on demand.

#### Create an Application Load Balancer

1. In the AWS Console, go to **EC2 > Load Balancers** and choose **Create Load Balancer**.
2. Under **Application Load Balancer**, select **Create**.
3. Name your load balancer `webserverloadbalancer`.
4. Under **Network mapping**, select the **Lab VPC** and choose **Public Subnet 1** and **Public Subnet 2**.
5. Under **Security groups**, select the `HTTPAccess` security group and remove any others.
6. Under **Listeners and routing**, create a new target group named `webserver-app` with **Instances** as the target type.
7. Adjust **Advanced health check settings**:
   - Health check path: `/index.php`
   - Healthy threshold: `2`
   - Interval: `10` seconds
8. After creating the target group, return to the load balancer configuration and set the **Listener HTTP:80** to forward traffic to `webserver-app`.
9. Finish creating the load balancer.

#### Create a Launch Template

1. In the EC2 console, go to **Launch Templates** and create a new template:
   - Name: `WebServerLaunchTemplate`
   - AMI: Select the `WebServer` AMI created earlier.
   - Instance type: `t2.micro`
   - Security group: `HTTPAccess`
   - Enable **Detailed CloudWatch monitoring**.

#### Create an Auto Scaling Group

1. In the EC2 console, go to **Auto Scaling Groups** and create a new group:
   - Name: `WebServersASGroup`
   - Launch template: `WebServerLaunchTemplate`
   - VPC: Select **Lab VPC**.
   - Subnets: Choose **Private Subnet 1** and **Private Subnet 2**.
   - Attach the group to the load balancer target group `webserver-app`.
   - Enable CloudWatch group metrics collection.
   - Set desired capacity: `2`, minimum capacity: `2`, and maximum capacity: `4`.
   - Create a scaling policy:
     - Policy name: `MyScalingPolicy`
     - Metric type: **Average CPU utilization**
     - Target value: `45`%.

2. Finalize the creation of the Auto Scaling group.

### 4. Verifying Auto Scaling Configuration

1. Verify that two new instances are created and initializing under the Auto Scaling group.
2. Go to **Target Groups** and confirm that the instances in `webserver-app` are healthy.
3. Test the web application by accessing it via the load balancer URL (available under the **Description** tab of the load balancer).
4. On the web application, click **Start Stress** to spike CPU utilization.
5. Monitor the Auto Scaling group in the **Activity** tab to confirm that additional instances are launched in response to the high CPU load.

This confirms that your Auto Scaling group and load balancer are functioning as expected!```