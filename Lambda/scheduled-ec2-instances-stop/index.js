/*jshint esversion: 6 */
const AWS = require('aws-sdk');

exports.handler = async (event) => {

    const ec2 = new AWS.EC2();
    return ec2.describeInstances({
        Filters: [{
            Name: 'instance-state-name',
            Values: ['running']
        }]
    }).promise().then(data => {

        console.log('Reservations', data.Reservations);

        let instanceIds = [];

        data.Reservations.forEach(reservation => {
            reservation.Instances.forEach(instance => {
                // Look for nuxeoKeepAlive tag
                let tagIndex = instance.Tags.findIndex(tag => {
                    if (tag.Key === "nuxeoKeepAlive") {
                        // If this is a date, check to see if it is in the past
                        // Current date will be "in the past" for the daily check
                        if (/([12]\d{3}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]))/.test(tag.Value)) {
                            let keepAliveDate = new Date(tag.Value);
                            let currentDate = new Date();
                            // If today is less than the keep alive date, return true
                            return currentDate.getTime() < keepAliveDate.getTime();
                        }
                        return tag.Value !== "false";
                    }
                    return false;
                });
                if (tagIndex == -1) {
                    instanceIds.push(instance.InstanceId);
                }
            })
        });

        console.log('Instances to stop', instanceIds);

        return ec2.stopInstances({
            InstanceIds: instanceIds
        }).promise();

    }).then(data => {
        console.log('Success stopping instances', JSON.stringify(data, null, 2));
    }).catch(err => {
        console.log('failure', err);
    });

};