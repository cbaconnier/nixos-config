{ pkgs, config, ... }:
{
  home.activation.claude-theme = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    _s="$HOME/.claude/settings.json"
    if [ -f "$_s" ]; then
      ${pkgs.jq}/bin/jq '.theme = "dark"' "$_s" > "$_s.tmp" && mv "$_s.tmp" "$_s"
    fi
  '';
}
