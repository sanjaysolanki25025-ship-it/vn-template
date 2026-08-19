import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/constant/app_string.dart';
import '../../../data/models/failure_model.dart';
import '../../../data/models/other_app_model.dart';
import '../../../core/utils/app_logger.dart';

class OtherAppRepository {
  final FirebaseFirestore fireStore;

  OtherAppRepository({FirebaseFirestore? fireStore})
    : fireStore = fireStore ?? FirebaseFirestore.instance;

  Future<Either<Failure, List<OtherAppModel>>> fetchOtherApps() async {
    try {
      AppLogger.log("Fetching other apps from Firestore");
      final snapshot = await fireStore
          .collection(AppStrings.txtApps)
          .get();

      final apps = await Future.wait(
        snapshot.docs.map((doc) async {
          final app = OtherAppModel.fromJson(doc.data());

          if (app.appLink.isEmpty) {
            return app;
          }

          if (app.appName.isNotEmpty && app.appLogo.isNotEmpty) {
            return app;
          }
          return app;
        }),
      );
      
      AppLogger.log("Successfully fetched ${apps.length} other apps");
      return right(apps);
    } on FirebaseException catch (e) {
      AppLogger.log("Firebase error while fetching other apps: ${e.message}", error: e);
      return left(Failure("Firebase error: ${e.message}"));
    } catch (e) {
      AppLogger.log("Unexpected error while fetching other apps: $e", error: e);
      return left(Failure("Unexpected error: $e"));
    }
  }
}
