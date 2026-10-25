{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Oracle: a god or a vision speaking from above, in a vast bright hall.
#   voice    the voice itself
#   octave   +12 semitones, mixed in quietly
#   fifth    +7 semitones, mixed in quietly
#   hall     very long bright reverb on the sum
let
  # autotalent latency in samples; the dry branch is delayed to match it.
  latency = 2047.0 / 48000.0;
  # Time-domain pitch shifter (see dragon): with all 12 notes allowed, one scale note is one
  # semitone; correction strength 0 leaves the pitch uncorrected.
  shifter =
    name: semitones:
    ladspa name "autotalent" "autotalent" {
      "Pitch shift (scale notes)" = semitones;
      "Correction strength" = 0.0;
      "Pull to fixed pitch" = 0.0;
      "Formant correction" = 0.0;
      Mix = 1.0;
      Bb = 0.0;
      Db = 0.0;
      Eb = 0.0;
      Gb = 0.0;
      Ab = 0.0;
    };
in
{
  description = "Oracle";

  nodes = [
    (builtin "hp" "bq_highpass" {
      Freq = 120.0;
      Q = 0.707;
    })
    (lv2 "gate" "${lsp}gate_mono" {
      gt = 0.0032; # threshold -50 dB
      gr = 0.001; # closed gate attenuation -60 dB
      at = 1.0;
      rt = 200.0;
      shpm = 2.0; # the gate only listens above 200 Hz, so low rumble cannot open it
      shpf = 200.0;
    })
    (
      (builtin "dly" "delay" { "Delay (s)" = latency; })
      // {
        config."max-delay" = 0.1;
      }
    )
    (shifter "octave" 12.0)
    (shifter "fifth" 7.0)
    # Linear gains: voice 1.0, octave 0.35, fifth 0.3.
    (builtin "pre" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.35;
      "Gain 3" = 0.3;
    })
    (builtin "bright" "bq_highshelf" {
      Freq = 4000.0;
      Q = 0.7;
      Gain = 3.0;
    })
    # Wet only; the dry signal is mixed back in by `mix`.
    (ladspa "verb" "gverb_1216" "gverb" {
      "Roomsize (m)" = 80.0;
      "Reverb time (s)" = 6.0;
      Damping = 0.3;
      "Input bandwidth" = 0.8;
      "Dry signal level (dB)" = -70.0;
      "Early reflection level (dB)" = -18.0;
      "Tail level (dB)" = -8.0;
    })
    (builtin "mix" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.4; # hall amount, about -8 dB
    })
    # boost and alr are off: the limiter only limits, it does not raise quiet sounds
    (lv2 "limiter" "${lsp}limiter_mono" {
      g_in = 0.6;
      boost = 0.0;
      alr = 0.0;
      th = 0.708;
    })
  ];

  links = [
    (link "hp:Out" "gate:in")
    (link "gate:out" "dly:In")
    (link "gate:out" "octave:Input")
    (link "gate:out" "fifth:Input")
    (link "dly:Out" "pre:In 1")
    (link "octave:Output" "pre:In 2")
    (link "fifth:Output" "pre:In 3")
    (link "pre:Out" "bright:In")
    (link "bright:Out" "verb:Input")
    (link "bright:Out" "mix:In 1")
    (link "verb:Left output" "mix:In 2")
    (link "mix:Out" "limiter:in")
  ];

  inputs = [ "hp:In" ];
  outputs = [ "limiter:out" ];
}
