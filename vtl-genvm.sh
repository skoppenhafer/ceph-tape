#!/bin/bash
project="ENTER PROJECT NAME HERE"

gcloud compute \
        --project $project instances create "vtl" \
        --zone "us-central1-f" \
        --machine-type "n1-standard-2" \
        --min-cpu-platform "Automatic" \
        --image "centos-7-v20180129" \
        --image-project "centos-cloud" \
        --boot-disk-size "10" \
        --boot-disk-type "pd-standard" \
        --boot-disk-device-name "boot-disk"

gcloud compute disks create vtl-data --zone us-central1-f --size 10GB

gcloud compute instances attach-disk vtl --disk vtl-data --zone us-central1-f

gcloud compute instances add-metadata vtl --zone us-central1-f --metadata-from-file ssh-keys=/home/steve_koppenhafer/.ssh/gcp-ansible.pub
