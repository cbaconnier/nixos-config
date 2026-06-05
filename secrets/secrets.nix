let
  clement = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmZBpXRxxtLSikNIKhM60HV4/785VVIwDv33NDqvDoL nixos-agenix";
in
{
  "hue-api-key.age".publicKeys = [ clement ];
}
