import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:library_admin/common/custom_button.dart';
import '../../controllers/authentication_controller.dart';
import '../../utils/constants.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final formKey = GlobalKey<FormState>();
  final AuthenticationController authenticationController =
      Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthenticationController>(
        builder: (controller) {
          return SizedBox(
            height: double.maxFinite,
            width: double.maxFinite,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome Admin",
                        style: TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 10),
                      const Text("Login to access your account details",
                          style: TextStyle()),
                      const SizedBox(height: 30),
                      //create a new account using email and password
                      Form(
                        key: formKey,
                        child: SizedBox(
                          width: 350,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                    hintText: "Your Email",
                                    prefixIcon: Icon(Icons.alternate_email)),
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Enter your email"
                                      : null;
                                },
                              ),
                              TextFormField(
                                controller: controller.passwordController,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    hintText: "Your Password",
                                    prefixIcon: Icon(Icons.visibility)),
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Enter your password"
                                      : null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      //signup button
                      authenticationController.isLoading
                          ? const CircularProgressIndicator(color: kPrimary)
                          : CustomButton(
                              backgroundColor: kPrimary,
                              text: "Login",
                              onPress: () {
                                if (formKey.currentState!.validate()) {
                                  controller.loginWithEmailAndPassword();
                                }
                              },
                              height: 45,
                              width: 400),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
