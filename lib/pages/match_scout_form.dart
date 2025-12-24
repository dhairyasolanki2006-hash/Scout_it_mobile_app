// match_scout_form.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'login_page.dart' as login;


class MatchScoutForm extends StatefulWidget {
  @override
  _MatchScoutFormState createState() => _MatchScoutFormState();
}

class _MatchScoutFormState extends State<MatchScoutForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  String? _barcodeData;

  // 🔧 EDIT THESE FIELDS as your game evolves each year
  List<Map<String, dynamic>> matchScoutFields = [
    {'label': 'Team Number', 'type': 'number', 'required': true},
    {
      'label': 'Match Number',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9','10','11','12'],
      'required': true
    },
    {
      'label': 'Start Position',
      'type': 'checkbox',
      'options': ['Far Side', 'Middle', 'Processor']
    },
    {
      'label': 'AUTO-moved?',
      'type': 'checkbox',
      'options': ['Yes', 'No']
    },
    {
      'label': 'AUTO-L1',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },    
    {
      'label': 'AUTO-L2',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'AUTO-L3',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'AUTO-L4',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
        {
      'label': 'AUTO-remove-algae',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'AUTO-processor',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'AUTO-barge',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'L1',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },    
    {
      'label': 'L2',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'L3',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'L4',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
        {
      'label': 'Remove-algae',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'Processor',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'Barge',
      'type': 'select',
      'options': ['1','2','3','4','5','6','7','8','9']
    },
    {
      'label': 'Endgame',
      'type': 'checkbox',
      'options': ['Shallow Climb', 'Deep Climb', 'Parked', 'Failed Climb']
    },
    {
      'label': 'Drive team rating',
      'type': 'select',
      'options': ['NOOB', 'MEH', 'MID', 'CLUTCH', 'GOAT']
    },
        {
      'label': 'Defence rating',
      'type': 'select',
      'options': ['NOOB', 'MEH', 'MID', 'CLUTCH', 'GOAT']
    },
  ];

  @override
  void initState() {
    super.initState();
    for (var field in matchScoutFields) {
      if (field['type'] == 'text' || field['type'] == 'number') {
        _controllers[field['label']] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  // ────────────────── UI ───────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: matchScoutFields.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (_, i) => _buildField(matchScoutFields[i]),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              child: const Text('Submit and Generate Barcode',
                  style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 24),
            if (_barcodeData != null) _buildBarcodePreview(context),
          ],
        ),
      ),
    );
  }

  // ────────────────── Field Builders ───────────────────────────
  Widget _buildField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'text':
      case 'number':
        return _buildInputField(field);
      case 'select':
        return _buildDropdown(field);
      case 'checkbox':
        return _buildCheckboxGroup(field);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInputField(Map<String, dynamic> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field['label'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controllers[field['label']],
          keyboardType:
              field['type'] == 'number' ? TextInputType.number : TextInputType.text,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (field['required'] == true && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onSaved: (value) =>
              _formData[field['label']] = value?.isEmpty ?? true ? 'No Data' : value,
        ),
      ],
    );
  }

  Widget _buildDropdown(Map<String, dynamic> field) {
    String? currentValue = _formData[field['label']] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field['label'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: currentValue,  // ← sets the current value
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: (field['options'] as List<String>)
              .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 18))))
              .toList(),
          validator: (value) {
            if (field['required'] == true && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _formData[field['label']] = value;
            });
          },
          onSaved: (value) {
            _formData[field['label']] = value ?? 'No Data';
          },
        ),
      ],
    );
  }


  Widget _buildCheckboxGroup(Map<String, dynamic> field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field['label'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...((field['options'] as List<String>).map((option) {
          bool isChecked = (_formData[field['label']] ?? []).contains(option);
          return CheckboxListTile(
            value: isChecked,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.orange,
            contentPadding: EdgeInsets.zero,
            title: Text(option, style: const TextStyle(fontSize: 18)),
            onChanged: (value) {
              setState(() {
                _formData[field['label']] ??= [];
                if (value == true) {
                  _formData[field['label']].add(option);
                } else {
                  _formData[field['label']].remove(option);
                }
              });
            },
          );
        })).toList(),
      ],
    );
  }

  // ────────────────── Submit / Barcode ─────────────────────────
  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _formKey.currentState?.save();
    _formData['Team Number'] = _controllers['Team Number']?.text ?? 'No Data';

    // Mark unchecked checkbox groups as 'No Data'.
    for (var field in matchScoutFields) {
      if (field['type'] == 'checkbox' &&
          (_formData[field['label']] == null || _formData[field['label']].isEmpty)) {
        _formData[field['label']] = 'No Data';
      }
    }

    _formData['Submitted by'] = login.currentUsername ?? 'Unknown';
    _formData['Time stamp'] = DateTime.now().toIso8601String();

    final barcodePayload = {
      'sheet': 'Match-Scout-Data-Raw', //  <-- <sheet tab> for your GAS script
      'data' : _formData,
    };

    setState(() => _barcodeData = jsonEncode(barcodePayload));
  }

  Widget _buildBarcodePreview(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Column(
          children: [
            const Text('Scan This Barcode:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            QrImageView(
              data: _barcodeData!,
              size: 250,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 16),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red, size: 28),
          tooltip: 'Close barcode',
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Close Barcode'),
                content: const Text('Are you sure you want to close the barcode?'),
                actions: [
                  TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)),
                  TextButton(child: const Text('Yes'),    onPressed: () => Navigator.pop(context, true)),
                ],
              ),
            );
            if (confirm == true) {
              setState(() {
                _barcodeData = null;
                _formKey.currentState?.reset();
                _formData.clear();
                _controllers.values.forEach((c) => c.clear());
              });
            }
          },
        ),
      ],
    );
  }
}
