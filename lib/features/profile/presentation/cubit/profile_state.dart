part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;
  final UserStatistics statistics;
  // Podríamos añadir aquí las preferencias del usuario si las manejamos con este Cubit
  // final bool notificationsEnabled;
  // final bool darkModeEnabled;

  const ProfileLoaded({
    required this.user,
    required this.statistics,
    // this.notificationsEnabled = false, // Valor por defecto
    // this.darkModeEnabled = false,    // Valor por defecto
  });

  @override
  List<Object?> get props => [user, statistics/*, notificationsEnabled, darkModeEnabled*/];

  // ProfileLoaded copyWith({
  //   User? user,
  //   UserStatistics? statistics,
  //   bool? notificationsEnabled,
  //   bool? darkModeEnabled,
  // }) {
  //   return ProfileLoaded(
  //     user: user ?? this.user,
  //     statistics: statistics ?? this.statistics,
  //     notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  //     darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
  //   );
  // }
}

class ProfileFailure extends ProfileState {
  final String message;

  const ProfileFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// Estado específico para el logout si es necesario, aunque AuthCubit ya lo maneja
// class ProfileLogoutInProgress extends ProfileState {}
// class ProfileLogoutSuccess extends ProfileState {}