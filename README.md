# 🛑 This repo is no longer maintained 🛑
# 🛑 Use [nuxeo-sandbox/presales-vmdemo](https://github.com/nuxeo-sandbox/presales-vmdemo) instead 🛑

# Description
AWS resources used by the Nuxeo Presales Team.
These are provided for inspiration and we encourage developers to use them as code samples and learning resources.

The master branch currently deploys a Nuxeo LTS 2023 stack. To deploy a Nuxeo LTS 2021 stack, please use the [lts2021](https://github.com/nuxeo/presales-vmdemo/tree/lts2021) branch 

# Content
## AMI
This repository contains a [packer.io](https://www.packer.io/) [template](https://github.com/nuxeo/presales-vmdemo/tree/master/AMI-builder) to automate the creation of AMI images with all the required OS packages pre-installed
See the  [README](https://github.com/nuxeo/presales-vmdemo/tree/master/AMI-builder) to get more details about how to use it

## Cloud formation templates
This repository contains one [template](https://github.com/nuxeo/presales-vmdemo/blob/master/AWS-CF-templates/Nuxeo.template) to provision a Nuxeo demo stack, and one [template](https://github.com/nuxeo/presales-vmdemo/blob/master/AWS-CF-templates/NEV.template) to provision a NEV stack
These templates use the AMI mentioned above. 

## EC2 install scripts
Install scripts are used when a new EC2 instance is launched using the CF template and set up the instance using resources from:
- https://github.com/nuxeo-sandbox/nuxeo-presales-docker for Nuxeo
- https://github.com/nuxeo-sandbox/nuxeo-presales-nev for NEV

## Lambda functions
Lambda functions are used to automate shutdown of instances and updating route 53 records when instances are started or stopped.
See the [README](https://github.com/nuxeo/presales-vmdemo/tree/master/Lambda) for details about each functions.

# About Nuxeo
[Nuxeo](www.nuxeo.com), developer of the leading Content Services Platform, is reinventing enterprise content management (ECM) and digital asset management (DAM). Nuxeo is fundamentally changing how people work with data and content to realize new value from digital information. Its cloud-native platform has been deployed by large enterprises, mid-sized businesses and government agencies worldwide. Customers like Verizon, Electronic Arts, ABN Amro, and the Department of Defense have used Nuxeo's technology to transform the way they do business. Founded in 2008, the company is based in New York with offices across the United States, Europe, and Asia.

Learn more at www.nuxeo.com.
