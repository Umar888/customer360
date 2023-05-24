import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gc_customer_app/bloc/zip_store_list_bloc/zip_store_list_bloc.dart';
import 'package:gc_customer_app/models/cart_model/cart_detail_model.dart';
import 'package:gc_customer_app/models/common_models/records_class_model.dart';
import 'package:gc_customer_app/models/product_detail_model/get_zip_code_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ZipStoreListBloc? zipStoreListBloc;

  blocTest<ZipStoreListBloc, ZipStoreListState>(
    'Load Data',
    setUp: () => zipStoreListBloc = ZipStoreListBloc(),
    tearDown: () => zipStoreListBloc = null,
    build: () => zipStoreListBloc!,
    act: (bloc) => bloc.add(PageLoad(
      getZipCodeListSearch: [],
      getZipCodeList: [],
      productsInCart: [],
      records: Records(),
    )),
    expect: () => [
      ZipStoreListState().copyWith(zipStoreListStatus: ZipStoreListStatus.loadState),
      zipStoreListBloc!.state.copyWith(
        zipStoreListStatus: ZipStoreListStatus.successState,
        initialExtent: 0.25,
        minExtent: 0.25,
        maxExtent: 0.25,
        productsInCart: [],
        zipCode: "",
        currentRecord: [Records()],
        getZipCodeListSearch: [],
        getZipCodeList: [],
      ),
    ],
  );

  blocTest<ZipStoreListBloc, ZipStoreListState>(
    'Set Zip Code',
    setUp: () => zipStoreListBloc = ZipStoreListBloc(),
    tearDown: () => zipStoreListBloc = null,
    build: () => zipStoreListBloc!,
    act: (bloc) => bloc.add(SetZipCode(zipCode: "123-456")),
    expect: () => [
      ZipStoreListState().copyWith(zipCode: "123-456"),
    ],
  );

  blocTest<ZipStoreListBloc, ZipStoreListState>(
    'Set Offset',
    setUp: () => zipStoreListBloc = ZipStoreListBloc(),
    tearDown: () => zipStoreListBloc = null,
    build: () => zipStoreListBloc!,
    act: (bloc) => bloc.add(SetOffset(offset: 0)),
    expect: () => [
      ZipStoreListState().copyWith(offset: 0),
    ],
  );

  blocTest<ZipStoreListBloc, ZipStoreListState>(
    'Change Initial Extent',
    setUp: () => zipStoreListBloc = ZipStoreListBloc(),
    tearDown: () => zipStoreListBloc = null,
    build: () => zipStoreListBloc!,
    act: (bloc) => bloc.add(ChangeInitialExtent(initialExtent: 0.25)),
    expect: () => [
      ZipStoreListState().copyWith(initialExtent: 0.25),
    ],
  );

  blocTest<ZipStoreListBloc, ZipStoreListState>(
    'Change Is Expanded',
    setUp: () => zipStoreListBloc = ZipStoreListBloc(),
    tearDown: () => zipStoreListBloc = null,
    build: () => zipStoreListBloc!,
    act: (bloc) => bloc.add(ChangeIsExpanded(isExpanded: true)),
    expect: () => [
      ZipStoreListState().copyWith(isExpanded: true),
    ],
  );

  blocTest<ZipStoreListBloc, ZipStoreListState>(
    'Clear Other Node Data',
    setUp: () => zipStoreListBloc = ZipStoreListBloc(),
    tearDown: () => zipStoreListBloc = null,
    build: () => zipStoreListBloc!,
    seed: () => ZipStoreListState(getZipCodeListSearch: [
      GetZipCodeList(otherNodeData: [OtherNodeData()])
    ]),
    act: (bloc) => bloc.add(ClearOtherNodeData()),
    expect: () => [],
  );

  blocTest<ZipStoreListBloc, ZipStoreListState>(
    'Add Other Node Data',
    setUp: () => zipStoreListBloc = ZipStoreListBloc(),
    tearDown: () => zipStoreListBloc = null,
    build: () => zipStoreListBloc!,
    seed: () => ZipStoreListState(
      getZipCodeListSearch: [GetZipCodeList(otherNodeData: [])],
      getZipCodeList: [
        GetZipCodeList(otherNodeData: [OtherNodeData(label: "dummy"), OtherNodeData(label: "xyz")])
      ],
    ),
    act: (bloc) => bloc.add(AddOtherNodeData(name: "dummy")),
    expect: () => [],
  );

  blocTest<ZipStoreListBloc, ZipStoreListState>(
    'Update Bottom Cart With Items',
    setUp: () => zipStoreListBloc = ZipStoreListBloc(),
    tearDown: () => zipStoreListBloc = null,
    build: () => zipStoreListBloc!,
    act: (bloc) =>
        bloc.add(UpdateBottomCartWithItems(items: [Items(quantity: 2, itemId: "123")], records: [Records(oliRecId: "123", quantity: "1")])),
    expect: () => [
      ZipStoreListState().copyWith(
        productsInCart: [Records(quantity: "2", oliRecId: "123")],
      )
    ],
  );
}
