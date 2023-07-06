import 'package:burger_review_3/constants.dart';
import 'package:burger_review_3/resources/auth_methods.dart';
import 'package:burger_review_3/screens/signup_screen.dart';
import 'package:burger_review_3/text_field_input.dart';
import 'package:burger_review_3/utils.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (res == 'success') {
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      //showSnackBar(res, context);
      showFlushBar(res, context);
    }
  }

  void navigateToSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraint) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraint.maxHeight),
                      child: IntrinsicHeight(
                        child: SafeArea(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Flexible(
                                //   child: Container(),
                                //   flex: 2,
                                // ),
                                SizedBox(
                                  height: 50,
                                ),
                                Container(
                                  child: Row(children: [
                                    Expanded(
                                      child: Container(
                                        height: 150,
                                        child: Image.asset(
                                            'assets/Images/theNightShiftLogo.png'),
                                      ),
                                    ),
                                    // Expanded(
                                    //   child: Container(
                                    //     //height: 150,
                                    //     child: Image.asset(
                                    //         'assets/Images/mikeEatingBurger.png'),
                                    //   ),
                                    // ),
                                  ]),
                                  width: double.infinity,
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                TextFieldInput(
                                    textEditingController: _emailController,
                                    hintText: 'Enter your email',
                                    textInputType: TextInputType.emailAddress),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFieldInput(
                                  textEditingController: _passwordController,
                                  hintText: 'Enter your password',
                                  textInputType: TextInputType.text,
                                  isPass: true,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                InkWell(
                                  onTap: loginUser,
                                  child: Container(
                                    child: _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Log in',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                    width: double.infinity,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(12),
                                    decoration: const ShapeDecoration(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(4),
                                          ),
                                        ),
                                        color: Colors.blue),
                                  ),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Flexible(
                                  child: Container(),
                                  flex: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: const Text(
                    "Don't have an account?",
                    style: const TextStyle(color: Colors.black),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                ),
                GestureDetector(
                  onTap: navigateToSignUp,
                  child: Container(
                    child: const Text(
                      " Sign up",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            padding: EdgeInsets.only(bottom: 30),
          ),
        ],
      ),
    );
  }
}
