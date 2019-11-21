# PortSnort
> Asynchronous Scan -> Synchronous Scan -> Fast and accurate enumeration | xfaraday

## Usage
*Make sure to have masscan and nmap installed*
Example:
```sh
./portsnort.sh -t <ip-address> -r 5000
```
Explanation:
Scans the <ip-address> with masscan at 5000 packets/second with the port range of 1-65535.  Masscan creates a file with the open ports on the computer and then passes the open port list to nmap to aggresively scan the services in detail.
 
This process saves a lot of time because nmap's synchronous scan on all ports is avoided by using a faster asynchronous alternative that can still allow for good accuracy via nmap's aggresive scan on found ports.

Pass from an Asynchronous scanner to nmap for those of us who need to go sonic fast
