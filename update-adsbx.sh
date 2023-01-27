#!/bin/bash
set -e

TIME=`date +"%Y-%m-%dT%H%M%S"`

## All the config files we might need to change
declare -a ALL_CONFIG_FILES=("/etc/default/adsbexchange" "/boot/adsbx-env" "/usr/local/bin/adsbexchange-feed.sh")

## now loop through the config files
for CONFIG_FILE in "${ALL_CONFIG_FILES[@]}"
do
  if test -f "$CONFIG_FILE"; then
    echo "$CONFIG_FILE exists."

    BACKUP_FILE="$CONFIG_FILE.bak.$TIME" 

    #Make a backup of the existing config
    echo "  Copying to backup file $BACKUP_FILE";
    cp $CONFIG_FILE $BACKUP_FILE
 
    #Replace references to feeder domains
    echo "  Updating config file"
    sudo sed -i 's/feed.adsbexchange.com/feed.adsb.fi/g' $CONFIG_FILE
  fi
done

echo ""
echo "Restarting feeder service"
sudo systemctl restart adsbexchange-feed
sudo systemctl restart adsbexchange-mlat
echo "Disabling stats service"
sudo systemctl disable --now adsbexchange-stats

echo "Waiting 10 seconds..."
sleep 10
echo "Checking connectivity. You should see two lines below"
netstat -t -n | grep -E '30004|31090'
