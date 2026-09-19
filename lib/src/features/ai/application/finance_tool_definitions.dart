import '../../finance/domain/models.dart';
import '../domain/ai_provider.dart';

// A single read schema avoids resending account/month filters in many tools.
const financeToolDefinitions = [
  AIToolDefinition(
    name: 'query_finances',
    description: 'Consulta dados financeiros locais atualizados. Use visualize=true para pedir um gráfico local compatível; nunca desenhe o gráfico em texto. balance: dinheiro em caixa atual; savings_plan: margem mensal para uma meta e não substitui balance. Para decidir quanto gastar, chame balance e savings_plan juntas. Listas paginam por offset.',
    parameters: {
      'type': 'object',
      'properties': {
        'operation': {
          'type': 'string',
          'enum': [
            'accounts',
            'balance',
            'transactions',
            'month_summary',
            'category_spending',
            'budget_status',
            'savings_plan',
            'compare_months',
            'cash_flow',
            'invoices',
          ],
        },
        'month': {
          'type': 'string',
          'description': 'YYYY-MM; padrão mês atual.',
        },
        'months': {
          'type': 'integer',
          'minimum': 1,
          'maximum': 12,
          'description': 'compare_months, cash_flow ou invoices: 1–12 meses desde month; gráficos usam 6 por padrão.',
        },
        'account_ref': {
          'type': 'string',
          'description': 'Nome/ID; balance, transactions, category_spending, compare_months, cash_flow ou invoices.',
        },
        'search': {
          'type': 'string',
          'maxLength': 160,
          'description': 'Parte do nome; accounts ou transactions.',
        },
        'category': {'type': 'string'},
        'type': {
          'type': 'string',
          'enum': ['income', 'expense', 'transfer', 'cardPayment'],
        },
        'status': {
          'type': 'string',
          'enum': ['paid', 'pending', 'planned'],
        },
        'from': {'type': 'string', 'description': 'YYYY-MM-DD; transactions.'},
        'to': {'type': 'string', 'description': 'YYYY-MM-DD; transactions.'},
        'limit': {'type': 'integer', 'minimum': 1, 'maximum': 20},
        'offset': {'type': 'integer', 'minimum': 0},
        'savings_target_cents': {
          'type': 'integer',
          'minimum': 0,
          'maximum': 100000000000,
          'description': 'Meta mensal obrigatória em savings_plan.',
        },
        'visualize': {
          'type': 'boolean',
          'description': 'Solicita um gráfico calculado e renderizado localmente. Não gere Markdown, Mermaid, imagem ou código de gráfico.',
        },
        'monthly_income_cents': {
          'type': 'integer',
          'minimum': 0,
          'maximum': 100000000000,
          'description':
              'Renda TOTAL informada; substitui a registrada na simulação.',
        },
      },
      'required': ['operation'],
      'additionalProperties': false,
    },
  ),
  AIToolDefinition(
    name: 'prepare_transaction',
    description:
        'Prepara lançamento para revisão, sem salvar. Nunca paga fatura.',
    parameters: {
      'type': 'object',
      'properties': {
        'name': {
          'type': 'string',
          'maxLength': 160,
          'description': 'Nome curto: Mercado, Notebook; sem valor/data/conta.',
        },
        'amount_cents': {
          'type': 'integer',
          'minimum': 1,
          'maximum': 100000000000,
          'description': 'Valor por parcela, em centavos.',
        },
        'category': {'type': 'string', 'enum': financeCategories},
        'type': {
          'type': 'string',
          'enum': ['income', 'expense', 'transfer'],
        },
        'account_ref': {
          'type': 'string',
          'description': 'Nome ou ID da conta/cartão.',
        },
        'target_account_ref': {
          'type': 'string',
          'description': 'Destino obrigatório para transferência.',
        },
        'purchase_date': {
          'type': 'string',
          'description': 'YYYY-MM-DD: data da compra, nunca vencimento do cartão; padrão hoje.',
        },
        'status': {
          'type': 'string',
          'enum': ['paid', 'pending', 'planned'],
        },
        'installments': {'type': 'integer', 'minimum': 1, 'maximum': 60},
        'initial_installment': {'type': 'integer', 'minimum': 1, 'maximum': 60},
        'recurrence': {
          'type': 'string',
          'enum': ['none', 'daily', 'weekly', 'monthly', 'yearly'],
        },
        'notes': {'type': 'string', 'maxLength': 1000},
      },
      'required': ['name', 'amount_cents', 'type', 'account_ref'],
      'additionalProperties': false,
    },
  ),
  AIToolDefinition(
    name: 'prepare_account',
    description: 'Prepara conta/carteira/cartão sem salvar. Cartão exige limite, fechamento e vencimento.',
    parameters: {
      'type': 'object',
      'properties': {
        'name': {'type': 'string', 'maxLength': 160},
        'kind': {
          'type': 'string',
          'enum': ['account', 'cash', 'card'],
        },
        'opening_balance_cents': {
          'type': 'integer',
          'minimum': -100000000000,
          'maximum': 100000000000,
        },
        'limit_cents': {
          'type': 'integer',
          'minimum': 1,
          'maximum': 100000000000,
        },
        'closing_day': {'type': 'integer', 'minimum': 1, 'maximum': 31},
        'due_day': {'type': 'integer', 'minimum': 1, 'maximum': 31},
      },
      'required': ['name', 'kind'],
      'additionalProperties': false,
    },
  ),
];
