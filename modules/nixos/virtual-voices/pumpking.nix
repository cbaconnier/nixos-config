{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Pumpking, "This is Halloween" style: a theatrical, snarling baritone, a gang of voices behind it.
#   high-pass -> gate -> compressor -> pitch -3 semitones, formants lowered -> EQ
#   the voice is also sent through a tiny room (a hint of hollow gourd), overdriven (rasp)
#   and chorused (the crowd), mixed back in, then a theatrical reverb.
{
  description = "Pumpking";

  nodes = [
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
      cr = 6.0;
      at = 10.0;
      rt = 150.0;
      kn = 0.5;
      mk = 2.51; # makeup +8 dB
    })
    # Mild negative formant warp: bigger than human, still articulate.
    (ladspa "pitch" "autotalent" "autotalent" {
      "Pitch shift (scale notes)" = -3.0;
      "Correction strength" = 0.0;
      "Pull to fixed pitch" = 0.0;
      "Formant correction" = 1.0;
      "Formant warp" = -0.25;
      Mix = 1.0;
      Bb = 0.0;
      Db = 0.0;
      Eb = 0.0;
      Gb = 0.0;
      Ab = 0.0;
    })
    (builtin "eq1" "bq_highpass" {
      Freq = 70.0;
      Q = 0.7;
    })
    (builtin "eq2" "bq_lowshelf" {
      Freq = 120.0;
      Q = 0.7;
      Gain = 3.0;
    })
    # Presence, so the diction cuts through the music.
    (builtin "eq3" "bq_peaking" {
      Freq = 2500.0;
      Q = 0.9;
      Gain = 3.0;
    })
    (builtin "eq4" "bq_lowpass" {
      Freq = 7000.0;
      Q = 0.707;
    })
    # Wet only: the inside of the gourd, a tiny dense room.
    (ladspa "shell" "gverb_1216" "gverb" {
      "Roomsize (m)" = 3.0;
      "Reverb time (s)" = 0.35;
      Damping = 0.4;
      "Input bandwidth" = 0.6;
      "Dry signal level (dB)" = -70.0;
      "Early reflection level (dB)" = -6.0;
      "Tail level (dB)" = -8.0;
    })
    (ladspa "rasp" "foverdrive_1196" "foverdrive" { "Drive level" = 3.0; })
    (builtin "rasp_lp" "bq_lowpass" {
      Freq = 3500.0;
      Q = 0.707;
    })
    # The crowd chanting along.
    (ladspa "crowd" "multivoice_chorus_1201" "multivoiceChorus" {
      "Number of voices" = 4.0;
      "Delay base (ms)" = 22.0;
      "Voice separation (ms)" = 5.0;
      "Detune (%)" = 4.0;
      "LFO frequency (Hz)" = 1.5;
      "Output attenuation (dB)" = -3.0;
    })
    # Wet only; the dry signal is mixed back in by `mix`.
    (ladspa "verb" "gverb_1216" "gverb" {
      "Roomsize (m)" = 14.0;
      "Reverb time (s)" = 0.9;
      Damping = 0.6;
      "Input bandwidth" = 0.7;
      "Dry signal level (dB)" = -70.0;
      "Early reflection level (dB)" = -18.0;
      "Tail level (dB)" = -12.0;
    })
    # Linear gains: voice 1.0, shell 0.2, rasp 0.4, reverb 0.2, crowd 0.45.
    (builtin "mix" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.2;
      "Gain 3" = 0.4;
      "Gain 4" = 0.2;
      "Gain 5" = 0.45;
    })
    # boost and alr are off: the limiter only limits, it does not raise quiet sounds
    (lv2 "limiter" "${lsp}limiter_mono" {
      g_in = 0.5;
      boost = 0.0;
      alr = 0.0;
      th = 0.708;
    })
  ];

  links = [
    (link "hp_in:Out" "gate:in")
    (link "gate:out" "comp:in")
    (link "comp:out" "pitch:Input")
    (link "pitch:Output" "eq1:In")
    (link "eq1:Out" "eq2:In")
    (link "eq2:Out" "eq3:In")
    (link "eq3:Out" "eq4:In")
    (link "eq4:Out" "shell:Input")
    (link "eq4:Out" "rasp:Input")
    (link "rasp:Output" "rasp_lp:In")
    (link "eq4:Out" "crowd:Input")
    (link "eq4:Out" "verb:Input")
    (link "eq4:Out" "mix:In 1")
    (link "shell:Left output" "mix:In 2")
    (link "rasp_lp:Out" "mix:In 3")
    (link "verb:Left output" "mix:In 4")
    (link "crowd:Output" "mix:In 5")
    (link "mix:Out" "limiter:in")
  ];

  inputs = [ "hp_in:In" ];
  outputs = [ "limiter:out" ];
}
