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
3. **Encuentra la dirección del X-Ray automáticamente** buscando una firma de bytes (con comodines) en la imagen del módulo.
4. Con **F1** alterna entre `B0 01` (activado) y `32 C0` (desactivado). Con **F2** sale restaurando los bytes.

## Detección automática (sobrevive a parches de Valve)

La firma se define en [`main.fa`](main.fa):

```
32 C0                          ; xor al, al  ← el objetivo
4C 8B A4 24 C8 00 00 00        ; mov r12, [rsp+0xC8]
48 8B B4 24 C0 00 00 00        ; mov rsi, [rsp+0xC0]
48 8B 9C 24 D0 00 00 00        ; mov rbx, [rsp+0xD0]
```

- Si la función mantiene esa forma en un build futuro, el programa la encuentra solo.
- Si Valve cambia la función, avisa `Firma no encontrada` y usa el **offset fijo** `DESPLAZAMIENTO_XRAY` (`0xC12629`, Build 14173) como respaldo.

## Requisitos

- Windows 10/11 **x64**.
- Ejecutar **como Administrador** (necesario para `PROCESS_ALL_ACCESS`).

## Uso (ejecutable precompilado)

Descargá `cs2-rayosX-forja.exe` de la [Release](https://github.com/forja-lang/cs2-rayosx-forja/releases), ejecutalo con CS2 abierto y presioná **F1**.

## Compilación

El [workflow de CI](.github/workflows/ci.yml) descarga el **último release oficial de Forja** ([forja-lang/forja](https://github.com/forja-lang/forja), que ya incluye las funciones nativas de forjaX) y compila el inyector con:

```bat
forja.exe compilar main.fa -o cs2-rayosX-forja.exe
```

Genera el `.exe` autónomo (VM + bytecode embebido) y, al pushear un tag `vX.Y`, publica la **Release** con el `.exe` y el `.zip`.

Localmente, con un Forja que tenga las nativas:

```bat
build.bat            → ejecuta el inyector (con CS2 abierto y como Administrador)
build.bat compilar   → genera forjaX.exe autónomo
```

## Estructura

```
├── main.fa               → lógica principal (espera cs2.exe, busca firma, toggle F1/F2)
├── proceso_externo.fa    → ProcesoExterno: abrir proceso, PID, handle, cerrar
├── gestor_modulos.fa     → GestorDeModulos/InfoModulo: base y tamaño de client.dll
├── build.bat             → ejecuta o compila el inyector (Forja local con nativas)
└── .github/workflows/    → CI: compila el .exe con el último release de Forja y publica Releases
```

Valve: arregla tu juego de mierda.
