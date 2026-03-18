#!/usr/bin/env bash

# Pasta com as ASCII arts
ASCII_DIR="$HOME/.config/fastfetch/ascii-arts"

# Array com todas as opções (arquivos ASCII + logo do NixOS)
OPTIONS=()

# Adiciona os arquivos ASCII ao array
if [ -d "$ASCII_DIR" ]; then
    while IFS= read -r -d '' file; do
        OPTIONS+=("$file")
    done < <(find "$ASCII_DIR" -type f -name "*.txt" -print0)
fi

# Adiciona a opção do logo NixOS
OPTIONS+=("nixos")

# Escolhe aleatoriamente uma opção
RANDOM_CHOICE="${OPTIONS[$RANDOM % ${#OPTIONS[@]}]}"

# Executa fastfetch com a opção escolhida
if [ "$RANDOM_CHOICE" = "nixos" ]; then
    fastfetch --logo nixos
else
    fastfetch --logo "$RANDOM_CHOICE"
fi
