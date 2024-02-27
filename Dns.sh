#!/bin/bash

clear

function endscript() {
  exit 1
}

trap endscript 2 15

echo -e "\e[1;37mEnter DNS IPs separated by ' ': \e[0m"
read -a DNS_IPS

echo -e "\e[1;37mEnter Your NameServers separated by ' ': \e[0m"
read -a NAME_SERVERS

LOOP_DELAY=4
echo -e "\e[1;37mCurrent loop delay is \e[1;33m${LOOP_DELAY}\e[1;37m seconds.\e[0m"
echo -e "\e[1;37mWould you like to change the loop delay? \e[1;36m[y/n]:\e[0m "
read -r change_delay

if [[ "$change_delay" == "y" ]]; then
  echo -e "\e[1;37mEnter custom loop delay in seconds \e[1;33m(5-15):\e[0m "
  read -r custom_delay
  if [[ "$custom_delay" =~ ^[5-9]$|^1[0-5]$ ]]; then
    LOOP_DELAY=$custom_delay
  else
    echo -e "\e[1;31mInvalid input. Using default loop delay of ${LOOP_DELAY} seconds.\e[0m"
  fi
fi

DIG_EXEC="DEFAULT"
CUSTOM_DIG=/data/data/com.termux/files/home/go/bin/fastdig
VER=0.3

case "${DIG_EXEC}" in
  DEFAULT|D)
    _DIG="$(command -v dig)"
    ;;
  CUSTOM|C)
    _DIG="${CUSTOM_DIG}"
    ;;
esac

if [ ! $(command -v ${_DIG}) ]; then
  printf "%b" "Dig command failed to run, please install dig(dnsutils) or check the DIG_EXEC & CUSTOM_DIG variable.\n" && exit 1
fi

# Initialize the counter
count=1

check_dns() {
  local DNS_IP="$1"
  local NAME_SERVER="$2"
  local result=$(${_DIG} "@${DNS_IP}" "${NAME_SERVER}" +short)
  if [ -z "$result" ]; then
    echo -e "DNS IP: ${DNS_IP} | NameServer: ${NAME_SERVER} | Status: \e[91mFailed\e[0m"
  else
    echo -e "DNS IP: ${DNS_IP} | NameServer: ${NAME_SERVER} | Status: \e[92mSuccess\e[0m"
  fi
}

countdown() {
    for i in {3..1}; do
        echo "Checking will start in $i seconds..."
        sleep 1
    done
}

countdown
clear

# Main loop
while true; do
  for DNS_IP in "${DNS_IPS[@]}"; do
    for NAME_SERVER in "${NAME_SERVERS[@]}"; do
      check_dns "$DNS_IP" "$NAME_SERVER" &
    done
  done
  wait # Wait for all background processes to finish
  ((count++))  # Increment the counter
  sleep $LOOP_DELAY
done

exit 0
