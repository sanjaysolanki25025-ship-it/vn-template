import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/data/models/failure_model.dart';
import 'package:vn_template/data/models/paged_templates_model.dart';
import 'package:vn_template/data/models/template_model.dart';

class HomeRepository {
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  /// Returns a PagedTemplates so caller receives mapped models plus pagination info.
  Future<Either<Failure, PagedTemplates>> fetchTemplateWithPagination({
    String? category,
    int limit = 6,
    DocumentSnapshot? lastDoc,
    double? randomStart,
  }) async {
    try {
      Query<Map<String, dynamic>> query = fireStore.collection(
        AppStrings.txtTemplatedYT,
      );

      if (category != null && category.isNotEmpty) {
        query = query.where("category", arrayContains: category);
      }

      // 🔥 RANDOM START + PAGINATION
      if (randomStart != null && lastDoc == null) {
        query = query
            .orderBy("rand")
            .where("rand", isGreaterThanOrEqualTo: randomStart);
      } else {
        query = query.orderBy("rand");
      }

      query = query.limit(limit);

      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query
          .get(const GetOptions(source: Source.server))
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException("slow internet"),
          );

      // ---- If empty after random start, restart from beginning ----
      if (snapshot.docs.isEmpty && randomStart != null) {
        return fetchTemplateWithPagination(category: category, limit: limit);
      }

      final templates = snapshot.docs
          .map((doc) => TemplateModel.fromMap(doc.data()).copyWith(id: doc.id))
          .toList();

      final last = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      final hasMore = snapshot.docs.length == limit;

      return right(
        PagedTemplates(templates: templates, lastDoc: last, hasMore: hasMore),
      );
    } on TimeoutException {
      return left(Failure(AppStrings.txtNoInternetConnection));
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        return left(Failure(AppStrings.txtNoInternetConnection));
      }
      return left(Failure("Firebase error: ${e.message}"));
    } catch (e) {
      return left(Failure("Unexpected error: $e"));
    }
  }
}
