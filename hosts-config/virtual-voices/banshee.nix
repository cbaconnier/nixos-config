{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Banshee: inhuman wail, the dry voice plus parallel branches summed in a mixer.
#   uncanny   formants shifted up, pitch up a bit, wobbling (autotalent)
#   echo      repeats of the uncanny branch
#   grit      the uncanny branch through a hard overdrive
#   shifted   frequency shift + fold-over distortion (inharmonic rasp)
#   mourners  5-voice chorus
#   weight    sub-bass following the voice (only reacts to loud passages)
#   breath    a 3-8 kHz hiss that follows the voice
# A high shelf brightens the sum. Echo and grit are high-passed: a banshee has no chest.
let
  # autotalent latency in samples; the other branches are delayed to match it.
  latency = 2047.0 / 48000.0;
in
{
  description = "Banshee";

  nodes = [
    # No chest: nothing below 250 Hz goes into the branches.
    (builtin "hp" "bq_highpass" {
      Freq = 250.0;
      Q = 0.707;
    })
    (
      (builtin "dly" "delay" { "Delay (s)" = latency; })
      // {
        config."max-delay" = 0.1;
      }
    )
    (ladspa "uncanny" "autotalent" "autotalent" {
      "Formant correction" = 1.0;
      "Formant warp" = 0.55;
      "Pitch shift (scale notes)" = 2.0;
      "Pull to fixed pitch" = 0.0;
      "Correction strength" = 0.0;
      "LFO depth" = 0.40;
      "LFO rate (Hz)" = 2.8;
      Mix = 1.0;
    })
    (ladspa "grit" "foverdrive_1196" "foverdrive" { "Drive level" = 3.0; })
    # A banshee has no chest: the overdrive and the echo keep only the top.
    (builtin "grit_hp" "bq_highpass" {
      Freq = 500.0;
      Q = 0.707;
    })
    (builtin "echo_hp" "bq_highpass" {
      Freq = 400.0;
      Q = 0.707;
    })
    (lv2 "echo" "urn:zamaudio:ZamDelay" {
      time = 150.0;
      feedb = 0.45;
      lpf = 1800.0;
      drywet = 1.0;
      gain = -14.0;
    })
    (ladspa "shifted" "bode_shifter_1431" "bodeShifter" { "Frequency shift" = 28.0; })
    # Keep the drive at or below 0.3: above ~0.4 foldover diverges and mutes the whole graph.
    (ladspa "rasp" "foldover_1213" "foldover" {
      Drive = 0.30;
      Skew = 0.35;
    })
    # DC blocker: foldover outputs a constant offset on silent input
    (builtin "dc" "bq_highpass" {
      Freq = 30.0;
      Q = 0.707;
    })
    (ladspa "mourners" "multivoice_chorus_1201" "multivoiceChorus" {
      "Number of voices" = 5.0;
      "Delay base (ms)" = 25.0;
      "Voice separation (ms)" = 1.5;
      "Detune (%)" = 4.5;
      "LFO frequency (Hz)" = 2.0;
      "Output attenuation (dB)" = -4.0;
    })
    (lv2 "weight" "http://drobilla.net/plugins/mda/SubSynth" {
      type = 0.0;
      level = 0.60;
      tune = 0.45;
      dry_mix = 0.0;
      thresh = 0.55;
    })
    (builtin "air" "bq_bandpass" {
      Freq = 6000.0;
      Q = 0.5;
    })
    (ladspa "hiss" "foverdrive_1196" "foverdrive" { "Drive level" = 3.0; })
    # Linear gains: dry 2.0, uncanny 1.0, echo 2.5, shifted 0.8, chorus 1.0, sub 0.5,
    # grit 0.4, breath 0.2.
    (builtin "mix" "mixer" {
      "Gain 1" = 2.0;
      "Gain 2" = 1.0;
      "Gain 3" = 2.5;
      "Gain 4" = 0.8;
      "Gain 5" = 1.0;
      "Gain 6" = 0.5;
      "Gain 7" = 0.4;
      "Gain 8" = 0.2;
    })
    # Brightness: +5 dB above 3.5 kHz on the summed voice.
    (builtin "bright" "bq_highshelf" {
      Freq = 3500.0;
      Q = 0.7;
      Gain = 10.0;
    })
    # boost and alr are off: the limiter only limits, it does not raise quiet sounds
    (lv2 "limiter" "${lsp}limiter_mono" {
      g_in = 0.45; # gain staging: brings the summed branches into the limiter's range
      boost = 0.0;
      alr = 0.0;
      th = 0.708;
    })
  ];

  links = [
    (link "hp:Out" "dly:In")
    (link "hp:Out" "uncanny:Input")
    (link "uncanny:Output" "echo:lv2_audio_in_1")
    (link "uncanny:Output" "grit:Input")
    (link "grit:Output" "grit_hp:In")
    (link "dly:Out" "shifted:Input")
    (link "shifted:Up out" "rasp:Input")
    (link "dly:Out" "mourners:Input")
    (link "dly:Out" "weight:left_in")
    (link "dly:Out" "weight:right_in")
    (link "dly:Out" "air:In")
    (link "air:Out" "hiss:Input")
    (link "dly:Out" "mix:In 1")
    (link "uncanny:Output" "mix:In 2")
    (link "echo:lv2_audio_out_1" "echo_hp:In")
    (link "echo_hp:Out" "mix:In 3")
    (link "rasp:Output" "dc:In")
    (link "dc:Out" "mix:In 4")
    (link "mourners:Output" "mix:In 5")
    (link "weight:left_out" "mix:In 6")
    (link "grit_hp:Out" "mix:In 7")
    (link "hiss:Output" "mix:In 8")
    (link "mix:Out" "bright:In")
    (link "bright:Out" "limiter:in")
  ];

  inputs = [ "hp:In" ];
  outputs = [ "limiter:out" ];
}
