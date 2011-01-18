#!/bin/bash
# Create an SSH keypair with for connecting from one CCIS machine to another.
# The passphrase is empty, and the public key will be authorized for you.

COMMENT="`whoami`@CCIS/auto"

set -o errexit
set -o nounset

if [ -f ~/.ssh/id_rsa.pub ] ; then
  echo You already have an SSH keypair. Bailing out, you can do this yourself.
  exit 1
fi

ssh-keygen -q -N "" -f ~/.ssh/id_rsa -t rsa -b 4096 -C "$COMMENT"
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

echo Finished. You can now do ssh between CCIS machines without interaction.

