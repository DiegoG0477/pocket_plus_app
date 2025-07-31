import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/usecases/get_current_user.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/usecases/login_user.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/usecases/logout_user.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/domain/usecases/register_user.dart'; // Ajusta ruta

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUser loginUserUseCase;
  final RegisterUser registerUserUseCase;
  final LogoutUser logoutUserUseCase;
  final GetCurrentUser getCurrentUserUseCase;

  AuthCubit({
    required this.loginUserUseCase,
    required this.registerUserUseCase,
    required this.logoutUserUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial());

  Future<void> appStarted() async {
    emit(AuthLoading());
    final failureOrUser = await getCurrentUserUseCase();
    failureOrUser.fold(
      (failure) => emit(
        AuthInitial(),
      ), // O AuthFailure si quieres mostrar un error al iniciar
      (user) {
        if (user != null) {
          emit(AuthSuccess(user: user));
        } else {
          emit(AuthInitial()); // No hay sesión activa
        }
      },
    );
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final failureOrUser = await loginUserUseCase(email, password);
    failureOrUser.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) {
        print("✅ CUBIT: Emitiendo AuthSuccess para el usuario: ${user.nombre}");
        emit(AuthSuccess(user: user));
      },
    );
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    String? fotoPerfilUrl, // Opcional
  }) async {
    emit(AuthLoading());
    final failureOrUser = await registerUserUseCase(
      nombre: nombre,
      email: email,
      password: password,
      fotoPerfilUrl: fotoPerfilUrl,
    );
    failureOrUser.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final failureOrVoid = await logoutUserUseCase();
    failureOrVoid.fold(
      (failure) => emit(
        AuthFailure(message: failure.message),
      ), // Podrías tener un error específico de logout
      (_) => emit(AuthLoggedOut()), // O directamente AuthInitial si prefieres
    );
  }
}
