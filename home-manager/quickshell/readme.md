# Run

    qs -p ~/nixos-config/home-manager/quickshell/src

Watcher is on by default. `QS_DISABLE_FILE_WATCHER=1` turns the watcher off.

    qs list          # running instances
    qs log           # logs
    qs kill          # stop

# Debug


# Resources

 ```
# icons name
find ~/.local/share/icons/Papirus-Dark/ -name "*"

nix-shell -p pantheon.elementary-iconbrowser
 > io.elementary.iconbrowser
```
