# gSwitch

gSwitch lets you set which graphics card your macbook pro can use, mainly to prevent it from using the discrete graphics card when it is simply unnecessary.  Why would you want to do that you ask?  Well the discrete graphics card uses significantly more power than the integrated one, which can ruin your battery life.  There are also problems on some macbooks with glitchy and buggy graphics card drivers that apple still hasn't fixed!

gSwitch is and always will be free.  However, if you want to thank me I will gladly take a donation :)

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=8BYQDVMMGR8EY&item_name=gSwitch+Donations&currency_code=USD&source=url)

## Install

### With Zip

[Download the most recent release](https://codyschrank.github.io/gSwitch/) (click download .zip).

Then after unzipping move the gSwitch.app file to your applications folder.

### With Brew

```bash
brew install gswitch
```

### From Source

```bash
brew update
brew install carthage
```

And then in the project folder bootstrap the frameworks:

```bash
carthage bootstrap
```

And then build in xcode

## Usage

The app is simple to control with _integrated only_, _discrete only_, and _dynamic switching_ in the menu.

You can also enable notifications for when your gpu changes (off by default)

You can also launch it from the terminal and set the desired setting using `--integrated`, `--discrete`, and `--dynamic`.

## FAQ

**Why won't the app start?**

You probably need to allow the application to run in _Settings_ -> _Security & Privacy_

**How do I know which gpu is active?**

The gear will have a dot in the middle when the discrete gpu is active.  Otherwise, it will just look like a gear.  The current gpu is also reported in the menu.

**Why does the app go back to _dynamic switching_ when a display is plugged in?**

Unfortunately your mac is designed such that in order to use an external display, it has to use the discrete graphics card. And since you plugged in the cable I'm assuming you want to use the display.

**What is a dependent process vs a hungry process?**

A dependent process is one that is currently using your discrete gpu. A hungry process is one that wants to use the discrete gpu but is not allowed because you have set _integrated only_. If you change to _dynamic switching_ or _discrete only_ any process that was hungry will become dependent.  You can force _integrated only_ when you have dependent processes but it might crash those processes.  You cannot force _integrated only_ if you have an external display plugged in.  

**How do I disable my discrete GPU?**

You can't, your macbook was designed to use both, but gSwitch can trick it into using the integrated one most of the time.  However gSwitch cannot prevent your discrete gpu from being accessed by the operating system, and it will be accessed for a short period of time when a process requests the use of it.  gSwitch just switches back to the integrated one as fast as it can.

Ok I lied you technically can but I DO NOT RECOMMEND IT.  This could potentially brick your computer  [https://apple.stackexchange.com/questions/166876/macbook-pro-how-to-disable-discrete-gpu-permanently-from-efi/285896#285896](https://apple.stackexchange.com/questions/166876/macbook-pro-how-to-disable-discrete-gpu-permanently-from-efi/285896#285896)

## Legacy

At this time it seems like gSwitch will not work on macbooks older than 2011. It appears that apple has removed the necessary API's from these macbooks on the modern macOS.  However there could be other API's that could work, I just can't find any.  GPU control with apple is mostly guess work since there isn't any documentation, so, [If anyone finds anything let me know here!](https://github.com/CodySchrank/gSwitch/issues/12)

## Notes

Requires macOS >= 10.12
