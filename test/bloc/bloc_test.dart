import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/landing_screen_bloc/landing_screen_bloc_bloc.dart';
import 'package:gc_customer_app/constants/colors.dart';
import 'package:gc_customer_app/data/reporsitories/landing_screen_repository/landing_screen_repository.dart';
import 'package:gc_customer_app/models/landing_screen/customer_info_model.dart';
import 'package:gc_customer_app/models/pinned_notes_model.dart';
import 'package:mockito/mockito.dart';

class LandingScreenBlocImpl extends Mock implements LandingScreenRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group(
    "Smart Trigger Bloc Test",
    () {
      late LandingScreenBlocImpl landingScreenBloc;
      setUp(
        () {
          const MethodChannel('plugins.flutter.io/shared_preferences').setMockMethodCallHandler(
            (MethodCall methodCall) async {
              if (methodCall.method == 'getAll') {
                return <String, dynamic>{}; // set initial values here if desired
              }
              return null;
            },
          );
          landingScreenBloc = LandingScreenBlocImpl();
        },
      );

      blocTest<LandingScreenBloc, LandingScreenState>(
        'when landing screen will load and successful',
        build: () {
          // when(landingScreenBloc.getAgentProfile("ankit.kumar@guitarcenter.com")).thenAnswer((_) async {
          //   return AgentAPIReturn(
          //       agent: Agent(
          //         name:"Ankit Kumar",
          //         isManager: true,
          //         email: "ankit.kumar@guitarcenter.com",
          //         id: "0054M000004UMmEQAW",
          //         phone: "+1 3233046476",
          //         allTasks: [],
          //         todayTasks: [],
          //         completedTasks: [],
          //         storeId: "101",
          //         storeName: "101 WESTLAKE VLG",
          //         pastOpenTasks: [],
          //         profileName: "System Administrator",
          //         unAssignedTasks: [],
          //         futureTasks: [],
          //         employeeId: "110085",
          //       ),
          //       message: "Record found.",
          //       userNotExist: false,
          //       userIsManager: true
          //   );
          // });
          return LandingScreenBloc(landingScreenRepository: landingScreenBloc);
        },
        act: (bloc) => bloc.add(LoadData()),
        expect: () => [
          LandingScreenState(landingScreenStatus: LandingScreenStatus.initial, message: ""),
          LandingScreenState().copyWith(
            offerList: [],
            // landingScreenRecommendationModelBuyAgain:
            //     landingScreenRecommendationModelBuyAgain,
            // landingScreenRecommendationModel: landingScreenRecommendationModel,
            pinnedNotesList: [PinnedNotes(
                textOfNote:
                'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
                authorOfNote: 'john Doe',
                dateOfNote: 'Aug 20, 2022',
                isLess: true,
                backgroundColor: AppColors.skyblueHex),PinnedNotes(
                textOfNote:
                'Jessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbjJessica  is a gutiar geerk, and loves acoustic n,c vcvbj',
                authorOfNote: 'john Doe',
                isLess: true,
                dateOfNote: 'Aug 20, 2022',
                backgroundColor: AppColors.yellowNotes)],
            // landingScreenReminders: landingScreenReminders,
            gettingAgentsList: true,
            isSearchAgent: false,
            gettingOffers: true,
            agentList: [],
            message: "",
            searchedAgentList: [],
            landingScreenStatus: LandingScreenStatus.success,
            customerInfoModel: CustomerInfoModel.fromJson({"done":false}),
            // taskModel: taskModel,
            gettingActivity: true,
            gettingFavorites: true,
            gettingAgentAssigned: true,
            isAgentAssigned: false,
            ),
        ],
      );
    },
  );
}
