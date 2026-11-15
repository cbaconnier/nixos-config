gsub("\u001b\\[[0-9;]*m"; "")
| capture("^\\s*(?<package>[^:]+): (?<from>.+) → (?<to>.+?)(, (?<size>[+-]?[0-9.]+ [KMG]iB))?$")
