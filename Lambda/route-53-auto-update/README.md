## Description

AWS resources to auto update route 53 records when an EC2 instance is restarted/stopped.

# Installation
The installation is not completely automated yet and requires a few manual steps

- Open the AWS console
- Go to the CloudFormation console
- Create a new stack using the template route53-auto-update.template
- Once the stack is created, go to the lambda console
- Open the nuxeo-route53-auto-update function
- Set the runtime to node.js 10x
- Copy paste the content of index.js in the inline editor
- Add an Environment variable HOSTED_ZONE which value is the ID of the target route53 hosted zone (which can be found on the route53 page)
- Save
- Go the CloudWatch console
- open the nuxeo-route53-auto-update rule and enable it

These are provided for inspiration and we encourage developers to use them as code samples and learning resources.

## About Nuxeo
[Nuxeo](www.nuxeo.com), developer of the leading Content Services Platform, is reinventing enterprise content management (ECM) and digital asset management (DAM). Nuxeo is fundamentally changing how people work with data and content to realize new value from digital information. Its cloud-native platform has been deployed by large enterprises, mid-sized businesses and government agencies worldwide. Customers like Verizon, Electronic Arts, ABN Amro, and the Department of Defense have used Nuxeo's technology to transform the way they do business. Founded in 2008, the company is based in New York with offices across the United States, Europe, and Asia.

Learn more at www.nuxeo.com.
