# Aplicativo de Gerenciamento de Despesas Pessoais

## Visão Geral

Este é um aplicativo móvel completo para gerenciamento de despesas pessoais, desenvolvido com Flutter para garantir compatibilidade entre plataformas Android e iOS. O aplicativo oferece uma interface intuitiva, moderna e funcional para ajudar os usuários a controlar suas finanças pessoais.

## Funcionalidades Principais

- **Cadastro de Entradas e Saídas**: Registre suas receitas e despesas com detalhes como valor, categoria, data e descrição.
- **Controle de Economias**: Defina metas de economia e acompanhe seu progresso.
- **Gráficos de Visualização**: Analise suas finanças com gráficos interativos mensais e anuais.
- **Backup de Dados**: Mantenha seus dados seguros com backup local e na nuvem.
- **Exportação de Relatórios**: Exporte relatórios financeiros em PDF ou Excel.

## Tecnologias Utilizadas

- **Flutter**: Framework para desenvolvimento multiplataforma
- **SQLite**: Banco de dados local para armazenamento de dados
- **fl_chart**: Biblioteca para criação de gráficos interativos
- **path_provider**: Gerenciamento de diretórios e arquivos
- **intl**: Internacionalização e formatação de datas e valores
- **pdf**: Geração de relatórios em PDF
- **excel**: Geração de relatórios em Excel

## Estrutura do Projeto

O projeto segue uma arquitetura organizada em camadas:

```
lib/
├── models/           # Modelos de dados
├── views/            # Telas da interface do usuário
├── controllers/      # Lógica de controle
├── services/         # Serviços (banco de dados, backup, relatórios)
├── utils/            # Utilitários e constantes
└── widgets/          # Componentes reutilizáveis
```

## Instalação

### Requisitos

- Flutter 3.0.0 ou superior
- Dart 2.17.0 ou superior
- Android Studio / Xcode para execução em emuladores ou dispositivos físicos

### Passos para Instalação

1. Clone o repositório:
   ```
   git clone https://github.com/seu-usuario/financas-app.git
   ```

2. Navegue até o diretório do projeto:
   ```
   cd financas-app
   ```

3. Instale as dependências:
   ```
   flutter pub get
   ```

4. Execute o aplicativo:
   ```
   flutter run
   ```

## Guia de Uso

### Dashboard

A tela inicial apresenta um resumo das suas finanças, incluindo:
- Saldo atual
- Total de entradas e saídas
- Economias acumuladas
- Gráfico de distribuição de despesas

### Transações

Para adicionar uma nova transação:
1. Toque no botão "+" na tela principal
2. Selecione o tipo (Entrada ou Saída)
3. Preencha os detalhes (valor, categoria, data, descrição)
4. Toque em "Adicionar"

Para editar ou excluir uma transação existente, toque nela na lista e selecione a ação desejada.

### Metas de Economia

Para criar uma nova meta:
1. Acesse a aba "Economias"
2. Toque no botão "+"
3. Defina um título, valor alvo, prazo e outros detalhes
4. Toque em "Criar Meta"

Para adicionar fundos a uma meta, acesse os detalhes da meta e toque em "Adicionar".

### Relatórios

Na aba "Relatórios", você pode:
- Visualizar gráficos de distribuição de despesas por categoria
- Analisar a evolução do seu fluxo de caixa
- Acompanhar o progresso das suas metas de economia
- Exportar relatórios em PDF ou Excel

### Backup e Restauração

Para fazer backup dos seus dados:
1. Acesse o menu de configurações
2. Selecione "Backup e Restauração"
3. Escolha entre backup local ou na nuvem
4. Toque em "Criar Backup"

Para restaurar um backup:
1. Acesse o menu de configurações
2. Selecione "Backup e Restauração"
3. Escolha o backup que deseja restaurar
4. Toque em "Restaurar"

## Sugestões para Melhorias Futuras

1. **Sincronização entre Dispositivos**: Implementar sincronização de dados entre múltiplos dispositivos.
2. **Reconhecimento de Imagem**: Adicionar funcionalidade para escanear recibos e extrair informações automaticamente.
3. **Integração Bancária**: Conectar com APIs de bancos para importar transações automaticamente.
4. **Previsões Financeiras**: Implementar algoritmos para prever gastos futuros com base no histórico.
5. **Versão Web**: Desenvolver uma versão web do aplicativo para acesso via navegador.
6. **Categorias Personalizáveis**: Permitir que o usuário crie e personalize suas próprias categorias.
7. **Orçamentos Mensais**: Adicionar funcionalidade para definir e acompanhar orçamentos por categoria.
8. **Múltiplas Moedas**: Suporte para transações em diferentes moedas com conversão automática.

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para detalhes.

## Contato

Para sugestões, dúvidas ou suporte, entre em contato através do email: exemplo@financasapp.com
