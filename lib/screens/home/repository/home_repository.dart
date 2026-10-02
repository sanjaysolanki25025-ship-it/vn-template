import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/core/utils/app_logger.dart';
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
    bool isWrapped = false,
  }) async {
    try {
      final isAll = category == null ||
          category.trim().isEmpty ||
          category.trim().toLowerCase() == 'all';

      if (isAll) {
        // 🔥 ALL FEED - CONTINUOUS CIRCULAR PAGINATION WITH 'rand'
        Query<Map<String, dynamic>> query = fireStore
            .collection(AppStrings.txtTemplatesData)
            .orderBy("rand");

        if (isWrapped) {
          // Wrapped phase: paginating from 0.0 towards randomStart
          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          } else {
            query = query.startAt([0.0]);
          }

          if (randomStart != null) {
            query = query.endBefore([randomStart]);
          }

          query = query.limit(limit);

          final snapshot = await query
              .get(const GetOptions(source: Source.server))
              .timeout(
                const Duration(seconds: 8),
                onTimeout: () => throw TimeoutException("slow internet"),
              );

          final rawDocs = snapshot.docs;
          final templates = rawDocs
              .map((doc) => TemplateModel.fromMap(doc.data()).copyWith(id: doc.id))
              .where((t) => t.hasValidVideo)
              .toList();

          final last = rawDocs.isNotEmpty ? rawDocs.last : null;
          final hasMore = rawDocs.length == limit;

          return right(
            PagedTemplates(
              templates: templates,
              lastDoc: last,
              hasMore: hasMore,
              isWrapped: true,
            ),
          );
        } else {
          // Normal phase: paginating from randomStart towards 1.0
          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          } else if (randomStart != null) {
            query = query.startAt([randomStart]);
          }

          query = query.limit(limit);

          final snapshot = await query
              .get(const GetOptions(source: Source.server))
              .timeout(
                const Duration(seconds: 8),
                onTimeout: () => throw TimeoutException("slow internet"),
              );

          var rawDocs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.docs);
          bool nextIsWrapped = false;

          // If reached 1.0 (rawDocs.length < limit), wrap around from 0.0 up to randomStart!
          if (rawDocs.length < limit && randomStart != null) {
            final needed = limit - rawDocs.length;
            Query<Map<String, dynamic>> wrapQuery = fireStore
                .collection(AppStrings.txtTemplatesData)
                .orderBy("rand")
                .startAt([0.0])
                .endBefore([randomStart])
                .limit(needed);

            final wrapSnapshot = await wrapQuery
                .get(const GetOptions(source: Source.server))
                .timeout(const Duration(seconds: 6));

            rawDocs.addAll(wrapSnapshot.docs);
            nextIsWrapped = true;
          }

          final templates = rawDocs
              .map((doc) => TemplateModel.fromMap(doc.data()).copyWith(id: doc.id))
              .where((t) => t.hasValidVideo)
              .toList();

          final last = rawDocs.isNotEmpty ? rawDocs.last : null;
          final hasMore = nextIsWrapped
              ? rawDocs.length == limit
              : rawDocs.length == limit;

          return right(
            PagedTemplates(
              templates: templates,
              lastDoc: last,
              hasMore: hasMore,
              isWrapped: nextIsWrapped,
            ),
          );
        }
      }

      // 🎯 SPECIFIC CATEGORY FILTERING WITH 'rand' & WRAP-AROUND
      final cleanCat = category.replaceAll('👑', '').trim();
      final isPremium = cleanCat.toLowerCase() == 'premium';

      final variations = <String>{
        cleanCat,
        cleanCat.toLowerCase(),
        cleanCat.toUpperCase(),
        if (cleanCat.isNotEmpty)
          '${cleanCat[0].toUpperCase()}${cleanCat.substring(1).toLowerCase()}',
      }.toList();

      Query<Map<String, dynamic>> baseCategoryQuery() {
        Query<Map<String, dynamic>> q = fireStore.collection(
          AppStrings.txtTemplatesData,
        );
        if (isPremium) {
          return q.where("coin", isGreaterThan: 0);
        } else {
          return q.where("category", arrayContainsAny: variations);
        }
      }

      // Attempt 1: Native query with rand order if index is available
      try {
        Query<Map<String, dynamic>> query = baseCategoryQuery().orderBy("rand");

        if (isWrapped) {
          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          } else {
            query = query.startAt([0.0]);
          }
          if (randomStart != null) {
            query = query.endBefore([randomStart]);
          }

          query = query.limit(limit);

          final snapshot = await query.get(const GetOptions(source: Source.server));
          final rawDocs = snapshot.docs;
          final templates = rawDocs
              .map((doc) => TemplateModel.fromMap(doc.data()).copyWith(id: doc.id))
              .where((t) => t.hasValidVideo)
              .toList();

          return right(
            PagedTemplates(
              templates: templates,
              lastDoc: rawDocs.isNotEmpty ? rawDocs.last : null,
              hasMore: rawDocs.length == limit,
              isWrapped: true,
            ),
          );
        } else {
          if (lastDoc != null) {
            query = query.startAfterDocument(lastDoc);
          } else if (randomStart != null) {
            query = query.startAt([randomStart]);
          }

          query = query.limit(limit);

          final snapshot = await query.get(const GetOptions(source: Source.server));
          var rawDocs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.docs);
          bool nextIsWrapped = false;

          if (rawDocs.length < limit && randomStart != null) {
            final needed = limit - rawDocs.length;
            Query<Map<String, dynamic>> wrapQuery = baseCategoryQuery()
                .orderBy("rand")
                .startAt([0.0])
                .endBefore([randomStart])
                .limit(needed);

            final wrapSnapshot = await wrapQuery.get(const GetOptions(source: Source.server));
            rawDocs.addAll(wrapSnapshot.docs);
            nextIsWrapped = true;
          }

          final templates = rawDocs
              .map((doc) => TemplateModel.fromMap(doc.data()).copyWith(id: doc.id))
              .where((t) => t.hasValidVideo)
              .toList();

          final last = rawDocs.isNotEmpty ? rawDocs.last : null;
          final hasMore = rawDocs.length == limit;

          if (templates.isNotEmpty || rawDocs.isNotEmpty) {
            return right(
              PagedTemplates(
                templates: templates,
                lastDoc: last,
                hasMore: hasMore,
                isWrapped: nextIsWrapped,
              ),
            );
          }
        }
      } catch (e) {
        AppLogger.log("Category query with rand failed (index or empty): $e. Using standard pagination.");
      }

      // Attempt 2: Safe Standard Fallback (Paginates cleanly without composite index error)
      Query<Map<String, dynamic>> fallbackQuery = baseCategoryQuery();

      if (lastDoc != null) {
        fallbackQuery = fallbackQuery.startAfterDocument(lastDoc);
      }
      fallbackQuery = fallbackQuery.limit(limit);

      final snapshot = await fallbackQuery
          .get(const GetOptions(source: Source.server))
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException("slow internet"),
          );

      var rawDocs = snapshot.docs;

      // In-memory fallback if variations didn't catch due to string format
      if (rawDocs.isEmpty && lastDoc == null) {
        final recentSnap = await fireStore
            .collection(AppStrings.txtTemplatesData)
            .limit(50)
            .get();

        rawDocs = recentSnap.docs.where((doc) {
          final data = doc.data();
          if (isPremium && (data['coin'] is num && data['coin'] > 0)) {
            return true;
          }
          final cat = data['category'];
          if (cat is List) {
            return cat.any((c) =>
                c.toString().trim().toLowerCase() == cleanCat.toLowerCase() ||
                c.toString().toLowerCase().contains(cleanCat.toLowerCase()));
          } else if (cat is String) {
            return cat.toLowerCase().contains(cleanCat.toLowerCase());
          }
          return false;
        }).toList();
      }

      final templates = rawDocs
          .map((doc) => TemplateModel.fromMap(doc.data()).copyWith(id: doc.id))
          .where((t) => t.hasValidVideo)
          .toList();

      final last = rawDocs.isNotEmpty ? rawDocs.last : null;
      final hasMore = rawDocs.length == limit;

      return right(
        PagedTemplates(
          templates: templates,
          lastDoc: last,
          hasMore: hasMore,
          isWrapped: false,
        ),
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

  /// Fetches category templates without using Firestore 'rand',
  /// removes invalid video/images, and randomizes the entire list with list.shuffle().
  Future<Either<Failure, List<TemplateModel>>> fetchCategoryTemplates({
    required String category,
    int limit = 300,
  }) async {
    try {
      final isAll = category.trim().isEmpty || category.trim().toLowerCase() == 'all';
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs = [];

      if (isAll) {
        final snap = await fireStore
            .collection(AppStrings.txtTemplatesData)
            .limit(limit)
            .get(const GetOptions(source: Source.server))
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw TimeoutException("slow internet"),
            );
        allDocs = snap.docs;
      } else {
        final cleanCat = category.replaceAll('👑', '').trim();
        final isPremium = cleanCat.toLowerCase() == 'premium';

        final variations = <String>{
          category,
          category.trim(),
          cleanCat,
          cleanCat.toLowerCase(),
          cleanCat.toUpperCase(),
          if (isPremium) ...['Premium 👑', 'premium 👑', 'Premium', 'premium', 'PREMIUM'],
          if (cleanCat.isNotEmpty)
            '${cleanCat[0].toUpperCase()}${cleanCat.substring(1).toLowerCase()}',
        }.toList();

        // 1. Primary query by category array
        final snap = await fireStore
            .collection(AppStrings.txtTemplatesData)
            .where("category", arrayContainsAny: variations)
            .limit(limit)
            .get()
            .timeout(
              const Duration(seconds: 12),
              onTimeout: () => throw TimeoutException("slow internet"),
            );

        final docMap = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
        for (final doc in snap.docs) {
          docMap[doc.id] = doc;
        }

        // 2. If Premium, also query coin > 0 to guarantee all premium items
        if (isPremium) {
          try {
            final coinSnap = await fireStore
                .collection(AppStrings.txtTemplatesData)
                .where("coin", isGreaterThan: 0)
                .limit(limit)
                .get()
                .timeout(const Duration(seconds: 10));
            for (final doc in coinSnap.docs) {
              docMap[doc.id] = doc;
            }
          } catch (e) {
            AppLogger.log("Coin query note: $e");
          }
        }

        allDocs = docMap.values.toList();

        // 3. Fallback if variations missed docs
        if (allDocs.isEmpty) {
          final recentSnap = await fireStore
              .collection(AppStrings.txtTemplatesData)
              .limit(100)
              .get();

          allDocs = recentSnap.docs.where((doc) {
            final data = doc.data();
            if (isPremium && (data['coin'] is num && data['coin'] > 0)) {
              return true;
            }
            final cat = data['category'];
            if (cat is List) {
              return cat.any((c) =>
                  c.toString().trim().toLowerCase() == cleanCat.toLowerCase() ||
                  c.toString().toLowerCase().contains(cleanCat.toLowerCase()));
            } else if (cat is String) {
              return cat.toLowerCase().contains(cleanCat.toLowerCase());
            }
            return false;
          }).toList();
        }
      }

      // Filter valid video (strips images)
      final templates = allDocs
          .map((doc) => TemplateModel.fromMap(doc.data()).copyWith(id: doc.id))
          .where((t) => t.hasValidVideo)
          .toList();

      // 🔥 USER DIRECTIVE: Randomize using list.shuffle()
      templates.shuffle();

      return right(templates);
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
