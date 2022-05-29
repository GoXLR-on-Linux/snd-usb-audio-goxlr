# GoXLR DKMS Module

Between kernels 5.11 and 5.19rc1 there has been a bug in the Linux Kernel which prevents the GoXLR from functioning correclty under pipewire based systems. While this bug has
been fixed, it will take time (potentially years in some LTS releases) for this fix to make it into various Linux distributions.

This DKMS module is designed to attempt to patch the fix into any 5.15 - 5.19 kernel, by downloading the kernel sources, patching the USB Audio driver, and installing it.

*WARNING*: Here be dragons.  
While DKMS is pretty common and standardised, this fix has currently only been tested on Manjaro, there's no reason why this wont work on other distributions, however, YMMV. If your
distribution uses out-of-band patches on the snd-usb-audio kernel driver, these will be removed by this DKMS module.

Use of this code is 'at your own risk', the GoXLR on Linux team accept no responsibility (either implied or otherwise) for any problems this may cause.

## Requirements
* dkms
* Linux Kernel Headers
* Alsa UCM (>=1.2.6)

Fetching these will be different depending on your distribution, please consult your distributions guides for instructions.

## Installation

Simply run the following:

```
git clone https://github.com/GoXLR-on-Linux/snd-usb-audio-goxlr.git
sudo mv snd-usb-audio-goxlr /usr/src/
sudo dkms install snd-usb-audio/goxlr
```
Then reboot your machine.

## Maintenance
Your distribution should automatically rebuild the module with kernel updates, however if this turns out not to be the case (and you no longer see the GoXLR on reboot), simply run:

`sudo dkms install snd-usb-audio/goxlr`

To reinstall the module under your new kernel, and reboot.

## Removal
To remove the module from all kernel versions, and restore the original snd-usb-audio module, run the following:

```
sudo dkms remove --all snd-usb-audio/goxlr
sudo rm -rf /usr/src/snd-usb-audio-goxlr
sudo rm /usr/src/goxlr-dkms*.tar.xz
```

Then reboot to fully restore the original module.


## Help
If you need help, feel free to open an issue here, and we'll do what we can, or catch us on [Discord](https://discord.gg/Wbp3UxkX2j) and we'll try to help!

### What about Pulse Audio?
While this fix does technically work for Pulse Audio, and remove the need to use the GoXLR on Linux script, in my testing I was experiencing 300ms of audio latency. Due to this solution
requiring a kernel patch, until it's formally introduced in 5.19rc1 solving the pulseaudio latency will likely need to wait until then.