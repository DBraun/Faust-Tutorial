/* Copyright 2013-2019 Matt Tytel
 *
 * vital is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * vital is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with vital.  If not, see <http://www.gnu.org/licenses/>.
 */
 
 /*
 This is an implementation of the Compressor effect from the Vital synthesizer:
 https://github.com/mtytel/vital/blob/main/src/synthesis/effects/compressor.cpp
 https://github.com/mtytel/vital/blob/main/src/common/synth_parameters.cpp
 https://github.com/mtytel/vital/blob/main/src/interface/editor_components/compressor_editor.cpp

 Faust author: David Braun

 This is a great reference for understanding dynamics:
 https://www.ableton.com/en/manual/live-audio-effect-reference/#multiband-dynamics
 */

import("stdfaust.lib");

kMaxExpandMult = 32.0;
kLowAttackMs = 2.8;
kBandAttackMs = 1.4;
kHighAttackMs = 0.7;
kLowReleaseMs = 40.0;
kBandReleaseMs = 28.0;
kHighReleaseMs = 15.0;

kMinGain = -30.0;
kMaxGain = 30.0;
kMinThreshold = -100.0;
kMaxThreshold = 12.0;
kMinSampleEnvelope = 5.0;

// crossover frequencies in Hertz
cf1 = 120; // todo: I might have read somewhere that it's 88.3 in Serum
cf2 = 2500;

compressor(attack, release, attack_ms, release_ms, lower_ratio, upper_ratio, lower_threshold, upper_threshold) = (compressorTick ~ si.bus(2)) : ba.selector(2, 3)
with {

    msec2samp = _/1000 : ba.sec2samp;

    attack_mult = attack_ms : msec2samp;
    release_mult = release_ms : msec2samp;

    attack_exponent = attack * 8.0 - 4.0;
    release_exponent = release * 8.0 - 4.0;

    envelope_attack_samples = exp(attack_exponent) * attack_mult : max(kMinSampleEnvelope);
    envelope_release_samples = exp(release_exponent) * release_mult : max(kMinSampleEnvelope);

    attack_scale = 1. / (envelope_attack_samples + 1.);
    release_scale = 1. / (envelope_release_samples + 1.);

    compressorTick(low_enveloped_mean_squared_, high_enveloped_mean_squared_, x) = low_enveloped_mean_squared, high_enveloped_mean_squared, out
    with {
        sample_squared = x*x;

        high_attack_mask = sample_squared > high_enveloped_mean_squared_;
        high_samples = ba.if(high_attack_mask, envelope_attack_samples, envelope_release_samples);
        high_scale = ba.if(high_attack_mask, attack_scale, release_scale);

        high_enveloped_mean_squared = (sample_squared + high_enveloped_mean_squared_ * high_samples) * high_scale : max(upper_threshold);

        upper_mag_delta = upper_threshold / high_enveloped_mean_squared;
        upper_mult = pow(upper_mag_delta, upper_ratio);

        low_attack_mask = sample_squared > low_enveloped_mean_squared_;
        low_samples = ba.if(low_attack_mask, envelope_attack_samples, envelope_release_samples);
        low_scale = ba.if(low_attack_mask, attack_scale, release_scale);

        low_enveloped_mean_squared = (sample_squared + low_enveloped_mean_squared_ * low_samples) * low_scale : min(lower_threshold);

        lower_mag_delta = lower_threshold / low_enveloped_mean_squared;
        lower_mult = pow(lower_mag_delta, lower_ratio);

        gain_compression = upper_mult * lower_mult : aa.clip(0., kMaxExpandMult);

        out = gain_compression*x;
    };
};

fx_compressor = hgroup("Compressor", ef.dryWetMixerConstantPower(wet, sp.stereoize(compressor_mono)))
with {

    attack = hslider("[0] Attack [style:knob]", .5, 0, 1, .01);
    release = hslider("[1] Release [style:knob]", .5, 0, 1, .01);

    // corresponding to three bands:
    LOW(x) = vgroup("[2] Low", x);
    BAND(x) = vgroup("[3] Mid", x);
    HIGH(x) = vgroup("[4] High", x);

    wet = hslider("[5] Wet [style:knob]", 1, 0, 1, .01);

    UPPER(x) = hgroup("[0] Upper", x);
    LOWER(x) = hgroup("[1] Lower", x);

    lower_threshold(default) = vslider("Threshold [unit:dB][tooltip:Below this threshold, either downward expansion or upward compression is applied.]", default, kMinThreshold, kMaxThreshold, .01) : ba.db2linear <: _*_;
    upper_threshold(default) = vslider("Threshold [unit:dB][tooltip:Above this threshold, downward compression is applied.]", default, kMinThreshold, kMaxThreshold, .01) : ba.db2linear <: _*_;

    upper_ratio(default) = vslider("Ratio [tooltip:Left-most means no downward compression, and right-most means maximal, like a limiter.]", default, 0, 1, .01) * 0.5;
    lower_ratio(default) = vslider("Ratio [tooltip:Left-most means downward expansion (gating), and right-most means upward compression (louder). In the middle means no effect.]", default, -1, 1, .01) * 0.5;

    gain(default) = hslider("Gain [style:knob][unit:dB]", default, kMinGain, kMaxGain, .01) : ba.db2linear;

    compressor_i(0, attack, release) = LOW(compressor(
        attack, release,
        kLowAttackMs,
        kLowReleaseMs,
        LOWER(lower_ratio(0.8)),
        UPPER(upper_ratio(0.9)),
        LOWER(lower_threshold(-35)),
        UPPER(upper_threshold(-28))
    )*gain(16.3));

    compressor_i(1, attack, release) = BAND(compressor(
        attack, release,
        kBandAttackMs,
        kBandReleaseMs,
        LOWER(lower_ratio(0.8)),
        UPPER(upper_ratio(0.857)),
        LOWER(lower_threshold(-36)),
        UPPER(upper_threshold(-25))
    )*gain(11.7));

    compressor_i(2, attack, release) = HIGH(compressor(
        attack, release,
        kHighAttackMs,
        kHighReleaseMs,
        LOWER(lower_ratio(0.8)),
        UPPER(upper_ratio(1)),
        LOWER(lower_threshold(-35)),
        UPPER(upper_threshold(-30))
    )*gain(16.3));

    compressor_mono = fi.crossover3LR4(cf1, cf2) : par(i, 3, (attack,release,_ : compressor_i(i))) :> _;
};

declare fx_compressor author "David Braun";
declare fx_compressor license "GNU General Public License v3";

process = fx_compressor;
