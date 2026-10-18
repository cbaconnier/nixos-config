{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Ghost: a hollow, distant ghost, mostly reverb. Breaths and whispers are kept (no gate).
#   dry      the voice, thinned out
#   haunt    the voice +3 semitones with a slow waver, mixed in quietly
#   echo     slow dark repeats of the haunt
#   hall     long dark reverb on dry + haunt
#   dry, haunt and echo go through `pre`; the hall is fed from it.
let
  # autotalent latency in samples; the dry branch is delayed to match it.
  latency = 2047.0 / 48000.0;
in
{
  description = "Ghost";

  nodes = [
    # Cuts mic handling noise and the chest.
    (builtin "hp" "bq_highpass" {
      Freq = 150.0;
      Q = 0.707;
    })
    (
      (builtin "dly" "delay" { "Delay (s)" = latency; })
      // {
        config."max-delay" = 0.1;
      }
    )
    # Time-domain pitch shift of +3 semitones, with a slow waver (see storyteller for the
    # parameter meaning).
    (ladspa "haunt" "autotalent" "autotalent" {
      "Pitch shift (scale notes)" = 3.0;
      "Correction strength" = 0.0;
      "Pull to fixed pitch" = 0.0;
      "Formant correction" = 0.0;
      "LFO depth" = 0.15;
      "LFO rate (Hz)" = 0.6;
      Mix = 1.0;
      Bb = 0.0;
      Db = 0.0;
      Eb = 0.0;
      Gb = 0.0;
      Ab = 0.0;
    })
    (lv2 "echo" "urn:zamaudio:ZamDelay" {
      time = 450.0;
      feedb = 0.5;
      lpf = 1500.0;
      drywet = 1.0;
      gain = -8.0;
    })
    (builtin "pre" "mixer" {
      "Gain 1" = 0.8;
      "Gain 2" = 0.5;
      "Gain 3" = 0.6;
    })
    # Wet only; the dry signal is `pre` itself.
    (ladspa "verb" "gverb_1216" "gverb" {
      "Roomsize (m)" = 60.0;
      "Reverb time (s)" = 8.0;
      Damping = 0.8;
      "Input bandwidth" = 0.5;
      "Dry signal level (dB)" = -70.0;
      "Early reflection level (dB)" = -20.0;
      "Tail level (dB)" = -6.0;
    })
    # Dark tail: no rumble, no brightness.
    (builtin "hall_hp" "bq_highpass" {
      Freq = 200.0;
      Q = 0.707;
    })
    (builtin "hall_lp" "bq_lowpass" {
      Freq = 4500.0;
      Q = 0.707;
    })
    (builtin "mix" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.3; # hall amount, about -10 dB
    })
    (builtin "dull" "bq_highshelf" {
      Freq = 6000.0;
      Q = 0.7;
      Gain = -4.0;
    })
    # boost and alr are off: the limiter only limits, it does not raise quiet sounds
    (lv2 "limiter" "${lsp}limiter_mono" {
      g_in = 0.7;
      boost = 0.0;
      alr = 0.0;
      th = 0.708;
    })
  ];

  links = [
    (link "hp:Out" "dly:In")
    (link "hp:Out" "haunt:Input")
    (link "haunt:Output" "echo:lv2_audio_in_1")
    (link "dly:Out" "pre:In 1")
    (link "haunt:Output" "pre:In 2")
    (link "echo:lv2_audio_out_1" "pre:In 3")
    (link "pre:Out" "verb:Input")
    (link "verb:Left output" "hall_hp:In")
    (link "hall_hp:Out" "hall_lp:In")
    (link "pre:Out" "mix:In 1")
    (link "hall_lp:Out" "mix:In 2")
    (link "mix:Out" "dull:In")
    (link "dull:Out" "limiter:in")
  ];

  inputs = [ "hp:In" ];
  outputs = [ "limiter:out" ];
}
