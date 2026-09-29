# BITÁCORA DE AVANCE Y ROADMAP — SALVIA FINANZAS
**Responsable:** Valentino Martin Marca Quedena  
**Rama de Trabajo:** `mejorar-ahorros-Valentino`  
**Repositorio Remoto:** `https://github.com/valentino0331/SalviaFinanzas.git`  
**Fecha de Corte:** 29 de Septiembre de 2026 (Semana 9)

---

## 1. ESTADO ACTUAL DEL PROYECTO (SEMANA 9)

### Módulo de Ahorros (`lib/features/savings/`) — 100% COMPLETADO Y PROBADO
- **Modelo de Dominio (`SavingsMission`):** Ubicado en `lib/features/savings/domain/savings_mission_model.dart`. Desacopla la lógica de negocio, porcentajes de progreso, meses restantes hasta la meta, monto de ahorro mensual sugerido y estados de la planta botánica (`seed`, `sprouting`, `growing`, `bloomed`).
- **Soporte de Fecha Límite (`deadline`):** Integrado en `api_service.dart`, `providers.dart` y en el formulario modal mediante un `DatePicker` accesible y con formato local en español (`intl`).
- **Separación de Componentes (`savings_widgets.dart`):** Extracción de widgets reutilizables (`SavingsFilterChips`, `SavingsMissionCard`, `EmptyMissionsCard`, `SavingsDialogHelper`, `SavingsTopBar`).
- **Filtros Interactivos:** Pestañas animadas para filtrar metas entre `Todas`, `Activas` y `Hechas`.
- **Hero Dial Circular:** Tarjeta con dial de progreso porcentual general y estado de salud financiera.
- **Validación Estática:** `dart analyze lib/features/savings/ test/` -> **0 errores, 0 warnings**.
- **Pruebas Automatizadas:** 10/10 pruebas pasando con éxito en `flutter test`:
  1. `test/features/savings/domain/savings_mission_model_test.dart` (7 pruebas unitarias).
  2. `test/features/savings/presentation/savings_screen_test.dart` (2 pruebas de widgets e interacción).
  3. `test/widget_test.dart` (1 prueba de integración visual general).

---

## 2. HISTORIAL DE COMMITS SUBIDOS A GITHUB

Los commits se re-fecharon cronológicamente respetando el ritmo semanal exigido por el docente y se subieron a la rama `mejorar-ahorros-Valentino`:

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

---

## 3. ROADMAP PARA EL AVANCE 2 (PRÓXIMAS 3 SEMANAS)

El **Avance 2** se sustentará en la **Semana 12**. A continuación se detalla el plan semanal de actividades y commits sugeridos para Valentino:

```text
SEMANA 10 (05 al 09 Oct): Módulo de Gastos y Dashboard (fl_chart)
├── Tareas:
│   ├── Pulir DashboardScreen con filtros por periodo (Mes / Semana).
│   ├── Asegurar actualización reactiva de gráficos de pastel (fl_chart) según categorías.
│   └── Añadir pruebas unitarias para agregación de gastos.
└── Commits recomendados:
    ├── feat(expenses): agregar selector de rango temporal mensual y semanal
    ├── feat(dashboard): optimizar renderizado reactivo del grafico de pastel fl_chart
    └── test(expenses): validar calculos de distribucion porcentual por categoria

SEMANA 11 (12 al 16 Oct): Asesor Financiero Algorítmico (Score & Tips)
├── Tareas:
│   ├── Formalizar el algoritmo del Financial Health Score (0 a 100) según la regla 50/30/20.
│   ├── Implementar semáforos de diagnóstico (Crítico, Moderado, Excelente) con tips contextuales.
│   └── Crear pruebas unitarias del algoritmo de asesoría.
└── Commits recomendados:
    ├── feat(advisor): implementar algoritmo de salud financiera basado en regla 50/30/20
    ├── feat(advisor): agregar tarjetas de diagnostico semaforico y recomendaciones contextuales
    └── test(advisor): suite de pruebas unitarias para evaluacion de Score y umbrales de riesgo

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
