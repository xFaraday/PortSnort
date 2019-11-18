#!/bin/bash

#masscan options, set defaults
rate="100000"    #packets/second
interface="tun0" #applies to both nmap and masscan 
target_ip=""     #applies to both nmap and masscan
ports="0-65535"
port_state="--open-only"


#nmap options, set defaults
opt="-A -sV"



