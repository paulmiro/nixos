# how to set up protonmail-bridge

```sh
systemctl --user stop protonmail-bridge.service
nix-shell -p protonmail-bridge
protonmail-bridge --cli
>>> login
>>> info # to get the password
>>> exit
systemctl --user start protonmail-bridge.service
```