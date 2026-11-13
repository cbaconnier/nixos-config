{ lib, osConfig, ... }:
{
  programs.claude-code = {
    enable = true;
    package = null;
    skills = lib.optionalAttrs (osConfig.programs.playground.enable or false) {
      playground = ./skills/playground/SKILL.md;
    };
    settings = {
      env = {
        CLAUDE_CODE_ENABLE_TELEMETRY = "1";
        OTEL_METRICS_EXPORTER = "otlp";
        OTEL_LOGS_EXPORTER = "otlp";
        OTEL_EXPORTER_OTLP_PROTOCOL = "grpc";
        OTEL_EXPORTER_OTLP_ENDPOINT = "http://127.0.0.1:4317";
        OTEL_LOG_TOOL_DETAILS = "1";
        OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE = "cumulative";
      };
      model = "sonnet";
      tui = "fullscreen";
      theme = "dark";
      preferredNotifChannel = "notifications_disabled";
      # deny also for the unsafe mode. Unsafe, but I'm not suicidal either
      permissions.deny = [
        "Bash(ssh *)"
        "Bash(scp *)"
        "Bash(sftp *)"
        "Bash(rsync *)"
        "Bash(ssh-add *)"
        "Bash(git push *)"
        "Bash(gh *)"
        "Bash(rbw *)"
        "Bash(bw *)"
        "Bash(bw-pass *)"
        "Bash(agenix *)"
        "Bash(age *)"
        "Bash(clipse *)"
        "Bash(wl-paste *)"
        "Bash(grim *)"
        "Bash(wtype *)"
        "Bash(kitten *)"
        "Bash(sudo *)"
        "Bash(sudoedit *)"
        "Bash(su *)"
        "Bash(doas *)"
        "Bash(pkexec *)"
        "Bash(run0 *)"
        "Read(~/.config/**)"
        "Read(~/.ssh/**)"
        "Read(~/.aws/**)"
        "Read(~/.mozilla/**)"
        "Read(~/.docker/**)"
        "Read(~/.pki/**)"
        "Read(~/.var/**)"
        "Read(~/.cache/**)"
        "Read(~/.local/**)"
        "Read(~/.zsh_history)"
        "Read(~/.bash_history)"
        "Read(~/.claude/.credentials.json)"
        "Read(//run/agenix/**)"
        "Read(//**/.env)"
        "Read(//**/.env.*)"
        "Edit(~/.claude/settings.json)"
        "Edit(~/.claude/settings.local.json)"
      ];
      permissions.ask = [
        "Bash(nix run *)"
        "Bash(nix shell *)"
        "Bash(nix develop *)"
        "Bash(nix-shell *)"
      ];
    };
  };
}
