{
  ladspa,
  lv2,
  builtin,
  link,
  lsp,
  ...
}:

# Walkie-talkie: narrow band, hard compression, heavy grit, a crackling hiss.
#   high-pass -> gate -> low-pass -> presence EQ -> compressor -> crusher -> overdrive -> mixer -> gate -> limiter
#   The hiss is a 3 kHz band of the voice, overdriven, mixed back in at low level.
{
  description = "Walkie-talkie";

  nodes = [
    # Narrow band: 500 Hz - 2.8 kHz, with a steeper top (two low-pass stages).
    (builtin "hp" "bq_highpass" {
      Freq = 500.0;
      Q = 0.707;
    })
    # Keeps the mic noise out of the compressor makeup and the overdrive.
    (lv2 "gate" "${lsp}gate_mono" {
      gt = 0.0032; # threshold -50 dB
      gr = 0.001; # closed gate attenuation -60 dB
      at = 1.0;
      rt = 100.0;
      shpm = 2.0; # the gate only listens above 200 Hz, so low rumble cannot open it
      shpf = 200.0;
    })
    (builtin "lp1" "bq_lowpass" {
      Freq = 2800.0;
      Q = 0.707;
    })
    (builtin "lp2" "bq_lowpass" {
      Freq = 2800.0;
      Q = 0.707;
    })
    (builtin "presence" "bq_peaking" {
      Freq = 1500.0;
      Q = 1.0;
      Gain = 5.0;
    })
    (lv2 "comp" "${lsp}compressor_mono" {
      cm = 0.0;
      al = 0.1; # threshold -20 dB
      cr = 8.0;
      at = 2.0;
      rt = 50.0;
      kn = 0.5;
      mk = 4.0; # makeup +12 dB
    })
    # Cheap digital radio: 8 bits at 8 kHz sampling.
    (ladspa "crush" "decimator_1202" "decimator" {
      "Bit depth" = 8.0;
      "Sample rate (Hz)" = 8000.0;
    })
    (ladspa "grit" "foverdrive_1196" "foverdrive" { "Drive level" = 3.0; })
    (builtin "air" "bq_bandpass" {
      Freq = 3000.0;
      Q = 0.5;
    })
    (ladspa "hiss" "foverdrive_1196" "foverdrive" { "Drive level" = 3.0; })
    (builtin "mix" "mixer" {
      "Gain 1" = 1.0;
      "Gain 2" = 0.25;
    })
    # The crusher's quantizer has no zero level: on silence it outputs a constant +-1/2 LSB
    # square noise, which is the continuous hiss. Only a gate after it can remove it; the
    # threshold (-34 dB) sits above that noise (-40 dB) and below the voice (-25..-10 dB).
    (lv2 "gate_out" "${lsp}gate_mono" {
      gt = 0.02;
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
    (link "gate:out" "lp1:In")
    (link "lp1:Out" "lp2:In")
    (link "lp2:Out" "presence:In")
    (link "presence:Out" "comp:in")
    (link "comp:out" "crush:Input")
    (link "crush:Output" "grit:Input")
    (link "comp:out" "air:In")
    (link "air:Out" "hiss:Input")
    (link "grit:Output" "mix:In 1")
    (link "hiss:Output" "mix:In 2")
    (link "mix:Out" "gate_out:in")
    (link "gate_out:out" "limiter:in")
  ];

  inputs = [ "hp:In" ];
  outputs = [ "limiter:out" ];
}
