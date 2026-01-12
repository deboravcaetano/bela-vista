-- == ========================================================== == --
-- == ======================== CREATION ======================== == --
-- Criação da Base de Dados BelaVista.
-- == ========================================================== == --

CREATE DATABASE IF NOT EXISTS BelaVista;

USE BelaVista;

CREATE TABLE Utilizador (
	Id INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Idade INT UNSIGNED NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    Telefone VARCHAR(15) NOT NULL,
    Admin BOOLEAN NOT NULL DEFAULT FALSE
);


CREATE TABLE Organizacao (
	Id INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(150) NOT NULL
);


CREATE TABLE UtilizadorPertenceOrganizacao (
	Id_Utilizador INT NOT NULL,
    Id_Organizacao INT NOT NULL,
    PRIMARY KEY (Id_Utilizador, Id_Organizacao),
    FOREIGN KEY (Id_Utilizador) REFERENCES Utilizador(Id) ON DELETE CASCADE,
    FOREIGN KEY (Id_Organizacao) REFERENCES Organizacao(Id) ON DELETE CASCADE
);


CREATE TABLE Viagem (
	Id INT AUTO_INCREMENT PRIMARY KEY,
    Titulo VARCHAR(150) NOT NULL,
    Descricao TEXT NOT NULL
);


CREATE TABLE ViagemRealizadaUtilizador (
    Id_Viagem INT NOT NULL,
	Id_Utilizador INT NOT NULL,
    Cargo ENUM('participante', 'organizador') NOT NULL,
    Avaliacao_Descritiva TEXT,
    Avaliacao_Quantitativa INT CHECK (Avaliacao_Quantitativa >= 0 AND Avaliacao_Quantitativa <=5),
    PRIMARY KEY (Id_Viagem, Id_Utilizador),
    FOREIGN KEY (Id_Utilizador) REFERENCES Utilizador(Id) ON DELETE CASCADE,
    FOREIGN KEY (Id_Viagem) REFERENCES Viagem(Id) ON DELETE CASCADE
);


 CREATE TABLE ViagemMencionaOrganizacao (
    Id_Viagem INT NOT NULL,
    Id_Organizacao INT NOT NULL,
    PRIMARY KEY (Id_Viagem, Id_Organizacao),
    FOREIGN KEY (Id_Viagem) REFERENCES Viagem(Id) ON DELETE CASCADE,
    FOREIGN KEY (Id_Organizacao) REFERENCES Organizacao(Id) ON DELETE CASCADE
);


CREATE TABLE DiaDeViagem (
    Data DATE NOT NULL,
	Id_Viagem INT NOT NULL,
    Custo DECIMAL(8,2) NOT NULL CHECK (Custo >= 0),
    Alojamento VARCHAR(150),
    Transporte VARCHAR(100),
    PRIMARY KEY(Data, Id_Viagem),
    FOREIGN KEY (Id_Viagem) REFERENCES Viagem(Id) ON DELETE CASCADE
);


CREATE TABLE PontoDeInteresse (
	Id INT AUTO_INCREMENT PRIMARY KEY,
    Nome VARCHAR(150) NOT NULL,
    Localizacao VARCHAR(200) NOT NULL,
    Descricao TEXT NOT NULL,
    Horario TIME NOT NULL,
    Data DATE NOT NULL,
    Id_Viagem INT NOT NULL,
    FOREIGN KEY (Data,Id_Viagem) REFERENCES DiaDeViagem(Data, Id_Viagem) ON DELETE CASCADE
);


CREATE TABLE Fotografias (
	Id_Fotografia INT AUTO_INCREMENT PRIMARY KEY,
    Id_PontoInteresse INT NOT NULL,
    Url_fotografia TEXT NOT NULL,
    FOREIGN KEY (Id_PontoInteresse) REFERENCES PontoDeInteresse(Id) ON DELETE CASCADE
);
