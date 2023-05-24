import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:gc_customer_app/data/data_sources/add_commission_data_source/add_commission_data_source.dart';
import 'package:gc_customer_app/data/reporsitories/add_commission_repository/add_commission_repository.dart';
import 'package:gc_customer_app/models/add_commission_model/search_employee_model.dart';
import 'package:gc_customer_app/models/user_profile_model.dart';
import 'package:gc_customer_app/primitives/constants.dart';
import 'package:gc_customer_app/services/storage/shared_preferences_service.dart';

part 'search_employees_event.dart';
part 'search_employees_state.dart';

enum EmployeeSearchType { id, name }

class SearchEmployeesBloc
    extends Bloc<SearchEmployeesEvent, SearchEmployeesState> {
  AddCommissionRepository addCommissionRepository = AddCommissionRepository(
      addCommissionDataSource: AddCommissionDataSource());

  int offset = 0;
  List<UserProfile> customers = [];
  List<SearchedEmployeeModel>? defaultEmployees;

  // Future<List<SearchedEmployeeModel>> getDefaultEmployee(
  //     String orderId, String userId) async {
  //   var resp =
  //       await addCommissionRepository.getDefaultEmployees(orderId, userId);

  //   return resp;
  // }

  SearchEmployeesBloc() : super(SearchEmployeesFailure()) {
    // on<GetDefaultEmployees>((event, emit) async {
    //   emit(SearchEmployeesProgress());
    //   var userId = await SharedPreferenceService().getValue(loggedInAgentId);
    //   defaultEmployees =
    //       await getDefaultEmployee(event.orderId, userId).catchError((_) {
    //     emit(SearchEmployeesFailure());
    //     return <SearchedEmployeeModel>[];
    //   });

    //   emit(SearchEmployeesSuccess(defaultEmployees: defaultEmployees));

    //   return;
    // });

    on<SearchEmployees>((event, emit) async {
      List<SearchedEmployeeModel> employees = [];
      emit(SearchEmployeesProgress());
      bool isIdNumber = double.tryParse(event.keySearch) != null;
      employees = await addCommissionRepository
          .searchEmployees(event.keySearch,
              isIdNumber ? EmployeeSearchType.id : EmployeeSearchType.name)
          .catchError((error) {
        print(error);
        emit(SearchEmployeesFailure());
      });

      emit(SearchEmployeesSuccess(
          employees: employees, defaultEmployees: defaultEmployees));

      return;
    });

    on<ClearData>((event, emit) async {
      emit(SearchEmployeesInitial());

      return;
    });
  }
}
