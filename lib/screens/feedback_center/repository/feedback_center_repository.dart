import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/data/models/failure_model.dart';
import 'package:vn_template/data/models/feedback_model.dart';
import 'package:vn_template/core/utils/app_logger.dart';

class FeedbackCenterRepository {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  Future<Either<Failure, Unit>> submitFeedback({
    required FeedbackModel model,
    File? referenceImageFile,
  }) async {
    try {
      final docRef = fireStore.collection(AppStrings.txtFeedback).doc();
      final docId = docRef.id;

      String? imageUrl;

      if (referenceImageFile != null && referenceImageFile.path.isNotEmpty) {
        final storageRef = firebaseStorage.ref().child('review/$docId.jpg');

        await storageRef.putFile(referenceImageFile);

        imageUrl = await storageRef.getDownloadURL();
      }

      final updatedModel = model.copyWith(id: docId, referenceImage: imageUrl);

      await docRef.set(updatedModel.toMap());

      AppLogger.log('Feedback submitted successfully. Doc ID: $docId', tag: 'FeedbackCenterRepository');
      return right(unit);
    } on FirebaseException catch (e, stack) {
      AppLogger.log('Firebase error while submitting feedback', tag: 'FeedbackCenterRepository', error: e, stackTrace: stack);
      return left(Failure("Firebase error: ${e.message}"));
    } catch (e, stack) {
      AppLogger.log('Unexpected error while submitting feedback', tag: 'FeedbackCenterRepository', error: e, stackTrace: stack);
      return left(Failure("Unexpected error: $e"));
    }
  }
}
