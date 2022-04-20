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


## Running the exploit
To demonstrate the exploit, we have two VMs, DebianExploiter and
DebianExploited. On the exploited machine (DebianExploited) is the
code to generate a new SSH key using the code base that was present in
Debian from 2006-2008. It generates the SSH key using the flawed
random byte-generating code, along with a script, `generate-key.sh`
which is simply an automation of what any debian user would do to
generate a key and add it to their list of keys allowed to SSH into
the host.
	
On the exploited machine, there is a modified version of the
`openssh-portable` code (OpenSSH) that generates candidate keys based
on different PID seeds and tries to SSH into the exploited machine.

On DebianExploited:

	./generate-keys.sh

On DebianExploiter:
	
	cd openssh-portable
	./ssh-exploit-driver.bash <IP-OF-DEBIAN-EXPLOITED>
	
Eventually, you'll get the message:

	Success with PID seed <some-pid>, file in trail_identity, trial_identity.pub
	
This means the script successfully SSHed to the victim machine by
guessing the private key, which has been put into
`trial_identity`. You can then SSH in with a normal SSH command:

	./ssh -i trial_identity -l ssluser <IP-OF-DEBIAN-EXPLOITED>

