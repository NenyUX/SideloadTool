#!/bin/bash
# Credits: https://github.com/NenyUX/SideloadTool (@NenyUX/SideloadTool)

banner="
  _________.__    .___     .__                    .______________           .__   
 /   _____/|__| __| _/____ |  |   _________     __| _/\__    ___/___   ____ |  |  
 \_____  \ |  |/ __ |/ __ \|  |  /  _ \__  \   / __ |   |    | /  _ \ /  _ \|  |  
 /        \|  / /_/ \  ___/|  |_(  <_> ) __ \_/ /_/ |   |    |(  <_> |  <_> )  |__
/_______  /|__\____ |\___  >____/\____(____  /\____ |   |____| \____/ \____/|____/
        \/         \/    \/                \/      \/                             "

show_banner() {
    clear
    printf "%s\n\n" "$banner"
}

if [[ "$EUID" -ne 0 ]]; then
    echo "Este script debe ejecutarse como root (usa sudo)."
    echo "This script must be run as root (use sudo)."
    exit 1
fi

show_banner

echo "Select language / Selecciona idioma / Выберите язык:"
echo "1) English"
echo "2) Español"
echo "3) Русский"
read -p "> " lang
show_banner

if [[ "$lang" == "1" ]]; then
    txt_warn="WARNING!"
    txt_warn2="It is recommended to perform a factory reset before flashing a custom ROM."
    txt_warn3="This will erase all data on the device. Make a backup first!"
    txt_warn4="Make sure you have the ROM and, if desired, the GApps package in the same folder as this script."
    txt_lineage_recommend="If you are going to install a LineageOS ROM, it is recommended to flash: boot.img, dtbo.img, recovery.img, super_empty.img, vbmeta.img"
    txt_continue="Do you want to continue? (type YES to continue): "
    txt_cancel="Operation cancelled by user."
    txt_dep="Do you want to install required dependencies (adb and fastboot)? (y/n): "
    txt_not_supported="Distribution not supported automatically. Please install ADB and Fastboot manually."
    txt_nixos_note="Detected NixOS. You can enable adb and fastboot by running: nix-shell -p android-tools"
    txt_rom_path="Enter the path or name of your custom ROM .zip file: "
    txt_gapps_path="Enter the path or name of your GApps .zip file (leave blank if not installing): "
    txt_boot_path="Enter the path or name of your boot.img file (leave blank to skip): "
    txt_dtbo_path="Enter the path or name of your dtbo.img file (leave blank to skip): "
    txt_recovery_path="Enter the path or name of your recovery.img file (leave blank to skip): "
    txt_super_path="Enter the path or name of your super_empty.img file (leave blank to skip): "
    txt_vbmeta_path="Enter the path or name of your vbmeta.img file (leave blank to skip): "
    txt_flash_imgs="Do you want to flash any of the recommended images before the ROM? (y/n): "
    txt_boot_error="ERROR: boot.img file not found"
    txt_dtbo_error="ERROR: dtbo.img file not found"
    txt_recovery_error="ERROR: recovery.img file not found"
    txt_super_error="ERROR: super_empty.img file not found"
    txt_vbmeta_error="ERROR: vbmeta.img file not found"
    txt_rom_error="ERROR: ROM file not found"
    txt_gapps_error="ERROR: GApps file not found"
    txt_connect="Connecting to device..."
    txt_recovery="Is the device in recovery mode and connected via USB? (y/n): "
    txt_pls_reboot="Please reboot your device into recovery and connect via USB."
    txt_sideload_start="Starting ROM sideload..."
    txt_sideload_instr="In your recovery, select: 'Apply update' > 'ADB Sideload'"
    txt_press="Press Enter when ready to continue..."
    txt_gapps="Do you want to install GApps after the ROM? (y/n): "
    txt_gapps_repeat="Repeat the process in recovery for sideload:"
    txt_gapps_fl="GApps flashed."
    txt_end="Process finished. If there are no errors, you can reboot the device from recovery."
    txt_flashing_rom="Flashing ROM"
    txt_flashing_gapps="Flashing GApps"
    txt_flashing_boot="Flashing boot.img"
    txt_flashing_dtbo="Flashing dtbo.img"
    txt_flashing_recovery="Flashing recovery.img"
    txt_flashing_super="Flashing super_empty.img"
    txt_flashing_vbmeta="Flashing vbmeta.img"
    txt_iphone="iPhone are not supported by this script. Exiting."
    txt_thanks="Thank you for using SideloadTool!"
elif [[ "$lang" == "2" ]]; then
    txt_warn="¡ADVERTENCIA!"
    txt_warn2="Se recomienda hacer un factory reset antes de flashear una custom ROM."
    txt_warn3="Esto borrará todos los datos del dispositivo. ¡Haz un respaldo antes!"
    txt_warn4="Asegúrate de tener la ROM y, si lo deseas, el paquete GApps en la misma carpeta que este script."
    txt_lineage_recommend="Si vas a instalar una ROM LineageOS, se recomienda flashear: boot.img, dtbo.img, recovery.img, super_empty.img, vbmeta.img"
    txt_continue="¿Desea continuar? (escriba SI para continuar): "
    txt_cancel="Operación cancelada por el usuario."
    txt_dep="¿Quieres instalar dependencias necesarias (adb y fastboot)? (s/n): "
    txt_not_supported="Distribución no soportado automáticamente. Instala ADB y Fastboot manualmente."
    txt_nixos_note="Detectado NixOS. Puedes habilitar adb y fastboot ejecutando: nix-shell -p android-tools"
    txt_rom_path="Escribe la ruta o nombre de tu archivo .zip de la custom ROM: "
    txt_gapps_path="Escribe la ruta o nombre de tu archivo .zip de GApps (deja en blanco si no los vas a instalar): "
    txt_boot_path="Escribe la ruta o nombre de tu boot.img (deja en blanco para omitir): "
    txt_dtbo_path="Escribe la ruta o nombre de tu dtbo.img (deja en blanco para omitir): "
    txt_recovery_path="Escribe la ruta o nombre de tu recovery.img (deja en blanco para omitir): "
    txt_super_path="Escribe la ruta o nombre de tu super_empty.img (deja en blanco para omitir): "
    txt_vbmeta_path="Escribe la ruta o nombre de tu vbmeta.img (deja en blanco para omitir): "
    txt_flash_imgs="¿Quieres flashear alguna de las imágenes recomendadas antes de la ROM? (s/n): "
    txt_boot_error="ERROR: No se encuentra el archivo boot.img"
    txt_dtbo_error="ERROR: No se encuentra el archivo dtbo.img"
    txt_recovery_error="ERROR: No se encuentra el archivo recovery.img"
    txt_super_error="ERROR: No se encuentra el archivo super_empty.img"
    txt_vbmeta_error="ERROR: No se encuentra el archivo vbmeta.img"
    txt_rom_error="ERROR: No se encuentra el archivo de la ROM"
    txt_gapps_error="ERROR: No se encuentra el archivo de GApps"
    txt_connect="Conectando con el dispositivo..."
    txt_recovery="¿El dispositivo está en modo recovery y conectado por USB? (s/n): "
    txt_pls_reboot="Por favor, reinicia tu dispositivo en recovery y conéctalo por USB."
    txt_sideload_start="Iniciando sideload de la ROM..."
    txt_sideload_instr="En tu recovery, selecciona: 'Apply update' > 'ADB Sideload'"
    txt_press="Presiona Enter cuando estés listo para continuar..."
    txt_gapps="¿Quieres instalar GApps después de la ROM? (s/n): "
    txt_gapps_repeat="Ahora repite el proceso en el recovery para sideload:"
    txt_gapps_fl="GApps flasheado."
    txt_end="Proceso terminado. Si no hay errores, puedes reiniciar el dispositivo desde el recovery."
    txt_flashing_rom="Flasheando ROM"
    txt_flashing_gapps="Flasheando GApps"
    txt_flashing_boot="Flasheando boot.img"
    txt_flashing_dtbo="Flasheando dtbo.img"
    txt_flashing_recovery="Flasheando recovery.img"
    txt_flashing_super="Flasheando super_empty.img"
    txt_flashing_vbmeta="Flasheando vbmeta.img"
    txt_iphone="Este script no permite iPhone. Saliendo."
    txt_thanks="¡Gracias por usar SideloadTool!"
elif [[ "$lang" == "3" ]]; then
    txt_warn="ВНИМАНИЕ!"
    txt_warn2="Рекомендуется выполнить сброс к заводским настройкам перед прошивкой кастомной прошивки."
    txt_warn3="Это удалит все данные на устройстве. Сделайте резервную копию заранее!"
    txt_warn4="Убедитесь, что ROM и, при необходимости, пакет GApps находятся в той же папке, что и этот скрипт."
    txt_lineage_recommend="Если вы собираетесь устанавливать LineageOS ROM, рекомендуется прошить: boot.img, dtbo.img, recovery.img, super_empty.img, vbmeta.img"
    txt_continue="Вы хотите продолжить? (введите ДА для продолжения): "
    txt_cancel="Операция отменена пользователем."
    txt_dep="Хотите установить необходимые зависимости (adb и fastboot)? (д/н): "
    txt_not_supported="Дистрибутив не поддерживается автоматически. Установите ADB и Fastboot вручную."
    txt_nixos_note="Обнаружен NixOS. Вы можете включить adb и fastboot командой: nix-shell -p android-tools"
    txt_rom_path="Введите путь или имя файла вашей кастомной прошивки .zip: "
    txt_gapps_path="Введите путь или имя файла GApps .zip (оставьте пустым, если не устанавливаете): "
    txt_boot_path="Введите путь или имя файла boot.img (оставьте пустым, чтобы пропустить): "
    txt_dtbo_path="Введите путь или имя файла dtbo.img (оставьте пустым, чтобы пропустить): "
    txt_recovery_path="Введите путь или имя файла recovery.img (оставьте пустым, чтобы пропустить): "
    txt_super_path="Введите путь или имя файла super_empty.img (оставьте пустым, чтобы пропустить): "
    txt_vbmeta_path="Введите путь или имя файла vbmeta.img (оставьте пустым, чтобы пропустить): "
    txt_flash_imgs="Вы хотите прошить какие-либо из рекомендуемых образов перед ROM? (д/н): "
    txt_boot_error="ОШИБКА: Файл boot.img не найден"
    txt_dtbo_error="ОШИБКА: Файл dtbo.img не найден"
    txt_recovery_error="ОШИБКА: Файл recovery.img не найден"
    txt_super_error="ОШИБКА: Файл super_empty.img не найден"
    txt_vbmeta_error="ОШИБКА: Файл vbmeta.img не найден"
    txt_rom_error="ОШИБКА: Файл прошивки не найден"
    txt_gapps_error="ОШИБКА: Файл GApps не найден"
    txt_connect="Подключение к устройству..."
    txt_recovery="Устройство в режиме recovery и подключено по USB? (д/н): "
    txt_pls_reboot="Пожалуйста, перезагрузите устройство в recovery и подключите по USB."
    txt_sideload_start="Запуск sideload прошивки..."
    txt_sideload_instr="В recovery выберите: 'Apply update' > 'ADB Sideload'"
    txt_press="Нажмите Enter, когда будете готовы продолжить..."
    txt_gapps="Хотите установить GApps после прошивки? (д/н): "
    txt_gapps_repeat="Повторите процесс sideload в recovery:"
    txt_gapps_fl="GApps прошиты."
    txt_end="Процесс завершён. Если ошибок нет, можно перезагрузить устройство из recovery."
    txt_flashing_rom="Прошивка ROM"
    txt_flashing_gapps="Прошивка GApps"
    txt_flashing_boot="Прошивка boot.img"
    txt_flashing_dtbo="Прошивка dtbo.img"
    txt_flashing_recovery="Прошивка recovery.img"
    txt_flashing_super="Прошивка super_empty.img"
    txt_flashing_vbmeta="Прошивка vbmeta.img"
    txt_iphone="Этот скрипт не поддерживает iPhone. Завершение работы."
    txt_thanks="Спасибо за использование SideloadTool!"
else
    echo "Invalid option / Opción no válida / Неверный выбор"
    exit 1
fi

spinner() {
    local pid=$1
    local msg="$2"
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    tput civis
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %10 ))
        printf "\r%s %s" "$msg" "${spin:$i:1}"
        sleep 0.12
    done
    printf "\r%s ✔️\n" "$msg"
    tput cnorm
}

show_banner
echo -e "\033[1;31m$txt_warn\033[0m"
echo -e "\033[1m- $txt_warn2\n- $txt_warn3\n- $txt_warn4\033[0m"
echo ""
printf "%s\n\n" "$txt_lineage_recommend"

read -p "$txt_continue" confirm
show_banner

if { [[ "$lang" == "1" ]] && [[ "$confirm" != "YES" ]]; } || { [[ "$lang" == "2" ]] && [[ "$confirm" != "SI" ]]; } || { [[ "$lang" == "3" ]] && [[ "${confirm,,}" != "да" ]]; }; then
    echo "$txt_cancel"
    exit 1
fi

read -p "$txt_dep" instalar
show_banner

if { [[ "$lang" == "1" ]] && [[ "$instalar" == "y" ]]; } || { [[ "$lang" == "2" ]] && [[ "$instalar" == "s" ]]; } || { [[ "$lang" == "3" ]] && [[ "${instalar,,}" == "д" ]]; }; then
    if [ -f /etc/debian_version ]; then
        apt update
        apt install -y android-tools-adb android-tools-fastboot
    elif [ -f /etc/arch-release ]; then
        pacman -Sy --noconfirm android-tools
    elif [ -f /etc/NIXOS ]; then
        echo "$txt_nixos_note"
        read -p "Press Enter to continue..." 
    else
        echo "$txt_not_supported"
        exit 1
    fi
    show_banner
fi

read -p "$txt_rom_path" ROM_ZIP
show_banner
if [[ ! -f "$ROM_ZIP" ]]; then
    echo "$txt_rom_error"
    exit 1
fi

echo "$txt_connect"
adb devices

if lsusb | grep -q -i "iPhone\|Apple.*Mobile"; then
    echo "$txt_iphone"
    exit 1
fi

read -p "$txt_flash_imgs" flashimgs
show_banner

if { [[ "$lang" == "1" ]] && [[ "$flashimgs" == "y" ]]; } || { [[ "$lang" == "2" ]] && [[ "$flashimgs" == "s" ]]; } || { [[ "$lang" == "3" ]] && [[ "${flashimgs,,}" == "д" ]]; }; then
    read -p "$txt_boot_path" BOOT_IMG
    show_banner
    if [[ ! -z "$BOOT_IMG" ]]; then
        if [[ ! -f "$BOOT_IMG" ]]; then
            echo "$txt_boot_error"
            exit 1
        fi
        echo "$txt_flashing_boot"
        fastboot flash boot "$BOOT_IMG" > flash_boot.log 2>&1 &
        spinner $! "$txt_flashing_boot"
    fi

    read -p "$txt_dtbo_path" DTBO_IMG
    show_banner
    if [[ ! -z "$DTBO_IMG" ]]; then
        if [[ ! -f "$DTBO_IMG" ]]; then
            echo "$txt_dtbo_error"
            exit 1
        fi
        echo "$txt_flashing_dtbo"
        fastboot flash dtbo "$DTBO_IMG" > flash_dtbo.log 2>&1 &
        spinner $! "$txt_flashing_dtbo"
    fi

    read -p "$txt_recovery_path" RECOVERY_IMG
    show_banner
    if [[ ! -z "$RECOVERY_IMG" ]]; then
        if [[ ! -f "$RECOVERY_IMG" ]]; then
            echo "$txt_recovery_error"
            exit 1
        fi
        echo "$txt_flashing_recovery"
        fastboot flash recovery "$RECOVERY_IMG" > flash_recovery.log 2>&1 &
        spinner $! "$txt_flashing_recovery"
    fi

    read -p "$txt_super_path" SUPER_IMG
    show_banner
    if [[ ! -z "$SUPER_IMG" ]]; then
        if [[ ! -f "$SUPER_IMG" ]]; then
            echo "$txt_super_error"
            exit 1
        fi
        echo "$txt_flashing_super"
        fastboot flash super "$SUPER_IMG" > flash_super.log 2>&1 &
        spinner $! "$txt_flashing_super"
    fi

    read -p "$txt_vbmeta_path" VBMETA_IMG
    show_banner
    if [[ ! -z "$VBMETA_IMG" ]]; then
        if [[ ! -f "$VBMETA_IMG" ]]; then
            echo "$txt_vbmeta_error"
            exit 1
        fi
        echo "$txt_flashing_vbmeta"
        fastboot flash vbmeta "$VBMETA_IMG" > flash_vbmeta.log 2>&1 &
        spinner $! "$txt_flashing_vbmeta"
    fi
fi

read -p "$txt_recovery" cont
show_banner
if { [[ "$lang" == "1" ]] && [[ "$cont" != "y" ]]; } || { [[ "$lang" == "2" ]] && [[ "$cont" != "s" ]]; } || { [[ "$lang" == "3" ]] && [[ "${cont,,}" != "д" ]]; }; then
    echo "$txt_pls_reboot"
    exit 1
fi

echo "$txt_sideload_start"
echo "$txt_sideload_instr"
read -p "$txt_press"
show_banner

adb sideload "$ROM_ZIP" > sideload.log 2>&1 &
spinner $! "[$txt_flashing_rom]"

echo ""
read -p "$txt_gapps" gapps
show_banner

if { [[ "$lang" == "1" ]] && [[ "$gapps" == "y" ]]; } || { [[ "$lang" == "2" ]] && [[ "$gapps" == "s" ]]; } || { [[ "$lang" == "3" ]] && [[ "${gapps,,}" == "д" ]]; }; then
    read -p "$txt_gapps_path" GAPPS_ZIP
    show_banner
    if [[ ! -z "$GAPPS_ZIP" ]]; then
        if [[ ! -f "$GAPPS_ZIP" ]]; then
            echo "$txt_gapps_error"
            exit 1
        fi
        echo "$txt_gapps_repeat"
        echo "$txt_sideload_instr"
        read -p "$txt_press"
        show_banner
        adb sideload "$GAPPS_ZIP" > sideload_gapps.log 2>&1 &
        spinner $! "[$txt_flashing_gapps]"
        echo "$txt_gapps_fl"
    fi
fi

echo ""
echo "$txt_end"
echo ""
echo "$txt_thanks"
exit 0
