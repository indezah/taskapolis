import 'package:flutter/material.dart';

Image logoWidget(String imageName) {
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
  );
}

TextField reuseableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: isPasswordType,
    autocorrect: isPasswordType,
    cursorColor: Color.fromARGB(255, 0, 20, 85),
    style: TextStyle(color: Color.fromARGB(255, 0, 20, 85)),
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      labelText: text,
      prefixIcon: Icon(icon),
      labelStyle: TextStyle(color: Color.fromARGB(255, 0, 20, 85)),
      filled: true,
      fillColor: Colors.white,
    ),
    keyboardType:
        isPasswordType ? TextInputType.text : TextInputType.emailAddress,
  );
}

Container signInSignUpButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: ElevatedButton(
          onPressed: () {
            onTap();
          },
          child: Text(
            isLogin ? "Sign In" : "Sign Up",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                (states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white;
                  } else {
                    return Colors.white;
                  }
                },
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              )))));
}
