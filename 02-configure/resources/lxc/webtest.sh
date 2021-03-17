#!/bin/bash
# Generate web requests from random ips
function randip {
  dd if=/dev/urandom bs=4 count=1 2>/dev/null | od -An -tu1 | sed -e 's/^ *//' -e 's/  */./g'
}
for n in `seq 1 60`;
do
  siege --header "X-Forwarded-For: $(randip)" -q -c1 -r1 --no-parser -i -f /etc/urls.txt
done
