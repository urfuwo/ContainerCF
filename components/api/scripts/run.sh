#! /bin/bash

IP_ADDRESS=$(ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1)
sed -i "s/ip:.*/ip: \"${IP_ADDRESS}\"/" /var/vcap/bosh/state.yml
sed -i "s/constant[(]value=\" \([0-9.]\+\)\{4\} \"[)]/constant(value=\" ${IP_ADDRESS} \")/" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "/#only RELP, UDP, and TCP are supported/ r /root/fragments/syslog_drain.frag" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "s/local_route:.*/local_route: ${IP_ADDRESS}/" /var/vcap/jobs/cloud_controller_ng/config/cloud_controller_ng.yml
sed -i "s/failed host \([0-9.]\+\)\{4\}/failed host ${IP_ADDRESS}/" /var/vcap/jobs/cloud_controller_ng/*.monitrc
sed -i "s/^host:.*/host: ${IP_ADDRESS}/" /var/vcap/jobs/route_registrar/config/config.yml
sed -i "s/bind_addr\":\"\([0-9.]\+\)\{4\}\"/bind_addr\":\"${IP_ADDRESS}\"/" /var/vcap/jobs/consul_agent/config/config.json
sed -i '/echo.*resolvconf/d' /var/vcap/jobs/consul_agent/bin/agent_ctl
sed -i 's/sed.*resolv.conf/echo \"DNS handled by Docker\"/' /var/vcap/jobs/consul_agent/bin/agent_ctl

/root/job/start_all.sh
