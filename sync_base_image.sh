#!/bin/bash
base_image_list="
rhel8/httpd-24:1-120
ubi8/nginx-118:1-15
ubi8/openjdk-8:1.3-7
ubi8/openjdk-11:1.3-8
ubi8/dotnet-31-runtime:3.1-21.20201210070605
ubi8/dotnet-50-runtime:5.0-4.20201210070352
ubi8/python-27:2.7-121
ubi8/python-36:1-123
ubi8/python-38:1-43
ubi8/ruby-25:1-129
ubi8/ruby-26:1-71
ubi8/ruby-27:1-14
ubi8/nodejs-10:1-116
ubi8/nodejs-12:1-66
ubi8/nodejs-14:1-17
ubi8/ubi:8.3-227
ubi8/ubi-minimal:8.3-230
ubi8/ubi-init:8.3-17
"
redhat_registry=registry.redhat.io
private_registry=default-route-openshift-image-registry.apps.$1
for item in $base_image_list; do
    # echo $redhat_registry/$item
    podman pull $redhat_registry/$item 
    image_name=$(echo $item|cut -f2 -d '/')
    podman tag $redhat_registry/$item $redhat_registry/$item $private_registry/openshift/$image_name
    podman push $private_registry/openshift/$image_name --tls-verify=false
    echo "Tagged and pushed $private_registry/openshift/$image_name"
    only_image_name=$(echo $image_name |cut -f1 -d ':')
    podman tag $redhat_registry/$item $private_registry/openshift/$only_image_name:latest
    podman push $private_registry/openshift/$only_image_name:latest --tls-verify=false
    echo "Tagged and pushed $private_registry/openshift/$only_image_name:latest"
    #  label and annotate
    oc label is --overwrite $only_image_name source="$redhat_registry"
    oc annotate is --overwrite $only_image_name from="$redhat_registry/$item"
done

