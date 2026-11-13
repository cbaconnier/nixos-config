def esc: gsub("\\\\"; "\\\\\\\\") | gsub("\""; "\\\"");

gsub("\u001b\\[[0-9;]*m"; "")
| capture("^\\s*(?<package>[^:]+): (?<from>.+) → (?<to>.+?)(, (?<size>[+-]?[0-9.]+ [KMG]iB))?$")
| "nixos_update_package{package=\"\(.package | esc)\",from=\"\(.from | esc)\",to=\"\(.to | esc)\",size=\"\(.size // "" | esc)\"} 1"
