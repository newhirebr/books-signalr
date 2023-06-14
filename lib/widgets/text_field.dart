import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;

  const MyTextField({Key? key, this.label, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            offset: const Offset(5, 5),
            blurRadius: 10,
            color: Colors.grey.withOpacity(0.1),
          ),
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 10,
            color: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
        ),
        controller: controller,
      ),
    );
  }
}
