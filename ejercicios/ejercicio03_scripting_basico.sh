#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${HOME}/linux_scripts_practice"
mkdir -p "$BASE_DIR"

show_banner() {
  if [[ -t 1 ]]; then
    clear
  fi
  echo "========================================================="
  echo "  Ejercicio 03 - Scripting básico en Bash"
  echo "  Practica con variables, if, for, read, cron y backups"
  echo "========================================================="
}

show_menu() {
  cat <<'EOF_MENU'

  [1] Hola con argumento
  [2] Crear carpeta si no existe
  [3] Recorrer archivos .txt
  [4] Backup simple
  [5] Probar set -euo pipefail
  [6] Programar tarea con cron
  [7] Mostrar fecha, usuario y espacio libre
  [8] Practicar if + for + read en un mismo script
  [9] Salir

EOF_MENU
}

exercise_01_hola() {
  echo "==> Ejercicio 1: Crea un script que diga 'Hola, tu nombre' usando un argumento"
  echo "Ejemplo de uso:"
  echo "  ./script.sh Ana"
  echo

  if [[ $# -gt 0 ]]; then
    nombre="$1"
  else
    read -r -p "Escribe tu nombre: " nombre
  fi

  if [[ -z "$nombre" ]]; then
    echo "No has escrito nada. Inténtalo otra vez."
    return
  fi

  echo "Hola, $nombre"
}

exercise_02_carpeta() {
  echo "==> Ejercicio 2: Comprueba si una carpeta existe y la crea si no existe"
  read -r -p "Escribe el nombre de la carpeta: " carpeta

  if [[ -z "$carpeta" ]]; then
    echo "No has escrito un nombre."
    return
  fi

  if [[ -d "$carpeta" ]]; then
    echo "La carpeta ya existe: $carpeta"
  else
    mkdir -p "$carpeta"
    echo "Se ha creado la carpeta: $carpeta"
  fi

  ls -ld "$carpeta" 2>/dev/null || true
}

exercise_03_txt_loop() {
  echo "==> Ejercicio 3: Recorre archivos .txt y los muestra en pantalla"
  shopt -s nullglob
  archivos=(*.txt)

  if [[ ${#archivos[@]} -eq 0 ]]; then
    echo "No hay archivos .txt en esta carpeta."
    echo "Crea uno antes de probar este ejercicio, por ejemplo:"
    echo "  echo 'hola' > prueba.txt"
    return
  fi

  for archivo in "${archivos[@]}"; do
    echo "--- $archivo ---"
    cat "$archivo"
    echo
  done
}

exercise_04_backup() {
  echo "==> Ejercicio 4: Crea un backup simple de una carpeta en otra ubicación"
  read -r -p "Escribe la ruta de origen: " origen
  read -r -p "Escribe la ruta de destino: " destino

  if [[ -z "$origen" || -z "$destino" ]]; then
    echo "Debes indicar origen y destino."
    return
  fi

  if [[ ! -d "$origen" ]]; then
    echo "La carpeta origen no existe: $origen"
    return
  fi

  mkdir -p "$destino"
  nombre_copia="$(basename "$origen")_backup_$(date +%Y%m%d_%H%M%S)"
  cp -r "$origen" "$destino/$nombre_copia"

  echo "Backup creado correctamente: $destino/$nombre_copia"
  ls -ld "$destino/$nombre_copia"
}

exercise_05_set_eu_pipefail() {
  echo "==> Ejercicio 5: Añade set -euo pipefail y prueba qué pasa cuando falla algo"

  cat > "$BASE_DIR/ejemplo_error.sh" <<'EOF_SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

echo "Antes del fallo..."
ls /ruta_que_no_existe

echo "Esto nunca se ejecutará si falla algo"
EOF_SCRIPT

  chmod +x "$BASE_DIR/ejemplo_error.sh"
  echo "Script creado en: $BASE_DIR/ejemplo_error.sh"
  echo "Ahora lo ejecutaremos para ver qué pasa cuando hay un error."
  echo

  "$BASE_DIR/ejemplo_error.sh" || true

  echo
  echo "Explicación:"
  echo "  set -e: si un comando falla, el script se detiene."
  echo "  -u: si usas una variable no definida, falla."
  echo "  pipefail: si una tubería falla, también falla el script."
}

exercise_06_cron() {
  echo "==> Ejercicio 6: Programa una tarea con crontab y observa la salida en un archivo de log"

  cat > "$BASE_DIR/cron_ejercicio.sh" <<'EOF_SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

echo "Tarea ejecutada el $(date)" >> "${HOME}/cron_ejercicio.log"
EOF_SCRIPT

  chmod +x "$BASE_DIR/cron_ejercicio.sh"

  echo "Se ha creado un script en: $BASE_DIR/cron_ejercicio.sh"
  echo "Ahora añade esta línea a crontab:"
  echo "  crontab -e"
  echo "  */5 * * * * $BASE_DIR/cron_ejercicio.sh"
  echo
  echo "Después puedes comprobar el log con:"
  echo "  tail -f ${HOME}/cron_ejercicio.log"
  echo
  echo "Y para ver tu cron actual:"
  echo "  crontab -l"
}

exercise_07_info_sistema() {
  echo "==> Ejercicio 7: Muestra la fecha, el usuario actual y el espacio libre del disco"
  echo "Usuario actual: $(whoami)"
  echo "Fecha y hora: $(date)"
  echo
  echo "Espacio libre del disco:"
  df -h / | tail -n +2
}

exercise_08_if_for_read() {
  echo "==> Ejercicio 8: Practica con if, for y read en un mismo script"
  read -r -p "¿Cómo te llamas? " nombre

  if [[ -z "$nombre" ]]; then
    echo "No has escrito tu nombre."
    return
  fi

  echo "Hola, $nombre"

  for i in 1 2 3 4 5; do
    echo "Iteración $i"
  done

  read -r -p "¿Quieres continuar? [s/N]: " respuesta
  if [[ "$respuesta" == "s" || "$respuesta" == "S" ]]; then
    echo "Continuamos con la práctica."
  else
    echo "Se cancela la práctica."
  fi
}

main() {
  while true; do
    show_banner
    show_menu
    echo
    read -r -p "Elige una opción [1-9]: " opcion || exit 0

    case "$opcion" in
      1)
        exercise_01_hola
        ;;
      2)
        exercise_02_carpeta
        ;;
      3)
        exercise_03_txt_loop
        ;;
      4)
        exercise_04_backup
        ;;
      5)
        exercise_05_set_eu_pipefail
        ;;
      6)
        exercise_06_cron
        ;;
      7)
        exercise_07_info_sistema
        ;;
      8)
        exercise_08_if_for_read
        ;;
      9)
        echo "Saliendo del ejercicio de Bash."
        exit 0
        ;;
      *)
        echo "Opción no válida. Prueba con un número del 1 al 9."
        ;;
    esac

    echo
    read -r -p "Pulsa Enter para continuar..." _
  done
}

main "$@"
