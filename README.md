# autotrack.nvim

Plugin de Neovim para autotracking automático con timewarrior.

## Características

- Detecta automáticamente cuando cambias de archivo/buffer
- Inicia/para el tracking con timewarrior automáticamente
- Incluye tags para:
  - Nombre del proyecto (carpeta actual)
  - Rama de git actual
  - Tipo de archivo/lenguaje de programación
- Configuración personalizable

## Instalación

### Con lazy.nvim
```lua
{
  "tuusuario/autotrack.nvim",
  config = function()
    require("autotrack").setup()
  end
}
```

### Con packer.nvim
```lua
use {
  "tuusuario/autotrack.nvim",
  config = function()
    require("autotrack").setup()
  end
}
```

## Configuración

```lua
require("autotrack").setup({
  enabled = true,                                    -- Habilitar autotracking por defecto
  task_name = "autotrack.nvim",                     -- Nombre de la tarea en timewarrior
  exclude_filetypes = { "help", "qf", "netrw", "fugitive", "git" }  -- Tipos de archivo a excluir
})
```

## Comandos

- `:AutotrackStart` - Iniciar autotracking
- `:AutotrackStop` - Parar autotracking
- `:AutotrackToggle` - Alternar autotracking
- `:AutotrackStatus` - Mostrar estado actual

## Uso

El plugin se inicia automáticamente cuando se carga. Cada vez que cambies de buffer:

1. Para el tracking actual (si existe)
2. Inicia un nuevo tracking con tags:
   - `autotrack.nvim` (nombre de tarea)
   - `project:nombre_proyecto` (nombre de la carpeta)
   - `branch:rama_actual` (rama de git)
   - `lang:tipo_archivo` (lenguaje/tipo de archivo)

## Ejemplo de datos en timewarrior

```
timew summary project:mi-proyecto lang:lua
timew summary branch:feature/nueva-funcionalidad
timew summary autotrack.nvim
```

## Requisitos

- Neovim 0.7+
- timewarrior instalado y configurado
- Git (opcional, para detección de ramas)