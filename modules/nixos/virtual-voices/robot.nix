{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Robot: a 50 Hz ring modulation buzzes the voice, a flanger metallizes it, a bit crusher
# adds digital grit.
#   high-pass -> gate -> ring modulator -> flanger -> crusher -> band-pass -> compressor -> gate -> limiter
{
  description = "Robot";

  nodes = [
    (builtin "hp" "bq_highpass" {
      Freq = 120.0;
      Q = 0.707;
    })
    # The ring modulator buzzes on any noise, so the gate stays tight.
    (lv2 "gate" "${lsp}gate_mono" {
      gt = 0.0032; # threshold -50 dB
      gr = 0.001; # closed gate attenuation -60 dB
      at = 1.0;
      rt = 100.0;
      shpm = 2.0; # the gate only listens above 200 Hz, so low rumble cannot open it
      shpf = 200.0;
    })
    # Depth 2 is pure ring modulation (1 would be amplitude modulation).
    (ladspa "ring" "ringmod_1188" "ringmod_1i1o1l" {
      "Modulation depth (0=none, 1=AM, 2=RM)" = 2.0;
      "Frequency (Hz)" = 50.0;
      "Sine level" = 1.0;
      "Triangle level" = 0.0;
      "Sawtooth level" = 0.0;
      "Square level" = 0.0;
    })
    (ladspa "flange" "flanger_1191" "flanger" {
      "Delay base (ms)" = 6.0;
      "Max slowdown (ms)" = 2.0;
      "LFO frequency (Hz)" = 0.5;
      Feedback = 0.4;
    })
    (ladspa "crush" "decimator_1202" "decimator" {
      "Bit depth" = 10.0;
      "Sample rate (Hz)" = 16000.0;
    })
    (builtin "bp_hp" "bq_highpass" {
      Freq = 300.0;
      Q = 0.707;
    })
    (builtin "bp_lp" "bq_lowpass" {
      Freq = 5000.0;
      Q = 0.707;
    })
    (lv2 "comp" "${lsp}compressor_mono" {
      cm = 0.0;
      al = 0.1; # threshold -20 dB
      cr = 4.0;
      at = 5.0;
      rt = 75.0;
      kn = 0.5;
      mk = 4.0; # makeup +12 dB, the ring modulator lowers the level
    })
    # The crusher's quantizer has no zero level: on silence it outputs a constant +-1/2 LSB
    # square noise, which the compressor makeup raises into a continuous hiss. Only a gate
    # after it can remove it; the threshold (-40 dB) sits above that noise and below the voice.
    (lv2 "gate_out" "${lsp}gate_mono" {
      gt = 0.01;
      gr = 0.001; # closed gate attenuation -60 dB
      at = 1.0;
      rt = 150.0;
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
    (link "gate:out" "ring:Input")
    (link "ring:Output" "flange:Input")
    (link "flange:Output" "crush:Input")
    (link "crush:Output" "bp_hp:In")
    (link "bp_hp:Out" "bp_lp:In")
    (link "bp_lp:Out" "comp:in")
    (link "comp:out" "gate_out:in")
    (link "gate_out:out" "limiter:in")
  ];

  inputs = [ "hp:In" ];
  outputs = [ "limiter:out" ];
}
