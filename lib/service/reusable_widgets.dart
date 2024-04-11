import 'package:fitness/service/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

TextFormField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextFormField(
      controller: controller,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType,
      autocorrect: !isPasswordType,
      cursorColor: Colors.white,
      style: TextStyle(
        color: const Color.fromARGB(255, 137, 37, 37).withOpacity(0.9),
      ),
      decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: AppColors.grayColor,
          ),
          labelText: text,
          labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: AppColors.lightGrayColor,
          counterText: "",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: const BorderSide(
                  width: 0, style: BorderStyle.none, color: Colors.indigo))),
      maxLength: 150,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      keyboardType: isPasswordType
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress);
}

Container loginRegisterButton(
    BuildContext context, bool isLogin, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: AppColors.primaryG,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2))
        ]),
    child: MaterialButton(
      minWidth: double.maxFinite,
      height: 50,
      onPressed: () {
        onTap();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      textColor: AppColors.primaryColor1,
      child: Text(
        isLogin ? 'LOG IN' : 'REGISTER',
        style: const TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize: 16),
      ),
    ),
  );
}
