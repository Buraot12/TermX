#!/bin/bash

echo "Enter domain name:"
read domain

echo "Enter DNS server (optional, press Enter for default):"
read dns_server

if [ -z "$dns_server" ]; then
    dns_server=""
else
    dns_server="@${dns_server}"
fi

result=$(termux-telephony ping "${domain}${dns_server}")

echo "DNS query result:"
echo "$result"
