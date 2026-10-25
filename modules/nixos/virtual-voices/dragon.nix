{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Deep dragon: the voice lowered by 7 semitones, with a growl and a large reverb.
#   high-pass -> gate -> compressor -> pitch -7 semitones -> growl -> EQ -> reverb -> limiter
# growl: the voice multiplied by a ~30 Hz oscillator (rolled R, engine rumble), blended in.
{
  description = "Dragon";

  nodes = [
    # Cuts mic handling noise (bumps, table knocks) before the gate and the pitch shifter.
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
      at = 10.0;
      rt = 100.0;
      kn = 0.5;
      mk = 2.51; # makeup +8 dB
    })
    # Time-domain pitch shift, which keeps speech natural. With all 12 notes allowed, one scale
    # note is one semitone; correction strength 0 leaves the pitch uncorrected.
    (ladspa "pitch" "autotalent" "autotalent" {
      "Pitch shift (scale notes)" = -7.0;
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
    # Oscillator swinging between 0.6 and 1.0 at 30 Hz: amplitude modulation depth 40%.
    (builtin "rumble" "sine" {
      Freq = 30.0;
      Ampl = 0.2;
      Offset = 0.8;
    })
    (builtin "growl" "mult" { })
    (builtin "blend" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.6; # growl amount
    })
    (builtin "eq1" "bq_highpass" {
      Freq = 90.0;
      Q = 0.7;
    })
    (builtin "eq2" "bq_lowshelf" {
      Freq = 160.0;
      Q = 0.7;
      Gain = 5.71;
    })
    (builtin "eq3" "bq_peaking" {
      Freq = 260.0;
      Q = 1.0;
      Gain = 3.0;
    })
    (builtin "eq5" "bq_peaking" {
      Freq = 2600.0;
      Q = 0.9;
      Gain = 3.0;
    })
    (builtin "eq6" "bq_highshelf" {
      Freq = 7000.0;
      Q = 0.7;
      Gain = -6.0;
    })
    # Wet only; the dry signal is mixed back in by `mix`.
    (ladspa "verb" "gverb_1216" "gverb" {
      "Roomsize (m)" = 45.0;
      "Reverb time (s)" = 2.2;
      Damping = 0.6;
      "Input bandwidth" = 0.75;
      "Dry signal level (dB)" = -70.0;
      "Early reflection level (dB)" = -20.0;
      "Tail level (dB)" = -12.0;
    })
    # Sub-octave following the voice, tapped before the EQ high-pass (dragon weight).
    (lv2 "weight" "http://drobilla.net/plugins/mda/SubSynth" {
      type = 0.0;
      level = 0.60;
      tune = 0.45;
      dry_mix = 0.0;
      thresh = 0.55;
    })
    (builtin "mix" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.3; # reverb amount -10 dB
      "Gain 3" = 0.4; # sub
    })
    # Fixed gain (-8 dB) in front of the limiter; boost/alr are off so quiet sounds are not raised.
    (lv2 "limiter" "${lsp}limiter_mono" {
      g_in = 0.4;
      boost = 0.0;
      alr = 0.0;
      th = 0.708;
    })
  ];

  links = [
    (link "hp_in:Out" "gate:in")
    (link "gate:out" "comp:in")
    (link "comp:out" "pitch:Input")
    (link "pitch:Output" "blend:In 1")
    (link "pitch:Output" "growl:In 1")
    (link "rumble:Out" "growl:In 2")
    (link "growl:Out" "blend:In 2")
    (link "blend:Out" "eq1:In")
    (link "eq1:Out" "eq2:In")
    (link "eq2:Out" "eq3:In")
    (link "eq3:Out" "eq5:In")
    (link "eq5:Out" "eq6:In")
    (link "eq6:Out" "verb:Input")
    (link "eq6:Out" "mix:In 1")
    (link "verb:Left output" "mix:In 2")
    (link "blend:Out" "weight:left_in")
    (link "blend:Out" "weight:right_in")
    (link "weight:left_out" "mix:In 3")
    (link "mix:Out" "limiter:in")
  ];

  inputs = [ "hp_in:In" ];
  outputs = [ "limiter:out" ];
}
