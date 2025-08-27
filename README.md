# rainbow_edge_lighting 🌈

A Flutter widget that adds animated rainbow edge lighting around any child widget.

![Rainbow edge lighting screen](https://github.com/vlcl753/rainbow_edge_lighting/blob/main/rainbow_screen.gif?raw=true)

## Installation

```yaml
dependencies:
  rainbow_edge_lighting: ^1.1.0
```

---

## How it works

Wrap any widget with `RainbowEdgeLighting`:

```dart
import 'package:flutter/material.dart';
import 'package:rainbow_edge_lighting/rainbow_edge_lighting.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});
  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RainbowEdgeLighting(
        glowEnabled: true, // Enable outer glow halo
        radius: 20,        // corner radius
        thickness: 2.0,    // stroke width
        enabled: enabled,  // fade in/out when toggled
        speed: 0.8,        // rotations per second (rps)
        clip: false,       // clip the child with the same radius
        child: ElevatedButton(
          onPressed: () => setState(() => enabled = !enabled),
          child: Text(enabled ? 'ON' : 'OFF'),
        ),
      ),
    );
  }
}
```

A rotating rainbow stroke is painted around the child’s edge. Toggling `enabled` fades it smoothly in/out.

---

## Customize it

All accepted parameters:

| Name                      | Type            | Usage                                                                 | Required | Default |
|---------------------------|-----------------|-----------------------------------------------------------------------|:--------:|:-------:|
| `child`                   | `Widget`        | The inner widget inside the lighting border                           | **yes**  | `null`  |
| `radius`                  | `double`        | Corner radius of the border                                           | **yes**  | `null`    |
| `thickness`               | `double`        | Rainbow stroke width                                                  |    no    | `3.0`   |
| `colors`                  | `List<Color>?`  | Gradient colors (falls back to a rainbow palette)                     |    no    | `[red, orange, yellow, green, blue, indigo, purple, red]` |
| `enabled`                 | `bool`          | Turn animation on/off (with fade)                                     |    no    | `true`  |
| `speed`                   | `double`        | Rotation speed in rps (0 = stop)                                      |    no    | `0.8`   |
| `fadeDuration`            | `Duration`      | Fade-in/out duration when toggling                                    |    no    | `300ms` |
| `clip`                    | `bool`          | Clip the child with the same `radius`                                 |    no    | `false` |
| `glowEnabled`             | `bool`          | Enable outer glow halo (same palette as stroke)                       |    no    | `true`  |
| `showBorderWhenDisabled`  | `bool`          | Keep a static base border when disabled/faded out                     |    no    | `true`  |
| `disabledBorderColor`     | `Color`         | Base border color when disabled                                       |    no    | `0x33000000` |
| `disabledBorderThickness` | `double?`       | Base border width when disabled (defaults to `thickness`)             |    no    | `= thickness` |

**Notes**
- `speed` uses **rps (rotations per second)**. Example: `1.0` → one full rotation per second.
- If your `colors` start and end differ, the widget auto-applies a seamless loop so the gradient has **no visible seam**.
- If your child has rounded corners, set `clip: true` for a natural look.

---

## Quick examples

**1) Custom palette**
```dart
RainbowEdgeLighting(
  colors: const [
    Color(0xFFFF0080), // pink
    Color(0xFF7928CA), // purple
    Color(0xFF2AFADF), // cyan
    Color(0xFFFF0080), // close the loop
  ],
  speed: 1.2,
  radius: 20,
  child: const Text('Custom Colors'),
)
```

**2) Static border only (no animation)**
```dart
RainbowEdgeLighting(
  enabled: false,                 // animation off (fades out)
  radius: 20,
  showBorderWhenDisabled: true,   // keep static border
  disabledBorderColor: Colors.grey.withOpacity(0.4),
  disabledBorderThickness: 2.0,
  child: const Icon(Icons.lock),
)
```

**3) Clip the child to match radius**
```dart
RainbowEdgeLighting(
  clip: true,
  radius: 20,
  child: Container(
    width: 160,
    height: 64,
    radius: 20,
    color: Colors.black,
    alignment: Alignment.center,
    child: const Text('Clipped'),
  ),
)
```
