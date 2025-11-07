#!/bin/bash

PACKAGE_NAME="com.example.ihealthy"
DB_NAME="ihealthy.db"
DEST_DIR="$HOME/Área de trabalho"

echo "📦 Copiando banco de dados do app $PACKAGE_NAME..."

adb exec-out run-as $PACKAGE_NAME cat databases/$DB_NAME > "$DEST_DIR/$DB_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Banco exportado com sucesso para: $DEST_DIR/$DB_NAME"
    code "$DEST_DIR/$DB_NAME"
else
    echo "❌ Erro ao exportar banco."
fi

