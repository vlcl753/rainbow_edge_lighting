import 'package:flutter/material.dart';
import 'package:rainbow_edge_lighting/rainbow_edge_lighting.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LightingDemoPage(),
    );
  }
}

/// Generate [count] evenly spaced colors using HSL.
/// [sat] = saturation, [light] = lightness
List<Color> hslSweep({
  int count = 10,
  double sat = 0.8,
  double light = 0.55,
}) {
  assert(count >= 2);
  final list = <Color>[];
  for (int i = 0; i < count; i++) {
    final h = i / count; // 0..1
    final c = HSLColor.fromAHSL(1, h * 360, sat, light).toColor();
    list.add(c);
  }
  return smoothLoop(list);
}

class LightingDemoPage extends StatefulWidget {
  const LightingDemoPage({super.key});

  @override
  State<LightingDemoPage> createState() => _LightingDemoPageState();
}

class _LightingDemoPageState extends State<LightingDemoPage> {
  bool _enabled = true; // 예제 6: 토글용
  bool _glow = true; // 상단 스위치: 모든 카드의 glowEnabled 제어

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Rainbow Edge Lighting Demo'),
        actions: [
          Row(
            children: [
              const Text('Glow On/Off', style: TextStyle(color: Colors.white)),
              Switch(
                value: _glow,
                activeColor: Colors.pinkAccent,
                onChanged: (v) => setState(() => _glow = v),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1) Default rainbow (smooth loop)
            _title("1. Rainbow (Smooth Loop)"),
            RainbowEdgeLighting(
              glowEnabled: _glow,
              radius: 34,
              thickness: 2,
              speed: 0.5,
              enabled: true,
              colors: hslSweep(count: 12, sat: 0.9, light: 0.55),
              clip: true,
              child: Container(
                height: 180,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center( child: Text( "Rainbow. \nEdge Lighting", textAlign: TextAlign.center, style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30, ), ), ),
              ),
            ),

            const SizedBox(height: 36),

            // 2) Neon Blue (loop closed)
            _title("2. Neon Blue (Seamless Loop)"),
            RainbowEdgeLighting(
              glowEnabled: _glow,
              radius: 16,
              thickness: 4,
              speed: 1,
              colors: smoothLoop(const [
                Color(0xFFB3E5FC), // Light Sky Blue
                Color(0xFF81D4FA), // Sky Blue
                Color(0xFF4FC3F7), // Bright Blue
                Color(0xFF29B6F6), // Cool Blue
                Color(0xFF26C6DA), // Aqua
                Color(0xFF29B6F6), // Cool Blue
                Color(0xFF4FC3F7), // Bright Blue
                Color(0xFF81D4FA),
              ]),
              clip: true,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.ac_unit, size: 48, color: Colors.white),
              ),
            ),

            const SizedBox(height: 36),

            // 3) Burning Fire Ring (circle)
            _title("3. Burning Fire Ring (Circle)"),
            Center(
              child: RainbowEdgeLighting(
                glowEnabled: _glow,
                radius: 100,
                thickness: 5,
                speed: 1,
                colors: smoothLoop(
                    const [Colors.red, Colors.orange, Colors.yellow]),
                clip: true,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.local_fire_department,
                      size: 60, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // 4) Soft Pastel (slow animation)
            _title("4. Soft Pastel (Slow)"),
            RainbowEdgeLighting(
              glowEnabled: _glow,
              radius: 30,
              thickness: 5,
              speed: 1,
              colors: hslSweep(count: 8, sat: 0.35, light: 0.85),
              clip: true,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Text("Pastel Glow",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // 5) Stadium / Pill Shape
            _title("5. Stadium / Pill Shape"),
            RainbowEdgeLighting(
              glowEnabled: _glow,
              radius: 40,
              thickness: 4,
              speed: 1,
              colors: const [
                Color(0xFFFFCDD2), // Light Pink
                Color(0xFFEF9A9A), // Soft Red
                Color(0xFFE57373), // Bright Red
                Color(0xFFF44336), // Strong Red
                Color(0xFFFF7043), // Orange Red
                Color(0xFFF44336), // Strong Red
                Color(0xFFE57373), // Bright Red
                Color(0xFFEF9A9A),
              ],
              clip: true,
              child: Container(
                width: w - 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(40),
                ),
                alignment: Alignment.center,
                child: const Text("Stadium / Pill",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            const SizedBox(height: 36),

            // 6) Toggle On/Off (crossfade)
            _title("6. Toggle Switch (Crossfade)"),
            Center(
              child: Column(
                children: [
                  RainbowEdgeLighting(
                    glowEnabled: _glow,
                    radius: 40,
                    thickness: 4,
                    speed: 1,
                    enabled: _enabled,
                    showBorderWhenDisabled: true,
                    disabledBorderColor: Colors.white24,
                    colors: hslSweep(count: 9, sat: 0.9, light: 0.6),
                    clip: true,
                    child: Container(
                      width: 100,
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.power_settings_new,
                        size: 40,
                        color: _enabled ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Switch(
                    value: _enabled,
                    activeColor: Colors.pink,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(t, style: const TextStyle(color: Colors.white)),
      );
}
