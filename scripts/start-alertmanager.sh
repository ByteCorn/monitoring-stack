#!/bin/bash

# выход при любой ошибке
# указывает на необходимость завершения работы скрипта, если какая-либо команда завершилась с ошибкой, например, false
set -e

# проверка установки необходимых переменных среды
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo "ОШИБКА: Переменная среды TELEGRAM_BOT_TOKEN не установлена"
    exit 1
fi

if [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "ОШИБКА: Переменная среды TELEGRAM_CHAT_ID не установлена"
    exit 1
fi

# обрабатка шаблона с помощью envsubst, если он доступен, в противном случае используем sed
echo "Обработка шаблона Alertmanager..."
if command -v envsubst >/dev/null 2>&1; then
    envsubst < /etc/alertmanager/alertmanager.yml.tpl > /etc/alertmanager/alertmanager.yml
else
    # в качестве запасного варианта используется sed для подстановки переменных окружения
    sed "s/\${TELEGRAM_BOT_TOKEN}/$TELEGRAM_BOT_TOKEN/g; s/\${TELEGRAM_CHAT_ID}/$TELEGRAM_CHAT_ID/g" \
        /etc/alertmanager/alertmanager.yml.tpl > /etc/alertmanager/alertmanager.yml
fi

# запуск Alertmanager
echo "Запуск Alertmanager..."
exec /bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml 
