# Day 1

## Safety

1. Protect your ears and audio equipment.
1. Don't play audio if you don't need to.
1. Be ready to mute the sound at any moment.

Safety-related coding tips:
1. Don't send a constant non-zero output to speakers. For example, a sustained stream of 1s is bad.
1. Don't send "bad" values to functions. For example, the cutoff of a filter shouldn't be close to zero or close to the [Nyquist frequency](https://en.wikipedia.org/wiki/Nyquist_frequency) (half the sampling rate).

## Tutorial

The rest of the tutorial takes place inside `tutorial.dsp`. You can open it with this [link](https://faustide.grame.fr/?code=https://raw.githubusercontent.com/DBraun/Faust-Tutorial/refs/heads/main/tutorial.dsp). When you're done, come back to this `DAY1.md`.

## Soundfile server

This section mostly repeats information from [here](https://github.com/grame-cncm/faustide?tab=readme-ov-file#soundfiles-access). You can drag audio files into the file browser section on the left side of the IDE. Then those audio files can be accessed with the `soundfile` primitive. However, it's more convenient to be able to load any audio file from a folder on your own computer. For this, we need to run a Python server. If you haven't already, install [Python](https://www.python.org/downloads/). Then install `flask`:

```bash
pip3 install flask Flask-Cors
```

Next to the markdown file you're reading right now, there's a python file `server.py`. Navigate to it in a Terminal window and run this:

```bash
python3 server.py
```

If you want to configure the port or assets directory:

```bash
python script.py --assets-dir /path/to/custom/assets --port 8080
```

Now you can use `soundfile` with audio files that exist in your chosen assets directory.


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

David Braun's Faust Projects:
* [DawDreamer](https://github.com/DBraun/DawDreamer/)
* [Faust to JAX](https://github.com/DBraun/DawDreamer/blob/main/examples/Faust_to_JAX/Faust_to_JAX.ipynb)
* [Faust Box API](https://github.com/DBraun/DawDreamer/blob/main/examples/Box_API/Faust_Box_API.ipynb) (for Programming Language enthusiasts)
* [Faust in TouchDesigner](https://github.com/DBraun/TD-Faust)
* [FaucK](https://github.com/ccrma/fauck) (Faust + ChucK)
* [DX7-JAX](https://github.com/DBraun/DX7-JAX)

David Braun's Faust Talks:
* https://www.youtube.com/playlist?list=PLlgJDlgtJ1V-Eao5WFfI04Jdf9wYgYTvn
