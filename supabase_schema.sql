/* 
  COPIE E COLE ESTE SCRIPT NO SQL EDITOR DO SUPABASE PARA CONFIGURAR O BANCO
*/

-- 1. Tabela de Perfis (XP e Nível)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  nivel INTEGER DEFAULT 1,
  xp INTEGER DEFAULT 0,
  fragmentos INTEGER DEFAULT 0,
  pontos_talento INTEGER DEFAULT 0,
  palavras_dominadas TEXT[] DEFAULT '{}',
  talentos TEXT[] DEFAULT '{}',
  eras_restauradas TEXT[] DEFAULT '{}',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabela de Eras
CREATE TABLE eras (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL,
  descricao TEXT,
  cor_tema BIGINT,
  avatar_seed TEXT,
  icone_code INTEGER,
  nome_artefato TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabela de Palavras Mestras
CREATE TABLE palavras (
  id TEXT PRIMARY KEY,
  era_id TEXT REFERENCES eras(id) ON DELETE CASCADE,
  termo_principal TEXT NOT NULL,
  definicao TEXT,
  etimologia TEXT,
  classe_gramatical TEXT,
  frase_lacuna TEXT,
  autor_citacao TEXT,
  pergunta_quiz TEXT,
  opcoes_quiz TEXT[],
  index_correto_quiz INTEGER,
  explicacao_erro TEXT,
  desafio_criativo TEXT,
  aceitas_flexoes TEXT[],
  xp_valor INTEGER DEFAULT 200,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Enable RLS (Segurança)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE eras ENABLE ROW LEVEL SECURITY;
ALTER TABLE palavras ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Perfis visiveis para todos" ON profiles FOR SELECT USING (true);
CREATE POLICY "Usuarios editam proprio perfil" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Eras visiveis para todos" ON eras FOR SELECT USING (true);
CREATE POLICY "Palavras visiveis para todos" ON palavras FOR SELECT USING (true);
