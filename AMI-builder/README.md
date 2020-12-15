## Description

[packer.io](https://www.packer.io/) template to automate the creation of AMI images with all the required packages pre-installed

## How to build

- [install packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install)
- for nuxeo team members, use okta-aws to set/refresh the AWS credentials on your computer

```
git clone https://github.com/nuxeo/presales-vmdemo
cd AMI-builder
packer build template.json
```

- update `AWS-templates/NuxeoNoEIP-v2.template` with the new AMI ID for each region

## About Nuxeo
[Nuxeo](www.nuxeo.com), developer of the leading Content Services Platform, is reinventing enterprise content management (ECM) and digital asset management (DAM). Nuxeo is fundamentally changing how people work with data and content to realize new value from digital information. Its cloud-native platform has been deployed by large enterprises, mid-sized businesses and government agencies worldwide. Customers like Verizon, Electronic Arts, ABN Amro, and the Department of Defense have used Nuxeo's technology to transform the way they do business. Founded in 2008, the company is based in New York with offices across the United States, Europe, and Asia.

Learn more at www.nuxeo.com.
