#! /bin/bash
set -e
/bin/bash /vagrant/configs/join.sh -v >/dev/null 2>&1
echo "Executed join.sh to join the $(hostname -s) to cluster"