import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'login_page.dart' as login;

class PitScoutForm extends StatefulWidget {
  @override
  _PitScoutFormState createState() => _PitScoutFormState();
}

class _PitScoutFormState extends State<PitScoutForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  String? _barcodeData;

  List<Map<String, dynamic>> pitScoutFields = [
    {'label': 'Team Number', 'type': 'number', 'required': true},
    {
      'label': 'Autonomous strat',
      'type': 'checkbox',
      'options': ['None', 'Drive forward', 'Score 1 coral', 'Score More than 1 Coral', 'Remove Algae from reef', 'Score Algae', 'Other']
    },
    {
      'label': 'Drivetrain',
      'type': 'select',
      'options': ['Swerve', 'Tank', 'Mecanum', 'Other']
    },
    {
      'label': 'Coral-Intake',
      'type': 'select',
      'options': ['Feeder', 'Ground', 'Both', 'None', 'Other']
    },
    {
      'label': 'Coral-Score-Level',
      'type': 'checkbox',
      'options': ['L1', 'L2', 'L3', 'L4']
    },
    {
      'label': 'Can Remove Algae From Reef?',
      'type': 'select',
      'options': ['Yes', 'No']
    },
    {
      'label': 'Can Score Algae In Processor?',
      'type': 'select',
      'options': ['Yes', 'No']
    },
    {
      'label': 'Can Score Algae In Barge?',
      'type': 'select',
      'options': ['Yes', 'No']
    },
    {
      'label': 'Endgame',
      'type': 'checkbox',
      'options': ['Shallow Climb', 'Deep Climb']
    },
    {
      'label': 'Additional Notes',
      'type': 'text'
    },
  ];

  @override
  void initState() {
    super.initState();
    for (var field in pitScoutFields) {
      if (field['type'] == 'text' || field['type'] == 'number') {
        _controllers[field['label']] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

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
                itemCount: pitScoutFields.length,
                separatorBuilder: (context, index) => SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final field = pitScoutFields[index];
                  return _buildField(field);
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit and Generate Barcode', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            SizedBox(height: 24),
            if (_barcodeData != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Column(
                    children: [
                      Text('Scan This Barcode:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      QrImageView(
                        data: _barcodeData!,
                        size: 250,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red, size: 28),
                    tooltip: 'Close barcode',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Close Barcode'),
                          content: Text('Are you sure you want to close the barcode?'),
                          actions: [
                            TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
                            TextButton(child: Text('Yes'), onPressed: () => Navigator.of(context).pop(true)),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        setState(() {
                          _barcodeData = null;
                          _formKey.currentState?.reset();
                          _formData.clear();
                          _controllers.forEach((key, controller) => controller.clear());
                        });
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    switch (field['type']) {
      case 'text':
      case 'number':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field['label'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextFormField(
              controller: _controllers[field['label']],
              keyboardType: field['type'] == 'number' ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) {
                if (field['required'] == true && (value == null || value.isEmpty)) {
                  return 'This field is required';
                }
                return null;
              },
              onSaved: (value) {
                _formData[field['label']] = value?.isEmpty ?? true ? 'No Data' : value;
              },
            ),
          ],
        );

      case 'select':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field['label'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _formData[field['label']], // <- THIS is the fix
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: (field['options'] as List<String>)
                  .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option, style: TextStyle(fontSize: 18)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _formData[field['label']] = value ?? 'No Data';
                });
              },
              onSaved: (value) {
                _formData[field['label']] = value ?? 'No Data';
              },
            ),
          ],
        );


      case 'checkbox':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field['label'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...((field['options'] as List<String>).map((option) {
              bool isChecked = (_formData[field['label']] ?? []).contains(option);
              return CheckboxListTile(
                value: isChecked,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: Colors.orange,
                contentPadding: EdgeInsets.zero,
                title: Text(option, style: TextStyle(fontSize: 18)),
                onChanged: (value) {
                  setState(() {
                    if (_formData[field['label']] == null) _formData[field['label']] = [];
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

      default:
        return SizedBox();
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      _formData['Team Number'] = _controllers['Team Number']?.text ?? 'No Data';

      // Mark any unchecked checkboxes as 'No Data'
      pitScoutFields.forEach((field) {
        if (field['type'] == 'checkbox' && (_formData[field['label']] == null || _formData[field['label']].isEmpty)) {
          _formData[field['label']] = 'No Data';
        }
      });

      _formData['Submitted by'] = login.currentUsername ?? 'Unknown';
      _formData['Time stamp'] = DateTime.now().toIso8601String();

      final barcodePayload = {
        'sheet': 'Pit-Scout-Data-Raw',
        'data': _formData,
      };

      final jsonString = jsonEncode(barcodePayload);

      print(jsonString);

      setState(() {
        _barcodeData = jsonString;
      });
    }
  }
}
