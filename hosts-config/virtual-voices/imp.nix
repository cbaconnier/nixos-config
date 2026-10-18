{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Imp: a high, nervous, mischievous voice.
#   high-pass -> gate -> pitch +6 semitones, formants raised -> tremolo (9 Hz) -> bright EQ
#   mixed with a light chorus and a short slapback.
{
  description = "Imp";

  nodes = [
    (builtin "hp_in" "bq_highpass" {
      Freq = 250.0;
      Q = 0.707;
    })
    (lv2 "gate" "${lsp}gate_mono" {
      gt = 0.0032; # threshold -50 dB
      gr = 0.001; # closed gate attenuation -60 dB
      at = 1.0;
      rt = 150.0;
      shpm = 2.0; # the gate only listens above 200 Hz, so low rumble cannot open it
      shpf = 200.0;
    })
    # Positive formant warp raises the formants: a smaller creature.
    (ladspa "pitch" "autotalent" "autotalent" {
      "Pitch shift (scale notes)" = 6.0;
      "Correction strength" = 0.0;
      "Pull to fixed pitch" = 0.0;
      "Formant correction" = 1.0;
      "Formant warp" = 0.5;
      Mix = 1.0;
      Bb = 0.0;
      Db = 0.0;
      Eb = 0.0;
      Gb = 0.0;
      Ab = 0.0;
    })
    # Depth 0.35 is a partial amplitude modulation: the voice quivers but is never cut.
    (ladspa "quiver" "ringmod_1188" "ringmod_1i1o1l" {
      "Modulation depth (0=none, 1=AM, 2=RM)" = 0.35;
      "Frequency (Hz)" = 9.0;
      "Sine level" = 1.0;
      "Triangle level" = 0.0;
      "Sawtooth level" = 0.0;
      "Square level" = 0.0;
    })
    (builtin "eq" "bq_highshelf" {
      Freq = 4000.0;
      Q = 0.7;
      Gain = 3.0;
    })
    (ladspa "chorus" "multivoice_chorus_1201" "multivoiceChorus" {
      "Number of voices" = 3.0;
      "Delay base (ms)" = 18.0;
      "Voice separation (ms)" = 2.0;
      "Detune (%)" = 2.0;
      "LFO frequency (Hz)" = 2.5;
      "Output attenuation (dB)" = -4.0;
    })
    (lv2 "echo" "urn:zamaudio:ZamDelay" {
      time = 70.0;
      feedb = 0.2;
      lpf = 5000.0;
      drywet = 1.0;
      gain = -10.0;
    })
    # Linear gains: voice 1.0, chorus 0.5, echo 0.3.
    (builtin "mix" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.5;
      "Gain 3" = 0.3;
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
    (link "hp_in:Out" "gate:in")
    (link "gate:out" "pitch:Input")
    (link "pitch:Output" "quiver:Input")
    (link "quiver:Output" "eq:In")
    (link "eq:Out" "chorus:Input")
    (link "eq:Out" "echo:lv2_audio_in_1")
    (link "eq:Out" "mix:In 1")
    (link "chorus:Output" "mix:In 2")
    (link "echo:lv2_audio_out_1" "mix:In 3")
    (link "mix:Out" "limiter:in")
  ];

  inputs = [ "hp_in:In" ];
  outputs = [ "limiter:out" ];
}
