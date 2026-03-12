/// Dados fake usados no ecrã de **Perfil (Aluno)**.
///
/// Onde é usado:
/// - Em `lib/features/aluno/perfil/` para preencher a UI durante prototipagem/dev
///   quando ainda não há dados reais do utilizador vindos da API.
class PerfilMockData {
  const PerfilMockData._();

  /// Nome completo apresentado no perfil.
  static const nomeCompleto = 'Maria Silva';

  /// Email apresentado no perfil.
  static const email = 'estudante@email.com';

  /// Contacto telefónico apresentado no perfil.
  static const telefone = '+351 912 345 678';

  /// Texto “Sobre mim” do aluno.
  static const sobreMim =
      'Sou estudante do secundário interessado em ciências exatas. Gosto de aprender com explicadores pacientes e que usam exemplos práticos.';

  /// Lista de interesses/disciplinas preferidas.
  static const interesses = ['Matemática', 'Física', 'Inglês'];

  /// Nível de ensino do aluno.
  static const nivelEnsino = 'Secundário';
}
