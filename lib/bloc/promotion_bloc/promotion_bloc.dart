import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/data/reporsitories/promotions_screen_repository/promotions_screen_repository.dart';
import 'package:gc_customer_app/models/promotion_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';
import 'package:path_provider/path_provider.dart';

part 'promotion_event.dart';
part 'promotion_state.dart';

class PromotionBloC extends Bloc<PromotionEvent, PromotionScreenState> {
  final PromotionsScreenRepository promotionRepo;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File(
        '$path/promotion-${DateTime.now().millisecondsSinceEpoch}.html');
  }

  Future<String> getPromotionDetailService(
      String serviceCommunicationId) async {
    var promotionHtlm =
        await promotionRepo.getPromotionDetailService(serviceCommunicationId);
    if (kIsWeb) return promotionHtlm;
    final file = await _localFile;
    await file.writeAsString(promotionHtlm, mode: FileMode.writeOnly);
    return file.path;
  }

  Future<PromotionModel> getPromotionDetail(String promotionId) async {
    return await promotionRepo.getPromotionDetail(promotionId);
  }

  PromotionBloC(this.promotionRepo) : super(PromotionScreenInitial()) {
    on<LoadPromotions>(
      (event, emit) async {
        String recordId = await SharedPreferenceService().getValue(agentId);

        if ((recordId).isNotEmpty) {
          var promotions =
              await promotionRepo.getPromotions(recordId).catchError((_) {
            emit(PromotionScreenFailure());
            return [];
          });
          var activePros = promotions.last;
          emit(PromotionScreenSuccess(
              topPromotion: promotions.first, activePromotions: activePros));

          return;
        }

        emit(PromotionScreenFailure());
        return;
      },
    );
  }
}
