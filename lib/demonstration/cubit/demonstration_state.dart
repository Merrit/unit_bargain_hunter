part of 'demonstration_cubit.dart';

class DemonstrationState extends Equatable {
  final bool slidableDemoShown;

  const DemonstrationState({
    required this.slidableDemoShown,
  });

  @override
  List<Object> get props => [slidableDemoShown];

  DemonstrationState copyWith({
    bool? slidableDemoShown,
  }) {
    return DemonstrationState(
      slidableDemoShown: slidableDemoShown ?? this.slidableDemoShown,
    );
  }
}
