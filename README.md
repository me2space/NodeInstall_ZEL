# ZelNodeUpdate v1.0
A simple script to assist with updating ZelNodes to the latest version.

## NOTE: This script is the latest version for MainNet ZelNodes.

**NOTE:** This installation guide is provided as is with no warranties of any kind.

This script has been tested on Ubuntu 18.04.

**PLEASE BE SURE YOU ARE LOGGED IN AS YOUR USERNAME (not root) BEFORE RUNNING THIS SCRIPT**

```
wget -O zelnodeupdate.sh https://raw.githubusercontent.com/zelcash/ZelNodeUpdate/master/zelnodeupdate.sh && chmod +x zelnodeupdate.sh && bash ./zelnodeupdate.sh
```

The script will update your OS, install the new ZelNode binaries, and create a cron job to compress & rotate zel log files
