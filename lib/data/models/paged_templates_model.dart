import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vn_template/data/models/template_model.dart';

class PagedTemplates {
  final List<TemplateModel> templates;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  PagedTemplates({
    required this.templates,
    required this.lastDoc,
    required this.hasMore,
  });
}
