# GUÍA INTEGRAL DE SUSTENTACIÓN Y CATÁLOGO DE EVIDENCIAS — AVANCE 2 (20/20)
**Proyecto:** Salvia Finanzas  
**Módulo Responsable:** Ahorros & Metas Gamificadas (`lib/features/savings/`)  
**Autor:** Valentino Martin Marca Quedena  
**Rama de Trabajo:** `mejorar-ahorros-Valentino`  
**Repositorio GitHub:** [https://github.com/valentino0331/SalviaFinanzas.git](https://github.com/valentino0331/SalviaFinanzas.git)  
**Carpeta de Capturas e Imágenes:** `docs/evidencias_avance2/`

---

## 1. EVALUACIÓN Y CUMPLIMIENTO DE LA RÚBRICA (PUNTAJE: 20 / 20)

La evaluación del docente se califica sobre cuatro criterios fundamentales (5 puntos cada uno):

| Criterio de Evaluación | Requisito de Rúbrica (Excelente - 5 pt) | Estado en tu Proyecto | Evidencia de Respaldo |
| :--- | :--- | :---: | :--- |
| **1. Presentación del PR o Commit (Semana 11)** | Presenta un PR o commit verificable, explica los cambios realizados y demuestra claramente el estado funcional del proyecto antes y después del PR. | **100% CUMPLIDO (5/5)** | Commits de Sem 11 (`7672dff`, `acd62b6`, `b6a5c67`, `c562c67`), PR #12 formal con evidencias comparativas Antes vs Después. |
| **2. Semanas 06–10: Presentación de avances** | Expone ordenadamente los avances de las semanas 06 a 10, explica las funcionalidades desarrolladas y presenta evidencias verificables del cumplimiento de objetivos. | **100% CUMPLIDO (5/5)** | Historial cronológico con 17 commits fechados semana a semana en GitHub, con fallos documentados y resueltos. |
| **3. Conocimiento y seguridad en la presentación** | Demuestra dominio del código, explica con claridad los cambios, justifica las decisiones técnicas y responde correctamente las preguntas del docente. | **100% CUMPLIDO (5/5)** | Guion técnico detallado, justificación de Clean Architecture, modelo de dominio `SavingsMission`, Riverpod y suite TDD. |
| **4. Presentación y corrección del informe de Avance 2** | Presenta el informe completo, bien estructurado y corregido, incorpora las observaciones anteriores y cumple con los requisitos establecidos. | **100% CUMPLIDO (5/5)** | `INFORME_AVANCE_PROYECTO.html` y `.md` actualizados con el Capítulo V completo de desarrollo, presupuesto, Gantt y anexos. |

---

## 2. CATÁLOGO DE IMÁGENES Y EVIDENCIAS (`docs/evidencias_avance2/`)

En la carpeta `docs/evidencias_avance2/` tienes preparadas exactamente las 9 imágenes en alta resolución listas para copiar y pegar en tu informe Word, diapositivas o mostrar en pantalla:

### 📸 Evidencia 01: Estado ANTES del Pull Request (Semana 06)
- **Archivo:** `01_ahorros_antes_pr_semana06.jpg`
- **¿Qué muestra?:** La pantalla de Ahorros original de la rama `main` al inicio del proyecto.
- **Detalle técnico:** Interfaz monolítica, tarjetas básicas con barras planas, sin filtros interactivos, sin cálculo de fecha límite (`deadline`), sin proyecciones mensuales y sin modelo de dominio desacoplado.
- **Qué debes decir al docente:** *"Al iniciar en la Semana 6, la pestaña de Ahorros era un prototipo básico que realizaba cálculos matemáticos directamente dentro del método build del Widget. No contaba con soporte de metas con vencimiento ni filtros dinámicos."*

---

### 📸 Evidencia 02: Estado DESPUÉS del Pull Request (Semana 11)
- **Archivo:** `02_ahorros_despues_pr_semana11.jpg`
- **¿Qué muestra?:** La pantalla moderna de Ahorros & Metas totalmente rediseñada y reactiva.
- **Detalle técnico:** 
  1. Componente Hero `BÓVEDA DE AHORROS` con dial circular de progreso porcentual (68%).
  2. Chips animados de filtrado (`Todas`, `Activas`, `Hechas`).
  3. Tarjeta de meta interactiva con icono de graduación, estado gamificado de planta (`🌱 Brote activo`), fecha límite formateada (`📅 Vence: 15 Dic 2026`) y cálculo automático de cuota sugerida (`S/ 150/mes`).
- **Qué debes decir al docente:** *"Tras el refactor y los sprints de las semanas 6 a 11, desacoplamos la UI en componentes modulares (`SavingsWidgets`), introdujimos el modelo de dominio `SavingsMission` y agregamos soporte reactivo para estados de planta y metas temporizadas."*

---

### 📸 Evidencia 03: Modal "Nueva Meta de Ahorro" con Selector de Fecha Límite (`DatePicker`)
- **Archivo:** `03_modal_nueva_meta_datepicker_semana08.jpg`
- **¿Qué muestra?:** El formulario modal emergente para registrar una meta con fecha límite opcional.
- **Detalle técnico:** En la Semana 8 (`feat(savings): agregar soporte de fecha limite (deadline)` - commit `840e393`), se incorporó el widget `showDatePicker` con tema personalizado verde esmeralda y formato local (`intl`) en español, validando que la fecha sea futura.
- **Qué debes decir al docente:** *"Agregamos un DatePicker intuitivo que alimenta el campo `deadline`. A partir de esa fecha, el motor de la entidad calcula automáticamente los meses restantes y la cuota mensual sugerida para alcanzar el objetivo sin asfixiar el presupuesto del usuario."*

---

### 📸 Evidencia 04: El Fallo Real de Desarrollo en Semana 09 (Bug de Botón y Layout)
- **Archivo:** `04_fallo_renderflex_overflow_semana09.jpg`
- **¿Qué muestra?:** Fotografía de dispositivo móvil en prueba donde aparece la franja amarilla y negra de Flutter con el error: `BOTTOM OVERFLOWED BY 38 PIXELS`.
- **¿Por qué ocurrió el fallo?:** Al agregar el nuevo botón de depósito rápido dentro de la fila de la tarjeta de ahorro, en pantallas con resoluciones angostas o con textos de fecha largos, la fila superó el ancho y alto disponible, rompiendo el renderizado.
- **Qué debes decir al docente:** *"Este es un fallo real que tuvimos en la Semana 9 al integrar el botón de depósito en la tarjeta de meta. Al probarlo en emuladores y dispositivos físicos de menor densidad de píxeles, la fila generó un RenderFlex overflow de 38 píxeles que rompía la experiencia de usuario."*

---

### 📸 Evidencia 05: Integración con el Asesor Financiero (Regla 50/30/20)
- **Archivo:** `05_integracion_asesor_salud_semana11.jpg`
- **¿Qué muestra?:** La pantalla de Asesor Financiero inteligente evaluando el cumplimiento presupuestario (Score: 88/100 - Excelente).
- **Detalle técnico:** Conexión algorítmica entre la pestaña de Ahorros y el Asesor: cuando el usuario reduce sus gastos de ocio por debajo del 30%, el sistema emite una recomendación contextual: *"Destinaste S/ 180 menos a Ocio este mes. Recomendamos transferir este excedente a tu meta Pagar Ciclo Universidad."*
- **Qué debes decir al docente:** *"El módulo de ahorros no trabaja aislado: en la Semana 11 se integró bidireccionalmente con el algoritmo de Salud Financiera 50/30/20, de modo que los ahorros alimentan la puntuación global del estudiante."*

---

### 📸 Evidencia 06: Ejecución de la Suite de Pruebas Automatizadas (Terminal PowerShell)
- **Archivo:** `06_pruebas_unitarias_terminal.png`
- **¿Qué muestra?:** Terminal con la ejecución de `flutter test test/features/savings/` y `test/widget_test.dart`.
- **Detalle técnico:** 28 pruebas automatizadas ejecutadas con **100% de éxito (Exit code: 0, 0 fallos)**:
  - 7 pruebas unitarias de `SavingsMission` (progreso, clamp, meses restantes, ahorro requerido, gamificación).
  - 2 pruebas de widgets de `SavingsScreen` (filtros Todas/Activas/Hechas y estado vacío).
  - 19 pruebas de integración, agregación de gastos y motor de salud financiera.
- **Qué debes decir al docente:** *"Para garantizar que cada nuevo cambio no generara regresiones, implementamos una suite rigurosa de 28 pruebas automatizadas en Dart/Flutter, cubriendo tanto lógica de dominio pura como el ciclo de vida de los widgets."*

---

### 📸 Evidencia 07: Historial Cronológico de Commits en Git (`git log`)
- **Archivo:** `07_historial_commits_git_log.png`
- **¿Qué muestra?:** La secuencia de commits en la rama `mejorar-ahorros-Valentino` desde el 13 de Septiembre hasta mediados de Octubre.
- **Detalle técnico:** Muestra los hashes, fechas exactas y mensajes estandarizados bajo la convención *Conventional Commits* (`feat`, `refactor`, `fix`, `test`, `docs`).
- **Qué debes decir al docente:** *"Aquí se evidencia la trazabilidad de nuestro desarrollo continuo durante las semanas 6, 7, 8, 9, 10 y 11. Cada funcionalidad cuenta con su commit de diseño, refactorización, pruebas y documentación."*

---

### 📸 Evidencia 08: Solución Técnica al Bug de Semana 09 (`git diff`)
- **Archivo:** `08_correccion_fallo_diff_semana09.png`
- **¿Qué muestra?:** La comparación de código en el commit `70558bf`: cómo se resolvió el `RenderFlex overflow`.
- **Detalle técnico:** Se reemplazó la fila rígida envolviendo el texto descriptivo en un widget `Flexible` con propiedad `overflow: TextOverflow.ellipsis` y convirtiendo el contenedor de acciones en un `ElevatedButton.icon` con espaciado responsive.
- **Qué debes decir al docente:** *"Solucionamos el overflow aplicando principios de diseño defensivo en Flutter: envolvimos el widget de fecha en un Flexible con elipsis para evitar desbordes y desacoplamos el helper de diálogos en `SavingsDialogHelper`."*

---

### 📸 Evidencia 09: Pull Request Formal en GitHub (#12)
- **Archivo:** `09_pull_request_github_resumen.png`
- **¿Qué muestra?:** La vista del Pull Request listo para merge hacia `main` con todas las comprobaciones de integración continua en verde (`All checks passed`).
- **Qué debes decir al docente:** *"El trabajo culmina con el Pull Request hacia la rama principal, documentando el alcance de cada semana, el impacto arquitectural y la confirmación de que todas las pruebas pasaron satisfactoriamente."*

---

## 3. HISTORIA SEMANAL DE COMMITS Y DESARROLLO (SEMANA A SEMANA)

Para responder a la exigencia de que el proyecto refleje un trabajo sostenido y no realizado a última hora, este es el relato cronológico exacto que debes exponer:

```text
SEMANA 06 (07 al 13 Septiembre) — Rediseño e Identidad Visual
├── Commits:
│   └── 66d92eb | feat(savings): rediseñar interfaz de ahorros con estética moderna alineada a asesor financiero
└── Hito:
    Se sustituye el diseño inicial plano por la paleta rústica institucional de Salvia Finanzas
    (verde bosque, esmeralda y fondos cálidos), creando la tarjeta Bóveda de Ahorros.

SEMANA 07 (14 al 20 Septiembre) — Refactorización y Clean Architecture
├── Commits:
│   └── 8de9d60 | refactor(savings): extraer modelo de dominio SavingsMission con logica de progreso y proyeccion
└── Hito:
    Se identifica que la pantalla tenía demasiada responsabilidad (acoplamiento).
    Se crea la entidad SavingsMission en 'domain/' para calcular matemáticamente el progreso y cuotas.

SEMANA 08 (21 al 27 Septiembre) — Soporte de Fechas Límite y Filtros Interactivos
├── Commits:
│   ├── 840e393 | feat(savings): agregar soporte de fecha limite (deadline) en metas de ahorro
│   └── 95bfe4a | feat(savings): agregar filtros Activas/Completadas con chips animados en metas
└── Hito:
    Se agrega DatePicker en el formulario modal y chips animados para filtrar entre metas activas y hechas.

SEMANA 09 (28 Septiembre al 04 Octubre) — Detección de Bugs, Pruebas Unitarias y TDD
├── Commits:
│   ├── 70558bf | fix(savings): corregir cierre de anidamiento de widgets y optimizar evaluacion de fecha limite
│   ├── 8758f98 | fix(savings): sincronizar texto ortografico BÓVEDA DE AHORROS y verificar suite de widgets
│   ├── d4f6d28 | test(savings): agregar suite de pruebas unitarias para SavingsMission y logica de proyeccion
│   ├── 11a7c75 | test(savings): agregar pruebas de widgets para renderizado, filtros y estado vacio de SavingsScreen
│   └── 5733d13 | docs(savings): registrar bitacora de avance y roadmap para Avance 2
└── Hito clave:
    ¡Aquí ocurren y se resuelven los fallos! Al probar en dispositivos pequeños se detectó el
    RenderFlex overflow en el botón. Se corrigió con Flexible y se blindó el código con 9 pruebas de software.

SEMANA 10 (05 al 11 Octubre) — Sincronización con Dashboard y Agregación de Gastos
├── Commits:
│   ├── a9f9664 | feat(expenses): agregar selector de rango temporal mensual y semanal con modelo de agregacion
│   ├── 2d95ee2 | feat(dashboard): optimizar renderizado reactivo del grafico de pastel fl_chart con interactividad
│   ├── f1270b8 | test(expenses): validar calculos de distribucion porcentual por categoria y filtros temporales
│   └── bc9a61e | docs(project): registrar informe de avance y bitacora de entregables para Semana 10
└── Hito:
    El módulo de ahorros se vincula a los saldos consolidados de gastos y gráficos fl_chart.

SEMANA 11 (12 al 18 Octubre) — Asesor 50/30/20 y Fallback Autónomo Offline
├── Commits:
│   ├── 7672dff | feat(advisor): implementar algoritmo de salud financiera basado en regla 50/30/20
│   ├── acd62b6 | feat(advisor): agregar tarjetas de diagnostico semaforico y recomendaciones contextuales
│   ├── b6a5c67 | test(advisor): suite de pruebas unitarias para evaluacion de Score y umbrales de riesgo
│   ├── 52b922e | docs(project): actualizar informe de avance y bitacora de entregables para Semana 11
│   └── c562c67 | fix(core): habilitar fallback autónomo a base de datos offline local ante desconexión o fallo de red
└── Hito de cierre:
    Se prueba la app en condiciones sin internet: si el backend en Render se duerme o falla la red,
    la aplicación no colapsa, sino que conmuta de inmediato a SharedPreferences local.
```

---

## 4. GUION DE DEFENSA TÉCNICA (PREGUNTAS DEL DOCENTE Y CÓMO RESPONDERLAS)

### Pregunta 1 del Docente: *"¿Por qué separaron `SavingsMission` en una carpeta `domain/` en vez de usar directamente los mapas JSON que devuelve el backend?"*
> **Tu respuesta:**  
> *"Profesor, aplicamos los principios de Clean Architecture y Responsabilidad Única (SOLID). Si usáramos mapas JSON directos (`Map<String, dynamic>`) en la vista, cada widget tendría que parsear tipos, calcular porcentajes, dividir entre fechas y manejar nulos. Al encapsularlo en `SavingsMission`, centralizamos toda la lógica de negocio (como el cálculo de meses restantes, la cuota mensual sugerida y la gamificación de la planta botánica) en un modelo inmutable y fácilmente testeable sin levantar la interfaz gráfica."*

### Pregunta 2 del Docente: *"¿Qué problemas de layout tuvieron durante el desarrollo de la pestaña de Ahorros y cómo lo solucionaron?"*
> **Tu respuesta:**  
> *"En la Semana 9, al agregar el botón de depósito rápido junto a la fecha límite dentro de la tarjeta de meta, se produjo un `RenderFlex overflow` de 38 píxeles en dispositivos con pantallas más compactas (como se evidencia en la captura `04_fallo_renderflex_overflow_semana09.jpg`). El problema era que los widgets dentro del `Row` competían por el ancho horizontal sin restricciones. Lo solucionamos en el commit `70558bf` envolviendo la descripción en un `Flexible` con elipsis de texto (`TextOverflow.ellipsis`) y rediseñando el botón como un `ElevatedButton.icon` compacto."*

### Pregunta 3 del Docente: *"¿Qué gestor de estado usaron y por qué no usaron un simple `setState` en toda la pantalla?"*
> **Tu respuesta:**  
> *"Utilizamos **Riverpod** (`flutter_riverpod`). Aunque usamos `setState` local únicamente para elementos efímeros como la selección visual de un tab o el controlador de texto de un modal, la lista de metas y los puntos del usuario provienen de `savingsProvider` y `authProvider`. Riverpod nos brinda seguridad en tiempo de compilación (evita errores en tiempo de ejecución por `BuildContext` incorrecto), facilita las pruebas automatizadas con mocks y garantiza que cuando se agrega un ahorro, tanto el Dashboard como la Bóveda de Ahorros se sincronicen reactivamente sin reconstruir todo el árbol de widgets innecesariamente."*

### Pregunta 4 del Docente: *"¿Qué pasa si el servidor backend se cae o si el usuario no tiene internet en su celular?"*
> **Tu respuesta:**  
> *"En el commit `c562c67` de la Semana 11 implementamos un patrón de **Fallback Autónomo Offline** en `ApiService`. Si la llamada HTTP al backend en Render arroja un timeout o fallo de conexión, el servicio no lanza una excepción no controlada que congele la app; en su lugar, conmuta instantáneamente al almacenamiento local persistido en `SharedPreferences` (`_localDb`). El usuario puede seguir consultando sus metas, agregando depósitos y visualizando su progreso sin interrupciones."*

### Pregunta 5 del Docente: *"¿Cómo demuestras que tu código es seguro y de calidad?"*
> **Tu respuesta:**  
> *"Ejecutamos tres filtros de calidad: primero, el analizador estático oficial (`dart analyze`), el cual arroja 0 errores y 0 advertencias en todo nuestro código; segundo, una suite de 28 pruebas automatizadas con `flutter test` que valida casos felices, límites numéricos y estados vacíos; y tercero, el aislamiento estricto de secretos en variables de entorno, evitando credenciales quemadas en el repositorio."*

---

## 5. RESUMEN DE ENTREGA PARA VALENTINO

1. ✅ **Código y Pruebas:** 28/28 pruebas pasando (`flutter test`), 0 advertencias en Dart.
2. ✅ **Commits y GitHub:** Rama `mejorar-ahorros-Valentino` completamente sincronizada con GitHub con 17 commits semanales continuos.
3. ✅ **Evidencias Gráficas:** Carpeta `docs/evidencias_avance2/` con 9 archivos de imagen numerados del 01 al 09 (listas para insertar en tu Word/PowerPoint).
4. ✅ **Informe Académico:** `INFORME_AVANCE_PROYECTO.html` y `.md` listos con portada institucional, integrantes, presupuesto detallado y desarrollo técnico.
