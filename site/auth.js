/*
  Autenticação do site (roda 100% no navegador, sem servidor).
  - Usuários cadastrados ficam no localStorage ("fn_usuarios").
  - A sessão fica no sessionStorage.
  Para um projeto real, troque estas funções por fetch() para uma API
  (como no projeto AquaTech original).
*/

const CHAVE_USUARIOS = "fn_usuarios";

function lerUsuarios() {
  try {
    return JSON.parse(localStorage.getItem(CHAVE_USUARIOS)) || [];
  } catch (e) {
    return [];
  }
}

async function gerarHash(texto) {
  if (window.crypto && crypto.subtle) {
    const dados = new TextEncoder().encode(texto);
    const buf = await crypto.subtle.digest("SHA-256", dados);
    return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, "0")).join("");
  }
  // fallback simples (só para ambientes sem crypto.subtle)
  let h = 0;
  for (let i = 0; i < texto.length; i++) h = (h * 31 + texto.charCodeAt(i)) | 0;
  return "f" + h;
}

function mostrarMensagem(texto, tipo) {
  const el = document.getElementById("mensagem");
  el.className = "mensagem " + tipo;
  el.textContent = texto;
}

async function cadastrar() {
  const apelido = document.getElementById("apelido_input").value.trim();
  const email = document.getElementById("email_input").value.trim().toLowerCase();
  const senha = document.getElementById("senha_input").value;
  const confirmacao = document.getElementById("confirmacao_senha_input").value;

  if (!apelido || !email || !senha || !confirmacao) {
    return mostrarMensagem("Preencha todos os campos.", "erro");
  }
  if (apelido.length < 3) {
    return mostrarMensagem("O apelido precisa ter pelo menos 3 caracteres.", "erro");
  }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return mostrarMensagem("Digite um e-mail válido.", "erro");
  }
  if (senha.length < 6) {
    return mostrarMensagem("A senha precisa ter pelo menos 6 caracteres.", "erro");
  }
  if (senha !== confirmacao) {
    return mostrarMensagem("A confirmação de senha não confere.", "erro");
  }

  const usuarios = lerUsuarios();
  if (usuarios.some(u => u.email === email)) {
    return mostrarMensagem("Este e-mail já está cadastrado.", "erro");
  }

  usuarios.push({
    id: Date.now(),
    apelido: apelido,
    email: email,
    senhaHash: await gerarHash(senha),
    criadoEm: new Date().toISOString()
  });
  localStorage.setItem(CHAVE_USUARIOS, JSON.stringify(usuarios));

  mostrarMensagem("Cadastro realizado! Redirecionando para o login...", "sucesso");
  setTimeout(() => { window.location = "login.html"; }, 1800);
}

async function entrar() {
  const email = document.getElementById("email_input").value.trim().toLowerCase();
  const senha = document.getElementById("senha_input").value;

  if (!email || !senha) {
    return mostrarMensagem("Preencha e-mail e senha.", "erro");
  }

  const usuario = lerUsuarios().find(u => u.email === email);
  if (!usuario || usuario.senhaHash !== (await gerarHash(senha))) {
    return mostrarMensagem("E-mail ou senha incorretos.", "erro");
  }

  sessionStorage.ID_USUARIO = usuario.id;
  sessionStorage.NOME_USUARIO = usuario.apelido;
  sessionStorage.EMAIL_USUARIO = usuario.email;

  mostrarMensagem("Login realizado! Entrando...", "sucesso");
  setTimeout(() => { window.location = "painel.html"; }, 900);
}

function sair() {
  sessionStorage.clear();
  window.location = "index.html";
}

function estaLogado() {
  return !!sessionStorage.ID_USUARIO;
}

// Protege páginas que exigem login
function validarSessao() {
  if (!estaLogado()) window.location = "login.html";
}

// Ajusta a navbar conforme o usuário estar logado ou não
function ajustarNavbar() {
  const area = document.getElementById("nav_conta");
  if (!area) return;
  if (estaLogado()) {
    area.innerHTML =
      '<li><a href="painel.html">Painel</a></li>' +
      '<li><a href="#" onclick="sair(); return false;">Sair</a></li>';
  }
}

// Enter envia o formulário
document.addEventListener("keydown", function (e) {
  if (e.key !== "Enter") return;
  if (document.getElementById("confirmacao_senha_input")) cadastrar();
  else if (document.getElementById("senha_input")) entrar();
});

document.addEventListener("DOMContentLoaded", ajustarNavbar);