#!/bin/sh

#  install.sh
#  ProxyFace
#
#  Created by oymiss on 5/7/2021.
#  

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>io.github.oymiss.ProxyFace.clash</string>
    <key>ProgramArguments</key>
    <array>
        <string>$HOME/Library/Application Support/io.github.oymiss.ProxyFace/clash/clash</string>
        <string>-f</string>
        <string>$HOME/Library/Application Support/io.github.oymiss.ProxyFace/clash/config.yaml</string>
    </array>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/clash.log</string>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/clash.log</string>
    <key>WorkingDirectory</key>
    <string>$HOME/Library/Application Support/io.github.oymiss.ProxyFace/</string>
</dict>
</plist>" > "$HOME/Library/LaunchAgents/io.github.oymiss.ProxyFace.clash.plist"

echo "\"tail -f $HOME/Library/Logs/clash.log\" to check clash log"

mkdir -p "$HOME/Library/Application Support/io.github.oymiss.ProxyFace/clash/"
cp "$1/clash" "$HOME/Library/Application Support/io.github.oymiss.ProxyFace/clash/"
cp "$1/config.yaml" "$HOME/Library/Application Support/io.github.oymiss.ProxyFace/clash/"
cp "$1/user_config.yaml" "$HOME/Library/Application Support/io.github.oymiss.ProxyFace/clash/user_config.yaml"
echo "$HOME/.config/clash"
