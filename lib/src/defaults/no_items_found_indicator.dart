import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'defaults.dart';
class NoItemsFoundIndicator extends StatelessWidget {
  const NoItemsFoundIndicator({super.key});

  @override
  Widget build(BuildContext context) => const FirstPageExceptionIndicator(
        title: 'No items found',
        message: 'The list is currently empty.',
      );
}
