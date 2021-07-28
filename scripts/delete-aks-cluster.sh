#!/bin/bash

echo "Azure Group List"
az group list |  jq '.[].name'
echo "Is there any Resource Groupe to delete ?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
          echo "Enter Azure Group name to be deleted: "
          read AKS_RESOURCE_GROUP
          echo "The Azure Group $AKS_RESOURCE_GROUP will be deleted."
          echo
          echo "Do you wish to delete the Azure Group $AKS_RESOURCE_GROUP ?"
          select yn in "Yes" "No"; do
              case $yn in
                  Yes )az group delete --name $AKS_RESOURCE_GROUP; break;;
                  No ) exit;;
              esac
          done; break;;
        No ) exit;;
    esac
done

