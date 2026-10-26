# cs2-rayosX-forja (forjaX)

Port a **[Forja](https://github.com/forja-lang/forja)** del inyector **[cs2-rayoX](https://github.com/lococoi/cs2-rayoX/)**  (C++) — X-Ray para Counter-Strike 2 por parcheo directo de `client.dll`.

<img width="1223" height="732" alt="image" src="https://github.com/user-attachments/assets/6930c485-6545-4ac7-bc64-bf8be0045062" />

> [!WARNING]
> ⚠️ **Esto podría ser perjudicial.** Su uso podría violar los Términos de Servicio de Valve y puede resultar en **baneo permanente de la cuenta por VAC**. Este proyecto es **exclusivamente con fines educativos** (aprender APIs de Windows como `ReadProcessMemory`, `WriteProcessMemory`, `Toolhelp32`). Usalo bajo tu propia responsabilidad y solo en entornos de práctica/offline.

---

## Cómo funciona

En `client.dll` hay una función que controla el X-Ray del juego. En una dirección específica contiene la instrucción `xor al, al` (`32 C0`). Cambiarla a `mov al, 1` (`B0 01`) activa el glow en **todos** los jugadores al instante; restaurarla lo apaga.

El programa:
1. Espera a que `cs2.exe` esté abierto.
2. Carga `client.dll` (base + tamaño vía Toolhelp32).
3. **Encuentra la dirección del X-Ray automáticamente** combinando dos métodos:
   - Acceso al flag al inicio de la función (`cmp [rax+58],0; je rel32`) y **sigue el salto relativo** hasta el `xor al, al` objetivo.
   - Búsqueda del **epílogo** del X-Ray (22 bytes) como ancla específica.
   - Si ambos coinciden, usa esa dirección; si solo uno aparece, usa el disponible.
4. Con **F1** alterna entre `B0 01` (activado) y `32 C0` (desactivado). Con **F2** sale restaurando los bytes.

## Detección automática (sobrevive a parches de Valve)

Las firmas se definen en [`main.fa`](main.fa):

```
83 78 58 00                 ; cmp dword ptr [rax+58], 0
0F 84 ?? ?? ?? ??           ; je rel32  → destino = X-Ray
```

El finder lee el `rel32`, lo suma a la dirección siguiente al `je` y valida que el destino empiece con `xor al, al` (`32 C0`). Si el acceso no aparece, usa el epílogo:

```
32 C0                       ; xor al, al  ← el objetivo
4C 8D 9C 24 90 00 00 00     ; lea r11, [rsp+90]
49 8B 5B 30                 ; mov rbx, [r11+30]
49 8B 73 38                 ; mov rsi, [r11+38]
49 8B 7B 40                 ; mov rdi, [r11+40]
```

- Si la función mantiene el acceso o el epílogo, el programa la encuentra solo.
- Si nada coincide, avisa `Firma no encontrada` y usa el **offset fijo** `DESPLAZAMIENTO_XRAY` (`0xC7EC66`, build actual) como último recurso.

## Requisitos

- Windows 10/11 **x64**.
- Ejecutar (**como Administrador solo cuando sea necesario**).

## Uso (ejecutable precompilado)

Descargá `cs2-rayosX-forja.exe` de la [Release](https://github.com/lococoi/cs2-rayosx-forja/releases), ejecutalo con CS2 abierto y presioná **F1**.

## Compilación

El [workflow de CI](.github/workflows/ci.yml) descarga el **último release oficial de Forja** ([forja-lang/forja](https://github.com/forja-lang/forja), que ya incluye las funciones nativas de forjaX) y compila el inyector con:

```bat
forja.exe compilar main.fa -o cs2-rayosX-forja.exe
```

Genera el `.exe` autónomo (VM + bytecode embebido).

Localmente, con un Forja que tenga las nativas:

```bat
build.bat            → ejecuta el inyector (con CS2 abierto y como Administrador)
build.bat compilar   → genera forjaX.exe autónomo
```

## Estructura

```
├── main.fa               → lógica principal (espera cs2.exe, busca acceso/epílogo, toggle F1/F2)
├── proceso_externo.fa    → ProcesoExterno: abrir proceso, PID, handle, cerrar
├── gestor_modulos.fa     → GestorDeModulos/InfoModulo: base y tamaño de client.dll
├── build.bat             → ejecuta o compila el inyector (Forja local con nativas)
└── .github/workflows/    → CI: compila el .exe con el último release de Forja y publica Releases
```

Valve: arregla tu juego de mierda.
