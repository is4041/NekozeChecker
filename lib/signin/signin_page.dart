import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:posture_correction/home/home_page.dart';
import 'package:posture_correction/signin/signin_model.dart';
import 'package:provider/provider.dart';

import '../bottomnavigation.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
        create: (_) => SignInModel(),
        builder: (context, snapshot) {
          return Scaffold(
              body: Consumer<SignInModel>(builder: (context, model, child) {
            return Stack(children: [
              StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    // if (snapshot.connectionState == ConnectionState.waiting) {
                    //   return const Center(
                    //     child: CircularProgressIndicator(),
                    //   );
                    // }
                    if (snapshot.hasData) {
                      return BottomNavigation();
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //Googleでサインイン
                          SignInButton(Buttons.Google,
                              text: "Sign in with Google", onPressed: () async {
                            model.startLoading();
                            await model.signInWithGoogle();
                            model.endLoading();
                          }),
                          const SizedBox(height: 20),
                          //サインインしない
                          InkWell(
                            onTap: () async {
                              model.startLoading();
                              try {
                                await model.onSignInWithAnonymousUser();
                              } catch (e) {
                                await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(e.toString()),
                                        actions: [
                                          TextButton(
                                            child: const Text("ok"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ],
                                      );
                                    });
                              }
                              model.endLoading();
                            },
                            child: Container(
                              height: 35,
                              width: 220,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)),
                              child: const Center(child: Text("サインインせずに利用する")),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              if (model.isLoading)
                Container(
                  color: Colors.grey.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
            ]);
          }));
        });
  }
}
