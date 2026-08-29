import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

void main() {
  Widget test = FadeInUp(
    delay: const Duration(milliseconds: 200),
    duration: const Duration(milliseconds: 600),
    child: Container(),
  );
  print(test);
}
