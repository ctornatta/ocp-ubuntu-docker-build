FROM docker.io/ubuntu:16.04

USER 185
CMD sh -c 'while true; do cat /etc/lsb-release;sleep 5; done'
