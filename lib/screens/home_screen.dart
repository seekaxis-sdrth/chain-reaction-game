import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _playerCount = 2;
  int _gridRows = 9;
  int _gridCols = 6;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _startGame() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          playerCount: _playerCount,
          rows: _gridRows,
          cols: _gridCols,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _bgController,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: const [
                          Color(0xFFE53935),
                          Color(0xFF1E88E5),
                          Color(0xFF43A047),
                          Color(0xFFE53935),
                        ],
                        stops: [
                          0.0,
                          _bgController.value,
                          _bgController.value + 0.3,
                          1.0,
                        ].map((s) => s.clamp(0.0, 1.0)).toList(),
                      ).createShader(bounds),
                      child: child,
                    );
                  },
                  child: const Text(
                    'CHAIN\nREACTION',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                      height: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Strategy Board Game',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),
                _buildSettingCard(
                  title: 'Players',
                  value: _playerCount.toString(),
                  onDecrease:
                      _playerCount > 2 ? () => setState(() => _playerCount--) : null,
                  onIncrease:
                      _playerCount < 6 ? () => setState(() => _playerCount++) : null,
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  title: 'Grid Size',
                  value: '${_gridRows}x$_gridCols',
                  onDecrease: _gridRows > 5
                      ? () => setState(() {
                            _gridRows--;
                            _gridCols = (_gridRows * 2 / 3).round().clamp(3, 10);
                          })
                      : null,
                  onIncrease: _gridRows < 15
                      ? () => setState(() {
                            _gridRows++;
                            _gridCols = (_gridRows * 2 / 3).round().clamp(3, 10);
                          })
                      : null,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFFE53935).withValues(alpha: 0.4),
                    ),
                    child: const Text(
                      'START GAME',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildRulesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String value,
    VoidCallback? onDecrease,
    VoidCallback? onIncrease,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Row(
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: onDecrease != null ? Colors.white70 : Colors.white24,
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: Icon(
                  Icons.add_circle_outline,
                  color: onIncrease != null ? Colors.white70 : Colors.white24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HOW TO PLAY',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 12),
          _RuleItem(icon: '🔴', text: 'Tap a cell to place an orb'),
          _RuleItem(icon: '💥', text: 'Cells explode at critical mass'),
          _RuleItem(icon: '⛓️', text: 'Explosions capture neighbor cells'),
          _RuleItem(icon: '🏆', text: 'Last player with orbs wins!'),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final String icon;
  final String text;

  const _RuleItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
