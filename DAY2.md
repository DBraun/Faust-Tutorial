# Day 2

The goal of this day is to make a VST3 plugin of a tapestop effect ([Faust code](https://github.com/DBraun/Faust-Tutorial/blob/main/plugins_code/tapestop.dsp)). We have instructions for macOS, Windows, and Linux.

Outline:

1. Install Faust
1. Install Build Tools (Xcode/Visual Studio)
1. Install JUCE
1. Install Plugin GUI Magic (Optional)
1. Run `faust2juce`
1. Open and configure the generated Projucer file.
1. Build the project.
1. Test in a DAW/Audacity, etc.

## Faust Installation

To install Faust, go to the Faust [releases](https://github.com/grame-cncm/faust/releases/) page.

### macOS

Select between `Faust-2.*.*-arm64.dmg` ("Apple Silicon") and `Faust-2.*.*-x64.dmg` ("Intel").

You need to run something like this after installing:
```bash
xattr -c /Applications/Faust-2.77.3/bin/faust
```

Next, you'll add Faust to your PATH environment variable. If you know `vim` or `emacs`, you could use either for this next step. However, `nano` is easy to use, so we'll do this:

```bash
nano ~/.zshrc
```

Then type this **with the right Faust version** into the window:
```bash
export PATH="/Applications/Faust-2.77.3/bin/:$PATH"
```

Then `control-o` and press `enter` to write to the output.
Then `control-x` to exit `nano`.

Open a new Terminal window and confirm that Faust is in your path:
```bash
where faust
faust --version
```

### Windows

Select `Faust-2.*.*-win64.exe`.

Run the installer and install Faust to `C:/Program Files/Faust`.

Edit your system environment variables so that your semicolon-separated `PATH` includes `C:/Program Files/Faust/bin`.

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

### macOS

Install Xcode from the App Store.

### Windows

For Windows users, install [Visual Studio Community](https://visualstudio.microsoft.com/vs/community/), which is different from VS Code. At a minimum, you will want the "Windows" components, not necessarily the Android ones.

### Linux

No extra developer tools should be necessary.

## JUCE Installation

Go to the JUCE [releases](https://github.com/juce-framework/JUCE/releases/) and download the `.zip` for your OS.

### macOS

Unzip `juce-*.*.*-osx.zip` to `~/JUCE`. By using this exact location, you will save yourself a lot of frustration. *We really mean it.* You should have `~/JUCE/Projucer`.

### Windows

Unzip `juce-*.*.*-windows.zip` to a location such as `C:/JUCE`. By using this exact location, you will save yourself a lot of frustration. *We really mean it.* You should have `C:/JUCE/Projucer.exe`. 

### Linux

Unzip `juce-*.*.*-osx.zip` to `~/JUCE`. By using this exact location, you will save yourself a lot of frustration. *We really mean it.* You should have `~/JUCE/Projucer`.

## Plugin GUI Magic Installation (Optional)

Plugin GUI Magic can help you make a UI that is better than the default from `faust2juce`. It is a "what-you-see-is-what-you-get" (WYSIWYG) editor. Once the plugin is built, you can open it in a DAW and interactively adjust the layout of the UI components. Then you save a layout file. This file can be used to lock the layout in the future. If this sounds interesting, then try out this step!

Go to the Plugin GUI Magic [GitHub repository](https://github.com/ffAudio/foleys_gui_magic/). You can either clone it or download a zip of it.

> The "releases" page seems outdated as of January 2025, so don't use the "releases" like you may have done for Faust.

This repository can go anywhere. Mine is at `~/GitHub/foleys_gui_magic`, so I have `~/GitHub/foleys_gui_magic/VERSION.md`. I'm not calling attention to `VERSION.md` for any reason. It's just an identifiable file.

## Faust2JUCE

Now we will use the `faust2juce` command-line tool. You can read more about it [here](https://github.com/grame-cncm/faust/tree/master-dev/architecture/juce). Note that the *source code* of the tool is [here](https://github.com/grame-cncm/faust/blob/master-dev/tools/faust2appls/faust2juce). **It's actually just a shell script, even though it doesn't have the `.sh` extension.**

Since `faust` is available from the command line, `faust2juce` should be available too. Navigate to `Faust-Tutorial/plugin_code`. Then try `faust2juce` with no arguments. It should explain which options it takes.

> If you're on Windows, note that `faust2juce` is a shell script. The best way to run it is `Git Bash`, which is like a different command prompt. You may be able to launch this by searching for it from the Windows Search Box.

Let's now run this:

```bash
faust2juce -jucemodulesdir ~/JUCE/modules tapestop.dsp
```

If you're following the steps for Plugin GUI Magic, then you can add `-magic` like:

```bash
faust2juce -jucemodulesdir ~/JUCE/modules -magic tapestop.dsp
```

Next to `tapestop.dsp`, there should be a new directory called `tapestop`. Copy this directory to a new location.

> Why copy and move it? This directory contains `tapestop.jucer` and `FaustPluginProcessor.cpp`. If you were to change your `tapestop.dsp` effect and run `faust2juce` again, you'd overwrite both of them. You probably want to overwrite `FaustPluginProcessor.cpp` since that's where the DSP is, but you don't want to overwrite `tapestop.jucer` since that will have some settings that you may have configured manually, as you are about to do...

Now open the relocated `tapestop.jucer` file. If it doesn't open nicely, find `~/JUCE/Projucer` in Finder, open that. Then file-open `tapestop.jucer`.

Now look for a gear icon towards the top-left of the Projucer menu. If you hover your mouse over it, it should say "Project Settings". Click it. You should set a list editable fields such as "Project Name" and "Project Version". Scroll down to "Plugin Manufacturer" and change the name from "GRAME" to your name or company name. Adjust the other settings if you feel comfortable. For example, in "Plugin Formats", you may want to deselect everything except "VST3".

> Plugin GUI Magic (Optional). In the Projucer's left panel, there are three purple sections: "File Explorer", "Modules", and "Exporters". Click on "Modules" so that it expands. Find the "+" icon at the bottom of the expanded section. Click it and select "Add a module from a specified folder..." Navigate to `~/GitHub/foleys_gui_magic/modules/foleys_gui_magic` so that `Editor`/`General`/`Helpers` etc. are visible. Press "Open" to finalize your choice of this folder. You will see a pop-up in the lower left saying "Missing Module Dependencies". Select "Add missing dependencies". Now `foleys_gui_magic` should appear as a new entry in the Modules section in the left-panel.

At the very top, there is a menu called "Select exporter". For macOS, select "Xcode (macOS)" and then press the circular Xcode logo to the right. For Windows, select "Visual Studio" and then press the circular Visual Studio logo to the right.

## Building

### macOS

Xcode should open. In the top middle section, adjust the "Scheme" to `tapestop-All` and adjust the Run Destination to "My Mac". Press `command-b` to build the project. If there are no errors, use Finder to find `~/GitHub/Faust-Tutorial/plugins_code/tapestop/Builds/MacOSX/build/Debug/tapestop.vst3`. Navigate to `~/Audio/Plug-Ins/VST3` and confirm `tapestop.vst3` is already there. Now use a Digital Audio Workstation or Audacity to test this effect.

When you're done testing, we can build in Release mode. In Xcode, select "Product" from the menu  bar. Hold `option` and select "Archive...". The Build Configuration field should say "Release". Press the "Archive" button in the lower right. When it's done building, select "Distribute Content". Use all the default options to proceed forward until you can save to a specified folder. Inside this saved folder, you should be able to find `Products/Users/braun/Library/Audio/Plug-Ins/VST3/tapestop.vst3`. This is your final Release-mode VST3. Congrats!

### Windows

Select "Release" from the menu bar at the top of Visual Studio. Then press `control-shift-b` to build. Navigate to `Faust-Tutorial\plugins_code\tapestop\Builds\VisualStudio2019\x64\Release\VST3\tapestop.vst3`. This is your final Release-mode VST3. Congrats! Move it to a folder so that your Digital Audio Workstation can see it, and then try it out.

### Linux

In a terminal, navigate to `tapestop/Builds/Linux`. Then run `make`.

## Other Links

Julius Smith's [320C course](https://ccrma.stanford.edu/courses/320c) ("Audio DSP Projects in Faust and C++"), which also covers JUCE and Plugin GUI Magic.
