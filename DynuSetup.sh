#!/bin/bash

# This script must be run as root
#
# Root access is required for updating aptitude packages
#   as well as hard-coding system variables. If your plan
#   is to use an email appliance, do not use this script.
#   Rather, this is an exercise outside of the scope of
#   the BigRig-Scripts project.

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# This script is based upon the following:
#   https://www.dynu.com/DynamicDNS/IPUpdateClient/Linux
#   It is already presumed you have a dynu account.

# Ensuring an update before progressing further.
apt-get -qq update

# These are the required packages
apt-get --yes install ddclient

# EOF
