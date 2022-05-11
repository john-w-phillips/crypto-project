# CSCI 474/574 course project
## Proposal

To build the proposal, go to the `proposal` directory and type
`make`. This will create `proposal.pdf` from the `proposal.tex` file.

## Code

The `openssl` repository has (currently) two modified branches:
`debian-mod-point` -- the point where debian modified the code and
caused the vulnerability. This code is the same as the code that
debian began distributing in 2006. I (John) couldn't find the original code
anywhere so I read the mailing list and implemented the change.

The other branch, `hacked-ssl-for-running-exploit` contains SSL code
that has been modified in the same way, _plus_ a way for a developer
to set the PID that is normally mixed into the entropy message digest
in openSSL. This allows you to run an exploit by repeatedly trying
different PID 'seeds'.

The `openssh-portable` repository has a branch `old-ssh` which
contains code from that era modified to run the exploit by repeatedly
trying out different keys. There are two key programs:
`ssh-keyexploit.c` and `ssh-exploit-driver.bash`. `ssh-keyexploit.c`
generates a trial key based on its command line arguments and tries to
SSH into the host provided, exiting with success if it worked, failure
if not. `ssh-exploit-driver.bash` iterates over all 32768 possible
keys and runs `ssh-keyexploit.c` for each one.

### Building openssl

The process for building either branch of openssl is the same:

```sh
$ ./config shared
$ make install # should be done as root
```

This will install SSL in `/usr/local/ssl`. For whatever reason, SSL
has a nonstandard practice of putting their libraries into an `ssl`
subdirectory, rather than `/usr/local/lib`, `/usr/local/include`. In
order to run programs against these libraries you will need to
configure `LD_LIBRARY_PATH` accordingly.


### Building openssh-portable

This only needs to be done on the exploiter side if you are using a
2008-vintage debian VM. Otherwise you will have to do it for both
machines.

```sh
$ autoreconf
$ CFLAGS="-I/usr/local/ssl/include -L/usr/local/ssl/lib" ./configure --with-ssl-dir=/usr/local/ssl/
$ make -j
```


## Running the exploit
To demonstrate the exploit, we have two VMs, DebianExploiter and
DebianExploited. On the exploited machine (DebianExploited) is the
code to generate a new SSH key using the code base that was present in
Debian from 2006-2008. It generates the SSH key using the flawed
random byte-generating code, along with a script, `generate-key.sh`
which is simply an automation of what any debian user would do to
generate a key and add it to their list of keys allowed to SSH into
the host.
	
### Using the virtual machines

There are two VM images, `DebianExploited.vmdk` and
`DebianExploiter.vmdk`. To reduce the fuss associated with setting up
a VM network, we've included a script `run-vms.sh` in the `vms/`
folder. Due to size limitations of github, the vm images themselves
are not there but can be obtained from the ADIT lab (i.e. brown lab)
in the directory `~johphill/cryptography-project`. *This script
requires root/sudo priviledges.* This is required to set up networking
so that the machines can share an isolated network.

The virtual machines both have users called `ssluser`, with password
`P@$$` (note P is capitalized).

 On the exploited machine, there is a modified version of the
`openssh-portable` code (OpenSSH) that generates candidate keys based
on different PID seeds and tries to SSH into the exploited machine.

On DebianExploited:

	export LD_LIBRARY_PATH=/usr/local/ssl/lib:/usr/local/lib:/usr/lib:/lib
	./generate-keys.sh
	
The `export LD_LIBRARY_PATH` is necessary to link against the 'hacked'
version of SSL, which we installed in the [building
section](#building-openssl).

On DebianExploiter:
	
	cd openssh-portable
	export LD_LIBRARY_PATH=/usr/local/ssl/lib:/usr/local/lib:/usr/lib:/lib	
	./ssh-exploit-driver.bash <IP-OF-DEBIAN-EXPLOITED>

Eventually, you'll get the message:

	Success with PID seed <some-pid>, file in trail_identity, trial_identity.pub
	
This means the script successfully SSHed to the victim machine by
guessing the private key, which has been put into
`trial_identity`. You can then SSH in with a normal SSH command:

	./ssh -i trial_identity -l ssluser <IP-OF-DEBIAN-EXPLOITED>

Note that *both* machines use modified versions of the SSL library and
that you must ensure that the modified versions are being linked
against. You can use `ldd` to verify this.
