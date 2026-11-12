let
  agenix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBpSApCh+4eXV7ZYYJoG09S49Cyu5Pr/7Jd3kJ/95pw agenix";
  laptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMoZlGC7nFRkpodSUFXu9ulBykjZ6ZMee22aZStBUNgD root@laptop";
  home = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6pRVIeyj9AvBB0y0F6JuJ8+al8GR6O/3cbPheDced2 root@home";
  bento = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEMJQVj/5c/lzhQrznU5WiZb1PSVmBkmsLpOcO3dcDWh root@bento";
  keys = [
    agenix
    laptop
    home
    bento
  ];
in
{
  "hue-api-key.age".publicKeys = keys;
  "alloy-ingest.age".publicKeys = keys;
  "rbw-email.age".publicKeys = keys;
  "caddy-ingest.age".publicKeys = keys;
  "grafana-env.age".publicKeys = keys;
}
