{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Two entities speaking at once: two lowered copies of the voice, layered.
#   high-pass -> gate -> compressor -> two lowered voices in parallel -> EQ -> reverb -> limiter
# The voices sit 4 and 7.3 semitones below yours.
let
  # Time-domain pitch shift. With all 12 notes allowed one scale note is one semitone; the
  # correction strength 0 leaves the pitch uncorrected.
  shift = semitones: {
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
  description = "Double entity";

  nodes = [
    # Cuts mic handling noise before the gate and the pitch shifters.
    (builtin "hp_in" "bq_highpass" {
      Freq = 80.0;
      Q = 0.7;
    })
    (lv2 "gate" "${lsp}gate_mono" {
      gt = 0.01; # threshold -40 dB
      gr = 0.001; # closed gate attenuation -60 dB
      at = 1.0;
      rt = 250.0;
      shpm = 2.0; # the gate only listens above 200 Hz, so low rumble cannot open it
      shpf = 200.0;
    })
    (lv2 "comp" "${lsp}compressor_mono" {
      cm = 0.0;
      al = 0.0631; # threshold -24 dB
      cr = 5.0;
      at = 8.0;
      rt = 120.0;
      kn = 0.5;
      mk = 2.51; # makeup +8 dB
    })
    (ladspa "voice1" "autotalent" "autotalent" (shift (-4.0)))
    (ladspa "voice2" "autotalent" "autotalent" (shift (-7.3)))
    # Linear gains: first voice 1.0, second voice 0.79 (-2 dB).
    (builtin "voices" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.79;
    })
    (builtin "eq1" "bq_highpass" {
      Freq = 100.0;
      Q = 0.7;
    })
    (builtin "eq2" "bq_peaking" {
      Freq = 400.0;
      Q = 1.1;
      Gain = -4.5;
    })
    (builtin "eq3" "bq_peaking" {
      Freq = 1200.0;
      Q = 1.0;
      Gain = 6.0;
    })
    (builtin "eq4" "bq_peaking" {
      Freq = 2800.0;
      Q = 0.9;
      Gain = 8.0;
    })
    (builtin "eq5" "bq_highshelf" {
      Freq = 7500.0;
      Q = 0.7;
      Gain = -3.0;
    })
    # Wet only; the dry signal is mixed back in by `mix`.
    (ladspa "verb" "gverb_1216" "gverb" {
      "Roomsize (m)" = 55.0;
      "Reverb time (s)" = 2.8;
      Damping = 0.6;
      "Input bandwidth" = 0.75;
      "Dry signal level (dB)" = -70.0;
      "Early reflection level (dB)" = -20.0;
      "Tail level (dB)" = -10.0;
    })
    (builtin "mix" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.25; # reverb amount -12 dB
    })
    # Fixed gain (-8 dB) in front of the limiter; boost/alr are off so quiet sounds are not raised.
    (lv2 "limiter" "${lsp}limiter_mono" {
      g_in = 0.4;
      boost = 0.0;
      alr = 0.0;
      th = 0.63;
    })
  ];

  links = [
    (link "hp_in:Out" "gate:in")
    (link "gate:out" "comp:in")
    (link "comp:out" "voice1:Input")
    (link "comp:out" "voice2:Input")
    (link "voice1:Output" "voices:In 1")
    (link "voice2:Output" "voices:In 2")
    (link "voices:Out" "eq1:In")
    (link "eq1:Out" "eq2:In")
    (link "eq2:Out" "eq3:In")
    (link "eq3:Out" "eq4:In")
    (link "eq4:Out" "eq5:In")
    (link "eq5:Out" "verb:Input")
    (link "eq5:Out" "mix:In 1")
    (link "verb:Left output" "mix:In 2")
    (link "mix:Out" "limiter:in")
  ];

  inputs = [ "hp_in:In" ];
  outputs = [ "limiter:out" ];
}
