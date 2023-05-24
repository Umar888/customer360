// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'offers_screen_bloc.dart';

abstract class OfferScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OfferScreenProgress extends OfferScreenState {}

class OfferScreenFailure extends OfferScreenState {}

class OfferScreenSuccess extends OfferScreenState {
  final List<Offers>? offersScreenModel;
  final Records? product;
  final String? message;

  OfferScreenSuccess({
    required this.offersScreenModel,
    required this.message,
    required this.product,
  });
  @override
  List<Object?> get props => [offersScreenModel,message,product];
}
