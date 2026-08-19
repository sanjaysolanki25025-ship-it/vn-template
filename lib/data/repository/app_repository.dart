import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/data/helper/db_helper.dart';
import 'package:vn_template/data/models/category_model.dart';
import 'package:vn_template/data/models/failure_model.dart';
import 'package:vn_template/data/models/favourite_model.dart';
import 'package:vn_template/data/models/language_model.dart';
import 'package:vn_template/data/models/template_model.dart';

class AppRepository {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final dbHelper = DbHelper();

  static final StreamController<Map<String, dynamic>> _favouriteUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get favouriteUpdates => _favouriteUpdateController.stream;

  /// fetch category
  Future<Either<Failure, List<CategoryModel>>> fetchCategory() async {
    try {
      final querySnapshot = await fireStore
          .collection(AppStrings.txtCategory)
          .get();
      final categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromMap(doc.data()).copyWith(id: doc.id))
          .toList();
      return right(categories);
    } on FirebaseException catch (e) {
      return left(Failure("Firebase error: ${e.message}"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }

  /// fetch template
  // Future<Either<Failure, List<TemplateModel>>> fetchTemplate() async {
  //   try {
  //     final querySnapshot = await fireStore
  //         .collection(AppStrings.txtTemplates)
  //         .orderBy('createdAt', descending: true)
  //         .get();
  //
  //     final templates = querySnapshot.docs
  //         .map((doc) => TemplateModel.fromMap(doc.data()).copyWith(id: doc.id))
  //         .toList();
  //
  //     return right(templates);
  //   } on FirebaseException catch (e) {
  //     return left(Failure("Firebase error: ${e.message}"));
  //   } catch (e) {
  //     return left(Failure("Unexpected error: $e"));
  //   }
  // }

  /// fetch language
  Future<Either<Failure, List<LanguageModel>>> fetchLanguage() async {
    try {
      final querySnapshot = await fireStore
          .collection(AppStrings.txtLanguage)
          .get();
      final language = querySnapshot.docs
          .map((doc) => LanguageModel.fromMap(doc.data()).copyWith(id: doc.id))
          .toList();
      return right(language);
    } on FirebaseException catch (e) {
      return left(Failure("Firebase error: ${e.message}"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }

  /// fetch category by id
  Future<Either<Failure, CategoryModel>> fetchCategoryById({
    required String id,
  }) async {
    try {
      final docSnapshot = await fireStore
          .collection(AppStrings.txtCategory)
          .doc(id)
          .get();
      if (docSnapshot.exists) {
        final category = CategoryModel.fromMap(
          docSnapshot.data()!,
        ).copyWith(id: docSnapshot.id);
        return right(category);
      } else {
        return left(Failure(AppStrings.txtNoDataFound));
      }
    } on FirebaseException catch (e) {
      return left(Failure("Firebase error: ${e.message}"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }

  /// fetch language by id
  Future<Either<Failure, LanguageModel>> fetchLanguageById({
    required String id,
  }) async {
    try {
      final docSnapshot = await fireStore
          .collection(AppStrings.txtLanguage)
          .doc(id)
          .get();
      if (docSnapshot.exists) {
        final language = LanguageModel.fromMap(
          docSnapshot.data()!,
        ).copyWith(id: docSnapshot.id);
        return right(language);
      } else {
        return left(Failure(AppStrings.txtNoDataFound));
      }
    } on FirebaseException catch (e) {
      return left(Failure("Firebase error: ${e.message}"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }

  /// fetch template by id
  Future<Either<Failure, TemplateModel>> fetchTemplateById({
    required String id,
  }) async {
    try {
      final docSnapshot = await fireStore
          .collection(AppStrings.txtTemplatedYT)
          .doc(id)
          .get();
      if (docSnapshot.exists) {
        final language = TemplateModel.fromMap(
          docSnapshot.data()!,
        ).copyWith(id: docSnapshot.id);
        return right(language);
      } else {
        return left(Failure(AppStrings.txtNoDataFound));
      }
    } on FirebaseException catch (e) {
      return left(Failure("Firebase error: ${e.message}"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }

  /// ======= local database operations =======
  /// add favourite prompt
  Future<Either<Failure, FavouriteModel>> addFavourite({
    required FavouriteModel fav,
  }) async {
    try {
      final id = await dbHelper.insertFavourite(fav);
      _favouriteUpdateController.add({'templateId': fav.templateId, 'isFavourite': true});
      return right(fav.copyWith(id: id));
    } on DatabaseException catch (e) {
      return left(Failure("Database error: ${e.toString()}"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }


  /// remove favourite prompt
  Future<Either<Failure, int>> removeFavourite({
    required String templateId,
  }) async {
    try {
      final id = await dbHelper.deleteByTemplateId(templateId);
      _favouriteUpdateController.add({'templateId': templateId, 'isFavourite': false});
      return right(id);
    } on DatabaseException catch (e) {
      return left(Failure("Database error: ${e.toString()}"));
    } on SocketException {
      return left(Failure("No Internet connection"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }

  /// Fetch all favourite prompts
  Future<Either<Failure, List<FavouriteModel>>> fetchFavouriteTemplate() async {
    try {
      final hasInternet = await InternetConnection().hasInternetAccess;
      if (!hasInternet) {
        return left(Failure(AppStrings.txtNoInternetConnection));
      }
      final favourites = await dbHelper.getFavourites();
      return right(favourites);
    } on DatabaseException catch (e) {
      return left(Failure("Database error: ${e.toString()}"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }
}
