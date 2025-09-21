#!/bin/bash

banner="
  _________.__    .___     .__                    .______________           .__   
 /   _____/|__| __| _/____ |  |   _________     __| _/\__    ___/___   ____ |  |  
 \_____  \ |  |/ __ |/ __ \|  |  /  _ \__  \   / __ |   |    | /  _ \ /  _ \|  |  
 /        \|  / /_/ \  ___/|  |_(  <_> ) __ \_/ /_/ |   |    |(  <_> |  <_> )  |__
/_______  /|__\____ |\___  >____/\____(____  /\____ |   |____| \____/ \____/|____/
        \/         \/    \/                \/      \/                             "

clear
printf "%s\n\n" "$banner"

echo "Select language / Selecciona idioma:"
echo "1) English"
echo "2) Español"
read -p "> " lang
clear

if [[ "$lang" == "1" ]]; then
    txt_warn="WARNING: It is recommended to perform a factory reset before flashing a custom ROM."
    txt_warn2="Make sure you have the ROM and, if desired, the GApps package in the same folder as this script."
    txt_warn3="This will erase all data on the device. Make a backup first!"
    txt_continue="Do you want to continue? (type YES to continue): "
    txt_cancel="Operation cancelled by user."
    txt_dep="Do you want to install required dependencies (adb and fastboot)? (y/n): "
    txt_not_supported="Distribution not supported automatically. Please install ADB and Fastboot manually."
    txt_rom_path="Enter the path or name of your custom ROM .zip file: "
    txt_gapps_path="Enter the path or name of your GApps .zip file (leave blank if not installing): "
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
elif [[ "$lang" == "2" ]]; then
    txt_warn="ADVERTENCIA: Se recomienda hacer un factory reset antes de flashear una custom ROM."
    txt_warn2="Asegúrate de tener la ROM y, si lo deseas, el paquete GApps en la misma carpeta que este script."
    txt_warn3="Esto borrará todos los datos del dispositivo. ¡Haz un respaldo antes!"
    txt_continue="¿Desea continuar? (escriba SI para continuar): "
    txt_cancel="Operación cancelada por el usuario."
    txt_dep="¿Quieres instalar dependencias necesarias (adb y fastboot)? (s/n): "
    txt_not_supported="Distribución no soportada automáticamente. Instala ADB y Fastboot manualmente."
    txt_rom_path="Escribe la ruta o nombre de tu archivo .zip de la custom ROM: "
    txt_gapps_path="Escribe la ruta o nombre de tu archivo .zip de GApps (deja en blanco si no los vas a instalar): "
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
else
    echo "Invalid option / Opción no válida"
    exit 1
fi

printf "\n%*s\n" $(((${#banner} + ${#txt_warn}) / 2)) "$txt_warn"
printf "%*s\n" $(((${#banner} + ${#txt_warn2}) / 2)) "$txt_warn2"
printf "%*s\n\n" $(((${#banner} + ${#txt_warn3}) / 2)) "$txt_warn3"

read -p "$txt_continue" confirm
clear

if { [[ "$lang" == "1" ]] && [[ "$confirm" != "YES" ]]; } || { [[ "$lang" == "2" ]] && [[ "$confirm" != "SI" ]]; }; then
    echo "$txt_cancel"
    exit 1
fi

read -p "$txt_dep" instalar
clear

if { [[ "$lang" == "1" ]] && [[ "$instalar" == "y" ]]; } || { [[ "$lang" == "2" ]] && [[ "$instalar" == "s" ]]; }; then
    if [ -f /etc/debian_version ]; then
        sudo apt update
        sudo apt install -y android-tools-adb android-tools-fastboot
    elif [ -f /etc/arch-release ]; then
        sudo pacman -Sy --noconfirm android-tools
    else
        echo "$txt_not_supported"
        exit 1
    fi
    clear
fi

read -p "$txt_rom_path" ROM_ZIP
clear
if [[ ! -f "$ROM_ZIP" ]]; then
    echo "$txt_rom_error"
    exit 1
fi

echo "$txt_connect"
adb devices

read -p "$txt_recovery" cont
clear
if { [[ "$lang" == "1" ]] && [[ "$cont" != "y" ]]; } || { [[ "$lang" == "2" ]] && [[ "$cont" != "s" ]]; }; then
    echo "$txt_pls_reboot"
    exit 1
fi

echo "$txt_sideload_start"
echo "$txt_sideload_instr"
read -p "$txt_press"
clear

adb sideload "$ROM_ZIP"

echo ""
read -p "$txt_gapps" gapps
clear

if { [[ "$lang" == "1" ]] && [[ "$gapps" == "y" ]]; } || { [[ "$lang" == "2" ]] && [[ "$gapps" == "s" ]]; }; then
    read -p "$txt_gapps_path" GAPPS_ZIP
    clear
    if [[ ! -z "$GAPPS_ZIP" ]]; then
        if [[ ! -f "$GAPPS_ZIP" ]]; then
            echo "$txt_gapps_error"
            exit 1
        fi
        echo "$txt_gapps_repeat"
        echo "$txt_sideload_instr"
        read -p "$txt_press"
        clear
        adb sideload "$GAPPS_ZIP"
        echo "$txt_gapps_fl"
    fi
fi

echo ""
echo "$txt_end"
