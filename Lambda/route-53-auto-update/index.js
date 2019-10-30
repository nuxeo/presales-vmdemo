const AWS = require('aws-sdk');

exports.handler = async(event) => {
    console.log('event:', JSON.stringify(event));

    const ec2 = new AWS.EC2();
    const route53 = new AWS.Route53();
    const instanceId = event.detail['instance-id'];

    console.log('fetching instance info :', instanceId);

    return ec2.describeInstances({
        InstanceIds: [
            instanceId
        ]
    }).promise().then(function(data) {

        const instance = data.Reservations[0].Instances[0];
        console.log('Success getting EC2 instance info', JSON.stringify(instance, null, 2));

        let publicDNS = instance.PublicDnsName;
        console.log('Instance public DNS', publicDNS);

        let nuxeoDnsName;

        let dnsTag = instance.Tags.find(function(tag) {
            return tag.Key === "dnsName"
        });

        if (dnsTag) {
            nuxeoDnsName = dnsTag.Value;
        } else {
            nuxeoDnsName = instance.Tags.find(function(tag) {
                return tag.Key === "aws:cloudformation:stack-name"
            }).Value;
        }
        console.log('Nuxeo DNS Name', nuxeoDnsName);

        const instanceState = event.detail['state'];
        let action;

        if (instanceState === "running") {
            action = "UPSERT";
        } else if (instanceState === 'shutting-down' || instanceState === "stopping") {
            action = "DELETE";
        } else {
            throw ("Unsupported instance state");
        }
        //update records
        return route53.changeResourceRecordSets({
            ChangeBatch: {
                Changes: [{
                    Action: action,
                    ResourceRecordSet: {
                        Name: nuxeoDnsName + '.cloud.nuxeo.com.',
                        ResourceRecords: [{
                            Value: publicDNS
                        }],
                        TTL: 300,
                        Type: "CNAME"
                    }
                }, {
                    Action: action,
                    ResourceRecordSet: {
                        Name: 'kibana-' +
                            nuxeoDnsName + '.cloud.nuxeo.com.',
                        ResourceRecords: [{
                            Value: publicDNS
                        }],
                        TTL: 300,
                        Type: "CNAME"
                    }
                }],
                Comment: "Update after instance restart"
            },
            HostedZoneId: process.env.HOSTED_ZONE
        }).promise();

    }).then(function(data) {
        console.log('Success updating route 53 record', JSON.stringify(data, null, 2));
    }).catch(function(err) {
        console.log('failure', err);
    });
};
