import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'record_form.dart';

class AddRecordButton extends ConsumerWidget{
  const AddRecordButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => {
          _showAddFrom(context)
        },
        child: const Icon(Icons.smart_toy),
      );
  }
}

void _showAddFrom (BuildContext context) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const RecordForm(),
      );
    },
  );
}