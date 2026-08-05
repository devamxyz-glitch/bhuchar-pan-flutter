import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool loading = false;
  bool obscurePassword = true;

  late AnimationController _animationController;

  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;


  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );


    fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );


    scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );


    _animationController.forward();
  }



  Future<void> login() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }


    setState(() {
      loading = true;
    });


    try {

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Welcome Back 👋",
          ),
        ),
      );


    } on FirebaseAuthException catch (e) {


      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Login Failed",
          ),
        ),
      );


    } finally {


      if (mounted) {

        setState(() {
          loading = false;
        });

      }

    }

  }




  Future<void> register() async {


    if (!_formKey.currentState!.validate()) {
      return;
    }


    setState(() {
      loading = true;
    });



    try {


      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );



      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Account Created Successfully",
          ),
        ),
      );



    } on FirebaseAuthException catch(e) {


      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Registration Failed",
          ),
        ),
      );



    } finally {


      if (mounted) {

        setState(() {
          loading = false;
        });

      }

    }

  }





  Future<void> forgotPassword() async {


    if(emailController.text.trim().isEmpty){

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Enter your email first",
          ),
        ),
      );

      return;
    }



    try {


      await FirebaseAuth.instance
          .sendPasswordResetEmail(
        email: emailController.text.trim(),
      );


      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset email sent",
          ),
        ),
      );


    }catch(e){

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong",
          ),
        ),
      );

    }

  }





  @override
  void dispose() {

    emailController.dispose();

    passwordController.dispose();

    _animationController.dispose();

    super.dispose();

  }






  Widget glowCircle({
    required Alignment alignment,
    required double size,
  }) {

    return Align(

      alignment: alignment,

      child: Container(

        width: size,

        height: size,

        decoration: BoxDecoration(

          shape: BoxShape.circle,

          color: Colors.amber.withOpacity(0.05),


          boxShadow: [

            BoxShadow(

              color: Colors.amber.withOpacity(0.25),

              blurRadius: 120,

              spreadRadius: 10,

            ),

          ],

        ),

      ),

    );

  }
  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool password = false,
  }) {

    return Container(

      margin: const EdgeInsets.only(bottom: 18),

      child: TextFormField(

        controller: controller,

        obscureText: password ? obscurePassword : false,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),


        validator: (value) {

          if (value == null || value.trim().isEmpty) {
            return "Required";
          }


          if (!password &&
              !RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value.trim())) {

            return "Enter valid email";

          }


          if (password && value.length < 6) {

            return "Minimum 6 characters";

          }


          return null;

        },


        decoration: InputDecoration(

          hintText: hint,


          hintStyle: TextStyle(
            color: Colors.white.withOpacity(.45),
          ),


          prefixIcon: Icon(
            icon,
            color: Colors.amber,
          ),


          suffixIcon: password

              ? IconButton(

                  icon: Icon(

                    obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,

                    color: Colors.amber,

                  ),


                  onPressed: () {

                    setState(() {

                      obscurePassword = !obscurePassword;

                    });

                  },

                )

              : null,



          filled: true,


          fillColor: Colors.white.withOpacity(.05),



          border: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide.none,

          ),



          enabledBorder: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide(

              color: Colors.white.withOpacity(.08),

            ),

          ),



          focusedBorder: OutlineInputBorder(

            borderRadius:
                BorderRadius.circular(18),

            borderSide: const BorderSide(

              color: Colors.amber,

              width: 1.5,

            ),

          ),

        ),

      ),

    );

  }





  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff070707),


      body: Stack(

        children: [


          glowCircle(

            alignment: const Alignment(-1.2, -1),

            size: 260,

          ),



          glowCircle(

            alignment: const Alignment(1.2, 1),

            size: 220,

          ),





          SafeArea(

            child: Center(

              child: SingleChildScrollView(


                padding:
                    const EdgeInsets.symmetric(horizontal: 24),



                child: FadeTransition(

                  opacity: fadeAnimation,


                  child: ScaleTransition(

                    scale: scaleAnimation,


                    child: ClipRRect(

                      borderRadius:
                          BorderRadius.circular(30),



                      child: BackdropFilter(


                        filter: ImageFilter.blur(

                          sigmaX: 18,

                          sigmaY: 18,

                        ),



                        child: Container(


                          width: 390,


                          padding:
                              const EdgeInsets.all(28),




                          decoration: BoxDecoration(


                            color:
                                Colors.white.withOpacity(.06),



                            borderRadius:
                                BorderRadius.circular(30),



                            border: Border.all(

                              color:
                                  Colors.white.withOpacity(.08),

                            ),

                          ),




                          child: Form(


                            key: _formKey,



                            child: Column(


                              children: [



                                Container(


                                  width: 95,

                                  height: 95,



                                  decoration: BoxDecoration(


                                    shape: BoxShape.circle,



                                    gradient:
                                        const LinearGradient(


                                      colors: [


                                        Color(0xfffff176),


                                        Color(0xffffb300),


                                      ],

                                    ),



                                    boxShadow: [


                                      BoxShadow(


                                        color: Colors.amber
                                            .withOpacity(.45),


                                        blurRadius: 35,


                                      ),

                                    ],

                                  ),



                                  child: const Icon(


                                    Icons.shopping_bag_rounded,


                                    size: 46,


                                    color: Colors.black,


                                  ),


                                ),




                                const SizedBox(height: 22),




                                const Text(


                                  "BHUCHAR PAN",



                                  style: TextStyle(


                                    color: Colors.white,


                                    fontSize: 30,


                                    fontWeight:
                                        FontWeight.w900,


                                    letterSpacing: 2,

                                  ),

                                ),




                                const SizedBox(height: 8),




                                Text(


                                  "Premium Grocery Experience",



                                  style: TextStyle(


                                    color:
                                        Colors.white.withOpacity(.55),


                                    fontSize: 14,

                                  ),

                                ),





                                const SizedBox(height: 35),




                                buildTextField(

                                  controller: emailController,

                                  hint: "Email Address",

                                  icon: Icons.email_outlined,

                                ),




                                buildTextField(

                                  controller: passwordController,

                                  hint: "Password",

                                  icon: Icons.lock_outline,

                                  password: true,

                                ),




                                Align(


                                  alignment:
                                      Alignment.centerRight,



                                  child: TextButton(


                                    onPressed: forgotPassword,



                                    child: const Text(


                                      "Forgot Password?",



                                      style: TextStyle(


                                        color: Colors.amber,


                                        fontWeight:
                                            FontWeight.w600,

                                      ),

                                    ),

                                  ),

                                ),





                                const SizedBox(height: 12),





                                SizedBox(


                                  width: double.infinity,


                                  height: 56,



                                  child: ElevatedButton(


                                    onPressed:
                                        loading ? null : login,



                                    style:
                                        ElevatedButton.styleFrom(


                                      backgroundColor:
                                          Colors.amber,



                                      foregroundColor:
                                          Colors.black,



                                      shape:
                                          RoundedRectangleBorder(


                                        borderRadius:
                                            BorderRadius.circular(18),

                                      ),

                                    ),




                                    child: loading


                                        ? const SizedBox(


                                            height: 24,


                                            width: 24,


                                            child:
                                                CircularProgressIndicator(


                                              strokeWidth: 2.5,


                                              color: Colors.black,


                                            ),

                                          )



                                        : const Text(


                                            "LOGIN",



                                            style: TextStyle(


                                              fontSize: 17,


                                              fontWeight:
                                                  FontWeight.bold,

                                              letterSpacing: 1,

                                            ),

                                          ),


                                  ),

                                ),




                                const SizedBox(height: 16),





                                SizedBox(


                                  width: double.infinity,


                                  height: 56,



                                  child: OutlinedButton(


                                    onPressed:
                                        loading ? null : register,



                                    style:
                                        OutlinedButton.styleFrom(


                                      side: BorderSide(


                                        color: Colors.amber
                                            .withOpacity(.6),

                                      ),



                                      shape:
                                          RoundedRectangleBorder(


                                        borderRadius:
                                            BorderRadius.circular(18),

                                      ),

                                    ),




                                    child: const Text(


                                      "CREATE ACCOUNT",



                                      style: TextStyle(


                                        color: Colors.amber,


                                        fontWeight:
                                            FontWeight.bold,


                                        letterSpacing: 1,


                                      ),

                                    ),

                                  ),

                                ),





                                const SizedBox(height: 18),




                                TextButton(


                                  onPressed: () {


                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(

                                      const SnackBar(

                                        content: Text(
                                          "Guest Mode Coming Soon",
                                        ),

                                      ),

                                    );


                                  },



                                  child: Text(


                                    "Continue as Guest",



                                    style: TextStyle(


                                      color:
                                          Colors.white.withOpacity(.75),


                                    ),

                                  ),

                                ),




                                const SizedBox(height: 25),




                                Divider(

                                  color:
                                      Colors.white.withOpacity(.08),

                                ),




                                const SizedBox(height: 15),




                                const Text(


                                  "Designed & Developed by Devam",



                                  style: TextStyle(


                                    color: Colors.amber,


                                    fontSize: 13,


                                    fontWeight:
                                        FontWeight.w600,


                                    letterSpacing: 1,

                                  ),

                                ),



                              ],

                            ),

                          ),

                        ),

                      ),

                    ),

                  ),

                ),

              ),

            ),

          ),

        ],

      ),

    );

  }

}