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

**Why does the app go back to discrete when a display is plugged in?** Unfortunately your mac is designed such that in order to use an external display it has to use the dedicated graphics card. And since you plugged in the cable I'm assuming you want to use it. Unfortunately when you unplug the display, if you want to use a different mode than dynamic, you will have to manually set it (at this time).

**Why create this when the amazing [gfxCardStatus](https://github.com/codykrieger/gfxCardStatus) exists?** Well it had some problems on high sierra and I thought the notification system was a bit too happy so I rewrote the program in swift and made a bunch of changes.

## Roadmap

*   Auto updates
*   Localization
*   Polling for gpu vram and processor usage?

## Notes

Unless you have a 2013 Macbook Pro with a 750m consider yourself a guinea pig. Since this is so new it is untested on anything else. I'm especially unsure if this will work if you have a mac older than 2011.

Only tested on high sierra

Since I wrote this in about a week I'm sure there are going to be issues.
