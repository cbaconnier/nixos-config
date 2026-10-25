{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Warm narrator: the voice slightly lowered and warmed, with a light reverb.
#   high-pass -> gate -> de-esser -> compressor -> pitch -1.5 semitones -> EQ -> reverb -> limiter
{
  description = "Storyteller";

  nodes = [
    # Cuts mic handling noise before the gate and the pitch shifter.
    (builtin "hp_in" "bq_highpass" {
      Freq = 80.0;
      Q = 0.7;
    })
    (lv2 "gate" "${lsp}gate_mono" {
      gt = 0.0032; # threshold -50 dB
      gr = 0.001; # closed gate attenuation -60 dB
      at = 1.0;
      rt = 200.0;
      shpm = 2.0; # the gate only listens above 200 Hz, so low rumble cannot open it
      shpf = 200.0;
    })
    # Broadband de-esser: a compressor whose detector only hears above 4.5 kHz.
    (lv2 "deess" "${lsp}compressor_mono" {
      cm = 0.0;
      shpm = 2.0;
      shpf = 4500.0;
      al = 0.1; # threshold -20 dB
      cr = 3.0;
      at = 2.0;
      rt = 60.0;
      kn = 0.5;
    })
    (lv2 "comp" "${lsp}compressor_mono" {
      cm = 0.0;
      al = 0.1; # threshold -20 dB
      cr = 4.0;
      at = 5.0;
      rt = 75.0;
      kn = 0.5;
      mk = 2.0; # makeup +6 dB
    })
    # Time-domain pitch shift of -1.5 semitones (one scale note is one semitone with all
    # 12 notes allowed; correction strength 0 leaves the pitch uncorrected).
    (ladspa "pitch" "autotalent" "autotalent" {
      "Pitch shift (scale notes)" = -1.5;
      "Correction strength" = 0.0;
      "Pull to fixed pitch" = 0.0;
      "Formant correction" = 0.0;
      Mix = 1.0;
      Bb = 0.0;
      Db = 0.0;
      Eb = 0.0;
      Gb = 0.0;
      Ab = 0.0;
    })
    (builtin "eq1" "bq_lowshelf" {
      Freq = 150.0;
      Q = 0.7;
      Gain = 4.5;
    })
    (builtin "eq2" "bq_peaking" {
      Freq = 180.0;
      Q = 1.0;
      Gain = 3.5;
    })
    (builtin "eq3" "bq_peaking" {
      Freq = 800.0;
      Q = 1.0;
      Gain = -2.0;
    })
    (builtin "eq4" "bq_peaking" {
      Freq = 3500.0;
      Q = 0.7;
      Gain = 1.0;
    })
    (builtin "eq5" "bq_highshelf" {
      Freq = 9000.0;
      Q = 0.7;
      Gain = -3.0;
    })
    # Wet only; the dry signal is mixed back in by `mix`.
    (ladspa "verb" "gverb_1216" "gverb" {
      "Roomsize (m)" = 30.0;
      "Reverb time (s)" = 3.0;
      Damping = 0.6;
      "Input bandwidth" = 0.75;
      "Dry signal level (dB)" = -70.0;
      "Early reflection level (dB)" = -20.0;
      "Tail level (dB)" = -10.0;
    })
    (builtin "mix" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.063; # reverb amount -24 dB
    })
    # Fixed gain (-2 dB) in front of the limiter; boost/alr are off so quiet sounds are not raised.
    (lv2 "limiter" "${lsp}limiter_mono" {
      g_in = 0.8;
      boost = 0.0;
      alr = 0.0;
      th = 0.89;
    })
  ];

  links = [
    (link "hp_in:Out" "gate:in")
    (link "gate:out" "deess:in")
    (link "deess:out" "comp:in")
    (link "comp:out" "pitch:Input")
    (link "pitch:Output" "eq1:In")
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
