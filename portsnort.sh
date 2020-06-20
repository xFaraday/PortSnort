#!/bin/bash

#masscan options, set defaults
rate="5000"    #packets/second
interface="tun0" #applies to both nmap and masscan 
target_ip=""     #applies to both nmap and masscan
ports="1-65535"  #initial ports for masscan to scan
port_state="--open-only"

#nmap options, set defaults
opt="-A"



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

usage() {
printf -- "-r = masscan scan rate. \n"
printf -- "-p = port range to scan.  Default is 1-65535\n"
printf -- "-i = Network interface to scan from\n"
printf -- "-t = target ip to scan.  Currently only supports 1 IP at a time\n"
printf -- "-n = nmap options, Default is -A\n"
printf -- "-h = help\n"
}

if ! [ -z "$target_ip" ]; then 
  masscan --rate "$rate" -p "$ports" --adapter "$interface" "$target_ip" "$port_state" > masscan.txt
  wait
  nmap_scan_ports=$(sed 's/[ \t]*\([0-9]\{1,\}\).*/\1/' masscan.txt | cut -c 21- | awk '{print}' ORS=',')
    if ! [ -z "$nmap_scan_ports" ]; then
      nmap -A -p "${nmap_scan_ports::-1}" "$target_ip" > initial_scan	
    else
      echo "no open tcp ports, aborting scan"
      exit 1
    fi
else
  printf "\n No target IP specified.  Refer to usage.\n\n"
  usage
  exit 1
fi
