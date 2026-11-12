# Input: `hue-ctl state`. Output: one TSV row per lamp: id, name, reason, bri, target bri, command.
(first(.rooms[] | select(.name == $room)) // error("room not found: \($room)")) as $r
| (first($r.scenes[] | select(.name == $scene)) // error("scene not found: \($scene)")) as $s
| ($r.scenes | map(select(.status == "dynamic_palette" or (.active and (.name | IN($protect[]))))) | map(.name)) as $busy
| if ($busy | length) > 0 then
    ["", "*", "scene active: \($busy | join(", "))", "", "", ""]
  else
    $r.lights[]
    | $s.targets[.id] as $t
    | [ .id, .name,
        ( if $t == null then "not in scene"
          elif (.on | not) then "off"
          elif ($t.on | not) then "target is off"
          elif .effect != "no_effect" then "effect \(.effect)"
          elif .mirek == 0 then "not in white mode"
          elif $t.brightness == null then "scene has no brightness"
          elif .brightness <= $t.brightness + 5 then "already dim"
          else "ok" end ),
        .brightness, ($t.brightness // ""),
        ( { dimming: { brightness: $t.brightness }, dynamics: { duration: ($minutes * 60000) } }
          + if $t.mirek then { color_temperature: { mirek: $t.mirek } }
            elif $t.xy then { color: { xy: $t.xy } }
            else {} end
          | tojson ) ]
  end
| @tsv
