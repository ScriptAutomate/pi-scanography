# pi-scanography
Simple script(s) for using USB-powered scanners with the Raspberry Pi. This was created after reading [this cool article](https://blog.nextthing.co/a-scanner-pocketc-h-i-p/) about someone using a pocketCHIP with `scanimage`. The article has a broken-link to the GitHub repo, but you can find [their code/tutorial here](https://github.com/goatspit/pocketCHIP-photography).

## More In-Depth Tutorial for This Project
A more in-depth tutorial of what I did to go mobile with a Raspberry Pi 3, for scanography, [can be found here](https://www.cspenzichwrite.com/scanography/).

## Basic Directions

Want to just get up and running? Here we go!

### Install SANE

When using Raspbian Stretch as an OS, `scanimage` is not included by default. Let's get it.

```
# Update and Install SANE
# SANE: Scanner Access Now Easy
sudo apt install sane
```

### Basic Scanography Run

Clone the repo and make the script executable:
```
git clone https://github.com/ScriptAutomate/pi-scanography.git
chmod +x pi-scanography/scanography.sh
```

Execute the script:
```
~/pi-scanography/scanography.sh
```

This will do the following:
* Create a `scans` directory in the `pi-scanography` directory, if there isn't one already. This is where scans are output.
* Create a configuration file in the `scans` directory for a connected scanner, if there isn't already a configuration file present. This will be named after the type of scanner, as the device name (ex. `genesys:libusb:001:005`) can change each time it is connected to the Pi, but the device type does not (ex. `Canon LiDE 110 flatbed scanner`). An example configuration file in this case would be `~/pi-scanography/scans/.Canon-LiDE-110-flatbed-scanner`
* Run a scan with the output file placed in the `scans` directory, with a naming convention of `scan$NUMBER.jpeg` -- ex. `scan4.jpeg`

From the terminal, one can view a generated image with `gpicview scans/scan4.jpeg`