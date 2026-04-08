#!/bin/bash

# 1. Pasta do script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧹 Limpeza Profunda (Resolvendo erros de Digest/NotFound)..."

# Para tudo e remove volumes órfãos
docker compose down --volumes --remove-orphans

# Remove imagens do projeto para forçar rebuild limpo
docker compose rm -f

# ESTA É A CHAVE: Limpa o cache do builder do Docker que pode estar corrompido
echo "🧼 A limpar cache do Docker Builder..."
docker builder prune -f

# 2. Build total sem usar lixo antigo
echo "🛠️  A construir imagens do zero..."
docker compose build --no-cache

# 3. Levantar todos os serviços
echo "🆙 A levantar TODOS os contentores..."
# Usamos o --force-recreate aqui para garantir que todos tentem subir de novo
docker compose up -d --force-recreate

echo "✅ Verificando estado dos serviços..."
docker compose ps

echo "---------------------------------------------------"
echo "🚀 Se algum ainda não estiver 'Running', tenta correr: docker compose start"
echo "📍 API principal: http://localhost:9080"
echo "📍 Adminer:       http://localhost:9082"
echo "---------------------------------------------------"