import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/features/auth/domain/entities/user.dart';
import 'package:pocket_plus/features/auth/domain/usecases/logout_user.dart'; // Reutilizamos LogoutUser
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Para notificar logout
import 'package:pocket_plus/features/profile/domain/entities/user_statistics.dart';
import 'package:pocket_plus/features/profile/domain/usecases/get_user_profile_data.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetUserProfileData _getUserProfileDataUseCase;
  final LogoutUser _logoutUserUseCase;
  final AuthCubit _authCubit; // Para coordinar el estado de logout

  ProfileCubit({
    required GetUserProfileData getUserProfileDataUseCase,
    required LogoutUser logoutUserUseCase,
    required AuthCubit authCubit,
  })  : _getUserProfileDataUseCase = getUserProfileDataUseCase,
        _logoutUserUseCase = logoutUserUseCase,
        _authCubit = authCubit,
        super(ProfileInitial());

  Future<void> loadUserProfile() async {
    emit(ProfileLoading());
    final result = await _getUserProfileDataUseCase();
    result.fold(
      (failure) => emit(ProfileFailure(message: failure.message)),
      (data) => emit(ProfileLoaded(user: data.user, statistics: data.statistics)),
    );
  }

  Future<void> logout() async {
    // Podríamos emitir un ProfileLogoutInProgress si la UI necesita reaccionar
    final result = await _logoutUserUseCase();
    result.fold(
      (failure) {
        // Incluso si el logout en backend falla, forzamos el logout local en AuthCubit
        _authCubit.logout(); // Esto cambiará el estado global de autenticación
        emit(ProfileFailure(message: "Error al cerrar sesión: ${failure.message}. Sesión local terminada."));
      },
      (_) {
        _authCubit.logout(); // Notifica al AuthCubit para que cambie su estado
        // No necesitamos un ProfileLogoutSuccess aquí, AuthCubit manejará la redirección
      },
    );
  }

  // TODO: Métodos para cambiar preferencias (notificaciones, tema oscuro)
  // void toggleNotifications(bool enabled) {
  //   if (state is ProfileLoaded) {
  //     final currentState = state as ProfileLoaded;
  //     emit(currentState.copyWith(notificationsEnabled: enabled));
  //     // Aquí guardarías la preferencia en SharedPreferences o similar
  //   }
  // }
  // void toggleDarkMode(bool enabled) {
  //   if (state is ProfileLoaded) {
  //     // ... lógica similar y cambiar tema de la app globalmente ...
  //   }
  // }
}