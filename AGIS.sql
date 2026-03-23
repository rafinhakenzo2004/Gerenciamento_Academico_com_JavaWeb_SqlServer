CREATE DATABASE AGIS
GO

USE AGIS
GO

CREATE TABLE aluno (
	cpf 				CHAR(11) 		NOT NULL,
	nome 				VARCHAR(200) 	NOT NULL,
	nome_social	 		VHARCHAR(100),
	dt_nasc				DATE 			NOT NULL,
	telefone 			VARCHAR(15)		NOT NULL,
	email_pessoal		VARCHAR(50)	 	NOT NULL,
	email_corporativo   VARCHAR(50)		NOT NULL,
	dt_con_2grau		DATE			NOT NULL,
	instituicao_2grau	VARCHAR(100)	NOT NULL,
	pt_vestibular		INT 			NOT NULL,
	pos_vestibular		INT				NOT NULL,
	ano_ingresso		INT				NOT NULL,
	sem_ingresso		INT 			NOT NULL,
	sem_lim_grad		INT 			NOT NULL,
	ano_lim_grad		INT 			NOT NULL,
	ra 					VARCHAR(25) 	NOT NULL
PRIMARY KEY (cpf)
)

CREATE TABLE curso (
	codigo 		INT				NOT NULL,
	nome		VARCHAR(100)	NOT NULL,
	carga_hr	VARCHAR(30)		NOT NULL,
	sigla		VARCHAR(50) 	NOT NULL,
	nt_enade	INT				NOT NULL
	