#!/bin/bash

# AUTHOR:
#   github.com/ScriptAutomate
#   github.com/ScriptAutomate/pi-scanography
# DESCRIPTION:
#   - This is a simple script that creates new scans
#   easily with scanimage, from SANE, using an existing
#   configuration file or by creating a new one
#   - Very basic, takes no arguments
#   - Saves all scans in ~/pi-scanography/scans
#   - Saves basic configuration file: ~/pi-scanography/scans/.scanography
#   - Files are named: scan{number}.jpeg (example: scan4.jpeg)
#   - Naming convention allows new scans to generate
#   without overwriting any existing scan files
# NOTES:
#   Inspired by https://github.com/goatspit/pocketCHIP-photography
#   Even though goatspit initially made the tutorial for
#   PocketCHIP, I wanted to get my Raspberry Pi 3 up and running
#   in order to do the same thing. Mine should be compatible with
#   PocketCHIP and Raspberry Pi (Pi running Raspbian Stretch). 
#   Find more in the README.md

# Is scanimage tool available?
type scanimage &> /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: scanimage not found."
  echo "Please install a package containing 'scanimage'"
  echo "Example:"
  echo "Raspbian: sudo apt-get install sane"
  exit 1
fi

# Is a scans directory present?
SCANDIR="/home/$(whoami)/pi-scanography/scans"
if [ ! -d "$SCANDIR" ]; then
  echo "Making directory: $SCANDIR"
  mkdir "$SCANDIR"
fi

# Is a scanner connected?
echo "Checking for scanning devices..."
SCANNERCHECK=`scanimage -L | grep '^device '`
if [ -n "$SCANNERCHECK" ]; then
  SCANNERDEVICE=$(echo $SCANNERCHECK | sed s/.*\`// | sed s/\'.*//)
  SCANNERTYPE=$(echo $SCANNERCHECK | sed s/.*is\ a\ //)
  echo "Scanner found: $SCANNERDEVICE"
  echo "Scanner type: $SCANNERTYPE"
  # Is there already a configuration file for it?
  SCANCONF="$SCANDIR/.`echo $SCANNERTYPE | sed s/\ /-/g`"
  CONFIGFOUND=`cat "$SCANCONF" | grep "$SCANNERTYPE"`
  if [ -e "$SCANCONF" ]; then
    SCANCONFIGTYPE=`cat "$SCANCONF" | grep ^type | sed s/^type=//`
    if [ "$SCANCONFIGTYPE" == "$SCANNERTYPE" ]; then
      echo "Scanner configuration found for $SCANNERTYPE"
      XDIM=`cat "$SCANCONF" | grep ^xdim | sed s/^xdim=//`
      YDIM=`cat "$SCANCONF" | grep ^ydim | sed s/^ydim=//`
      RESOLUTION=`cat "$SCANCONF" | grep ^resolution | sed s/^resolution=//`
      SCANMODE=`cat "$SCANCONF" | grep ^mode | sed s/^mode=//`
      IMAGETYPE=`cat "$SCANCONF" | grep ^imagetype | sed s/^imagetype=//`
    fi
  else
    echo "No configuration found for $SCANNERTYPE"
    echo "Creating base configuration..."
    echo "Checking dimensions and resolution..."
    HELPFILE=$(scanimage --help -d "$SCANNERDEVICE")
    XDIM=$(echo "$HELPFILE" | grep 'x 0..' | sed s/.*\ 0\.\.// | sed s/\ .*//)
    YDIM=$(echo "$HELPFILE" | grep 'y 0..' | sed s/.*\ 0\.\.// | sed s/\ .*//)
    RESOLUTION=$(echo "$HELPFILE" | grep "\-\-resolution" | cut -d'[' -f2 | sed s/]//)
    SCANMODE="Color" # Use 'Color' in default config; Below line would use default
    #SCANMODE=$(echo "$HELPFILE" | grep "\-\-mode" | cut -d'[' -f2 | sed s/]//)
    IMAGETYPE="jpeg" # Use 'jpeg' in default config
    #IMAGETYPE=$(echo "$HELPFILE" | grep "\-\-format=" | cut -d'|' -f1 | sed s/.*\=//)
    echo "Default Dimensions: $XDIM x $YDIM"
    echo "Default Resolution: $RESOLUTION"
    echo "Default Scan Mode: $SCANMODE"
    echo "Default Image Type: $IMAGETYPE"
    echo "Saving config..."
    echo "type=$SCANNERTYPE" > "$SCANCONF"
    echo "xdim=$XDIM" >> "$SCANCONF"
    echo "ydim=$YDIM" >> "$SCANCONF"
    echo "resolution=$RESOLUTION" >> "$SCANCONF" 
    echo "mode=$SCANMODE" >> "$SCANCONF"
    echo "imagetype=$IMAGETYPE" >> "$SCANCONF"
  fi
else
  echo "ERROR: Scan failed -- check if scanner is connected"
  exit 1
fi

# Scan
LASTNUM=`ls $SCANDIR/scan*.$IMAGETYPE | sed s/.*scan//g | sed s/\.$IMAGETYPE//g | sort -V | tail -1`
NEXTNUM=`expr $LASTNUM + 1`
echo "Generating new scan: scan$NEXTNUM.$IMAGETYPE"
scanimage -p -d "$SCANNERDEVICE" -x $XDIM -y $YDIM --mode $SCANMODE --resolution $RESOLUTION --format $IMAGETYPE > "$SCANDIR/scan$NEXTNUM.$IMAGETYPE"
if [ $? -eq 0 ]; then
  echo "SUCCESS: scan$NEXTNUM.$IMAGETYPE generated"
else
  echo "ERROR: Scan failed"
fi
