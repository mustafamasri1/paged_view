import 'package:flutter/material.dart';

import 'defaults.dart';

class NewPageProgressIndicator extends StatelessWidget {
  const NewPageProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) => const FooterTile(
        child: CircularProgressIndicator(),
      );
}
