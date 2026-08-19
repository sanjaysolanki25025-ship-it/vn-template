import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vn_template/core/constant/app_string.dart';
import 'package:vn_template/data/models/feedback_model.dart';
import 'package:vn_template/screens/feedback_center/repository/feedback_center_repository.dart';

part 'feedback_center_event.dart';
part 'feedback_center_state.dart';

class FeedbackCenterBloc extends Bloc<FeedbackCenterEvent, FeedbackCenterState> {
  FeedbackCenterBloc() : super(FeedbackCenterState.initial()) {
    on<SelectedFeedbackOptionEvent>(_selectedFeedbackOptionEvent);
    on<CheckedTermConditionEvent>(_checkedTermConditionEvent);
    on<SelectedUploadImageEvent>(_selectedUploadImageEvent);
    on<RemoveReferenceImageEvent>(_removeReferenceImageEvent);
    on<SubmitFeedbackEvent>(_submitFeedbackEvent);
  }

  File? imageFile;
  final ImagePicker picker = ImagePicker();
  final formKey = GlobalKey<FormState>();
  TextEditingController facingIssueController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  FeedbackCenterRepository feedbackCenterRepository = FeedbackCenterRepository();

  /// selected feedback option event
  FutureOr<void> _selectedFeedbackOptionEvent(
    SelectedFeedbackOptionEvent event,
    Emitter<FeedbackCenterState> emit,
  ) {
    emit(state.copyWith(selectedOption: event.selectedOption));
  }

  /// checked term condition event
  FutureOr<void> _checkedTermConditionEvent(
    CheckedTermConditionEvent event,
    Emitter<FeedbackCenterState> emit,
  ) {
    emit(state.copyWith(isChecked: event.isChecked, status: FeedbackCenterStatus.initial));
  }

  /// selected upload image event
  Future<void> _selectedUploadImageEvent(
      SelectedUploadImageEvent event,
      Emitter<FeedbackCenterState> emit,
      ) async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
      );

      if (pickedFile == null) {
        // User cancelled picker
        emit(state.copyWith(
          status: FeedbackCenterStatus.initial,
        ));
        return;
      }

      emit(
        state.copyWith(
          imageFile: File(pickedFile.path),
          status: FeedbackCenterStatus.initial,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FeedbackCenterStatus.error,
          errorMessage: AppStrings.txtFailedToPickImage,
        ),
      );
    }
  }

  /// remove reference image event
  FutureOr<void> _removeReferenceImageEvent(
    RemoveReferenceImageEvent event,
    Emitter<FeedbackCenterState> emit,
  ) {
    emit(state.copyWith(imageFile: File(''), status: FeedbackCenterStatus.initial));
  }

  /// submit feedback event
  Future<void> _submitFeedbackEvent(SubmitFeedbackEvent event, Emitter<FeedbackCenterState> emit) async {
    if (state.isChecked == false) {
      emit(
        state.copyWith(
          status: FeedbackCenterStatus.error,
          errorMessage: AppStrings.txtPleaseSelectedPrivacyPolicy,
        ),
      );
      return;
    }
    
    emit(state.copyWith(status: FeedbackCenterStatus.submitLoading));
    final result = await feedbackCenterRepository.submitFeedback(
      model: event.model,
      referenceImageFile: state.imageFile,
    );
    result.match(
      (f) {
        emit(state.copyWith(status: FeedbackCenterStatus.submitError, errorMessage: f.message));
      },
      (r) {
        emit(state.copyWith(status: FeedbackCenterStatus.submitLoaded));
      },
    );
  }
}
