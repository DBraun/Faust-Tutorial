# Day 2

We're going to install Faust and developer tools for our operating system so that we can build VST plugins.

## Faust Installation:

Go to the [releases](https://github.com/grame-cncm/faust/releases/) page.

### macOS

Go to the [releases](https://github.com/grame-cncm/faust/releases/) page. Select between `Faust-2.*.*-arm64.dmg` and `Faust-2.*.*-x64.dmg` (arm64 for "Apple Silicon").

You need to run something like this after installing:
```bash
xattr -c /Applications/Faust-2.77.3/bin/faust
```

Next, add Faust to your PATH environment variable.
Example:
$ nano ~/.zshrc

Then type this **with the right Faust version** into the window:
```bash
export PATH="/Applications/Faust-2.77.3/bin/:$PATH"
```

Then `control-o` to write to the output.
Then `control-x` to exit.
Then confirm Faust is in your path:
```bash
where faust
faust --version
```

### Windows:

Go to the [releases](https://github.com/grame-cncm/faust/releases/) page. Select `Faust-2.*.*-win64.exe`.

Run the installer and install Faust to `C:/Program Files/Faust`.

Edit your system environment variables so that your semicolon-separated `PATH` includes `C:/Program Files/Faust`.

Open a new command prompt and confirm Faust is available:

```bash
faust --version
```

### Linux

Install using apt-get:

```bash
apt-get -y update
apt-get install faust
```

In a shell window, confirm Faust is available:

```bash
faust --version
```

## IDE Installation

### Windows

For Windows users, install [Visual Studio](https://visualstudio.microsoft.com/vs/community/), which is different from VS Code.

### macOS

Install Xcode from the App Store.

### Linux

No developer tools should be necessary.

## Other Links

Syntax manual:
https://faustdoc.grame.fr/manual/syntax/

Faust Libraries:
https://faustlibraries.grame.fr/

Powered by Faust / Community Projects:
https://faust.grame.fr/community/powered-by-faust/

Julius Smith's 320C for Faust and JUCE:
https://ccrma.stanford.edu/courses/320c

Julius Smith's textbooks:
1. Mathematics of the Discrete Fourier Transform (DFT) with Audio Applications: https://ccrma.stanford.edu/~jos/mdft/
1. Introduction to Digital Filters: https://ccrma.stanford.edu/~jos/filters/
and more...

For a shorter introduction to Fourier analysis, read Chapter 2 of [Fundamentals of Music Processing](https://www.audiolabs-erlangen.de/fau/professor/mueller/bookFMP). It's a great book for other content too.

David Braun's Projects:
* [DawDreamer](https://github.com/DBraun/DawDreamer/)
* [Faust to JAX](https://github.com/DBraun/DawDreamer/blob/main/examples/Faust_to_JAX/Faust_to_JAX.ipynb)
* [Faust Box API](https://github.com/DBraun/DawDreamer/blob/main/examples/Box_API/Faust_Box_API.ipynb) (for Programming Language enthusiasts)
* [Faust in TouchDesigner](https://github.com/DBraun/TD-Faust)
* [FaucK](https://github.com/ccrma/fauck) (Faust + ChucK)
* [DX7-JAX](https://github.com/DBraun/DX7-JAX)

David Braun's Faust Talks:
* https://www.youtube.com/playlist?list=PLlgJDlgtJ1V-Eao5WFfI04Jdf9wYgYTvn
