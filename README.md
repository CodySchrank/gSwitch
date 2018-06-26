# gSwitch

gSwitch allows control over the gpu on dual gpu macbooks. It also optionally gives a notification when the gpu changed.

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

## Usage

The app is simple to control with _integrated only_, _discrete only_, and _dynamic switching_ in the menu.

You can also launch it from the terminal and set the desired setting using `--integrated`, `--discrete`, and `--dynamic`.

## Roadmap

*   Polling for gpu vram and processor usage?
*   A settable list of applications/processes that are allowed to use discrete gpu when integrated only?

## FAQ

**Why does the app go back to _dynamic switching_ when a display is plugged in?** Unfortunately your mac is designed such that in order to use an external display it has to use the dedicated graphics card. And since you plugged in the cable I'm assuming you want to use the display. Unfortunately when you unplug the display, if you want to use a different mode, you will have to manually set it (at this time).

**What is a dependent process vs a hungry process?** A dependent process is one that is currently using your dedicated gpu. A hungry process is one that wants to use the dedicated gpu but is not allowed because you have set _integrated only_. If you change to _dynamic switching_ or _discrete only_ any process that was hungry will become dependent.

**Why can't I change to _integrated only_ when there is a dependent process?** You can not change to _integrated only_ when there is a dependency, because your dedicated gpu stays powered on. To prevent both gpus being power on the app prevents you from switching until you quit all dependent processes. (this is still being tested and might change in the future)

**Why create this when the amazing [gfxCardStatus](https://github.com/codykrieger/gfxCardStatus) exists?** Well its no longer actively maintained and it has some problems on high sierra, so I rewrote the program in swift and made a bunch of changes. I'm also considering adding more features. Regardless, big shoutout to [cody](https://github.com/codykrieger) this project wouldn't have been possible without his gpu mux code.

## Notes

I'm especially unsure if this will work if you have a mac older than 2011. ([Let me know if it does!](https://github.com/CodySchrank/gSwitch/issues/12))
