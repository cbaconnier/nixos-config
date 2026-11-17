def esc: tostring | gsub("\\\\"; "\\\\\\\\") | gsub("\""; "\\\"");

.[]
| . as $p
| .affected_by[]
| "nixos_cve{scope=\"\($scope)\",package=\"\(($p.pname // $p.name) | esc)\",version=\"\(($p.version // "") | esc)\",cve=\"\(. | esc)\"} \($p.cvssv3_basescore[.] // 0)"
