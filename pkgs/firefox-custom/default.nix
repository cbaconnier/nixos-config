# Firefox trusting the Caddy root CA, always launching the original *.default profile
{
  firefox,
  symlinkJoin,
  runtimeShell,
}:

let
  firefoxWithCert = firefox.override {
    extraPolicies.Certificates.Install = [ "${../../files/certs/caddy-root.crt}" ];
  };
in
symlinkJoin {
  name = "firefox-custom";
  paths = [ firefoxWithCert ];
  postBuild = ''
    rm $out/bin/firefox
    cat > $out/bin/firefox <<'EOF'
    #!${runtimeShell}
    for profile in "$HOME"/.mozilla/firefox/*.default "$HOME"/.mozilla/firefox/*.default-release; do
      if [ -d "$profile" ]; then
        exec ${firefoxWithCert}/bin/firefox --profile "$profile" "$@"
      fi
    done
    exec ${firefoxWithCert}/bin/firefox "$@"
    EOF
    chmod +x $out/bin/firefox
  '';
}
