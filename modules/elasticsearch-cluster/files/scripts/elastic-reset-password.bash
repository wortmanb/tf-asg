#!/bin/bash
set -euo pipefail
umask 077

yes | /usr/share/elasticsearch/bin/elasticsearch-reset-password -a -u elastic > elastic-reset-password.out
grep "New value" elastic-reset-password.out | sed "s/New value: //" > /tmp/ELASTIC_PASSWORD
chmod 600 /tmp/ELASTIC_PASSWORD
