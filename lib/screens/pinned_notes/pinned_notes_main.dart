import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gc_customer_app/bloc/pinned_notes_bloc/pinned_notes_bloc.dart';
import 'package:gc_customer_app/screens/pinned_notes/pinned_notes_screen.dart';

class PinnedNotesScreenMain extends StatelessWidget {
  PinnedNotesScreenMain({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PinnedNotesBloc>(
        create: (context) => PinnedNotesBloc(),
        child: PinnedNotesScreen());
  }
}
