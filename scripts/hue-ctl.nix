{ pkgs, ... }:

let
  # Flattens the bridge's resource dump into the shape the quickshell panel wants.
  stateFilter = pkgs.writeText "hue-state.jq" ''
      (.data | map(select(.type == "light")) | INDEX(.id))                      as $lights
    | (.data | map(select(.type == "device"))
        | map({ key: .id, value: (.services | map(select(.rtype == "light")) | map(.rid) | first) })
        | from_entries)                                                         as $devlight
    | (.data | map(select(.type == "grouped_light")) | INDEX(.id))              as $groups
    | (.data | map(select(.type == "scene")))                                   as $scenes
    | {
        all: (($groups | to_entries | map(select(.value.owner.rtype == "bridge_home")) | map(.key) | first) // ""),
        rooms: (
          .data
          | map(select(.type == "room"))
          | sort_by(.metadata.name)
          | map(
              .id as $rid
            | ((.services | map(select(.rtype == "grouped_light")) | map(.rid) | first) // "") as $gid
            | ([ .children[].rid
                 | $devlight[.] // empty
                 | $lights[.] // empty
                 | { id: .id,
                     name: .metadata.name,
                     archetype: (.metadata.archetype // ""),
                     on: .on.on,
                     brightness: (.dimming.brightness // 0),
                     ct: (.color_temperature != null),
                     hasColor: (.color != null),
                     colorX: (.color.xy.x // 0),
                     colorY: (.color.xy.y // 0),
                     effect: (.effects_v2.status.effect // "no_effect"),
                     effects: (.effects_v2.action.effect_values // []),
                     mirek: (.color_temperature.mirek // 0),
                     mirekMin: (.color_temperature.mirek_schema.mirek_minimum // 153),
                     mirekMax: (.color_temperature.mirek_schema.mirek_maximum // 500) } ]
               | sort_by(.name))                                                as $roomLights
            | ($roomLights | map(select(.ct)))                                  as $ctLights
            | (($roomLights | map(.effects)) as $lists
               | if ($lists | length) == 0 then []
                 else ($lists[0] | map(. as $e | select(all($lists[]; index($e) != null))))
                 end)                                                       as $roomEffects
            | (($roomLights | map(.effect) | unique) as $e
               | if ($e | length) == 1 then $e[0] else "" end)              as $roomEffect
            | ($roomLights | map(select(.hasColor and .colorX > 0)))             as $colorLights
            | ((($colorLights | map(select(.on)) | first) // ($colorLights | first)) // null) as $colorRef
            | {
                id: $rid,
                name: .metadata.name,
                group: $gid,
                on: ($groups[$gid].on.on // false),
                brightness: ($groups[$gid].dimming.brightness // 0),
                ct: (($ctLights | length) > 0),
                hasColor: (($roomLights | map(select(.hasColor)) | length) > 0),
                effect: $roomEffect,
                effects: $roomEffects,
                colorX: ($colorRef.colorX // 0),
                colorY: ($colorRef.colorY // 0),
                mirek: ($ctLights | map(select(.mirek > 0) | .mirek) | if length > 0 then ((add / length) | round) else 0 end),
                mirekMin: (($ctLights | map(.mirekMin) | max) // 153),
                mirekMax: (($ctLights | map(.mirekMax) | min) // 500),
                lights: $roomLights,
                scenes: ([ $scenes[]
                           | select(.group.rid == $rid)
                           | { id: .id,
                               name: .metadata.name,
                               active: (.status.active != "inactive"),
                               colors: ([ (.actions // [])[].action
                                          | (.effects_v2.action.parameters // {}) as $fx
                                          | if .color.xy then { x: .color.xy.x, y: .color.xy.y }
                                            elif .color_temperature.mirek then { mirek: .color_temperature.mirek }
                                            elif $fx.color.xy then { x: $fx.color.xy.x, y: $fx.color.xy.y }
                                            elif $fx.color_temperature.mirek then { mirek: $fx.color_temperature.mirek }
                                            else empty end ]
                                        | unique | .[0:3]) } ]
                         | sort_by(.name))
              }
            )
        )
      }
  '';
in
pkgs.writeShellScriptBin "hue-ctl" ''
  set -euo pipefail

  key_file="/run/agenix/hue-api-key"
  ip_file="''${XDG_CONFIG_HOME:-$HOME/.config}/hue/bridge-ip"

  usage() {
    echo "usage: hue-ctl <command>" >&2
    echo "" >&2
    echo "  state                  bridge state as JSON (rooms, lights, scenes)" >&2
    echo "  group <id> <json>      PUT on a grouped_light resource" >&2
    echo "  light <id> <json>      PUT on a light resource" >&2
    echo "  lights <json> <id>...  same PUT on several lights" >&2
    echo "  scene <id>             recall a scene" >&2
  }

  [ -r "$key_file" ] || { echo "hue-ctl: no API key at $key_file (agenix secret not decrypted?)" >&2; exit 1; }
  [ -r "$ip_file" ] || { echo "hue-ctl: no bridge address at $ip_file" >&2; exit 1; }

  key=$(tr -d '[:space:]' < "$key_file")
  bridge=$(tr -d '[:space:]' < "$ip_file")
  [ -n "$bridge" ] || { echo "hue-ctl: empty bridge address in $ip_file" >&2; exit 1; }

  # The key goes through a curl config file on stdin so it stays out of argv.
  api() {
    local method=$1 path=$2 body=''${3:-}
    local args=(--silent --show-error --insecure --max-time 10 -X "$method" -K - "https://$bridge/clip/v2/resource$path")
    if [ -n "$body" ]; then
      args+=(-H "Content-Type: application/json" --data-raw "$body")
    fi
    printf 'header = "hue-application-key: %s"\n' "$key" | ${pkgs.curl}/bin/curl "''${args[@]}"
  }

  put() {
    local resp
    resp=$(api PUT "$1" "$2")
    if ! printf '%s' "$resp" | ${pkgs.jq}/bin/jq -e '(.errors // []) | length == 0' > /dev/null; then
      echo "hue-ctl: $resp" >&2
      exit 1
    fi
  }

  case "''${1:-}" in
    state)
      api GET "" | ${pkgs.jq}/bin/jq -c -f ${stateFilter}
      ;;
    group)
      [ $# -eq 3 ] || { usage; exit 1; }
      put "/grouped_light/$2" "$3"
      ;;
    light)
      [ $# -eq 3 ] || { usage; exit 1; }
      put "/light/$2" "$3"
      ;;
    lights)
      [ $# -ge 3 ] || { usage; exit 1; }
      body=$2
      shift 2
      for id in "$@"; do
        put "/light/$id" "$body"
      done
      ;;
    scene)
      [ $# -eq 2 ] || { usage; exit 1; }
      put "/scene/$2" '{"recall":{"action":"active"}}'
      ;;
    *)
      usage
      exit 1
      ;;
  esac
''
