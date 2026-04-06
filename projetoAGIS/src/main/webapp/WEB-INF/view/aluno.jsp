<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <jsp:include page="fragmentos/head.jsp" />
    <title>AGIS - Gerenciar Aluno</title>
</head>
<body class="bg-light">

    <jsp:include page="fragmentos/header.jsp" />

    <main class="container mt-4 mb-5">
        <div class="row mb-3">
            <div class="col-12 text-center">
                <h2 class="display-6"><i class="fas fa-user-graduate me-2"></i>Gestão de Alunos</h2>
                <p class="text-muted small">O RA é gerado automaticamente pelo sistema através da Procedure.</p>
                <hr>
            </div>
        </div>

        <c:if test="${not empty saida}">
            <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                <i class="fas fa-check-circle me-2"></i> ${saida}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty erro}">
            <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                <i class="fas fa-exclamation-triangle me-2"></i> ${erro}
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <div class="card shadow mb-4">
            <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
                <span><i class="fas fa-edit me-2"></i>Ficha Cadastral</span>
                <span class="badge bg-secondary">Campos com * são obrigatórios</span>
            </div>
            <div class="card-body">
                <form action="aluno" method="post" class="row g-3">
                    
                    <div class="col-md-2">
                        <label class="form-label fw-bold">RA</label>
                        <input type="text" name="ra" class="form-control bg-light" 
                               value="${aluno.ra}" placeholder="Gerado" readonly>
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label fw-bold">CPF *</label>
                        <input type="text" name="cpf" class="form-control" required 
                               placeholder="000.000.000-00" value="${aluno.cpf}">
                    </div>
                    
                    <div class="col-md-7">
                        <label class="form-label fw-bold">Nome Completo *</label>
                        <input type="text" name="nome" class="form-control" required value="${aluno.nome}">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label fw-bold">Nome Social</label>
                        <input type="text" name="nomeSocial" class="form-control" value="${aluno.nome_social}">
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Data Nascimento *</label>
                        <input type="date" name="dataNasc" class="form-control" required value="${aluno.dt_nasc}">
                    </div>
                    
                    <div class="col-md-5">
                        <label class="form-label fw-bold">Telefone *</label>
                        <input type="text" name="telefone" class="form-control" required 
                               placeholder="(00) 00000-0000" value="${aluno.telefone}">
                    </div>

                    <div class="col-md-6">
                        <label class="form-label fw-bold">Email Pessoal *</label>
                        <input type="email" name="emailPessoal" class="form-control" required value="${aluno.email_pessoal}">
                    </div>
                    
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Email Corporativo</label>
                        <input type="email" name="emailCorp" class="form-control" value="${aluno.email_corporativo}">
                    </div>

                    <div class="col-md-3">
                        <label class="form-label fw-bold">Conclusão 2º Grau *</label>
                        <input type="date" name="data2G" class="form-control" required value="${aluno.dt_con_2grau}">
                    </div>
                    
                    <div class="col-md-9">
                        <label class="form-label fw-bold">Instituição 2º Grau *</label>
                        <input type="text" name="inst2G" class="form-control" required value="${aluno.instituicao_2grau}">
                    </div>

                    <div class="col-md-3">
                        <label class="form-label fw-bold">Pontos Vestibular</label>
                        <input type="number" name="pontosVest" class="form-control" value="${aluno.pt_vestibular}">
                    </div>
                    
                    <div class="col-md-3">
                        <label class="form-label fw-bold">Posição Vestibular</label>
                        <input type="number" name="posVest" class="form-control" value="${aluno.pos_vestibular}">
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label fw-bold">Ano Ingresso</label>
                        <input type="number" name="anoIngresso" class="form-control" value="${aluno.ano_ingresso}">
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label fw-bold">Semestre</label>
                        <select name="semIngresso" class="form-select">
                            <option value="1" ${aluno.sem_ingresso == 1 ? 'selected' : ''}>1º Sem</option>
                            <option value="2" ${aluno.sem_ingresso == 2 ? 'selected' : ''}>2º Sem</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2">
                        <label class="form-label fw-bold">Turno</label>
                        <input type="text" name="turno" class="form-control" value="${aluno.turno}">
                    </div>
                    
                    <div class="col-md-12">
                        <label class="form-label fw-bold">Curso de Ingresso *</label>
                        <select name="cursoCod" class="form-select" required>
                            <option value="" disabled ${empty aluno.curso_codigo ? 'selected' : ''}>Selecione um curso...</option>
                            <c:forEach var="c" items="${cursos}">
                                <option value="${c.codigo}" ${aluno.curso_codigo == c.codigo ? 'selected' : ''}>
                                    ${c.nome}
                                </option>
                            </c:forEach>
                        </select>
                    </div>

					<div class="col-12 mt-4 d-flex justify-content-center gap-2">
					    <button type="submit" name="botao" value="Inserir" class="btn btn-success px-4 shadow-sm">
					        <i class="fas fa-plus me-1"></i> Inserir
					    </button>
					    <button type="submit" name="botao" value="Atualizar" class="btn btn-warning px-4 shadow-sm">
					        <i class="fas fa-save me-1"></i> Atualizar
					    </button>
					    
					    <button type="submit" name="botao" value="Excluir" class="btn btn-danger px-4 shadow-sm" formnovalidate>
					        <i class="fas fa-trash me-1"></i> Excluir
					    </button>
					    <button type="submit" name="botao" value="Buscar" class="btn btn-primary px-4 shadow-sm" formnovalidate>
					        <i class="fas fa-search me-1"></i> Buscar por RA
					    </button>
					    <button type="submit" name="botao" value="Listar" class="btn btn-secondary px-4 shadow-sm" formnovalidate>
					        <i class="fas fa-list me-1"></i> Listar Todos
					    </button>
					</div>
                    </div>
                </form>
            </div>
        </div>

        <div class="card shadow border-0">
            <div class="card-header bg-secondary text-white fw-bold">
                <i class="fas fa-table me-2"></i>Alunos Cadastrados
            </div>
            <div class="table-responsive">
                <table class="table table-striped table-hover mb-0 align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th>RA</th>
                            <th>CPF</th>
                            <th>Nome</th>
                            <th>Curso</th>
                            <th class="text-center">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="a" items="${alunos}">
                            <tr>
                                <td class="fw-bold text-primary">${a.ra}</td>
                                <td>${a.cpf}</td>
                                <td>${a.nome}</td>
                                <td>${a.curso_codigo}</td>
                                <td class="text-center">
                                    <form action="aluno" method="post" style="display:inline;">
                                        <input type="hidden" name="ra" value="${a.ra}">
                                        <button type="submit" name="botao" value="Buscar" class="btn btn-sm btn-outline-info">
                                            <i class="fas fa-edit"></i> Editar
                                        </button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <jsp:include page="fragmentos/footer.jsp" />

</body>
</html>
