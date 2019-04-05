# gSwitch

gSwitch allows control over the gpu on dual gpu macbooks. It also optionally gives a notification when the gpu changed.

## Install

Either [download the most recent release](https://codyschrank.github.io/gSwitch/) or build from the source.

To build from the source

You must have Carthage installed:

```bash
brew update
brew install carthage
```

And then bootstrap the frameworks:

```bash
carthage bootstrap
```

and then build in xcode

## Usage

The app is simple to control with _integrated only_, _discrete only_, and _dynamic switching_ in the menu.

You can also launch it from the terminal and set the desired setting using `--integrated`, `--discrete`, and `--dynamic`.

## FAQ

**Why won't the app start?**
You probably need to allow the application to run in _Settings_ -> _Security & Privacy_

**How do I know which gpu is active?**
The gear will have a dot in the middle when the discrete gpu is active.  Otherwise, it will just look like a gear.  The current gpu is also reported in the menu.

**Why did the binary get reported as malicious?**
The code is not signed because I'm not paying apple $99 a year to do that.  If you don't trust me I suggest you run it through an online virus scanner or look at the code yourself.

**Why does the app go back to _dynamic switching_ when a display is plugged in?**
Unfortunately your mac is designed such that in order to use an external display, it has to use the discrete graphics card. And since you plugged in the cable I'm assuming you want to use the display.  When you unplug the display, if you want to use a different mode, you will have to manually set it (at this time).

**What is a dependent process vs a hungry process?**
A dependent process is one that is currently using your discrete gpu. A hungry process is one that wants to use the discrete gpu but is not allowed because you have set _integrated only_. If you change to _dynamic switching_ or _discrete only_ any process that was hungry will become dependent.

## Legacy

At this time it seems like gSwitch will not work on macbooks older than 2011. It appears that apple has removed the necessary API's from these macbooks on the modern macOS.  However there could be other API's that could work, I just can't find any.  GPU MUX is mostly guess work since there isn't any documentation, so, ([If anyone finds anything let me know here!](https://github.com/CodySchrank/gSwitch/issues/12))
