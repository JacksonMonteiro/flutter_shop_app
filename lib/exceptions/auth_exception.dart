class AuthException implements Exception {
  static const Map errors = {
    'EMAIL_EXISTS': 'Este e-mail já está cadastrado',
    'OPERATION_NOT_ALLOWED': 'Operação não permitida',
    'TOO_MANY_ATTEMPTS_TRY_LATER':
        'Acesso bloquado temporariamente, tente novamente mais tarde',
    'EMAIL_NOT_FOUND': 'E-mail não encontrado',
    'INVALID_PASSWORD': 'A senha informado não é válida para o usuário',
    'USER_DISABLED': 'Esta conta foi desabilitada',
  };

  final String key;

  AuthException(this.key);

  @override
  String toString() {
    return errors[key];
  }
}
