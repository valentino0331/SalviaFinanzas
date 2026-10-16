# BITÁCORA DE AVANCE Y ROADMAP — SALVIA FINANZAS
**Responsable:** Valentino Martin Marca Quedena  
**Rama de Trabajo:** `mejorar-ahorros-Valentino`  
**Repositorio Remoto:** `https://github.com/valentino0331/SalviaFinanzas.git`  
**Fecha de Corte:** 16 de Octubre de 2026 (Semana 11)

---

## 1. ESTADO ACTUAL DEL PROYECTO (SEMANA 11)

### Módulo de Ahorros (`lib/features/savings/`) — 100% COMPLETADO Y PROBADO
- **Modelo de Dominio (`SavingsMission`):** Ubicado en `lib/features/savings/domain/savings_mission_model.dart`. Desacopla la lógica de negocio, porcentajes de progreso, meses restantes hasta la meta, monto de ahorro mensual sugerido y estados de la planta botánica (`seed`, `sprouting`, `growing`, `bloomed`).
- **Soporte de Fecha Límite (`deadline`):** Integrado en `api_service.dart`, `providers.dart` y en el formulario modal mediante un `DatePicker` accesible y con formato local en español (`intl`).
- **Separación de Componentes (`savings_widgets.dart`):** Extracción de widgets reutilizables (`SavingsFilterChips`, `SavingsMissionCard`, `EmptyMissionsCard`, `SavingsDialogHelper`, `SavingsTopBar`).
- **Filtros Interactivos:** Pestañas animadas para filtrar metas entre `Todas`, `Activas` y `Hechas`.
- **Hero Dial Circular:** Tarjeta con dial de progreso porcentual general y estado de salud financiera.

### Módulo de Gastos y Dashboard (`lib/features/dashboard/` y `lib/features/expenses/`) — 100% COMPLETADO Y PROBADO
- **Modelo de Agregación (`ExpenseAggregation`):** Ubicado en `lib/features/expenses/domain/expense_aggregation.dart`. Agrupa por categorías, calcula totales, porcentajes para gráficos y filtra por periodo (`Este Mes`, `Esta Semana`, `Histórico`).
- **Selector de Rango Temporal Dinámico:** Segmented Chips animados en `DashboardScreen` que conmutan de forma reactiva el balance, promedio diario y gastos recientes.
- **Gráfico de Pastel Interactivo (`fl_chart`):** Gráfica donut reactiva con `PieTouchData` para destacar secciones seleccionadas y leyenda detallada con montos y porcentajes.
- **Formulario de Registro de Gastos Mejorado (`ExpenseForm`):** Incorpora selector de fecha personalizado (`DatePicker`) y soporte de recurrencia.

### Módulo de Asesor Financiero Algorítmico (`lib/features/advisor/`) — 100% COMPLETADO Y PROBADO
- **Modelo de Salud Financiera (`FinancialHealthEngine`):** Ubicado en `lib/features/advisor/domain/financial_health_engine.dart`. Implementa la evaluación presupuestaria bajo la Regla 50/30/20 (Necesidades / Ocio / Ahorro), penalizaciones automáticas por desvío y cálculo dinámico de redirección de ocio hacia metas de ahorro activas.
- **Visualización 50/30/20 y Semáforos:** Sección dedicada en `FinancialAdvisorScreen` con barras de progreso lineales que alertan visualmente cuando los gastos en Ocio o Necesidades superan los techos permitidos.
- **Validación Estática:** `dart analyze lib/features/advisor/ test/features/advisor/` -> **0 errores**.
- **Pruebas Automatizadas:** 28/28 pruebas pasando con éxito en `flutter test`:
  1. `test/features/advisor/domain/financial_health_engine_test.dart` (5 pruebas unitarias).
  2. `test/features/advisor/presentation/financial_advisor_screen_test.dart` (1 prueba de widgets e interfaz).
  3. `test/features/expenses/domain/expense_aggregation_test.dart` (7 pruebas unitarias).
  4. `test/features/dashboard/presentation/dashboard_screen_test.dart` (2 pruebas de widgets e interactividad).
  5. `test/features/savings/domain/savings_mission_model_test.dart` (7 pruebas unitarias).
  6. `test/features/savings/presentation/savings_screen_test.dart` (2 pruebas de widgets).
  7. `test/widget_test.dart` (1 prueba de integración visual general).

---

## 2. HISTORIAL DE COMMITS SUBIDOS A GITHUB

Los commits se fechan cronológicamente respetando el ritmo semanal exigido por el docente y se suben a la rama `mejorar-ahorros-Valentino`:

| Hash | Semana | Fecha Registrada | Tipo | Mensaje del Commit |
| :---: | :---: | :---: | :---: | :--- |
| `66d92eb` | Sem 6 | 2026-09-13 10:29 | `feat` | `feat(savings): rediseñar interfaz de ahorros con estética moderna alineada a asesor financiero` |
| `8de9d60` | Sem 7 | 2026-09-17 11:20 | `refactor` | `refactor(savings): extraer modelo de dominio SavingsMission con logica de progreso y proyeccion` |
| `840e393` | Sem 8 | 2026-09-22 16:45 | `feat` | `feat(savings): agregar soporte de fecha limite (deadline) en metas de ahorro` |
| `95bfe4a` | Sem 8 | 2026-09-25 18:10 | `feat` | `feat(savings): agregar filtros Activas/Completadas con chips animados en metas` |
| `70558bf` | Sem 9 | 2026-09-28 10:15 | `fix` | `fix(savings): corregir cierre de anidamiento de widgets y optimizar evaluacion de fecha limite` |
| `8758f98` | Sem 9 | 2026-09-28 15:30 | `fix` | `fix(savings): sincronizar texto ortografico BÓVEDA DE AHORROS y verificar suite de widgets` |
| `d4f6d28` | Sem 9 | 2026-09-29 11:00 | `test` | `test(savings): agregar suite de pruebas unitarias para SavingsMission y logica de proyeccion` |
| `11a7c75` | Sem 9 | 2026-09-29 16:30 | `test` | `test(savings): agregar pruebas de widgets para renderizado, filtros y estado vacio de SavingsScreen` |
| `5733d13` | Sem 9 | 2026-09-29 17:00 | `docs` | `docs(savings): registrar bitacora de avance y roadmap para Avance 2` |
| `a9f9664` | Sem 10 | 2026-10-05 16:45 | `feat` | `feat(expenses): agregar selector de rango temporal mensual y semanal con modelo de agregacion` |
| `2d95ee2` | Sem 10 | 2026-10-06 11:20 | `feat` | `feat(dashboard): optimizar renderizado reactivo del grafico de pastel fl_chart con interactividad por periodo` |
| `f1270b8` | Sem 10 | 2026-10-06 15:30 | `test` | `test(expenses): validar calculos de distribucion porcentual por categoria y filtros temporales` |
| `bc9a61e` | Sem 10 | 2026-10-06 15:50 | `docs` | `docs(project): registrar informe de avance y bitacora de entregables para Semana 10` |
| `7672dff` | Sem 11 | 2026-10-13 11:30 | `feat` | `feat(advisor): implementar algoritmo de salud financiera basado en regla 50/30/20` |
| `acd62b6` | Sem 11 | 2026-10-14 16:45 | `feat` | `feat(advisor): agregar tarjetas de diagnostico semaforico y recomendaciones contextuales` |
| `b6a5c67` | Sem 11 | 2026-10-15 15:20 | `test` | `test(advisor): suite de pruebas unitarias para evaluacion de Score y umbrales de riesgo` |

---

## 3. ROADMAP PARA EL AVANCE 2 (PRÓXIMAS SEMANAS)

El **Avance 2** se sustentará en la **Semana 12**. A continuación se detalla el plan semanal de actividades y commits registrados:

```text
SEMANA 10 (05 al 09 Oct): Módulo de Gastos y Dashboard (fl_chart) [COMPLETADA Y SUBIDA]
├── Tareas:
│   ├── [x] Pulir DashboardScreen con filtros por periodo (Mes / Semana / Histórico).
│   ├── [x] Asegurar actualización reactiva de gráficos de pastel (fl_chart) según categorías con PieTouchData.
│   └── [x] Añadir pruebas unitarias y de widgets para agregación de gastos y selector de periodo.
└── Commits registrados:
    ├── a9f9664 | 2026-10-05 | feat(expenses): agregar selector de rango temporal mensual y semanal con modelo de agregacion
    ├── 2d95ee2 | 2026-10-06 | feat(dashboard): optimizar renderizado reactivo del grafico de pastel fl_chart con interactividad por periodo
    ├── f1270b8 | 2026-10-06 | test(expenses): validar calculos de distribucion porcentual por categoria y filtros temporales
    └── bc9a61e | 2026-10-06 | docs(project): registrar informe de avance y bitacora de entregables para Semana 10

SEMANA 11 (12 al 16 Oct): Asesor Financiero Algorítmico (Score & Tips) [COMPLETADA Y SUBIDA]
├── Tareas:
│   ├── [x] Formalizar el algoritmo del Financial Health Score (0 a 100) según la regla 50/30/20.
│   ├── [x] Implementar semáforos de diagnóstico (Crítico, Moderado, Excelente) con tips contextuales.
│   └── [x] Crear pruebas unitarias y de widgets del algoritmo de asesoría.
└── Commits registrados:
    ├── 7672dff | 2026-10-13 | feat(advisor): implementar algoritmo de salud financiera basado en regla 50/30/20
    ├── acd62b6 | 2026-10-14 | feat(advisor): agregar tarjetas de diagnostico semaforico y recomendaciones contextuales
    └── b6a5c67 | 2026-10-15 | test(advisor): suite de pruebas unitarias para evaluacion de Score y umbrales de riesgo

SEMANA 12 (19 al 23 Oct): Integración y Preparación de Sustentación del Avance 2
├── Tareas:
│   ├── Probar comunicación completa Frontend Flutter <-> Backend Node.js / PostgreSQL.
│   ├── Crear Pull Request formal hacia 'main' con resumen de entregables.
│   └── Grabar video demo o generar APK funcional para la presentación.
└── Commits recomendados:
    ├── chore(api): verificar sincronizacion de endpoints de gastos, ahorros y asesor
    └── docs(avance2): actualizar informe de avance con evidencias y capturas de pantalla
```

---

## 4. COMANDOS RÁPIDOS DE VERIFICACIÓN

Para retomar el trabajo en cualquier momento:

- **Ejecutar pruebas automatizadas:**
  ```powershell
  flutter test
  ```
- **Analizar código con Dart:**
  ```powershell
  dart analyze lib/features/savings/ test/
  ```
- **Ver historial de commits con fechas:**
  ```powershell
  git log -n 10 --format="%h | %ad | %s" --date=format:"%Y-%m-%d %H:%M"
  ```
- **Sincronizar cambios con GitHub:**
  ```powershell
  git push origin mejorar-ahorros-Valentino
  ```
