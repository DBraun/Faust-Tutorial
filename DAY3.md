# Day 3

Today is an exciting day because we will put Faust code on both the Daisy [Pod](https://electro-smith.com/products/pod) and Cleveland Music Co. [DIY Guitar Pedal](https://clevelandmusicco.com/hothouse-diy-digital-signal-processing-platform-kit/).

Outline:

1. Install the Daisy Toolchain
1. Install Daisy Examples
1. Install Hothouse Examples
1. Install Python
1. Update Environment Variables
1. Advice for Code on Microcontrollers
1. `faust2daisy` Demos
1. `faust2hothouse` Demos

# Install the Daisy Toolchain

Instructions for installing the Daisy Toolchain are [here](https://github.com/electro-smith/DaisyWiki/wiki/1.-Setting-Up-Your-Development-Environment#1-install-the-toolchain). Pick the link that's right for your OS:
* [macOS](https://github.com/electro-smith/DaisyWiki/wiki/1b.-Installing-the-Toolchain-on-Mac#Download-the-Installer)
* [Windows](https://github.com/electro-smith/DaisyWiki/wiki/1c.-Installing-the-Toolchain-on-Windows)
* [Linux](https://github.com/electro-smith/DaisyWiki/wiki/1d.-Installing-the-Toolchain-on-Linux)

On macOS, there may be some issues with permissions, but we'll help you with them.

# Install Daisy Examples

Use `git` to clone the [Daisy Examples](https://github.com/electro-smith/DaisyExamples/):

```bash
git clone --recursive https://github.com/electro-smith/DaisyExamples
```

**It is important to use `--recursive` so that submodules are cloned.**

# Install the Hothouse Examples

We will summarize the intructions [here](https://github.com/clevelandmusicco/HothouseExamples/wiki/10%E2%80%90Minute-Quick-Start#getting-and-initializing-the-code).

> Windows users: Be sure to run all of the following commands from within Git Bash. Running them from cmd.exe or a Powershell terminal will not work.

```bash
cd ~/GitHub # where we'll keep HothouseExamples
git clone --recursive https://github.com/clevelandmusicco/HothouseExamples
cd HothouseExamples
git submodule update --init --recursive
make -C libDaisy
make -C DaisySP
```

# Install Python

We need `python3` to be accessible from the command line. Currently when using `faust2daisy` with the `-sdram` option or the `faust2hothouse` tool at all, `python3` is called to make some adjustments to the generated code. This will eventually be improved so that Python isn't needed.

You can download Python [here](https://www.python.org/downloads/). If you're on Windows, the easiest solution might be to just find your `python.exe` and copy-paste it into `python3.exe`.

# Update Environment Variables

Yesterday, we updated our `PATH` variable so that the `faust` binary was always accessible from Terminal. Now we're going to add new environment variables to help with both the `faust2daisy` and `faust2hothouse` scripts. If you'd rather use `vim` or `emacs` for the steps below, that's ok! We'll use `nano`:

```bash
nano ~/.zshrc
```

Adjusting for where you cloned the repositories, add these lines:
```
export LIBDAISY_DIR=~/GitHub/DaisyExamples/libdaisy
export DAISYSP_DIR=~/GitHub/DaisyExamples/DaisySP
export HOTHOUSE_DIR=~/GitHub/HothouseExamples
```

Then `control-o`, `enter`, and `control-x` one at a time to save and exit.

# Advice for Code on Microcontrollers

When writing code for microcontrollers such as Daisy devices or guitar pedals, keep in mind that your final *output* signal should never exceed the bounds of negative one to positive one. If it goes outside these bounds, it will ["clip"](https://en.wikipedia.org/wiki/Clipping_(audio)).

# `faust2daisy` Demos

Go to [daisy_code/README.md](daisy_code/README.md). When you're done, come back for the `faust2hothouse` demos.

# `faust2hothouse` Demos

Go to [hothouse_code/README.md](hothouse_code/README.md).
