import 'package:flutter/cupertino.dart';

class HomeLoadingWidget extends StatelessWidget {
  HomeLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CupertinoActivityIndicator(radius: 15));
  }
}
