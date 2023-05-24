import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gc_customer_app/data/reporsitories/case_history_screen_repository/case_history_screen_repository.dart';
import 'package:gc_customer_app/models/case_history_models/open_order_model.dart';
import 'package:gc_customer_app/services/networking/http_response.dart';

import '../../models/case_history_models/case_history_cases_model.dart';
import '../../models/case_history_models/case_history_chart_details_model.dart';
import '../../primitives/constants.dart';
import '../../services/storage/shared_preferences_service.dart';

part 'case_history_screen_event.dart';
part 'case_history_screen_state.dart';

class CaseHistoryScreenBloc
    extends Bloc<CaseHistoryScreenEvent, CaseHistoryScreenState> {
  CaseHistoryScreenRepository caseHistoryScreenRepository;
  CaseHistoryScreenBloc({required this.caseHistoryScreenRepository})
      : super(CaseHistoryScreenProgress()) {
    late CaseHistoryChartDetails caseHistoryChartDetails;
    late OpenCasesListModel openCasesListModelObject;
    late CaseHistoryListModelClass caseHistoryListModelClass;
    on<LoadData>((event, emit) async {
      emit(CaseHistoryScreenProgress());
      HttpResponse opencaseHistoryResponse = await getOpenCaseHistoryObject();
      if (opencaseHistoryResponse.status == false) {
      } else {
        if (opencaseHistoryResponse.data != null &&
            opencaseHistoryResponse.status == true) {
          openCasesListModelObject =
              OpenCasesListModel.fromJson(opencaseHistoryResponse.data);
        }
      }

      HttpResponse caseHistoryResponse = await getCaseHistoryCases();
      if (caseHistoryResponse.status == false) {
      } else {
        if (caseHistoryResponse.data != null &&
            caseHistoryResponse.status == true) {
          caseHistoryListModelClass =
              CaseHistoryListModelClass.fromJson(caseHistoryResponse.data);
        }
      }
      HttpResponse chartDetailResponse = await getChartData();
      if (chartDetailResponse.status == false) {
      } else {
        if (chartDetailResponse.data != null &&
            chartDetailResponse.status == true) {
          caseHistoryChartDetails =
              CaseHistoryChartDetails.fromJson(chartDetailResponse.data);
        }
      }
      emit(CaseHistoryScreenSuccess(
          caseHistoryChartDetails: caseHistoryChartDetails,
          openCasesListModel: openCasesListModelObject,
          caseHistoryListModelClass: caseHistoryListModelClass));
    });
  }
  Future<dynamic> getChartData() async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response =
        await caseHistoryScreenRepository.getCaseHistoryChartData(id);
    return response;
  }

  Future<dynamic> getOpenCaseHistoryObject() async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response =
        await caseHistoryScreenRepository.getOpenCasesHistoryList(id);
    return response;
  }

  Future<dynamic> getCaseHistoryCases() async {
    var id = await SharedPreferenceService().getValue(agentId);
    final response =
        await caseHistoryScreenRepository.getCaseHistoryCases(id);
    return response;
  }
}
