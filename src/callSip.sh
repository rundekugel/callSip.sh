#!/bin/sh
#$Id: callSip.sh 424 2014-03-02 11:03:29Z gaul1 $
#2014 initial version - by lifesim.de
#2017 server parsed from sip-adress - by lifesim.de

viaserver=""  #fritz.box
port=5060
caller=555@caller
callId=c$(date +%s)	
localIp=na
duration=5	#sek.
cseq=1
crlf='\r\n'
protocol=TCP
verbose=0


show_help(){
  echo SIP Phone caller. V1.0u$Rev: 424 $ by lifesim.de $crlf
  echo "usage:$crlf $0 [-v N|-p Port|-d Sec.|-s Via-server] sip-user-address"$crlf
  echo "option (default)    , desc."
  echo " -c (555@caller)    , caller sip-address or phone number"
  echo " -d (5)             , duration(sec.)"
  echo " -l (na)            , own ip or URI"
  echo " -p (5060)          , port"
  echo " -s (from address)  , via-server ip or URI"
  echo " -u (),             , use UDP instead of TCP"
  echo " -v (0)             , verboselevel 0..4"
  echo 
  echo "examples:$crlf $0 -d3 alice@home.net"
  echo "   #starts a sip call to alice and hangs up after 3 sec."
  echo $crlf $0 -c+4930555@x alice@home.net"
  echo "   #starts a sip call to alice with callerid 004930555."
}

getServer(){  #param = full sip adress
  sa=$1
  s=$(echo $sa |cut -d@ -f 2)
  echo $s
}

tcpTx(){
  msgt=$1
  #msgt=$msgt"Cseq: $cseq $2"$crlf
  msgt=$msgt$crlf

  if [ "$protocol" = "UDP" ] ; then
    udpOpt="-u"
    #echo u:$udpOpt , $protocol
  fi

  if [ $verbose -gt 3 ] ; then
    echo "nc $udpOpt -w 3 -C $viaserver $port"
  fi
  if [ $verbose -gt 2 ] ; then
    echo tx:'\n'$1
  fi
  #echo -e $1 | nc -w 3 -C $addr $port  
  if [ $verbose -gt 1 ] ; then
    echo $1 | nc $udpOpt -w 3 -C $viaserver $port  
  else
    echo $1 | nc $udpOpt -w 3 -C $viaserver $port  > /dev/null
  fi 

  cseq=$(($cseq+1))
  #let cseq=cseq +1
}

a=$*

if [ -z "$*" ] ; then
  show_help
  exit 1
fi

while getopts "h?uc:d:s:v:l: $*" opt; do
    #echo "$opt = $OPTARG"
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    c)  caller="$OPTARG"
        ;;
    d)  duration=$(($OPTARG))
        ;;
    l)  localIp="$OPTARG"
        ;;
    s)  viaserver="$OPTARG"
        ;;
    u)  protocol=UDP
        ;;
    v) 	verbose=$(($OPTARG))
        ;;
    esac
done

#get last argument
for i
do
 receiver=$i
done

if [ $verbose -gt 0 ] ; then
  echo SIP Phone caller. V0.1-$Rev: 424 $
fi

if [ -z $viaserver  ] ;then
  viaserver=$(getServer $receiver)
fi

if [ $verbose -gt 3 ] ; then
  echo duration=[$duration]
  echo verbose=[$verbose]
  echo via-server=[$viaserver]
  echo receiver=[$receiver]
fi


#
msg=""
#msg=$crlf
msg=$msg"INVITE sip:"$receiver" SIP/2.0"$crlf
msg=$msg"Via: SIP/2.0/$protocol $viaserver"$crlf
msg=$msg"To: sip:"$receiver";tag=x"$crlf
msg=$msg"From: sip:"$caller$crlf
msg=$msg"Call-ID: "$callId$crlf
msg=$msg"Cseq: $cseq INVITE"$crlf
#msg=$msg"Contact: sip:xx@"$localIp$crlf
#msg=$msg$crlf

tcpTx "$msg"
#cseq=$(($cseq+1))
sleep $duration

#
msg=""
#msg=$crlf
msg=$msg"BYE sip:"$receiver" SIP/2.0"$crlf
msg=$msg"Via: SIP/2.0/$protocol $viaserver"$crlf
msg=$msg"To: sip:"$receiver";tag=x"$crlf
msg=$msg"From: sip:"$caller$crlf
msg=$msg"Call-ID: "$callId$crlf
msg=$msg"Cseq: $cseq BYE"$crlf
msg=$msg$crlf
tcpTx "$msg"
sleep .3

if [ $verbose -gt 0 ] ; then
  echo done.
fi
