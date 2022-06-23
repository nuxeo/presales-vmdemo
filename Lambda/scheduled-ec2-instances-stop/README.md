## Description

AWS resources to schedule EC2 instances periodic shutdown.

# Installation
The installation is not completely automated yet and requires a few manual steps

- Open the AWS console
- Go to the CloudFormation console
- Create a new stack using the template scheduled-ec2-instances-stop.template
- Once the stack is created, go to the lambda console
- Open the nuxeo-scheduled-ec2-shutdown function
- Set the runtime to node.js 16x
- Copy paste the content of index.js in the inline editor
- Save and deploy
- Go the CloudWatch page and open the Events > Rules
- open the nuxeo-scheduled-ec2-shutdown rule, configure the CRON expression for your timezone and enable it

These are provided for inspiration and we encourage developers to use them as code samples and learning resources.

## About Nuxeo
[Nuxeo](www.nuxeo.com), developer of the leading Content Services Platform, is reinventing enterprise content management (ECM) and digital asset management (DAM). Nuxeo is fundamentally changing how people work with data and content to realize new value from digital information. Its cloud-native platform has been deployed by large enterprises, mid-sized businesses and government agencies worldwide. Customers like Verizon, Electronic Arts, ABN Amro, and the Department of Defense have used Nuxeo's technology to transform the way they do business. Founded in 2008, the company is based in New York with offices across the United States, Europe, and Asia.

Learn more at www.nuxeo.com.
