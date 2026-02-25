# 🌌 O Grimório Perdido

**O Grimório Perdido** é uma plataforma gamificada de imersão literária e filológica, projetada para restaurar o conhecimento das eras esquecidas da língua portuguesa através de uma experiência visualmente mística e interativa.

![Status do Projeto](https://img.shields.io/badge/Status-Hospedado%20na%20Vercel-gold?style=for-the-badge)
![Tech](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter)
![Backend](https://img.shields.io/badge/Supabase-Auth%20&%20DB-green?style=for-the-badge&logo=supabase)

---

## 📜 Sobre o Projeto

Ocupando o papel de um **Guardião**, o usuário deve navegar por diferentes Eras Literárias (como o Quinhentismo) para "dominar" palavras mestras. Cada palavra é um artefato de conhecimento que exige compreensão teórica, aplicação prática e criatividade para ser restaurada no Grimório pessoal do jogador.

---

## ✨ Funcionalidades Atuais

### 🎮 Experiência de Jogo (Gameplay)
*   **Linha do Tempo das Eras**: Navegação fluida entre períodos literários com progresso individual por capítulo.
*   **Ciclo de Imersão em 4 Estágios**:
    1.  **Revelação**: Compreensão do termo, sua classe gramatical e etimologia.
    2.  **Quiz de Sabedoria**: Teste de múltipla escolha sobre o significado profundo.
    3.  **A Lacuna Histórica**: Desafio de preenchimento de lacunas em citações de autores clássicos.
    4.  **A Forja**: Desafio criativo onde o usuário deve escrever textos originais usando o termo aprendido.
*   **Sistemas RPG**:
    *   **Ganho de XP e Níveis**: Sistema de progressão de personagem.
    *   **Árvore de Talentos**: Gastar pontos de talento para desbloquear habilidades (como dobro de XP).
    *   **Biblioteca de Relíquias**: Visualização de artefatos e palavras já dominadas no "Meu Grimório".

### 🔐 Autenticação e Persistência (Supabase)
*   **Acesso de Guardião**: Sistema de Login e Cadastro integrado ao **Supabase Auth**.
*   **Persistência Híbrida**: 
    *   Uso de **SharedPreferences** para estado local rápido.
    *   Estrutura pronta para sincronização em nuvem.
*   **Modo Admin**: Acesso exclusivo para mestres (via email `admin@grimorio.com`) para gerenciar o conteúdo do jogo.

### ⚒️ Painel do Mestre (Forja de Conhecimento)
*   **Criação de Conteúdo**: Interface administrativa para adicionar novas palavras a qualquer era existente.
*   **✨ Auxílio de IA**: Botão funcional que simula a geração de conteúdo complexo (etimologia, perguntas, citações) para agilizar o trabalho do administrador.

### 🎨 Design e Estética (Premium UI)
*   **Tema "Dark Mystic"**: Paleta de cores baseada em preto profundo, ouro antigo e tons vibrantes para cada era.
*   **Fundo Dinâmico**: "Galáxia de Letras" animada que reage à navegação.
*   **Micro-interações**: Partículas de luz ao acertar respostas e animações de tremor ao errar.

---

## 🚀 Tecnologias Utilizadas

*   **Frontend**: Flutter (Web/Mobile)
*   **Gerenciamento de Estado**: Provider
*   **Backend**: Supabase (Autenticação)
*   **Persistência Local**: Shared Preferences
*   **Hospedagem**: Vercel
*   **Estilização**: Google Fonts (Georgia/Inter)

---

## 🛠️ Configuração de Desenvolvimento

Se desejar rodar o projeto localmente:

1.  **Clone o repositório**:
    ```bash
    git clone https://github.com/AngeloCasten/grimorio-perdido.git
    ```
2.  **Instale as dependências**:
    ```bash
    flutter pub get
    ```
3.  **Variáveis de Ambiente**: O projeto utiliza `--dart-define` para segurança. Rode com:
    ```bash
    flutter run -d chrome --dart-define=SUPABASE_URL=SUA_URL --dart-define=SUPABASE_ANON_KEY=SUA_KEY
    ```

---

## 🌌 Versão Vercel (SPA Routing)

O projeto inclui um arquivo `vercel.json` configurado para evitar erros de 404 em Single Page Applications:
```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/" }
  ]
}
```

---

*Forjado com paixão e código por **Angelo Casten** e **Antigravity AI***.
