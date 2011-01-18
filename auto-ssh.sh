#!/bin/bash
# Create an SSH keypair with for connecting from one CCIS machine to another.
# The passphrase is empty, and the public key will be authorized for you.

KEY_FNAME="id_CCIS_auto"
COMMENT="`whoami`@CCIS/auto"

set -o errexit
set -o nounset

ssh-keygen -q -N "" -f ~/.ssh/$KEY_FNAME -t rsa -b 4096 -C "$COMMENT"
cat ~/.ssh/$KEY_FNAME.pub >> ~/.ssh/authorized_keys

echo "Finished. You can now do ssh between CCIS machines without interaction."

