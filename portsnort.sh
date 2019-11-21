#!/bin/bash

#masscan options, set defaults
rate="5000"    #packets/second
interface="tun0" #applies to both nmap and masscan 
target_ip=""     #applies to both nmap and masscan
ports="1-65535"  #initial ports for masscan to scan
port_state="--open-only"

#nmap options, set defaults
opt="-A -sV"



#running checks
if ! [ -x "$(command -v masscan)" ]; then
  echo 'Error: Masscan is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v nmap)" ]; then
  echo 'Error: Nmap is not installed.' >&2
  exit 1
fi

if [ "$EUID" -ne 0 ]; then
  echo 'Error: Please run as root'
  exit 1
fi

#getting options, r=rate i=interface t=target_ip n=nmap arguments h=help
while getopts 'r:i:t:n:h' option; do
  case "$option" in
    r)rate=${OPTARG};;
	p)ports=${OPTARG};;
    i)interface=${OPTARG};;
    t)target_ip=${OPTARG};;
    n)opt=${OPTARG};;
    h) usage; exit 0;;
  esac
done


if ! [ -z "$target_ip" ]; then 
  masscan --rate "$rate" -p "$ports" --adapter "$interface" "$target_ip" "$port_state" > masscan.txt
  wait
  nmap_scan_ports=$(awk '{print $4}' masscan.txt | grep -o '[0-9]\+' | awk '{print}' ORS=',')
    if ! [ -z "$nmap_scan_ports" ]; then
      nmap -A -sV -p "${nmap_scan_ports::-1}" "$target_ip" > initial_scan	
    else
      echo "no open tcp ports, aborting scan"
      exit 1
    fi
else
  echo "no target specified"
  exit 1
fi
