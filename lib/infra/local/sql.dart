// lib/infra/local/sql.dart

const String sqlCreateTable = '''
-- Tabela de pacientes
CREATE TABLE Paciente (
    idPaciente INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    dataNascimento TEXT,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco VARCHAR(255),
    convenio VARCHAR(100),
    alergias TEXT,                     -- NOVO
    condicoesPreExistentes TEXT        -- NOVO
);

-- Tabela de profissionais da saúde
CREATE TABLE Profissional (
    idProfissional INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100),
    registro VARCHAR(50),
    email VARCHAR(100),
    telefone VARCHAR(15),
    tipoUsuario TEXT NOT NULL
);

-- Tabela de salas (consultórios, laboratórios, etc.)
CREATE TABLE Sala (
    idSala INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(50),
    tipo VARCHAR(50),
    capacidade INT
);

-- Tabela de receitas médicas
CREATE TABLE Receita (
    idReceita INTEGER PRIMARY KEY AUTOINCREMENT,
    dataEmissao TEXT,
    observacoes TEXT
);

-- Tabela de consultas
CREATE TABLE Consulta (
    idConsulta INTEGER PRIMARY KEY AUTOINCREMENT,
    dataHora TEXT NOT NULL,
    motivo TEXT,
    diagnostico TEXT,
    idPaciente INT,
    idProfissional INT,
    idSala INT,
    idReceita INT,
    FOREIGN KEY (idPaciente) REFERENCES Paciente(idPaciente) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idProfissional) REFERENCES Profissional(idProfissional) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idSala) REFERENCES Sala(idSala) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idReceita) REFERENCES Receita(idReceita) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabela de exames
CREATE TABLE Exame (
    idExame INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(100),
    descricao TEXT
);

-- Resultados dos exames vinculados às consultas
CREATE TABLE ResultadoExame (
    idResultado INTEGER PRIMARY KEY AUTOINCREMENT,
    idConsulta INT,
    idExame INT,
    resultado TEXT, -- Descrição do resultado
    urlDocumento TEXT, -- NOVO: Para um link/URL do documento
    FOREIGN KEY (idConsulta) REFERENCES Consulta(idConsulta) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idExame) REFERENCES Exame(idExame) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Cadastro de medicamentos
CREATE TABLE Medicamento (
    idMedicamento INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    estoqueAtual INT
);

-- Prescrição dos medicamentos por receita
CREATE TABLE PrescricaoMedicamento (
    idPrescricao INTEGER PRIMARY KEY AUTOINCREMENT,
    idReceita INT,
    idMedicamento INT,
    dosagem VARCHAR(100),
    via VARCHAR(50),
    frequencia VARCHAR(100),
    FOREIGN KEY (idReceita) REFERENCES Receita(idReceita) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idMedicamento) REFERENCES Medicamento(idMedicamento) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Registro financeiro por consulta
CREATE TABLE Financeiro (
    idFinanceiro INTEGER PRIMARY KEY AUTOINCREMENT,
    idConsulta INT,
    valor REAL,
    formaPagamento VARCHAR(50),
    dataPagamento TEXT,
    statusPagamento TEXT,
    FOREIGN KEY (idConsulta) REFERENCES Consulta(idConsulta) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Contas a receber
CREATE TABLE ContaReceber (
    idConta INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(255),
    valor REAL,
    vencimento TEXT,
    status TEXT
);

-- Contas a pagar
CREATE TABLE ContaPagar (
    idConta INTEGER PRIMARY KEY AUTOINCREMENT,
    descricao VARCHAR(255),
    valor REAL,
    vencimento TEXT,
    status TEXT
);
''';
