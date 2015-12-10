#!/bin/bash

# This script can be used to create a live weather wallpaper, (using an image from EUMETSAT).
# The image is refreshed only if a user is loged on.  

# Replace storage path and image to your own path and image.
# Add the following three lines to the end of /home/<username>/.profile
#    if [ "$HOME/bin/LiveWallpaper.sh" ] ; then
#        $HOME/bin/LiveWallpaper.sh &
#    fi
# Optional: you can select another image to be downloaded from any web site that permits it.
# Optional: you can select another location to store the downloaded image.

# KILL previous script processes
name=( $( pgrep "LiveWallpaper.sh" ) )
for (( i = 0 ; i < ${#name[@]} - 1 ; i++ )); do
    kill -9 ${name[$i]}
done

#e.g. Browse http://oiswww.eumetsat.org/IPPS/html/latestImages.html and choose an image from there.
GETIMAGE="http://oiswww.eumetsat.org/IPPS/html/latestImages/EUMETSAT_MSG_MPE-easternEurope.jpg"
#GETIMAGE="http://oiswww.eumetsat.org/IPPS/html/latestImages/EUMETSAT_MSG_RGB-12-12-9i-segment17.jpg"
#GETIMAGE="http://oiswww.eumetsat.org/IPPS/html/latestImages/EUMETSAT_MSG_IR108EColor-easternEurope.jpg"
STOREIMAGE="$HOME/Pictures/LiveWallpaper.jpg"
UPDATE="900" # number of seconds between updates (900s = 15min, 3600s=1h, 10800s=3h)

# For GNOME 3. The following gsettings line sets the background image using dconf key.
gsettings set org.gnome.desktop.background picture-uri 'file://'$STOREIMAGE

# For GNOME 2 you can omit the above line and select the background thru user interface.

while [ 1 ]; do
	COUNTER=0
	while [ $COUNTER -lt 3 ]; do 	# if can not get image, retry for (max COUNTER*sleep) seconds (3*60=180sec=3min)
		wget  -O "$STOREIMAGE.tmp" $GETIMAGE
		temp=$(stat -c%s "$STOREIMAGE.tmp")
		if [[ $temp > 1000 ]] 	# if image is greater than 1000 bytes
			then 	rm $STOREIMAGE
				mv "$STOREIMAGE.tmp" $STOREIMAGE
#				echo image is refreshed
				break
		fi
		sleep 60 		# if can not get image, retry after 60 seconds
        	let COUNTER=COUNTER+1 
	done
#	echo now I will sleep for the defined time
	sleep $UPDATE
done

##########################
# NOT GOOD, ALTERNATIVE METHOD
#
# Some web sites suggest gnome-schedule (cron) as an update mechanism. However
# if a computer is used by more than one person, then the update script is executed
# when computer is powered on, even when a user without wallpaper is logged on.
# In this situation, we can stop fetch and changing the wallpaper by an extra
# user check. However the cron job is executed and our logfiles are getting bigger.
# If you want to use this method, copy the next commands in a new file and call
# that file from gnome-schedule. If you are the only user of a computer then you
# can use only the three lines "wget..., sleep..., and DISPLAY..." as bellow.
#
# GETIMAGE="http://oiswww.eumetsat.org/IPPS/html/latestImages/EUMETSAT_MSG_MPE-easternEurope.jpg"
# STOREIMAGE="$HOME/Εικόνες/EUMetSatWallpaper.jpg"#
# USER="yourusername"
# who | grep $USER
# if [ $? = 0 ]
# then
#  wget  -O $STOREIMAGE $GETIMAGE
#  sleep 5
#  DISPLAY=:0 GSETTINGS_BACKEND=dconf gsettings set org.gnome.desktop.background picture-uri file://$STOREIMAGE
# fi
##########################
