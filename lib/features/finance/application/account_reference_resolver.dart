import '../domain/entities/finance_account.dart';

class AccountResolution {
  const AccountResolution._({this.account, this.candidates = const []});

  const AccountResolution.resolved(FinanceAccount account)
    : this._(account: account);

  const AccountResolution.notFound() : this._();

  const AccountResolution.ambiguous(List<FinanceAccount> candidates)
    : this._(candidates: candidates);

  final FinanceAccount? account;
  final List<FinanceAccount> candidates;

  bool get isResolved => account != null;
  bool get isAmbiguous => account == null && candidates.length > 1;
}

/// Resolve referências humanas (nome, tipo ou ID) sem expor essa tarefa à IA.
class AccountReferenceResolver {
  const AccountReferenceResolver();

  AccountResolution resolve(String? reference, List<FinanceAccount> accounts) {
    final available = accounts.where((account) => !account.archived).toList();
    if (available.isEmpty) return const AccountResolution.notFound();

    final raw = reference?.trim() ?? '';
    if (raw.isEmpty) {
      return available.length == 1
          ? AccountResolution.resolved(available.single)
          : AccountResolution.ambiguous(available);
    }

    final byId = available.where((account) => account.id == raw).toList();
    if (byId.length == 1) return AccountResolution.resolved(byId.single);

    final normalizedReference = normalizeFinanceText(raw);
    var candidates = available.where((account) {
      final normalizedName = normalizeFinanceText(account.name);
      return normalizedName == normalizedReference;
    }).toList();
    if (candidates.length == 1) {
      return AccountResolution.resolved(candidates.single);
    }

    final asksForCard = _containsAny(normalizedReference, const [
      'cartao',
      'credito',
      'fatura',
    ]);
    final asksForCash = _containsAny(normalizedReference, const [
      'dinheiro',
      'carteira',
      'especie',
    ]);
    final asksForBankAccount = _containsAny(normalizedReference, const [
      'conta',
      'corrente',
      'banco',
      'debito',
    ]);

    final referenceWithoutKind = _removeKindWords(normalizedReference);
    candidates = available.where((account) {
      if (asksForCard) {
        if (!account.isCard) return false;
      } else if (asksForCash) {
        if (account.kind != 'cash') return false;
      } else if (asksForBankAccount && account.kind != 'account') {
        return false;
      }
      final normalizedName = normalizeFinanceText(account.name);
      return referenceWithoutKind.isEmpty ||
          normalizedName.contains(referenceWithoutKind) ||
          referenceWithoutKind.contains(normalizedName);
    }).toList();

    if (candidates.length == 1) {
      return AccountResolution.resolved(candidates.single);
    }
    if (candidates.length > 1) return AccountResolution.ambiguous(candidates);

    final referenceTokens = referenceWithoutKind
        .split(' ')
        .where((token) => token.length >= 2)
        .toSet();
    candidates = available.where((account) {
      final nameTokens = normalizeFinanceText(account.name).split(' ').toSet();
      return referenceTokens.any(nameTokens.contains);
    }).toList();
    if (candidates.length == 1) {
      return AccountResolution.resolved(candidates.single);
    }
    if (candidates.length > 1) return AccountResolution.ambiguous(candidates);

    return const AccountResolution.notFound();
  }

  bool _containsAny(String value, List<String> words) =>
      words.any((word) => value.split(' ').contains(word));

  String _removeKindWords(String value) {
    const ignored = {
      'a',
      'ao',
      'cartao',
      'credito',
      'da',
      'de',
      'debito',
      'do',
      'fatura',
      'meu',
      'minha',
      'na',
      'no',
      'o',
      'conta',
      'banco',
      'corrente',
    };
    return value
        .split(' ')
        .where((token) => token.isNotEmpty && !ignored.contains(token))
        .join(' ');
  }
}

String normalizeFinanceText(String value) {
  const replacements = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  var normalized = value.toLowerCase();
  replacements.forEach((from, to) {
    normalized = normalized.replaceAll(from, to);
  });
  return normalized
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
