part of 'auth_cubit.dart'; // Para que el cubit pueda acceder a los estados privados

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {} // Estado inicial, usuario no autenticado o desconocido

class AuthLoading extends AuthState {} // Cargando durante login/register

class AuthSuccess extends AuthState {
  final User user; // Usuario autenticado

  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// Podrías tener un estado para cuando el usuario cierra sesión exitosamente
class AuthLoggedOut extends AuthState {}