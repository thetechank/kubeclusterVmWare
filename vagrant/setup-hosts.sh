#!/bin/bash
#
# Set up /etc/hosts so we can resolve all the machines in the VirtualBox network
set -e
NUM_MASTERS=$1
NUM_WORKERS=$2
NUM_LBS=$3
IFNAME=$4
NETWORKADDR=$5
MASTERIPSTART=$6
WORKERIPSTART=$7
LBIPSTART=$8

echo "Updating Hosts"

echo ${NUM_MASTERS}
echo ${NUM_WORKERS}
echo ${IFNAME}
echo ${NETWORKADDR}
echo ${MASTERIPSTART}
echo ${WORKERIPSTART}
echo ${LBIPSTART}


#ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
ADDRESS="$(ip -4 addr show | grep "${NETWORKADDR}" | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
NETWORK=$(echo $ADDRESS | awk 'BEGIN {FS="."} ; { printf("%s.%s.%s", $1, $2, $3) }')
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-jammy entry
sed -e '/^.*ubuntu-jammy.*/d' -i /etc/hosts
sed -e "/^.*$2.*/d" -i /etc/hosts

for (( i=1; i <= $NUM_MASTERS; i++ ))
do
  echo "${NETWORKADDR}.$((MASTERIPSTART+$i))  master-$i" >>/etc/hosts
done

for (( i=1; i <= $NUM_WORKERS; i++ ))
do
  echo "${NETWORKADDR}.$((WORKERIPSTART+$i))  worker-$i" >>/etc/hosts
done

for (( i=1; i <= $NUM_LBS; i++ ))
do
  echo "${NETWORKADDR}.$((LBIPSTART+$i))  lb-$i" >>/etc/hosts
done
