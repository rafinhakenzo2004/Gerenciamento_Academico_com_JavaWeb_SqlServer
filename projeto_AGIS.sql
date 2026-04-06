USE Agis
GO

CREATE TABLE aluno (
	ra 					VARCHAR(10) 	NOT NULL,
	cpf 				CHAR(11) 		NOT NULL,
	nome 				VARCHAR(100) 	NOT NULL,
	nome_social	 		VARCHAR(100)	NULL    ,
	dt_nasc				DATE			NOT NULL,
	telefone 			VARCHAR(20)		NOT NULL,
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
	turno 				VARCHAR(10) 	NOT NULL,
	curso_codigo		INT				NOT NULL
PRIMARY KEY (ra)
FOREIGN KEY (curso_codigo) REFERENCES curso(codigo)
)

CREATE TABLE curso (
	codigo 		INT				NOT NULL,
	nome		VARCHAR(100)	NOT NULL,
	carga_hr	VARCHAR(30)		NOT NULL,
	sigla		VARCHAR(50) 	NOT NULL,
	nota_enade	INT				NOT NULL
	PRIMARY KEY (codigo)
)

CREATE TABLE disciplina (
	codigo				INT			NOT NULL,
	curso_codigo		INT			NOT NULL,
	nome				VARCHAR(30) NOT NULL,
	qtd_horas_total		INT			NOT NULL,
	hora_inicio			VARCHAR(5)  NOT NULL,
	dia_semana			VARCHAR(15) NOT NULL,
	duracao_hora_aula	INT			NOT NULL
PRIMARY KEY (codigo, curso_codigo)
FOREIGN KEY (curso_codigo) REFERENCES curso(codigo)
)

CREATE TABLE conteudo (
    disciplina_codigo    INT             NOT NULL,
    curso_codigo         INT             NOT NULL,
    descricao            VARCHAR(100)    NOT NULL,
PRIMARY KEY (disciplina_codigo, curso_codigo),
FOREIGN KEY (disciplina_codigo, curso_codigo) REFERENCES disciplina(codigo, curso_codigo),
FOREIGN KEY (curso_codigo) REFERENCES curso(codigo)
);

CREATE TABLE matricula (
    aluno_ra            VARCHAR(10)    NOT NULL,
    disciplina_codigo   INT            NOT NULL,
    curso_codigo        INT            NOT NULL,
    ano                 INT            NOT NULL,
    semestre            INT            NOT NULL,
PRIMARY KEY (aluno_ra, disciplina_codigo, curso_codigo),
FOREIGN KEY (aluno_ra) REFERENCES aluno(ra),
FOREIGN KEY (disciplina_codigo, curso_codigo) REFERENCES disciplina(codigo, curso_codigo)
)

GO

CREATE PROCEDURE sp_valida_cpf 
	@cpf char(11)

AS
BEGIN
	DECLARE @d1 INT, @d2 INT, @i INT, @soma INT, @resto INT
	DECLARE @valido BIT = 1

	IF LEN(@cpf) < 11
	BEGIN 
		RAISERROR ('insira um cpf válido',16,1)
		RETURN
	END

	SET @soma = 0
	SET @i = 1
	WHILE @i <= 9
	BEGIN
		SET @soma = @soma + (CAST(SUBSTRING(@cpf, @i, 1) AS INT) * (11 - @i))
		SET @i = @i + 1
	END
	SET @resto = @soma % 11
	IF @resto < 2 SET @d1 = 0 ELSE SET @d1 = 11 - @resto

	SET @soma = 0
    SET @i = 1
    WHILE @i <= 10
    BEGIN
        SET @soma = @soma + (CAST(SUBSTRING(@cpf, @i, 1) AS INT) * (12 - @i))
        SET @i = @i + 1
    END
    SET @resto = @soma % 11
    IF @resto < 2 SET @d2 = 0 ELSE SET @d2 = 11 - @resto

	IF EXISTS (SELECT 1 FROM aluno WHERE cpf = @cpf)
	BEGIN
		RAISERROR ('Erro, cpf já existe', 16, 1)
	END

END

GO

CREATE PROCEDURE sp_valida_idade
	@dt_nasc DATE
AS 
BEGIN
	DECLARE @idade INT
	DECLARE @hoje DATE = GETDATE()

	SET @idade = DATEDIFF(YEAR, @dt_nasc, @hoje)

	IF (MONTH(@dt_nasc) > MONTH(@hoje)) OR 
		(MONTH(@dt_nasc) = MONTH(@hoje)) AND (DAY(@dt_nasc) > DAY(@hoje))
	BEGIN
		SET @idade = @idade - 1
	END
	
	IF (@idade < 16)
	BEGIN
		RAISERROR('O aluno deve ter 16 anos ou mais',16,1)
	END
	
	PRINT 'Idade validado'
END

GO

CREATE PROCEDURE sp_data_limite 
    @ano_ingresso INT,
    @sem_ingresso INT,
    @ano_lim_grad INT OUTPUT,
    @sem_lim_grad INT OUTPUT
AS
BEGIN 
    SET @ano_lim_grad = @ano_ingresso + 5
    SET @sem_lim_grad = @sem_ingresso 
END
GO

CREATE PROCEDURE sp_gera_ra
	@ano_ingresso INT,
	@sem_ingresso INT,
	@ra VARCHAR(10)	OUTPUT
AS
BEGIN
	DECLARE @aleatorio INT

	SET @aleatorio = (ABS(CHECKSUM(NEWID())) % 9000) + 1000

	SET @ra = CAST(@ano_ingresso AS VARCHAR) +
			  CAST(@sem_ingresso AS VARCHAR) +
			  CAST(@aleatorio AS VARCHAR)
END

GO

CREATE PROCEDURE sp_matricula_criacao
	@aluno_ra VARCHAR(10),
	@dis_codigo INT,
	@dis_curso_codigo INT,
	@ano INT,
	@semestre INT
AS
BEGIN
	DECLARE @novo_dia VARCHAR(15), @novo_inicio VARCHAR(5), @nova_duracao INT

	SELECT @novo_dia = dia_semana, @novo_inicio = hora_inicio, @nova_duracao = duracao_hora_aula
	FROM disciplina
	WHERE codigo = @dis_codigo AND curso_codigo = @dis_curso_codigo

	IF EXISTS (
		SELECT 1
		FROM matricula m
		JOIN disciplina d ON m.disciplina_codigo = d.codigo AND m.curso_codigo = d.curso_codigo
		WHERE m.aluno_ra = @aluno_ra
		AND m.ano = @ano
		AND m.semestre = @semestre
		AND d.dia_semana = @novo_dia
		AND d.hora_inicio = @novo_inicio
	)
	BEGIN
		RAISERROR('Erro, aluno já possui disciplina neste horário',16,1)
		RETURN
	END

	IF EXISTS (
		SELECT 1 FROM matricula m WHERE @aluno_ra = aluno_ra AND @dis_codigo = disciplina_codigo AND @ano = ano AND @semestre = semestre)
		BEGIN
			RAISERROR ('Já está matriculado nessa disciplia neste semestre',16,1)
			RETURN
		END

	INSERT INTO matricula (aluno_ra, disciplina_codigo, curso_codigo, ano, semestre)VALUES (@aluno_ra, @dis_codigo, @dis_curso_codigo, @ano, @semestre)
	PRINT ('Matricula feita com sucesso')
END

GO

CREATE PROCEDURE sp_insere_aluno 
    @ra                 VARCHAR(10) OUTPUT,
    @cpf                CHAR(11),
    @nome               VARCHAR(100),
    @nome_social        VARCHAR(100),
    @dt_nasc            DATE,
    @telefone           VARCHAR(20),
    @email_pessoal      VARCHAR(50),
    @email_corporativo  VARCHAR(50),
    @dt_con_2grau       DATE,
    @instituicao_2grau  VARCHAR(100),
    @pt_vestibular      INT,
    @pos_vestibular     INT,
    @ano_ingresso       INT,
    @sem_ingresso       INT,
    @turno              VARCHAR(10),
    @curso_codigo       INT
AS
BEGIN
    -- Validações internas
    IF EXISTS (SELECT 1 FROM aluno WHERE cpf = @cpf)
    BEGIN
        RAISERROR('Erro: Este CPF já está vinculado a outro aluno.', 16, 1);
        RETURN;
    END

    DECLARE @ano_lim_calc INT, @sem_lim_calc INT;
    
    -- Chama as procedures auxiliares
    EXEC sp_valida_cpf @cpf;
    EXEC sp_valida_idade @dt_nasc;
    EXEC sp_gera_ra @ano_ingresso, @sem_ingresso, @ra OUTPUT;
    EXEC sp_data_limite @ano_ingresso, @sem_ingresso, @ano_lim_calc OUTPUT, @sem_lim_calc OUTPUT;

    INSERT INTO aluno (
        ra, cpf, nome, nome_social, dt_nasc, telefone, email_pessoal, 
        email_corporativo, dt_con_2grau, instituicao_2grau, pt_vestibular, 
        pos_vestibular, ano_ingresso, sem_ingresso, sem_lim_grad, ano_lim_grad, turno, curso_codigo
    )
    VALUES (
        @ra, @cpf, @nome, @nome_social, @dt_nasc, @telefone, @email_pessoal, 
        @email_corporativo, @dt_con_2grau, @instituicao_2grau, @pt_vestibular, 
        @pos_vestibular, @ano_ingresso, @sem_ingresso, @sem_lim_calc, @ano_lim_calc, @turno, @curso_codigo
    );
END

GO

CREATE PROCEDURE sp_exclui_aluno
    @ra VARCHAR(10),
    @saida VARCHAR(100) OUTPUT
AS
BEGIN

	IF EXISTS (SELECT 1 FROM matricula WHERE aluno_ra = @ra)
    BEGIN
        SET @saida = 'Erro: Aluno possui matrículas ativas e não pode ser removido.'
        RETURN
    END

    BEGIN TRY
        DELETE FROM matricula WHERE aluno_ra = @ra
        
        DELETE FROM aluno WHERE ra = @ra
        SET @saida = 'Aluno e seus registros foram removidos com sucesso.'
    END TRY
    BEGIN CATCH
        SET @saida = 'Erro ao excluir: ' + ERROR_MESSAGE()
    END CATCH
END

GO

CREATE PROCEDURE sp_atualiza_aluno
    @ra VARCHAR(10), @nome VARCHAR(100), @nome_social VARCHAR(100),
    @telefone VARCHAR(20), @email_p VARCHAR(50), @email_c VARCHAR(50),
    @turno VARCHAR(10), @saida VARCHAR(100) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM aluno WHERE ra = @ra)
    BEGIN
        UPDATE aluno SET 
            nome = @nome, nome_social = @nome_social, telefone = @telefone,
            email_pessoal = @email_p, email_corporativo = @email_c, turno = @turno
        WHERE ra = @ra
        SET @saida = 'Dados do aluno atualizados com sucesso.'
    END
    ELSE SET @saida = 'Erro: Aluno não encontrado.'
END
GO

CREATE VIEW v_disciplinas 
AS
	SELECT 
		d.codigo AS disciplina_codigo,
		d.nome AS disciplina_nome,
		d.qtd_horas_total AS disciplina_qtd_horas_total,
		d.hora_inicio AS disciplina_hora_inicio,
		d.dia_semana AS disciplina_dia_semana,
		d.duracao_hora_aula AS disciplina_duracao_hora_aula,
		c.nome AS curso_nome,
		c.codigo AS curso_codigo
	FROM disciplina d
	JOIN curso c ON d.curso_codigo = c.codigo

GO

CREATE PROCEDURE sp_lista_disciplina_aluno
	@ra VARCHAR(10)
AS
BEGIN
	DECLARE @curso_aluno INT

	SELECT TOP 1 @curso_aluno = curso_codigo
	FROM matricula
	WHERE aluno_ra = @ra

	SELECT * FROM v_disciplinas
	WHERE curso_codigo = @curso_aluno
END
GO

CREATE PROCEDURE sp_insere_disciplina
    @codigo INT,
    @curso_codigo INT,
    @nome VARCHAR(30),
    @qtd_horas_total INT, 
    @inicio VARCHAR(5),
    @dia VARCHAR(15),
    @duracao INT,
    @saida VARCHAR(100) OUTPUT
AS
BEGIN

	IF EXISTS (SELECT 1 FROM disciplina WHERE codigo = @codigo AND curso_codigo = @curso_codigo)
    BEGIN
        SET @saida = 'Erro: Esta disciplina já está cadastrada para este curso.'
        RETURN
    END

    DECLARE @total_disciplinas_curso INT
    
    IF (@codigo < 1001)
    BEGIN
        SET @saida = 'Erro: O código da disciplina deve ser igual ou superior a 1001.'
        RETURN
    END

    SELECT @total_disciplinas_curso = COUNT(*) 
    FROM disciplina 
    WHERE curso_codigo = @curso_codigo

    IF (@total_disciplinas_curso >= 50)
    BEGIN
        SET @saida = 'Erro: Este curso já atingiu o limite máximo de 50 disciplinas.'
        RETURN
    END

    BEGIN TRY
        INSERT INTO disciplina (codigo, curso_codigo, nome, qtd_horas_total, hora_inicio, dia_semana, duracao_hora_aula)
        VALUES (@codigo, @curso_codigo, @nome, @qtd_horas_total, @inicio, @dia, @duracao)
        
        SET @saida = 'Disciplina ' + CAST(@codigo AS VARCHAR) + ' inserida com sucesso!'
    END TRY
    BEGIN CATCH
        SET @saida = 'Erro ao inserir: ' + ERROR_MESSAGE()
    END CATCH
END

GO

CREATE PROCEDURE sp_exclui_disciplina
	@codigo INT,
	@curso_codigo INT,
	@saida VARCHAR(100) OUTPUT
AS
BEGIN
	BEGIN TRY
		DELETE FROM conteudo WHERE disciplina_codigo = @codigo AND curso_codigo = @curso_codigo
		
		DELETE FROM disciplina WHERE codigo = @codigo AND curso_codigo = @curso_codigo
		
		SET @saida = 'Disciplina e seus conteúdos foram removidos.'
	END TRY
	BEGIN CATCH
		SET @saida = 'Erro ao excluir: Verifique se há alunos matriculados.'
	END CATCH
END

GO

CREATE PROCEDURE sp_atualiza_disciplina
    @codigo INT, @curso_cod INT, @nome VARCHAR(30),
    @horas INT, @inicio VARCHAR(5), @dia VARCHAR(15),
    @duracao INT, @saida VARCHAR(100) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM disciplina WHERE codigo = @codigo AND curso_codigo = @curso_cod)
    BEGIN
        UPDATE disciplina SET 
            nome = @nome, qtd_horas_total = @horas, hora_inicio = @inicio,
            dia_semana = @dia, duracao_hora_aula = @duracao
        WHERE codigo = @codigo AND curso_codigo = @curso_cod
        SET @saida = 'Disciplina atualizada com sucesso.'
    END
    ELSE SET @saida = 'Erro: Disciplina não encontrada para este curso.'
END
GO

CREATE PROCEDURE sp_insere_curso
    @codigo     INT,
    @nome       VARCHAR(100),
    @carga_hr   VARCHAR(30),
    @sigla      VARCHAR(50),
    @nota_enade INT,
    @saida      VARCHAR(100) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM curso WHERE codigo = @codigo)
    BEGIN
        SET @saida = 'Erro: Já existe um curso cadastrado com o código ' + CAST(@codigo AS VARCHAR)
        RETURN
    END

    IF (@codigo <= 0 OR @codigo > 100) 
    BEGIN 
        SET @saida = 'Erro: O código do curso deve estar entre 1 e 100.'
        RETURN
    END
    
    BEGIN TRY 
        INSERT INTO curso (codigo, nome, carga_hr, sigla, nota_enade) 
        VALUES (@codigo, @nome, @carga_hr, @sigla, @nota_enade)

        SET @saida = 'Curso ' + CAST(@codigo AS VARCHAR) + ' inserido com sucesso!'
    END TRY
    BEGIN CATCH
        SET @saida = 'Erro ao inserir: ' + ERROR_MESSAGE()
    END CATCH
END

GO

CREATE PROCEDURE sp_exclui_curso
	@codigo INT,
	@saida VARCHAR(100) OUTPUT
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM curso WHERE codigo = @codigo)
		BEGIN
			SET @saida = 'Erro: Curso código ' + CAST(@codigo AS VARCHAR) + ' não encontrado.'
			RETURN
		END

		IF EXISTS (SELECT 1 FROM aluno WHERE curso_codigo = @codigo) OR 
	   EXISTS (SELECT 1 FROM disciplina WHERE curso_codigo = @codigo)
	BEGIN
		SET @saida = 'Erro: Não é possível excluir um curso que possui alunos ou disciplinas vinculados.'
		RETURN
	END

	BEGIN TRY
		DELETE FROM curso WHERE codigo = @codigo
		SET @saida = 'Curso excluído com sucesso!'
	END TRY
	BEGIN CATCH
		SET @saida = 'Erro ao excluir curso: ' + ERROR_MESSAGE()
	END CATCH
END

GO

CREATE PROCEDURE sp_atualiza_curso
	@codigo 	INT,
	@nome		VARCHAR(100),
	@carga_hr	VARCHAR(30),
	@sigla		VARCHAR(50),
	@nota_enade	INT,
	@saida		VARCHAR(100) OUTPUT
AS
BEGIN
	IF EXISTS (SELECT 1 FROM curso WHERE codigo = @codigo)
	BEGIN
		BEGIN TRY
			UPDATE curso 
			SET nome = @nome, 
			    carga_hr = @carga_hr, 
			    sigla = @sigla, 
			    nota_enade = @nota_enade
			WHERE codigo = @codigo
			
			SET @saida = 'Curso ' + @sigla + ' atualizado com sucesso!'
		END TRY
		BEGIN CATCH
			SET @saida = 'Erro ao atualizar: ' + ERROR_MESSAGE()
		END CATCH
	END
	ELSE
	BEGIN
		SET @saida = 'Erro: Código de curso ' + CAST(@codigo AS VARCHAR) + ' não encontrado.'
	END
END
GO

CREATE PROCEDURE sp_insere_matricula
    @aluno_ra   VARCHAR(10),
    @disc_cod   INT,
    @curso_cod  INT,
    @ano        INT,
    @semestre   INT,
    @saida      VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM aluno WHERE ra = @aluno_ra)
    BEGIN
        SET @saida = 'Erro: Aluno não encontrado.'
        RETURN
    END

    IF NOT EXISTS (SELECT 1 FROM disciplina WHERE codigo = @disc_cod AND curso_codigo = @curso_cod)
    BEGIN
        SET @saida = 'Erro: Disciplina não cadastrada para este curso.'
        RETURN
    END

    IF EXISTS (SELECT 1 FROM matricula WHERE aluno_ra = @aluno_ra AND disciplina_codigo = @disc_cod AND curso_codigo = @curso_cod)
    BEGIN
        SET @saida = 'Erro: O aluno já possui matrícula nesta disciplina.'
        RETURN
    END

    BEGIN TRY
        INSERT INTO matricula (aluno_ra, disciplina_codigo, curso_codigo, ano, semestre)
        VALUES (@aluno_ra, @disc_cod, @curso_cod, @ano, @semestre)
        
        SET @saida = 'Matrícula confirmada com sucesso!'
    END TRY
    BEGIN CATCH
        SET @saida = 'Erro ao processar matrícula: ' + ERROR_MESSAGE()
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE sp_lista_disponiveis_aluno
    @aluno_ra VARCHAR(10)
AS
BEGIN
    DECLARE @curso_aluno INT
    SELECT @curso_aluno = curso_codigo FROM aluno WHERE ra = @aluno_ra

    SELECT 
        d.codigo, 
        d.nome, 
        d.curso_codigo, 
        d.qtd_horas_total, 
        d.hora_inicio, 
        d.dia_semana
    FROM disciplina d
    WHERE d.curso_codigo = @curso_aluno
    AND d.codigo NOT IN (
        SELECT disciplina_codigo 
        FROM matricula 
        WHERE aluno_ra = @aluno_ra
    )
END
GO

CREATE PROCEDURE sp_atualiza_matricula
    @aluno_ra   VARCHAR(10),
    @disc_cod   INT,
    @curso_cod  INT,
    @ano        INT,
    @semestre   INT,
    @saida      VARCHAR(100) OUTPUT
AS
BEGIN

	IF NOT EXISTS (SELECT 1 FROM disciplina WHERE codigo = @disc_cod AND curso_codigo = @curso_cod)
		BEGIN
			SET @saida = 'Erro: Disciplina ou Curso inválido.'
			RETURN
	END

    IF EXISTS (SELECT 1 FROM matricula 
               WHERE aluno_ra = @aluno_ra 
               AND disciplina_codigo = @disc_cod 
               AND curso_codigo = @curso_cod)
    BEGIN
        SET @saida = 'Erro: Esta disciplina já consta na sua grade de matrícula.'
        RETURN
    END

    BEGIN TRY
        INSERT INTO matricula (aluno_ra, disciplina_codigo, curso_codigo, ano, semestre)
        VALUES (@aluno_ra, @disc_cod, @curso_cod, @ano, @semestre)
        
        SET @saida = 'Grade atualizada: Nova disciplina inserida com sucesso.'
    END TRY
    BEGIN CATCH
        SET @saida = 'Erro ao atualizar grade: ' + ERROR_MESSAGE()
    END CATCH
END
GO

CREATE PROCEDURE sp_visualiza_matricula_aluno
    @aluno_ra VARCHAR(10)
AS
BEGIN
    SELECT 
        m.ano, 
        m.semestre, 
        d.nome AS nome_disciplina, 
        d.dia_semana, 
        d.hora_inicio,
        c.nome AS nome_curso
    FROM matricula m
    INNER JOIN disciplina d ON m.disciplina_codigo = d.codigo AND m.curso_codigo = d.curso_codigo
    INNER JOIN curso c ON m.curso_codigo = c.codigo
    WHERE m.aluno_ra = @aluno_ra
    ORDER BY m.ano DESC, m.semestre DESC, d.nome ASC
END
GO

CREATE PROCEDURE sp_insere_conteudo
    @disciplina_cod INT,
    @curso_cod      INT,
    @descricao      VARCHAR(200),
    @saida          VARCHAR(100) OUTPUT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM disciplina WHERE codigo = @disciplina_cod AND curso_codigo = @curso_cod)
    BEGIN
        SET @saida = 'Erro: Disciplina não encontrada para este curso.'
        RETURN
    END

    IF EXISTS (SELECT 1 FROM conteudo WHERE disciplina_codigo = @disciplina_cod 
               AND curso_codigo = @curso_cod AND descricao = @descricao)
    BEGIN
        SET @saida = 'Erro: Este tópico de conteúdo já foi cadastrado.'
        RETURN
    END

    BEGIN TRY
        INSERT INTO conteudo (disciplina_codigo, curso_codigo, descricao)
        VALUES (@disciplina_cod, @curso_cod, @descricao)
        
        SET @saida = 'Conteúdo inserido com sucesso!'
    END TRY
    BEGIN CATCH
        SET @saida = 'Erro ao inserir conteúdo: ' + ERROR_MESSAGE()
    END CATCH
END
GO

CREATE PROCEDURE sp_atualiza_conteudo
    @disciplina_cod INT,
    @curso_cod      INT,
    @descricao_antiga VARCHAR(200),
    @nova_descricao   VARCHAR(200),
    @saida            VARCHAR(100) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM conteudo 
               WHERE disciplina_codigo = @disciplina_cod 
               AND curso_codigo = @curso_cod 
               AND descricao = @descricao_antiga)
    BEGIN
        BEGIN TRY
            UPDATE conteudo 
            SET descricao = @nova_descricao
            WHERE disciplina_codigo = @disciplina_cod 
              AND curso_codigo = @curso_cod 
              AND descricao = @descricao_antiga
            
            SET @saida = 'Conteúdo atualizado com sucesso!'
        END TRY
        BEGIN CATCH
            SET @saida = 'Erro ao atualizar: ' + ERROR_MESSAGE()
        END CATCH
    END
    ELSE
    BEGIN
        SET @saida = 'Erro: Conteúdo original não encontrado.'
    END
END
GO

CREATE PROCEDURE sp_exclui_conteudo
    @disciplina_cod INT,
    @curso_cod      INT,
    @descricao      VARCHAR(200),
    @saida          VARCHAR(100) OUTPUT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM conteudo 
               WHERE disciplina_codigo = @disciplina_cod 
               AND curso_codigo = @curso_cod 
               AND descricao = @descricao)
    BEGIN
        BEGIN TRY
            DELETE FROM conteudo 
            WHERE disciplina_codigo = @disciplina_cod 
              AND curso_codigo = @curso_cod 
              AND descricao = @descricao
              
            SET @saida = 'Conteúdo removido com sucesso!'
        END TRY
        BEGIN CATCH
            SET @saida = 'Erro ao excluir: ' + ERROR_MESSAGE()
        END CATCH
    END
    ELSE
    BEGIN
        SET @saida = 'Erro: Registro não existe.'
    END
END
GO

EXEC sp_lista_disponiveis_aluno '202612732'