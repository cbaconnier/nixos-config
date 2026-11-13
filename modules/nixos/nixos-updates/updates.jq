def esc: gsub("\\\\"; "\\\\\\\\") | gsub("\""; "\\\"");

gsub("\u001b\\[[0-9;]*m"; "")
| capture("^\\s*(?<package>[^:]+): (?<from>.+) → (?<to>.+?)(, [+-][0-9.]+ KiB)?$")
| "nixos_update_package{package=\"\(.package | esc)\",from=\"\(.from | esc)\",to=\"\(.to | esc)\"} 1"
