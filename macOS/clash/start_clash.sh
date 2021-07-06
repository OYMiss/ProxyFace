#!/bin/sh

#  start_clash.sh
#  ProxyFace
#
#  Created by oymiss on 3/7/2021.
#

chmod 644 "$HOME/Library/LaunchAgents/io.github.oymiss.ProxyFace.clash.plist"
launchctl load -wF "$HOME/Library/LaunchAgents/io.github.oymiss.ProxyFace.clash.plist"
launchctl start io.github.oymiss.ProxyFace.clash
