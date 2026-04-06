<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <jsp:include page="WEB-INF/view/fragmentos/head.jsp" />
    <title>AGIS - Início</title>
</head>
<body class="bg-light">

    <jsp:include page="WEB-INF/view/fragmentos/header.jsp" />

    <main class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-10 text-center bg-white shadow-sm p-5 rounded">
                <h1 class="display-4 fw-bold">Bem-vindo ao AGIS</h1>
                <p class="lead text-muted">Gestão Acadêmica</p>
                
                <div class="d-flex justify-content-center gap-3 mt-4">
                    <a href="aluno" class="btn btn-primary btn-lg px-8">Alunos</a>
                </div>
            </div>
        </div>

        <div class="row mt-5 g-4 justify-content-center">
            
            <%-- 1. Disciplinas --%>
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 text-center">
                    <div class="card-body">
                        <h3 class="card-title h4 fw-bold">Disciplinas</h3>
                        <p class="text-muted small">Gerencie a grade curricular e detalhes das matérias.</p>
                        <a href="disciplina" class="btn btn-dark w-100">Acessar</a>
                    </div>
                    <%-- Conteúdo inserido como uma sub-opção dentro de Disciplinas --%>
                    <div class="card-footer bg-light border-0 pb-3">
                        <a href="conteudo" class="btn btn-sm btn-link text-decoration-none">
                            <i class="fas fa-book-open me-1"></i> Gerenciar Conteúdos
                        </a>
                    </div>
                </div>
            </div>

            <%-- 2. Matrícula --%>
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 text-center">
                    <div class="card-body">
                        <h3 class="card-title h4 fw-bold">Matrícula</h3>
                        <p class="text-muted small">Realize e acompanhe as inscrições dos alunos.</p>
                        <a href="matricula" class="btn btn-dark w-100">Acessar</a>
                    </div>
                </div>
            </div>

            <%-- 3. Cursos --%>
            <div class="col-md-4">
                <div class="card h-100 shadow-sm border-0 text-center">
                    <div class="card-body">
                        <h3 class="card-title h4 fw-bold">Cursos</h3>
                        <p class="text-muted small">Configuração de cursos, turnos e períodos.</p>
                        <a href="curso" class="btn btn-dark w-100">Acessar</a>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <jsp:include page="WEB-INF/view/fragmentos/footer.jsp" />

</body>
</html>
