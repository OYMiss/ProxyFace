#!/bin/sh

#  stop_clash.sh
#  ProxyFace
#
#  Created by oymiss on 3/7/2021.
#

launchctl stop io.github.oymiss.ProxyFace.clash
launchctl unload -wF "$HOME/Library/LaunchAgents/io.github.oymiss.ProxyFace.clash.plist"
