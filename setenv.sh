#!/bin/bash

# Если передан аргумент, используем его, иначе предлагаем выбрать
if [ -z "$1" ]; then
  echo "Выберите окружение:"
  select ENV_NAME in dev stage prod; do
    if [[ -n "$ENV_NAME" ]]; then
      break
    fi
  done
else
  ENV_NAME=$1
fi

ENV_FILE="env/$ENV_NAME.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Файл окружения $ENV_FILE не найден!"
  exit 1
fi

cp "$ENV_FILE" .env
echo "Файл окружения $ENV_NAME.env скопирован в .env"