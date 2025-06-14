// lib/infra/local/sql.dart

const String sqlCreateTable = '''
-- Tabela de usuários para autenticação
CREATE TABLE Usuario (
    idUsuario INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    passwordHash TEXT NOT NULL,
    salt TEXT NOT NULL,
    email VARCHAR(100) UNIQUE,
    tipo TEXT NOT NULL
);

-- Tabela de pacientes
CREATE TABLE Paciente (
    idPaciente INTEGER PRIMARY KEY AUTOINCREMENT,
    idUsuario INT,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    dataNascimento TEXT,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco VARCHAR(255),
    convenio VARCHAR(100),
    alergias TEXT,
    condicoesPreExistentes TEXT,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabela de profissionais da saúde
CREATE TABLE Profissional (
    idProfissional INTEGER PRIMARY KEY AUTOINCREMENT,
    idUsuario INT,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(100),
    registro VARCHAR(50),
    email VARCHAR(100),
    telefone VARCHAR(15),
    tipoUsuario TEXT NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabela de salas
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

-- Tabela de Procedimentos
CREATE TABLE Procedimento (
    idProcedimento INTEGER PRIMARY KEY AUTOINCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    valor REAL NOT NULL
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
    idProcedimentoPrincipal INT,
    FOREIGN KEY (idPaciente) REFERENCES Paciente(idPaciente) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idProfissional) REFERENCES Profissional(idProfissional) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idSala) REFERENCES Sala(idSala) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idReceita) REFERENCES Receita(idReceita) ON DELETE NO ACTION ON UPDATE NO ACTION,
    FOREIGN KEY (idProcedimentoPrincipal) REFERENCES Procedimento(idProcedimento) ON DELETE SET NULL ON UPDATE CASCADE
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
    resultado TEXT,
    urlDocumento TEXT,
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

-- Prescrição dos medicamentos por receita (ADICIONADO QUANTIDADE AQUI)
CREATE TABLE PrescricaoMedicamento (
    idPrescricao INTEGER PRIMARY KEY AUTOINCREMENT,
    idReceita INT,
    idMedicamento INT,
    dosagem VARCHAR(100),
    via VARCHAR(50),
    frequencia VARCHAR(100),
    quantidade INT NOT NULL, -- <<<< NOVO: QUANTIDADE PARA BAIXA DE ESTOQUE >>>>
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