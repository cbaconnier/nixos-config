pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property var rooms: []
  property string allGroup: ""
  property bool available: false
  property bool loaded: false

  // Polling only runs while a consumer asks for it.
  property bool polling: false

  // Writes the bridge has not echoed back yet, so a slow poll cannot undo a click.
  property var pending: ({})
  property var pendingScene: null

  readonly property int pendingMs: 5000

  function refresh() {
    if (!stateProc.running)
      stateProc.running = true;
  }

  function roomById(id: string): var {
    return root.rooms.find(r => r.id === id) ?? null;
  }

  function recallScene(roomId: string, sceneId: string) {
    root.patchRoom(roomId, {
      on: true
    });
    root.patchScenes(roomId, sceneId);
    Quickshell.execDetached(["hue-ctl", "scene", sceneId]);
    settle.restart();
  }

  function setRoomOn(room: var, on: bool) {
    root.patchRoom(room.id, {
      on: on
    });
    root.put("group", room.group, {
      on: {
        on: on
      }
    });
  }

  function setRoomBrightness(room: var, pct: real) {
    // The bridge has no brightness 0; dragging to the bottom means off.
    if (pct < 1) {
      root.setRoomOn(room, false);
      return;
    }

    root.patchRoom(room.id, {
      on: true,
      brightness: pct
    });
    root.put("group", room.group, {
      on: {
        on: true
      },
      dimming: {
        brightness: pct
      }
    });
  }

  function setRoomMirek(room: var, mirek: int) {
    root.patchRoom(room.id, {
      on: true,
      mirek: mirek
    });
    root.put("group", room.group, {
      on: {
        on: true
      },
      color_temperature: {
        mirek: mirek
      }
    });
  }

  function setRoomColor(room: var, hue: real) {
    const xy = root.colorToXy(Qt.hsva(Math.max(0, Math.min(0.9999, hue / 360)), 1, 1, 1));

    // A plain colour write would cancel a running effect; tint it instead.
    if (root.running(room.effect)) {
      root.patchEffect(room, room.effect, {
        on: true,
        colorX: xy.x,
        colorY: xy.y
      });
      root.putLights(room.lights, room.effect, {
        color: {
          xy: xy
        }
      });
      return;
    }

    root.patchRoom(room.id, {
      on: true,
      colorX: xy.x,
      colorY: xy.y
    });
    root.put("group", room.group, {
      on: {
        on: true
      },
      color: {
        xy: xy
      }
    });
  }

  // Presets read back from the Hue app: an xy anchor, or mirek where the app
  // anchors on temperature instead; xy then only drives the swatch.
  readonly property var effectPresets: ({
      "candle": [
        { label: "Défaut", x: 0.49, y: 0.41 },
        { label: "Orange", x: 0.5798, y: 0.3922 },
        { label: "Blanc chaud", x: 0.5267, y: 0.4133, mirek: 500 }
      ],
      "fire": [
        { label: "Défaut", x: 0.58, y: 0.38 },
        { label: "Violet", x: 0.1741, y: 0.0577 },
        { label: "Vert", x: 0.162, y: 0.3909 }
      ],
      "prism": [
        { label: "Lumineux", x: 0.2116, y: 0.0759 },
        { label: "Pastel", x: 0.2969, y: 0.2427 }
      ],
      "sparkle": [
        { label: "Blanc", x: 0.3122, y: 0.3282, mirek: 153 },
        { label: "Jaune", x: 0.4598, y: 0.4105, mirek: 370 },
        { label: "Orange", x: 0.5899, y: 0.3846 },
        { label: "Rouge", x: 0.6915, y: 0.3083 }
      ],
      "opal": [
        { label: "Lumineux", x: 0.2694, y: 0.1039 },
        { label: "Pastel", x: 0.2969, y: 0.2427 }
      ],
      "glisten": [
        { label: "Doré", x: 0.4518, y: 0.4086, mirek: 357 },
        { label: "Rose", x: 0.3837, y: 0.246 },
        { label: "Violet", x: 0.2202, y: 0.11 }
      ],
      "underwater": [
        { label: "Bleu", x: 0.1698, y: 0.1824 },
        { label: "Bleu clair", x: 0.2245, y: 0.2707 },
        { label: "Turquoise", x: 0.1598, y: 0.3048 },
        { label: "Vert", x: 0.1617, y: 0.3761 }
      ],
      "cosmos": [
        { label: "Bleu", x: 0.1532, y: 0.0476 },
        { label: "Violet", x: 0.1853, y: 0.0635 },
        { label: "Rose", x: 0.2567, y: 0.0977 },
        { label: "Doré", x: 0.545, y: 0.3944 }
      ],
      "sunbeam": [
        { label: "Défaut", x: 0.2195, y: 0.2472 },
        { label: "Orange", x: 0.4556, y: 0.3622 },
        { label: "Violet", x: 0.218, y: 0.1496 }
      ],
      "enchant": [
        { label: "Défaut", x: 0.1532, y: 0.0476 }
      ]
    })

  function presetsFor(effect: string): var {
    return root.effectPresets[effect] ?? [];
  }

  function presetColor(preset: var): color {
    return root.xyColor(preset.x, preset.y);
  }

  function presetActive(room: var, effect: string, preset: var): bool {
    if (!room || room.effect !== effect)
      return false;
    return Math.abs(room.colorX - preset.x) < 0.01 && Math.abs(room.colorY - preset.y) < 0.01;
  }

  function applyPreset(room: var, effect: string, preset: var) {
    root.patchEffect(room, effect, {
      on: true,
      colorX: preset.x,
      colorY: preset.y
    });

    root.putLights(room.lights, effect, preset.mirek !== undefined ? {
      color_temperature: {
        mirek: preset.mirek
      }
    } : {
      color: {
        xy: {
          x: preset.x,
          y: preset.y
        }
      }
    });
  }

  // grouped_light has no effects_v2, so a room effect is written light by light.
  function setRoomEffect(room: var, effect: string) {
    root.patchEffect(room, effect, root.running(effect) ? {
      on: true
    } : ({}));
    root.putLights(room.lights, effect, null);
  }

  function patchEffect(room: var, effect: string, extra: var) {
    const fields = Object.assign({
      effect: effect
    }, extra);

    root.patchRoom(room.id, fields);

    for (const light of room.lights)
      if (light.effects.includes(effect))
        root.patchLight(light.id, fields);
  }

  function running(effect: string): bool {
    return !!effect && effect !== "no_effect";
  }

  function putLights(lights: var, effect: string, parameters: var) {
    const ids = lights.filter(l => l.effects.includes(effect)).map(l => l.id);
    if (ids.length === 0)
      return;

    const action = {
      effect: effect
    };
    if (parameters)
      action.parameters = parameters;

    const body = {
      effects_v2: {
        action: action
      }
    };
    if (root.running(effect))
      body.on = {
        on: true
      };

    Quickshell.execDetached(["hue-ctl", "lights", JSON.stringify(body)].concat(ids));
    settle.restart();
  }

  function setLightOn(light: var, on: bool) {
    root.patchLight(light.id, {
      on: on
    });
    root.put("light", light.id, {
      on: {
        on: on
      }
    });
  }

  function setLightBrightness(light: var, pct: real) {
    if (pct < 1) {
      root.setLightOn(light, false);
      return;
    }

    root.patchLight(light.id, {
      on: true,
      brightness: pct
    });
    root.put("light", light.id, {
      on: {
        on: true
      },
      dimming: {
        brightness: pct
      }
    });
  }

  function setLightMirek(light: var, mirek: int) {
    root.patchLight(light.id, {
      on: true,
      mirek: mirek
    });
    root.put("light", light.id, {
      on: {
        on: true
      },
      color_temperature: {
        mirek: mirek
      }
    });
  }

  function setLightColor(light: var, hue: real) {
    const xy = root.colorToXy(Qt.hsva(Math.max(0, Math.min(0.9999, hue / 360)), 1, 1, 1));

    root.patchLight(light.id, {
      on: true,
      colorX: xy.x,
      colorY: xy.y
    });

    if (root.running(light.effect)) {
      root.putLights([light], light.effect, {
        color: {
          xy: xy
        }
      });
      return;
    }

    root.put("light", light.id, {
      on: {
        on: true
      },
      color: {
        xy: xy
      }
    });
  }

  function allOff() {
    for (const room of root.rooms) {
      root.patchRoom(room.id, {
        on: false
      });

      for (const light of room.lights)
        root.patchLight(light.id, {
          on: false
        });
    }

    if (root.allGroup)
      root.put("group", root.allGroup, {
        on: {
          on: false
        }
      });
  }

  function put(kind: string, id: string, body: var) {
    if (!id)
      return;
    Quickshell.execDetached(["hue-ctl", kind, id, JSON.stringify(body)]);
    settle.restart();
  }

  // Bridge state lags behind a write, so echo it locally and defend it until it catches up.
  function remember(id: string, fields: var) {
    const next = Object.assign({}, root.pending);
    next[id] = {
      fields: Object.assign({}, next[id]?.fields ?? {}, fields),
      until: Date.now() + root.pendingMs
    };
    root.pending = next;
  }

  function patchRoom(roomId: string, fields: var) {
    root.remember(roomId, fields);
    root.rooms = root.rooms.map(r => r.id === roomId ? Object.assign({}, r, fields) : r);
  }

  function patchLight(lightId: string, fields: var) {
    root.remember(lightId, fields);
    root.rooms = root.rooms.map(r => Object.assign({}, r, {
      lights: r.lights.map(l => l.id === lightId ? Object.assign({}, l, fields) : l)
    }));
  }

  function patchScenes(roomId: string, activeId: string) {
    root.pendingScene = {
      room: roomId,
      scene: activeId,
      until: Date.now() + root.pendingMs
    };
    root.rooms = root.rooms.map(r => r.id !== roomId ? r : Object.assign({}, r, {
      scenes: r.scenes.map(s => Object.assign({}, s, {
        active: s.id === activeId
      }))
    }));
  }

  // Replays still-unconfirmed writes on top of a fresh bridge read.
  function overlay(fresh: var): var {
    const now = Date.now();
    const kept = {};

    const merge = o => {
      const p = root.pending[o.id];
      if (!p || p.until < now || root.agrees(o, p.fields))
        return o;
      kept[o.id] = p;
      return Object.assign({}, o, p.fields);
    };

    const out = fresh.map(r => {
      const room = merge(r);
      return Object.assign({}, room, {
        lights: room.lights.map(merge),
        scenes: root.overlayScenes(room.id, room.scenes, now)
      });
    });

    root.pending = kept;
    return out;
  }

  function overlayScenes(roomId: string, scenes: var, now: double): var {
    const p = root.pendingScene;
    if (!p || p.room !== roomId)
      return scenes;

    if (p.until < now || scenes.some(s => s.id === p.scene && s.active)) {
      root.pendingScene = null;
      return scenes;
    }

    return scenes.map(s => Object.assign({}, s, {
      active: s.id === p.scene
    }));
  }

  function agrees(current: var, fields: var): bool {
    for (const k in fields) {
      const want = fields[k];
      const have = current[k];
      // Percentages and mireds tolerate rounding; xy coordinates do not.
      const tolerance = Math.abs(want) >= 1 ? 1 : 0.01;
      if (typeof want === "number" ? Math.abs((have ?? 0) - want) > tolerance : have !== want)
        return false;
    }
    return true;
  }

  // CIE xy (Y normalised to the brightest channel) to sRGB, for scene swatches.
  function xyColor(x: real, y: real): color {
    if (y <= 0)
      return Qt.rgba(1, 1, 1, 1);

    const z = 1 - x - y;
    const X = x / y;
    const Z = z / y;

    let r = X * 3.2406 - 1.5372 - Z * 0.4986;
    let g = X * -0.9689 + 1.8758 + Z * 0.0415;
    let b = X * 0.0557 - 0.204 + Z * 1.057;

    const peak = Math.max(r, g, b, 1e-6);
    return Qt.rgba(root.gamma(r / peak), root.gamma(g / peak), root.gamma(b / peak), 1);
  }

  function gamma(c: real): real {
    const v = Math.max(0, Math.min(1, c));
    return v <= 0.0031308 ? 12.92 * v : 1.055 * Math.pow(v, 1 / 2.4) - 0.055;
  }

  // sRGB back to CIE xy, for writing a colour to the bridge.
  function colorToXy(c: color): var {
    const linear = v => v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
    const r = linear(c.r);
    const g = linear(c.g);
    const b = linear(c.b);

    const X = r * 0.4124 + g * 0.3576 + b * 0.1805;
    const Y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    const Z = r * 0.0193 + g * 0.1192 + b * 0.9505;
    const sum = X + Y + Z;

    return sum > 0 ? {
      x: X / sum,
      y: Y / sum
    } : {
      x: 0.3127,
      y: 0.329
    };
  }

  // Mired to an approximate blackbody colour (Tanner Helland's fit).
  function mirekColor(mirek: int): color {
    const k = Math.max(1000, Math.min(12000, 1000000 / Math.max(1, mirek))) / 100;
    let r, g, b;

    if (k <= 66) {
      r = 255;
      g = 99.4708025861 * Math.log(k) - 161.1195681661;
      b = k <= 19 ? 0 : 138.5177312231 * Math.log(k - 10) - 305.0447927307;
    } else {
      r = 329.698727446 * Math.pow(k - 60, -0.1332047592);
      g = 288.1221695283 * Math.pow(k - 60, -0.0755148492);
      b = 255;
    }

    const clamp = v => Math.max(0, Math.min(255, v)) / 255;
    return Qt.rgba(clamp(r), clamp(g), clamp(b), 1);
  }

  function swatchColor(entry: var): color {
    if (entry.mirek !== undefined)
      return root.mirekColor(entry.mirek);
    return root.xyColor(entry.x, entry.y);
  }

  Component.onCompleted: refresh()
  onPollingChanged: if (polling)
    refresh()

  Timer {
    interval: 4000
    repeat: true
    running: root.polling
    onTriggered: root.refresh()
  }

  // Lets the bridge apply a write before we trust its state again.
  Timer {
    id: settle

    interval: 700
    onTriggered: root.refresh()
  }

  Process {
    id: stateProc

    command: ["hue-ctl", "state"]

    stdout: StdioCollector {
      onStreamFinished: {
        let state;
        try {
          state = JSON.parse(text);
        } catch (e) {
          root.available = false;
          root.loaded = true;
          return;
        }

        root.rooms = root.overlay(state.rooms ?? []);
        root.allGroup = state.all ?? "";
        root.available = true;
        root.loaded = true;
      }
    }

    stderr: StdioCollector {
      onStreamFinished: if (text.trim())
        console.warn("hue:", text.trim())
    }
  }
}
