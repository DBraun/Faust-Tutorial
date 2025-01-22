# Faust to Hothouse

Read the documentation for the [`faust2hothouse`](https://github.com/grame-cncm/faust/tree/master-dev/architecture/hothouse) tool. The source code is [here](https://github.com/grame-cncm/faust/blob/master-dev/tools/faust2appls/faust2hothouse), but you shouldn't need to read it. This tool has a lot in common with `faust2daisy` because the Hothouse pedal uses a Daisy Seed.

## Flashing the Hothouse

You previously learned how to Flash the Daisy Seed on the Pod. The Daisy in the Hothouse pedal can be put into bootloader mode by holding the left footswitch for 2 seconds because we have previously installed one of the Hothouse Examples. If the Hothouse has never been used before, then you should follow these [instructions](https://github.com/clevelandmusicco/HothouseExamples/wiki/10%E2%80%90Minute-Quick-Start).

## Hello Hothouse

Let's put our familiar tapestop effect on the pedal. Hold the left footswitch for two seconds. Then run this:

```bash
cd Faust-Tutorial/hothouse_code
faust2hothouse -sr 48000 -bs 48 tapestop.dsp
```

The *right* footswitch is a button (not checkbox/toggle) that enables the effect.

## Other Effects

A Jimi Hendrix-like [Fuzz Face](https://en.wikipedia.org/wiki/Fuzz_Face):
```bash
faust2hothouse -sr 48000 -bs 48 fuzzFace.dsp
```

A Fairfield Circuitry Shallow Water:
```bash
faust2hothouse -sr 48000 -bs 48 fairfield.dsp
```
