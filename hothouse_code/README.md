# Faust to Hothouse

Read the documentation for the [`faust2hothouse`](https://github.com/grame-cncm/faust/tree/master-dev/architecture/hothouse) tool. The source code is [here](https://github.com/grame-cncm/faust/blob/master-dev/tools/faust2appls/faust2hothouse), but you shouldn't need to read it. This tool has a lot in common with `faust2daisy` because the Hothouse pedal uses a Daisy Seed.

## Using the IDE

We can skip the step of using `faust2hothouse` on the command line by using the online [IDE](https://faustide.grame.fr/). If you'd like to do this, open the tapestop effect with this [link](https://faustide.grame.fr/?code=https://raw.githubusercontent.com/DBraun/Faust-Tutorial/refs/heads/main/hothouse_code/tapestop.dsp). Make sure polyphony is set to "Mono." Then use the yellow truck icon "Export". For platform, select "Hothouse". Then compile, download, and unzip.

## Flashing the Hothouse

You previously learned how to Flash the Daisy Seed on the Pod. The Daisy in the Hothouse pedal can be put into bootloader mode by holding the left footswitch for 2 seconds because we have previously installed one of the Hothouse Examples. If the Hothouse has never been used before, then you should follow these [instructions](https://github.com/clevelandmusicco/HothouseExamples/wiki/10%E2%80%90Minute-Quick-Start).

## Hello Hothouse

Let's put our familiar tapestop effect on the pedal. Hold the left footswitch for two seconds. Then run this:

```bash
cd Faust-Tutorial/hothouse_code
faust2hothouse -sr 48000 -bs 48 tapestop.dsp
```

The *right* footswitch is a button (not checkbox/toggle) that enables the effect.

> If you used the online IDE to export the tapestop project, then you don't need to use `faust2hothouse` (but you do need the steps in [DAY3.md](https://github.com/DBraun/Faust-Tutorial/blob/main/DAY3.md)). So instead of using `faust2hothouse`, put the pedal into bootloader, `cd` to the downloaded project directory and run:
> ```bash
> make
> make program-dfu
> ```

## Other Effects

A Jimi Hendrix-like [Fuzz Face](https://en.wikipedia.org/wiki/Fuzz_Face):
```bash
faust2hothouse -sr 48000 -bs 48 fuzzFace.dsp
```

A Fairfield Circuitry Shallow Water:
```bash
faust2hothouse -sr 48000 -bs 48 fairfield.dsp
```
