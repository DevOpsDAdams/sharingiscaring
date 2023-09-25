#!/bin/env bash

instance_id=$1
volume_type='io1'
profile='<<profile_name>>'
IOPS='16000'

for x in $(aws ec2 describe-instances --instance-ids $instance_id --profile $profile --query 'Reservations[*].Instances[*].BlockDeviceMappings[?DeviceName!=`/dev/sda1`].Ebs.VolumeId' --output text); do echo $x; aws ec2 modify-volume --volume-id $x --volume-type $volume_type --iops=$IOPS --profile $profile; done
