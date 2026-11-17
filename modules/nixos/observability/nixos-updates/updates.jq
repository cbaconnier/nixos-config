def esc: gsub("\\\\"; "\\\\\\\\") | gsub("\""; "\\\"");

"nixos_update_package{package=\"\(.package | esc)\",from=\"\(.from | esc)\",to=\"\(.to | esc)\",size=\"\(.size // "" | esc)\",changelog=\"\($changelogs[.package] // "" | esc)\"} 1"
