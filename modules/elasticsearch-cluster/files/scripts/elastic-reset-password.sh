#!/bin/bash
#
yes | /usr/share/elasticsearch/bin/elasticsearch-reset-password -a -u elastic > elastic-reset-password.out
grep "New value" elastic-reset-password.out | sed "s/New value: //" > /tmp/ELASTIC_PASSWORD
