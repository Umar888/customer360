import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';

class NavigatorWebBloC {
  var _selectedTabObject = BehaviorSubject<int>()..add(0);
  Stream<int> get selectedTab => _selectedTabObject.stream;
  int get selectedTabIndex => _selectedTabObject.value!;
  set selectedTabIndex(int index) => _selectedTabObject.add(index);
}
