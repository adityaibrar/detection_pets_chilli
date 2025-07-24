import '../../constant/theme/theme.dart';
import '../../constant/utils/pest_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FuzzyDialog extends StatefulWidget {
  final Function(List<String> selectedSymptoms) onDetectionPressed;

  const FuzzyDialog({super.key, required this.onDetectionPressed});

  @override
  State<FuzzyDialog> createState() => _FuzzyDialogState();
}

class _FuzzyDialogState extends State<FuzzyDialog> {
  final Map<String, bool> _selectedSymptoms = {};

  @override
  void initState() {
    super.initState();
    for (var symptom in PestClass.diseaseSymptoms) {
      _selectedSymptoms[symptom] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: whiteColor,
      title: Text(
        'Gejala Tanaman Cabai',
        style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 24.sp),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PestClass.diseaseSymptoms.map((symptom) {
            return CheckboxListTile(
              checkColor: whiteColor,
              activeColor: primaryColor,
              title: Text(
                PestClass.symptomDisplayNames[symptom] ?? symptom,
                style: blackTextStyle.copyWith(fontSize: 16.sp),
              ),
              value: _selectedSymptoms[symptom],
              onChanged: (bool? value) {
                setState(() {
                  _selectedSymptoms[symptom] = value ?? false;
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: primaryTextStyle.copyWith(color: Colors.red),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          onPressed: () {
            final selected = _selectedSymptoms.entries
                .where((entry) => entry.value)
                .map((entry) => entry.key)
                .toList();

            if (selected.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pilih minimal satu gejala!')),
              );
              return;
            }

            widget.onDetectionPressed(selected);
            Navigator.pop(context);
          },
          child: Text('Deteksi', style: whiteTextStyle),
        ),
      ],
    );
  }
}
