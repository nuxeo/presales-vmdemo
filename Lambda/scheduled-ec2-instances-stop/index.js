const AWS = require('aws-sdk');

exports.handler = async(event) => {

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
        //look for nuxeoKeepAlive tag
        let tagIndex = instance.Tags.findIndex(tag => {
          return tag.Key === "nuxeoKeepAlive";
        });
        if (tagIndex == -1) {
          instanceIds.push(instance.InstanceId)
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
