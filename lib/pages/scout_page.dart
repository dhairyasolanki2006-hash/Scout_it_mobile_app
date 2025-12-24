// scout_page.dart
import 'package:flutter/material.dart';
import 'pit_scout_form.dart';
import 'match_scout_form.dart'; // <-- Make sure this exists

class ScoutPage extends StatefulWidget {
  @override
  _ScoutPageState createState() => _ScoutPageState();
}

class _ScoutPageState extends State<ScoutPage> {
  int _selectedScoutType = 0; // 0 = Pit Scout, 1 = Match Scout

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toggle Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoutTypeButton(0, 'Pit Scout'),
            SizedBox(width: 16),
            _buildScoutTypeButton(1, 'Match Scout'),
          ],
        ),
        SizedBox(height: 20),

        // Conditional Form
        Expanded(
          child: _selectedScoutType == 0
              ? PitScoutForm()
              : MatchScoutForm(), // 🔄 Toggle to MatchScoutForm here
        ),
      ],
    );
  }

  Widget _buildScoutTypeButton(int index, String title) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedScoutType == index
            ? Colors.orange
            : const Color(0xFF002E6A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          _selectedScoutType = index;
        });
      },
      child: Text(title),
    );
  }
}
