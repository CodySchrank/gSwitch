# gSwitch

gSwitch allows control over the gpu on dual gpu macs. It also optionally gives a notification when the gpu changed.

## Install

Either [download the most recent release](https://codyschrank.github.io/gSwitch/) or build from the source.

To build from the source

You must have Carthage installed:

```
brew update
brew install carthage
```

And then bootstrap the frameworks:

```
carthage bootstrap
```

and then build in xcode

## FAQ

**Why does the app go back to _dynamic switching_ when a display is plugged in?** Unfortunately your mac is designed such that in order to use an external display it has to use the dedicated graphics card. And since you plugged in the cable I'm assuming you want to use the display. Unfortunately when you unplug the display, if you want to use a different mode, you will have to manually set it (at this time).

**What is a dependent process vs a hungry process?** A dependent process is one that is currently using your dedicated gpu. A hungry process is one that wants to use the dedicated gpu but is not allowed because you have set _integrated only_. If you change to _dynamic switching_ or _discrete only_ any process that was hungry will become dependent.

**Why can't I change to _Integrated Only_ when there is a dependent process?** You can not change to _integrated only_ when there is a dependency, because your dedicated gpu stays powered on. To prevent both gpus being power on the app prevents you from switching until you quit all dependent processes. (this is still being tested and might change in the future)

**Why create this when the amazing [gfxCardStatus](https://github.com/codykrieger/gfxCardStatus) exists?** Well it had some problems on high sierra and I thought the notification system was a bit too happy so I rewrote the program in swift and made a bunch of changes. I'm also considering adding more features. Regardless, big shoutout to [cody](https://github.com/codykrieger) this project wouldn't have been possible without his gpu mux code.

## Roadmap

*   Auto updates
*   Localization
*   Polling for gpu vram and processor usage?
*   A settable list of applications/processes that are allowed to use discrete gpu (when integrated only)?

## Notes

Unless you have a 2013 Macbook Pro with a 750m consider yourself a guinea pig. Since this is so new it is untested on anything else. I'm especially unsure if this will work if you have a mac older than 2011.

Since I wrote this in about a week I'm sure there are going to be issues.
