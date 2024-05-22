#!/bin/bash

# Функция для получения пользовательского ввода
get_user_input() {
    read -p "Введите текст уведомления: " notification_text

    while true; do
        read -p "Введите время задержки (например, 10s, 5m, 2h): " delay
        if [[ "$delay" =~ ^[0-9]+[smh]$ ]]; then
            break
        else
            echo "Пожалуйста, введите допустимое значение времени (например, 10s, 5m, 2h)."
        fi
    done

    read -p "Выберите уровень срочности (low, normal, critical): " urgency
}

# Функция для преобразования времени задержки в секунды
convert_delay_to_seconds() {
    local value=${delay::-1}
    local unit=${delay: -1}
    case "$unit" in
        s) delay_seconds=$value ;;
        m) delay_seconds=$((value * 60)) ;;
        h) delay_seconds=$((value * 3600)) ;;
    esac
}

# Функция для проверки и установки параметров уведомления
set_notification_parameters() {
    case "$urgency" in
        low)
            icon="dialog-information"
            timeout=3000
            ;;
        normal)
            icon="dialog-information"
            timeout=5000
            ;;
        critical)
            icon="dialog-warning"
            timeout=7000
            ;;
        *)
            echo "Недопустимый уровень срочности. Используем 'normal' по умолчанию."
            icon="dialog-information"
            timeout=5000
            urgency="normal"
            ;;
    esac
}

# Функция для отображения уведомления
show_notification() {
    # Проверка наличия notify-send
    if ! command -v notify-send &> /dev/null
    then
        echo "Команда notify-send не найдена. Установите пакет libnotify-bin."
        exit 1
    fi

    notify-send -u "$urgency" -i "$icon" -t "$timeout" "$notification_text"
}

# Основной блок выполнения скрипта
main() {
    get_user_input
    convert_delay_to_seconds
    set_notification_parameters
    sleep "$delay_seconds"
    show_notification
}

# Запуск основного блока
main
