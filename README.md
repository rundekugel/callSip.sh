callSip.sh
==========

call a voip phone 
this simple batch script uses sip via netcat, to let a voip phone ring

 usage:
callSip.sh [-v N|-p Port|-d Sec.|-s Via-server] sip-user-address 
option (default) , desc.
 -c (555@nowhere) , caller sip-address or phone number
 -d (5) , duration(sec.)
 -l (na) , own ip or URI
 -p (5060) , port
 -s (from address) , via-server ip or URI
 -u (), , use UDP instead of TCP
 -v (0) , verboselevel 0..4 

example:
 src/callSip.sh -d3 alice@home.net
   #starts a sip call to alice and hangs up after 3 sec.
 

if your system has python, I recommend https://github.com/rundekugel/callsip.py

by lifesim.de
