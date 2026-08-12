#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${HOME}/linux_practice_cli"
PRACTICE_USER="labuser"
PRACTICE_GROUP="labgroup"

prepare_workspace() {
  mkdir -p "$BASE_DIR"
}

show_banner() {
  printf '\n'
  printf '====================================================\n'
  printf '  Linux Practice CLI - Ejercicio 02\n'
  printf '  Administración básica de usuarios, permisos y servicios\n'
  printf '====================================================\n'
}

show_menu() {
  cat <<'EOF_MENU'
  [1] Crear usuario de prueba
  [2] Añadirlo a un grupo y comprobar id/groups
  [3] Permisos en una carpeta y ls -l
  [4] Probar sudo y revisar sudoers
  [5] Comprobar systemctl status en un servicio local
  [6] Backup con tar y comparación con rsync
  [7] Script simple y programación con cron
  [8] Salir
EOF_MENU
}

create_user_demo() {
  echo "==> Paso 1: crear usuario de prueba"

  if [[ $EUID -ne 0 ]]; then
    echo "Necesitas privilegios de root o sudo para crear usuarios."
    echo "Comandos esperados:"
    echo "  sudo useradd -m -s /bin/bash $PRACTICE_USER"
    echo "  sudo passwd $PRACTICE_USER"
    return
  fi

  if id "$PRACTICE_USER" >/dev/null 2>&1; then
    echo "El usuario $PRACTICE_USER ya existe."
  else
    useradd -m -s /bin/bash "$PRACTICE_USER"
    echo "Usuario creado: $PRACTICE_USER"
  fi

  echo "Verifica con:"
  echo "  id $PRACTICE_USER"
  echo "  groups $PRACTICE_USER"
}

add_user_to_group_demo() {
  echo "==> Paso 2: añadir usuario a un grupo"

  if [[ $EUID -ne 0 ]]; then
    echo "Necesitas privilegios de root o sudo para añadir usuarios a grupos."
    echo "Comandos esperados:"
    echo "  sudo groupadd $PRACTICE_GROUP"
    echo "  sudo usermod -a -G $PRACTICE_GROUP $PRACTICE_USER"
    echo "  id $PRACTICE_USER"
    echo "  groups $PRACTICE_USER"
    return
  fi

  if ! getent group "$PRACTICE_GROUP" >/dev/null 2>&1; then
    groupadd "$PRACTICE_GROUP"
    echo "Grupo creado: $PRACTICE_GROUP"
  else
    echo "El grupo $PRACTICE_GROUP ya existe."
  fi

  usermod -a -G "$PRACTICE_GROUP" "$PRACTICE_USER"
  echo "Usuario añadido al grupo: $PRACTICE_GROUP"
  echo "Salida esperada:"
  id "$PRACTICE_USER"
  groups "$PRACTICE_USER"
}

permissions_demo() {
  echo "==> Paso 3: permisos en una carpeta simple"

  local demo_dir="$BASE_DIR/permisos_demo"
  mkdir -p "$demo_dir"
  touch "$demo_dir/archivo.txt"
  chmod 750 "$demo_dir"

  echo "Carpeta creada: $demo_dir"
  echo "Permisos actuales:"
  ls -ld "$demo_dir"
  ls -l "$demo_dir"

  echo "Prueba rápida:"
  echo "  chmod 700 "$demo_dir""
  echo "  ls -ld "$demo_dir""
}

sudo_demo() {
  echo "==> Paso 4: sudo y validación del archivo sudoers"

  if ! command -v sudo >/dev/null 2>&1; then
    echo "El comando sudo no está disponible en este sistema."
    return
  fi

  echo "Comando básico a probar:"
  if [[ $EUID -eq 0 ]]; then
    echo "  sudo -u nobody whoami"
  else
    echo "  sudo whoami"
    sudo whoami || true
  fi

  echo "Validación de sudoers:"
  echo "  sudo visudo"
  echo "  sudo visudo -cf /etc/sudoers"
}

systemctl_demo() {
  echo "==> Paso 5: systemctl status de un servicio local"

  if ! command -v systemctl >/dev/null 2>&1; then
    echo "systemctl no está disponible en este entorno."
    return
  fi

  local service=""
  for candidate in ssh cron dbus; do
    if systemctl list-unit-files --type=service 2>/dev/null | grep -q "^${candidate}\.service"; then
      service="$candidate"
      break
    fi
  done

  if [[ -z "$service" ]]; then
    echo "No se encontró un servicio local típico. Prueba con:"
    echo "  systemctl list-unit-files --type=service | head"
    return
  fi

  echo "Servicio elegido: $service"
  systemctl status "$service" --no-pager || true
}

backup_demo() {
  echo "==> Paso 6: backup con tar y comparación con rsync"

  local source_dir="$BASE_DIR/backup_source"
  local backup_dir="$BASE_DIR/backup_output"
  local tar_dir="$backup_dir/tar"
  local rsync_dir="$backup_dir/rsync"

  mkdir -p "$source_dir" "$tar_dir" "$rsync_dir"
  echo "Ejemplo de archivo" > "$source_dir/ejemplo.txt"
  echo "Más contenido" > "$source_dir/otro.txt"

  tar -czf "$tar_dir/backup.tar.gz" -C "$source_dir" .
  rsync -a "$source_dir/" "$rsync_dir/"

  echo "Archivos creados en: $backup_dir"
  ls -lh "$tar_dir" "$rsync_dir"
  echo "Comparación:"
  diff -qr "$source_dir" "$rsync_dir" || true
  echo "Lista del tar:"
  tar -tzf "$tar_dir/backup.tar.gz"
}

cron_demo() {
  echo "==> Paso 7: crear un script y programarlo con cron"

  local script_path="$BASE_DIR/cron_hello.sh"
  cat > "$script_path" <<'EOF_SCRIPT'
#!/usr/bin/env bash
printf '%s: ejercicio cron ejecutado\n' "$(date)" >> "${HOME}/cron_ejercicio.log"
EOF_SCRIPT
  chmod +x "$script_path"

  echo "Script creado: $script_path"
  echo "Contenido sugerido del cron:"
  echo "  crontab -e"
  echo "  */5 * * * * $script_path"
  echo "Verifica con:"
  echo "  crontab -l"
  echo "  tail -f ${HOME}/cron_ejercicio.log"
}

main() {
  prepare_workspace

  while true; do
    show_banner
    show_menu
    echo
    read -r -p "Elige una opción [1-8]: " option || exit 0

    case "$option" in
      1)
        create_user_demo
        ;;
      2)
        add_user_to_group_demo
        ;;
      3)
        permissions_demo
        ;;
      4)
        sudo_demo
        ;;
      5)
        systemctl_demo
        ;;
      6)
        backup_demo
        ;;
      7)
        cron_demo
        ;;
      8)
        echo "Saliendo del ejercicio de práctica de Linux."
        exit 0
        ;;
      *)
        echo "Opción no válida. Prueba con 1, 2, 3, 4, 5, 6, 7 u 8."
        ;;
    esac

    echo
    read -r -p "Pulsa Enter para continuar..." _
  done
}

main "$@"
