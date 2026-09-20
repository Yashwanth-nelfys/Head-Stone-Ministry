import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'config/r2_config.dart';
import 'home_page.dart';
import 'saved/saved_messages_controller.dart';
import 'services/message_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await GetStorage.init();

  MessageService.instance.initializeR2(
    accessKeyId: R2Config.accessKeyId,
    secretAccessKey: R2Config.secretAccessKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(SavedMessagesController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HeadStone Ministry',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
