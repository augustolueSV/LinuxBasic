#!/usr/bin/env bash
set -euo pipefail

DATA_FILE="${HOME}/.linux_practice_tasks"

ensure_storage() {
  if [[ ! -f "$DATA_FILE" ]]; then
    : > "$DATA_FILE"
  fi
}

show_banner() {
  printf '\n'
  printf '====================================================\n'
  printf '  Linux Practice CLI - Ejercicio 01\n'
  printf '  Gestor simple de tareas\n'
  printf '====================================================\n'
}

show_menu() {
  cat <<'EOF_MENU'
  [1] Añadir tarea
  [2] Listar tareas
  [3] Marcar como hecha
  [4] Eliminar tarea
  [5] Salir
EOF_MENU
}

list_tasks() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No hay tareas registradas. Añade la primera con la opción 1."
    return
  fi

  echo "Tareas actuales:"
  local index=1
  while IFS='|' read -r title status; do
    [[ -z "${title:-}" ]] && continue
    if [[ "$status" == "done" ]]; then
      printf '  [%02d] %s  [COMPLETADA]\n' "$index" "$title"
    else
      printf '  [%02d] %s  [PENDIENTE]\n' "$index" "$title"
    fi
    ((index++))
  done < "$DATA_FILE"
}

add_task() {
  local title=""
  if [[ $# -gt 0 ]]; then
    title="$1"
  else
    read -r -p "Nombre de la tarea: " title
  fi

  if [[ -z "$title" ]]; then
    echo "La tarea no puede estar vacía."
    return
  fi

  printf '%s|pending\n' "$title" >> "$DATA_FILE"
  echo "Tarea añadida: $title"
}

mark_done() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No hay tareas para cerrar."
    return
  fi

  list_tasks
  read -r -p "Selecciona el número de la tarea a cerrar: " task_number
  if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
    echo "Entrada inválida. Debe ser un número."
    return
  fi

  local index=1
  local temp_file
  temp_file=$(mktemp)
  while IFS='|' read -r title status; do
    if [[ -z "${title:-}" ]]; then
      continue
    fi

    if (( index == task_number )); then
      printf '%s|done\n' "$title" >> "$temp_file"
    else
      printf '%s|%s\n' "$title" "$status" >> "$temp_file"
    fi
    ((index++))
  done < "$DATA_FILE"

  mv "$temp_file" "$DATA_FILE"
  echo "Tarea marcada como completada."
}

delete_task() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No hay tareas para eliminar."
    return
  fi

  list_tasks
  read -r -p "Selecciona el número de la tarea a eliminar: " task_number
  if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
    echo "Entrada inválida. Debe ser un número."
    return
  fi

  local index=1
  local temp_file
  temp_file=$(mktemp)
  while IFS='|' read -r title status; do
    if [[ -z "${title:-}" ]]; then
      continue
    fi

    if (( index != task_number )); then
      printf '%s|%s\n' "$title" "$status" >> "$temp_file"
    fi
    ((index++))
  done < "$DATA_FILE"

  mv "$temp_file" "$DATA_FILE"
  echo "Tarea eliminada."
}

main() {
  ensure_storage

  while true; do
    show_banner
    show_menu
    echo
    read -r -p "Elige una opción [1-5]: " option || exit 0

    case "$option" in
      1)
        add_task
        ;;
      2)
        list_tasks
        ;;
      3)
        mark_done
        ;;
      4)
        delete_task
        ;;
      5)
        echo "Saliendo del gestor de tareas."
        exit 0
        ;;
      *)
        echo "Opción no válida. Prueba con 1, 2, 3, 4 o 5."
        ;;
    esac

    echo
    read -r -p "Pulsa Enter para continuar..." _
  done
}

main "$@"
