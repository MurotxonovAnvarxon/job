part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignUp extends AuthEvent {
  final String email;
  final String password;

  const SignUp(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignIn extends AuthEvent {
  final String email;
  final String password;

  const SignIn(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class SignOut extends AuthEvent {}