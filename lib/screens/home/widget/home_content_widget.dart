import 'package:flutter/cupertino.dart';

class HomeContent extends StatelessWidget {
  final ScrollController scrollController;

  const HomeContent({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
        child: Column(
          children: [
            // Add your widgets here
          ],
        ),
      ),
    );
  }
}
