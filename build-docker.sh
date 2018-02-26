#!/bin/bash
set -e
exec docker build --force-rm -t phusion/netdata-ubuntu-16.04-builder:latest docker-env
