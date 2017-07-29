#!/usr/bin/env bash
/usr/bin/supervisord --nodaemon
/usr/sbin/apache2ctl -D FOREGROUND