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
#   https://linuxconfig.org/configuring-gmail-as-sendmail-email-relay
#   It is already presumed you have a properly configured
#   GMail user name and Gmail application-dedicated
#   password.

# Ensuring an update before progressing further.
apt-get -qq update

# These are the required packages
apt-get --yes --force-yes install sendmail mailutils sendmail-bin 

# Create the Gmail configuration directory
mkdir -m 700 /etc/mail/authinfo

# Get both the user and password information to store
echo ""
read -p "Enter your Gmail Email address: " gmailaddress
echo ""
read -sp "Enter your Application Password: " gmailpasswd
echo ""

# Write the relevant data to gmail-auth as a hash map
echo "Authinfo: \"U:root\" \"I:$gmailaddress\" \"P:$gmailpasswd\"" > /etc/mail/authinfo/gmail-auth

# The command actually writes gmail-auth.db, so we are not overwriting it
makemap hash /etc/mail/authinfo/gmail-auth < /etc/mail/authinfo/gmail-auth

# Now I have lines to insert into /etc/mail/sendmail.rc, but
#  at the moment I'm not comfortable I can test the block is in there
#  and THEN insert it if it is not. I will name it gmail.df.
#
# My primary goal is "get this working," in the process learn scripting
#   better, and THEN update this script to perform the task without
#   direct intervention. So for the moment...
#
echo "Be sure to insert the file, \"gmail.def\" into /etc/mail/sendmail.mc,"
echo "  but only once and as shown in the example web page at"
echo "  https://linuxconfig.org/configuring-gmail-as-sendmail-email-relay"
echo ""
echo "As these scripts develop, a future update will handle this on your"
echo "  behalf so you won't have to. --Romaq"

# The following steps have to be performed manually until as mentioned
#   above, gmail.def can be safely inserted into the sendmail.mc file.
#
# Rebuild the sendmail configuration
# make -C /etc/mail
#
# Reload the Sendmail service
# systemctl status sendmail
# 
# Do a configuation test and verify this script has worked correctly.
# echo "Sendmail relay through gmail test." | mail -s "Sendmail gmail Relay" $gmailaddress

#
# EOF
