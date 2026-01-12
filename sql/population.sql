-- == ========================================================== == --
-- == ======================= POPULATION ======================= == --
-- Povoamento da base de dados Bela Vista.
-- == ========================================================== == --

USE BelaVista;

INSERT INTO Utilizador (Nome, Idade, Email, Telefone, Admin) VALUES
  ('Débora Caetano', 19, 'debora.caetano@email.com', '912345678', FALSE),
  ('Gonçalo Fernandes', 78, 'gonçalo.fernandes@email.com', '934567890', TRUE),
  ('Jonas Johanes', 22, 'jonas.johanes@email.com', '914567890', FALSE);

INSERT INTO Organizacao (Nome) VALUES
  ('CeBELUM'),
  ('CeSIUM'),
  ('BestTravel');

INSERT INTO UtilizadorPertenceOrganizacao (Id_Utilizador, Id_Organizacao) VALUES
  (2, 2),
  (3, 2),
  (2, 3);

INSERT INTO Viagem (Titulo, Descricao) VALUES
  ('Tour pelo Douro', 'Viagem de dia inteiro pelo Vale do Douro com visita a quintas'),
  ('Roteiro Histórico Porto', 'Descoberta dos principais monumentos históricos do Porto'),
  ('Escapadinha em Guimarães', 'Fim de semana no berço da nação portuguesa'),
  ('Aventura na Serra da Estrela', 'Experiência de montanha com trilhos e gastronomia local');

INSERT INTO ViagemMencionaOrganizacao (Id_Viagem, Id_Organizacao) VALUES
  (1, 1),
  (2, 1),
  (1, 3),
  (3, 2),
  (4, 3);

INSERT INTO DiaDeViagem (Data, Id_Viagem, Custo, Alojamento, Transporte) VALUES
  ('2025-03-15', 1, 75.50, 'Hotel Douro Vista', 'Autocarro turístico'),
  ('2025-03-20', 2, 45.00, NULL, 'A pé'),
  ('2025-03-21', 2, 40.00, NULL, 'Metro'),
  ('2025-04-05', 3, 60.00, 'Pousada de Guimarães', 'Carro próprio'),
  ('2025-04-06', 3, 55.00, 'Pousada de Guimarães', 'A pé'),
  ('2025-05-10', 4, 80.00, 'Casa da Montanha', 'Carrinha 4x4'),
  ('2025-05-11', 4, 70.00, 'Casa da Montanha', 'A pé');

INSERT INTO PontoDeInteresse (Nome, Localizacao, Descricao, Horario, Data, Id_Viagem) VALUES
  ('Quinta do Vesúvio', 'Douro', 'Quinta vinícola com provas de vinho', '09:00:00', '2025-03-15', 1),
  ('Miradouro de São Leonardo', 'Douro', 'Vista panorâmica sobre o rio', '11:30:00', '2025-03-15', 1),
  ('Restaurante DOC', 'Douro', 'Almoço com vista privilegiada', '13:00:00', '2025-03-15', 1),
  ('Torre dos Clérigos', 'Porto Centro', 'Monumento icónico do Porto', '09:00:00', '2025-03-20', 2),
  ('Livraria Lello', 'Porto Centro', 'Uma das livrarias mais bonitas do mundo', '10:30:00', '2025-03-20', 2),
  ('Ribeira do Porto', 'Porto Centro', 'Passeio junto ao rio com esplanadas', '12:00:00', '2025-03-20', 2),
  ('Palácio da Bolsa', 'Porto Centro', 'Salão Árabe e arquitetura impressionante', '14:00:00', '2025-03-21', 2),
  ('Caves do Vinho do Porto', 'Vila Nova de Gaia', 'Prova de vinhos do Porto', '16:00:00', '2025-03-21', 2),
  ('Castelo de Guimarães', 'Guimarães', 'Castelo medieval, berço de Portugal', '10:00:00', '2025-04-05', 3),
  ('Paço dos Duques', 'Guimarães', 'Palácio do século XV', '14:00:00', '2025-04-05', 3),
  ('Centro Histórico', 'Guimarães', 'Passeio pelas ruas medievais', '09:00:00', '2025-04-06', 3),
  ('Torre da Estrela', 'Serra da Estrela', 'Ponto mais alto de Portugal Continental', '10:00:00', '2025-05-10', 4),
  ('Lagoa Comprida', 'Serra da Estrela', 'Lagoa glaciar com trilho pedestre', '14:00:00', '2025-05-10', 4),
  ('Queijaria Artesanal', 'Serra da Estrela', 'Visita e prova de queijo da serra', '10:00:00', '2025-05-11', 4);

INSERT INTO Fotografias (Id_PontoInteresse, Url_fotografia) VALUES
  (1, 'https://fotos.belavista.com/douro/quinta-vesuvio-1.jpg'),
  (2, 'https://fotos.belavista.com/douro/miradouro-leonardo.jpg'),
  (4, 'https://fotos.belavista.com/porto/torre-clerigos-exterior.jpg'),
  (4, 'https://fotos.belavista.com/porto/torre-clerigos-vista.jpg'),
  (5, 'https://fotos.belavista.com/porto/lello-escadaria.jpg'),
  (7, 'https://fotos.belavista.com/porto/palacio-bolsa.jpg'),
  (9, 'https://fotos.belavista.com/guimaraes/castelo-exterior.jpg'),
  (10, 'https://fotos.belavista.com/guimaraes/paco-duques.jpg'),
  (12, 'https://fotos.belavista.com/estrela/torre-vista.jpg'),
  (13, 'https://fotos.belavista.com/estrela/lagoa-comprida.jpg');

INSERT INTO ViagemRealizadaUtilizador (Id_Viagem, Id_Utilizador, Cargo, Avaliacao_Descritiva, Avaliacao_Quantitativa) VALUES
  (1, 1, 'organizador', 'Experiência maravilhosa! Tudo muito bem organizado.', 5),
  (1, 2, 'participante', 'Adorei as quintas e as paisagens do Douro.', 5),
  (2, 3, 'organizador', 'Porto é sempre uma boa escolha.', 4),
  (2, 1, 'participante', 'Conheci lugares que não conhecia no Porto!', 5),
  (3, 2, 'organizador', 'Guimarães tem um charme especial.', 5),
  (4, 3, 'organizador', 'A serra estava linda mas o trilho foi cansativo.', 4);
  