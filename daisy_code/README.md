# Faust to Daisy

Read the documentation for the [`faust2daisy`](https://github.com/grame-cncm/faust/tree/master-dev/architecture/daisy) tool. The source code is [here](https://github.com/grame-cncm/faust/blob/master-dev/tools/faust2appls/faust2daisy), but you shouldn't need to read it.

The `faust2daisy` tool works for the entire Daisy microcontroller ecosystem, but we'll use it for the Pod. The Daisy ecosystem is only one of many destinations to which Faust can be deployed. For other examples, check out [faust2appls](https://github.com/grame-cncm/faust/tree/master-dev/tools/faust2appls).

## Pod

The Pod is the barebones Daisy Seed with 65MB memory plus two knobs, two buttons, and an encoder. An encoder is like a knob that can rotate unlimited amounts in either direction. Currently, the `faust2daisy` tool lets us use the knobs and buttons but not yet the encoder.

## Hello Synthesizer

Let's make a "synthesizer" using a single oscillator. You won't be able to control the synthesiser with MIDI, but you will be able to control the volume with the first knob and the pitch with the second knob The code uses [quantizers.lib](https://faustlibraries.grame.fr/libs/quantizers/) to make our pitch fit into a major scale.

In the current directory, run the following:
```bash
faust2daisy -pod -sdram -sr 48000 -bs 16 oscillator.dsp
```

It will say, "Press ENTER when Daisy is in DFU mode." Connect the Pod to your computer via micro-USB cable. Put the Daisy into DFU/bootloader mode by *holding* the `BOOT` button down and then *holding* the `RESET` button. Then release the `RESET` button and then release the `BOOT` button. This procedure is demonstrated below:

> ![Flashing the Pod Example](https://github.com/electro-smith/DaisyWiki/raw/master/resources/Seed_Connect.gif) ([image credit](https://github.com/electro-smith/DaisyWiki/wiki/1.-Setting-Up-Your-Development-Environment))

Then press `RESET` once and then press `BOOT` once. You should see a light on the Pod that fades from bright to dim and back in a cycle.

Now you can press `enter` in Terminal to confirm that the Daisy is in `dfu` mode. If all goes well, you should see this "error" message:

```
dfu-util: Error during download get_status
make: *** [program-dfu] Error 74
```

This error can be ignored. Connect headphones to either the line out or headphone out on the Pod and see if the knobs control the generated audio.

Now's a good time to examine how the script works. Run the `faust2daisy` code above again, but this time press enter without putting the Pod into `dfu` mode. In Finder you'll see a directory named `oscillator`. Examine the content of this directory. Inside it, run the following:

```bash
make clean
make
```

If it all seemed to work, then do the button sequence to put the Pod into Bootloder mode and then run
```bash
make program-dfu
```

## Polyphony

Polyphony is not yet working on the Daisy. See Faust issue [#1090](https://github.com/grame-cncm/faust/issues/1090).

## Better Synthesizer

A more complete "synthesizer" (still not MIDI enabled or polyphonic) is `synth.dsp`. Build it with this:

```bash
faust2daisy -pod -sdram -sr 48000 -bs 16 synth.dsp
```

Read the beginning of `synth.dsp` to see what the parameters do.

## Tape Stop

The Daisy Pod can process incoming audio too. Connect some audio signal to the 1/8" Audio In Jack. Build it with this:

```bash
faust2daisy -pod -sdram -sr 48000 -bs 16 tapestop.dsp
```

## Looper

```bash
faust2daisy -pod -sdram -sr 48000 -bs 16 looper.dsp
```
