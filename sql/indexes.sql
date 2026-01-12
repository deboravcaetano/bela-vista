-- == ========================================================== == --
-- == ========================= INDEXES ======================== == --
-- Indexação do Sistema de Dados.
-- == ========================================================== == --

USE BelaVista;

-- Viagem
CREATE INDEX idx_Viagem_Id ON Viagem(Id);
CREATE INDEX idx_Viagem_Titulo ON Viagem(Titulo);

-- DiaDeViagem
CREATE INDEX idx_DiaDeViagem_IdViagem ON DiaDeViagem(Id_Viagem);
CREATE INDEX idx_DiaDeViagem_Data ON DiaDeViagem(Data);

-- ViagemRealizadaUtilizador
CREATE INDEX idx_VRU_IdViagem ON ViagemRealizadaUtilizador(Id_Viagem);
CREATE INDEX idx_VRU_IdUtilizador ON ViagemRealizadaUtilizador(Id_Utilizador);
CREATE INDEX idx_VRU_Cargo ON ViagemRealizadaUtilizador(Cargo);

-- Utilizador
CREATE INDEX idx_Utilizador_Id ON Utilizador(Id);
CREATE INDEX idx_Utilizador_Nome ON Utilizador(Nome);

-- UtilizadorPertenceOrganizacao
CREATE INDEX idx_UPO_IdOrganizacao ON UtilizadorPertenceOrganizacao(Id_Organizacao);
CREATE INDEX idx_UPO_IdUtilizador ON UtilizadorPertenceOrganizacao(Id_Utilizador);
