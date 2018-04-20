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

Why create this when the amazing [gfxCardStatus](https://github.com/codykrieger/gfxCardStatus) exists? Well it had problems on high sierra and I thought the notification system was a bit too happy so I rewrote the program in swift and made a bunch of changes.

## Roadmap

*   And an auto-updater
*   Localization
*   Polling for gpu vram and processor usage?

## Notes

Unless you have a 2013 Macbook Pro with a 750m consider yourself a guinea pig. Since this is so new it is untested on anything else. I'm still unsure if this will work if you have a mac older than 2010.

Only tested on high sierra

Since I wrote this in about a week I'm sure there are going to be issues.
