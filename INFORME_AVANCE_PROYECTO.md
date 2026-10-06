# INFORME DE AVANCE DEL PROYECTO FINAL

**PROYECTO:**  
**SALVIA FINANZAS: SISTEMA MÓVIL GAMIFICADO PARA LA GESTIÓN DE FINANZAS PERSONALES, FOMENTO DE HÁBITOS DE AHORRO Y ASESORÍA FINANCIERA INTELIGENTE EN ESTUDIANTES UNIVERSITARIOS Y JÓVENES PROFESIONALES**

---

### **DATOS GENERALES DEL PROYECTO**
- **Institución:** Nivel Superior Universitario
- **Curso:** Proyecto Final / Taller de Proyectos de Software
- **Equipo de Trabajo (Integrantes):**
  1. **Valentino Martin Marca Quedena**
  2. **Flores Calderón, Eduardo José**
  3. **Astrid Milenka Coveñas Ipanaque**
  4. **Diani Abad Guerrero**
- **Repositorio Oficial:** [https://github.com/valentino0331/SalviaFinanzas.git](https://github.com/valentino0331/SalviaFinanzas.git)
- **Versión del Informe:** Avance 1.0
- **Año:** 2026

---

## CONFIGURACIÓN DE FORMATO Y ESTILO (NORMATIVA ACADÉMICA)
El presente informe ha sido estructurado considerando las directrices formales de presentación académica y estándares de la institución:
- **Margen Superior:** 2.5 cm
- **Margen Inferior:** 3.0 cm
- **Margen Derecho:** 2.5 cm
- **Margen Izquierdo:** 3.0 cm
- **Interlineado:** 1.5 líneas / Estilo APA 7ma Edición
- **Tipografía:** Arial / Times New Roman 12 pt (Títulos en negrita y jerarquía formal)

---

# CAPÍTULO I: DESCRIPCIÓN DE LA SITUACIÓN PROBLEMA DEL PROYECTO

### 1.1. Contexto y Realidad Problemática
En la actualidad, la educación e inclusión financiera constituyen uno de los desafíos socioeconómicos más críticos en América Latina, con una repercusión particularmente acentuada en el Perú. Según reportes de la Superintendencia de Banca, Seguros y Administradoras Privadas de Fondos de Pensiones (SBS, 2023) y el Banco Central de Reserva del Perú (BCRP, 2024), más del 65% de la población joven económicamente activa y en etapa formativa carece de conocimientos financieros básicos para la elaboración de presupuestos, diversificación del ahorro y control del sobreendeudamiento.

Los jóvenes universitarios y los recién egresados se encuentran inmersos en una etapa de transición hacia la independencia económica. Durante esta fase, deben administrar presupuestos limitados compuestos por mesadas familiares, ingresos provenientes de prácticas preprofesionales, empleos de tiempo parcial o emprendimientos juveniles. Sin embargo, este grupo demográfico enfrenta un entorno hiperestimulado por el consumo digital impulsado por el comercio electrónico, las billeteras digitales (como Yape y Plin) y los servicios de suscripción en línea, lo que fomenta el fenómeno de los "gastos hormiga" (compras diarias imperceptibles como café, snacks, delivery, transporte por aplicativo o microtransacciones de entretenimiento). Estos desembolsos, aunque individualmente pequeños, llegan a erosionar entre el 20% y el 35% de los ingresos mensuales disponibles de un estudiante.

A este escenario se suma la ineficacia de los mecanismos convencionales de control de gastos. Las herramientas analógicas (anotaciones en libretas, cuadernos de cuentas) o las hojas de cálculo tradicionales (Microsoft Excel, Google Sheets) presentan barreras de usabilidad significativas:
1. **Alta fricción operativa:** Requieren un ingreso manual tedioso y continuo de cada transacción, lo que ocasiona que más del 70% de los usuarios abandonen el registro antes de completar dos semanas de uso.
2. **Ausencia de retroalimentación en tiempo real:** No brindan diagnósticos automáticos ni alertas tempranas que adviertan al usuario sobre desvíos presupuestarios o patrones de consumo perjudiciales.
3. **Falta de incentivos conductuales:** Carecen de dinámicas de motivación intrínseca o extrínseca que refuercen la constancia y la disciplina de ahorro.

Por otra parte, las aplicaciones móviles de finanzas existentes en el mercado global suelen estar dirigidas a perfiles adultos consolidados con flujos de ingresos estables y carteras de inversión complejas (como fondos mutuos o hipotecas), resultando saturadas de interfaces burocráticas y ajenas a las necesidades prioritarias del estudiante universitario (tales como el pago oportuno de pensiones educativas, compra de materiales académicos, membresías de bienestar físico o creación de su primer fondo de emergencia).

En este marco, surge **Salvia Finanzas**, una plataforma móvil multiplataforma desarrollada bajo un enfoque de **gamificación aplicada y acompañamiento algorítmico inteligente**, diseñada con una identidad visual cálida y rústica que busca desestigmatizar la ansiedad financiera y transformar la gestión monetaria en una experiencia pedagógica, accesible, interactiva y de reforzamiento positivo de hábitos diarios.

### 1.2. Planteamiento del Problema
A partir del diagnóstico de la realidad problemática, se formula la interrogante central y las preguntas específicas de investigación e ingeniería:

#### 1.2.1. Pregunta General
¿De qué manera el desarrollo e implementación de una aplicación móvil gamificada con arquitectura modular y asesoramiento algorítmico inteligente (**Salvia Finanzas**) influye en la capacidad de control presupuestario y en la adopción de hábitos de ahorro sistemáticos en jóvenes universitarios y recién egresados?

#### 1.2.2. Preguntas Específicas
1. ¿Cómo diseñar una arquitectura de software desacoplada, reactiva y escalable en Flutter y backend en Node.js/PostgreSQL que permita registrar y categorizar transacciones financieras en tiempo real con mínima fricción para el usuario?
2. ¿Qué mecánicas de gamificación (misiones de ahorro, retos diarios, acumulación de experiencia y rachas de cumplimiento) resultan efectivas para reducir la tasa de abandono en el seguimiento de finanzas personales?
3. ¿Cómo estructurar un algoritmo de diagnóstico y salud financiera (*Financial Advisor Engine*) capaz de computar un puntaje objetivo (*Score*) de 0 a 100, emitir semáforos de riesgo y proveer recomendaciones personalizadas basadas en el comportamiento de consumo del usuario?
4. ¿Cuál es el nivel de viabilidad técnica, operativa y económica para el despliegue del sistema en infraestructuras cloud serverless seguras y accesibles?

---

# CAPÍTULO II: ANTECEDENTES Y BASES TEÓRICAS

## 2.1.- Antecedentes

### 2.1.1.- Antecedentes Internacionales
- **Rodríguez y Morales (2022, España):** En su investigación titulada *"Gamificación aplicada al bienestar financiero de la Generación Z en aplicaciones móviles"*, publicada en la Universidad Politécnica de Madrid, evaluaron el impacto del uso de mecánicas de ludificación (barras de progreso, avatares e insignias) en 240 jóvenes usuarios. Concluyeron que la incorporación de retos a corto plazo y refuerzo positivo incrementó la retención de los usuarios en un 42% y mejoró la tasa de ahorro voluntario en un 18% en comparación con aplicaciones analíticas convencionales. Este estudio sustenta la arquitectura de misiones y rachas adoptada en **Salvia Finanzas**.
- **Chen, Huang y Kumar (2021, EE.UU. / Singapur):** En el estudio *"Algorithmic Financial Coaching: Assessing Nudge Theory in Personal Budgeting Apps"*, publicado en el *Journal of Financial Behavioral Science*, analizaron cómo los micro-consejos automatizados y las alertas de semáforo conductual basados en la "Teoría del Empujón" (*Nudge Theory*) alteraron el comportamiento de consumo impulsivo en usuarios de 18 a 25 años. Demostraron que una retroalimentación visual clara (estado Crítico, Moderado, Excelente) reduce en un 27% los gastos superfluos en rubros de ocio y comida rápida. Este aporte fundamenta el módulo `FinancialAdvisorScreen` implementado en nuestra solución.
- **Vargas y Zapata (2023, Colombia):** En su trabajo de grado *"Desarrollo de un sistema móvil reactivo multiplataforma para el fomento de la cultura del ahorro en estudiantes de educación superior"*, Universidad de los Andes, evidenciaron que el uso de tecnologías híbridas como Flutter complementadas con gestores de estado inmutables (Riverpod) redujo el consumo de batería y mejoró la latencia de respuesta frente a interfaces web embebidas, facilitando la adopción continua del sistema en dispositivos de gama media y baja.

### 2.1.2.- Antecedentes Nacionales
- **Mendoza y Ticona (2023, Perú - PUCP):** En la tesis de pregrado titulada *"Aplicación móvil basada en micro-hábitos para la mejora de la administración financiera en jóvenes trabajadores de Lima Metropolitana"*, Pontificia Universidad Católica del Perú, se identificó que el 74% de los jóvenes encuestados reconoce tener problemas para identificar sus gastos hormiga debido a la inmediatez de los pagos digitales (Yape/Plin). La investigación demostró que los usuarios que interactuaron con una aplicación que premiaba el cumplimiento de hábitos diarios de bajo esfuerzo (ej. "Comer en casa", "Registrar gasto del día") incrementaron su saldo disponible a fin de mes en un 15.4%.
- **Superintendencia de Banca, Seguros y AFP (SBS, 2023 - Perú):** En la *"Encuesta Nacional de Capacidades Financieras en el Perú"*, se determinó que solo el 28% de la población peruana cuenta con un nivel adecuado de educación financiera, siendo los jóvenes entre 18 y 24 años el segmento más vulnerable frente al estrés financiero y con menor tenencia de fondos de emergencia estructurados. El informe enfatiza la necesidad imperativa de desarrollar herramientas pedagógicas accesibles que democraticen el acceso al presupuesto personal.
- **Quispe y Alarcón (2024, Perú - UNMSM):** En el trabajo de investigación *"Arquitecturas Cloud Serverless y Bases de Datos PostgreSQL para el soporte de microservicios transaccionales en Fintechs peruanas"*, concluyeron que la adopción de esquemas relacionales normalizados con control de concurrencia e indexación adecuada garantiza una reducción del 60% en costos de infraestructura para proyectos en fase de incubación y despliegue rápido.

### 2.1.3.- Antecedentes Locales
- **Estudio de Consumo Universitario en Lima Metropolitana (2023):** Investigaciones aplicadas en universidades públicas y privadas de Lima (UNI, San Marcos, UTP, UPC) revelan que el presupuesto promedio mensual de un estudiante universitario oscila entre los S/ 400.00 y S/ 1,500.00 soles (dependiendo de si cubre pensión académica, viáticos o materiales). De este monto, más del 55% se distribuye entre alimentación fuera del hogar, transporte público y fotocopias/licencias de software, siendo recurrentes los momentos de insolvencia durante las semanas de exámenes parciales y finales.
- **Iniciativas Locales de Bancarización Juvenil:** A nivel distrital y regional, la masificación de los pagos QR ha eliminado el uso de efectivo, lo cual reduce la conciencia del gasto real ("dolor de pagar"). Las iniciativas locales carecen de módulos pedagógicos complementarios que ayuden a los jóvenes de distritos limeños a monitorear cuánto de su dinero digital se destina a compras no esenciales.

---

## 2.2.- Bases Teóricas

### 2.2.1. Finanzas Personales y Salud Financiera
- **Presupuesto y la Regla 50/30/20 (Elizabeth Warren):** Marco conceptual que postula la asignación porcentual de los ingresos netos en tres categorías cardinales: 50% para Necesidades Básicas (alimentación, vivienda, transporte, pensión de estudios), 30% para Deseos / Ocio (salidas, entretenimiento, compras no indispensables) y 20% para Ahorro o amortización de deudas. Salvia Finanzas incorpora esta métrica dentro del cálculo del asesor financiero.
- **Puntaje de Salud Financiera (*Financial Health Score*):** Métrica cuantitativa (escala de 0 a 100) que sintetiza la capacidad de un individuo para cumplir obligaciones de corto plazo, absorber contingencias imprevistas (fondo de emergencia) y mantener una relación gastos/ingresos menor o igual al 80%.

### 2.2.2. Teoría de la Gamificación y Economía Conductual
- **Marco de Trabajo Octalysis (Yu-kai Chou, 2015):** Modelo que desglosa la motivación humana en 8 motores nucleares (*Core Drives*). Salvia Finanzas aplica:
  - *Desarrollo y Realización (Puntos y niveles):* Acumulación de puntos por registrar transacciones y cumplir metas.
  - *Influencia Social y Afinidad (Tabla de Clasificación / Leaderboard):* Comparación positiva en comunidad para fomentar el hábito.
  - *Evitación y Pérdida (Rachas / Streaks):* Deseo de no interrumpir la secuencia continua de días con hábitos cumplidos.
- **El Bucle del Hábito (Charles Duhigg & James Clear):** Estructura compuesta por Señal (recordatorio de gasto), Rutina (ingreso de la transacción en menos de 10 segundos) y Recompensa (animación visual, puntos y actualización del estado de salud financiera).

### 2.2.3. Arquitectura de Software y Tecnologías de Implementación
- **Arquitectura Limpia (*Clean Architecture*) y Principios SOLID:** Separación estricta entre la capa de presentación, capa de dominio (casos de uso, entidades) y capa de infraestructura (servicios HTTP, persistencia local). Garantiza que la lógica del negocio permanezca desacoplada del framework visual.
- **Framework Móvil Flutter y Lenguaje Dart:** Tecnología de código abierto de Google para la compilación nativa multiplataforma (Android, iOS, Web). Utiliza un motor de renderizado directo por widgets (*Impeller/Skia*), permitiendo interfaces fluidas a 60 fps y un diseño visual coherente.
- **Patrón de Gestión de Estado Riverpod:** Sistema reactivo y seguro en tiempo de compilación para la gestión de estados globales, eliminación de memory leaks y pruebas unitarias aisladas sin dependencia del árbol de widgets (`ProviderScope`, `ConsumerWidget`).
- **Backend RESTful con Node.js y Express:** Entorno de ejecución asíncrono no bloqueante basado en eventos, óptimo para operaciones intensivas de E/S y distribución de servicios web livianos con formato JSON.
- **PostgreSQL y Modelo Relacional Híbrido:** Motor de base de datos relacional robusto con cumplimiento ACID (Atomicidad, Consistencia, Aislamiento y Durabilidad). La arquitectura del proyecto integra soporte para PostgreSQL en la nube (Neon Cloud Serverless) con mecanismos de contingencia en memoria (*Mock DB*) para pruebas automatizadas y desarrollo sin conexión.

---

# CAPÍTULO III: OBJETIVOS Y JUSTIFICACIÓN

## 3.1.- Objetivo General
Desarrollar e implementar un sistema de software móvil multiplataforma gamificado (**Salvia Finanzas**), basado en el framework Flutter y una arquitectura de servicios backend en Node.js con base de datos relacional PostgreSQL, que permita la administración integral de ingresos y egresos, el establecimiento de misiones de ahorro cuantificables, la consolidación de micro-hábitos de consumo responsable y la provisión de diagnósticos automáticos de salud financiera orientados a jóvenes universitarios y profesionales.

## 3.2.- Objetivos Específicos
1. **OE1:** Diseñar una interfaz de usuario (*UI/UX*) intuitiva, empática y de estilo visual rústico-orgánico que minimice la carga cognitiva y el estrés financiero, permitiendo registrar transacciones en menos de tres interacciones en pantalla.
2. **OE2:** Construir el módulo transaccional para el registro, edición, categorización (Comida, Universidad, Transporte, Gym, Ocio, etc.) y visualización estadística de gastos mensuales mediante gráficos analíticos interactivos (`fl_chart`).
3. **OE3:** Desarrollar el módulo de **Misiones de Ahorro**, permitiendo a los usuarios definir metas financieras con montos objetivos, fechas límite (*deadlines*), cálculo dinámico de porcentajes de progreso y asignación visual de fondos.
4. **OE4:** Implementar el motor de **Gamificación y Hábitos**, incorporando mecánicas de misiones diarias, seguimiento de rachas consecutivas (*streaks*), recompensas en puntos de experiencia (*XP*) y una tabla de clasificación comunitaria (*Leaderboard*).
5. **OE5:** Diseñar e integrar un **Asesor Financiero Algorítmico (*Financial Advisor Engine*)** capaz de calcular el *Score* de salud financiera del usuario en una escala de 0 a 100, emitir diagnósticos categóricos (Crítico, Moderado, Excelente) y generar recomendaciones personalizadas basadas en el porcentaje de consumo de los últimos 30 días.
6. **OE6:** Implementar mecanismos de seguridad, persistencia de datos (PostgreSQL en Neon Cloud / SharedPreferences) y autenticación centralizada mediante tokens de identidad (Google OAuth 2.0 / JWT).
7. **OE7:** Validar la estabilidad, usabilidad y rendimiento del sistema mediante pruebas unitarias, pruebas de integración y evaluación de satisfacción con usuarios finales.

## 3.3.- Justificación

### 3.3.1. Justificación Teórica
La investigación y desarrollo de este proyecto se fundamenta en la convergencia de la economía conductual, la teoría de la autodeterminación y la ingeniería de software moderna. Permite contrastar experimentalmente cómo los estímulos de la gamificación y la retroalimentación inmediata (*feedback loop*) alteran la relación psicológica del individuo con el dinero, transformando conceptos financieros abstractos (presupuesto base, tasas de ahorro) en acciones prácticas y medibles del día a día.

### 3.3.2. Justificación Práctica
En el plano empírico, **Salvia Finanzas** resuelve de manera directa la necesidad insatisfecha de miles de estudiantes de educación superior que buscan tener el control de su economía sin verse abrumados por aplicaciones bancarias complejas o formatos de cálculo inaccesibles. La aplicación provee una herramienta de bolsillo que alerta oportunamente sobre sobregiros, asiste en la cobertura de pagos educativos vitales y premia el esfuerzo personal con una experiencia de usuario gratificante.

### 3.3.3. Justificación Social y Económica
A nivel social, la plataforma promueve la inclusión y madurez financiera temprana en los jóvenes, mitigando los riesgos de sobreendeudamiento informal o dependencia crediticia perjudicial al inicio de la vida laboral. Fomentar una cultura de ahorro sistemático desde la universidad contribuye a la formación de ciudadanos con mayor resiliencia económica y bienestar socioemocional.

### 3.3.4. Justificación Tecnológica / Metodológica
El proyecto demuestra la viabilidad de utilizar tecnologías de vanguardia de código abierto y alta productividad: Flutter con Riverpod en el cliente y Node.js con PostgreSQL Serverless en la nube. Establece un patrón arquitectónico limpio, desacoplado y replicable para el desarrollo ágil de aplicaciones móviles de impacto social en el ámbito universitario.

---

# CAPÍTULO IV: PLANIFICACIÓN DEL PROYECTO

## 4.1.- Cronograma de Actividades (Diagrama de Gantt)
El proyecto se desarrolla bajo el marco metodológico ágil **Scrum**, distribuido en un periodo de **16 semanas académicas** agrupadas en 5 fases estructurales:
- **Fase 1:** Análisis y Especificación de Requisitos (Semanas 1 - 3)
- **Fase 2:** Diseño de Arquitectura, Modelado de Datos y Prototipado UI/UX (Semanas 4 - 6)
- **Fase 3:** Desarrollo e Implementación del Sistema - Sprints Core (Semanas 7 - 12)
- **Fase 4:** Pruebas, Control de Calidad (QA) y Seguridad (Semanas 13 - 14)
- **Fase 5:** Despliegue, Validación con Usuarios y Entrega Final (Semanas 15 - 16)

### Matriz del Cronograma de Actividades
| ID | Actividad / Tarea Principal | Responsable | Semanas (1 - 16) | Entregable Clave |
| :--- | :--- | :--- | :---: | :--- |
| **F1.1** | Levantamiento de necesidades y encuestas a universitarios | Diani Abad | Sem 1 - 2 | Informe de requerimientos |
| **F1.2** | Definición de historias de usuario y criterios de aceptación | Astrid Coveñas | Sem 2 - 3 | Backlog priorizado |
| **F2.1** | Diseño de la identidad rústica y prototipado UI en Figma | Valentino Marca | Sem 4 - 5 | Wireframes y Design System |
| **F2.2** | Modelado de base de datos relacional y diseño de la API | Eduardo Flores | Sem 5 - 6 | Script `db.sql` y diagramas ER |
| **F2.3** | Configuración del repositorio y pipeline de CI/CD | Valentino Marca | Sem 6 | Repositorio GitHub configurado |
| **F3.1** | Implementación del módulo de autenticación (Google OAuth/JWT) | Eduardo Flores | Sem 7 - 8 | Endpoint `/api/auth/google` |
| **F3.2** | Implementación del módulo de Gastos y Dashboard (`fl_chart`) | Valentino Marca | Sem 8 - 9 | Módulo `expenses` funcional |
| **F3.3** | Desarrollo del módulo de Misiones de Ahorro y Metas | Astrid Coveñas | Sem 9 - 10 | Módulo `savings` funcional |
| **F3.4** | Construcción del motor de Hábitos diarios y Rachas | Diani Abad | Sem 10 - 11 | Módulo `habits` y streaks |
| **F3.5** | Implementación del Asesor Financiero (*Score* y Tips) | Valentino Marca | Sem 11 - 12 | Algoritmo `/api/financial-advisor` |
| **F4.1** | Pruebas unitarias de widgets e integración en Flutter | Eduardo Flores | Sem 13 | Suite de pruebas automatizadas |
| **F4.2** | Pruebas de estrés de API y auditoría de seguridad backend | Valentino Marca | Sem 13 - 14 | Reporte de QA y mitigación de fallos |
| **F4.3** | Simplificación y optimización de código | Todo el equipo | Sem 14 | Código refactorizado y limpio |
| **F5.1** | Despliegue del Backend en la nube (Render / Neon PostgreSQL) | Eduardo Flores | Sem 15 | Servidor de producción activo |
| **F5.2** | Pruebas de usabilidad piloto con grupo focal de estudiantes | Astrid / Diani | Sem 15 - 16 | Matriz de feedback y métricas |
| **F5.3** | Redacción del informe final y preparación de sustentación | Todo el equipo | Sem 16 | Documento final y APK compilado |

---

### Representación del Diagrama de Gantt
```text
Semanas:                 1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16
───────────────────────────────────────────────────────────────────────────────────────
[Fase 1: Requisitos]
Levantamiento necesidades  [██████]
Historias de usuario           [██████]

[Fase 2: Diseño & Arq.]
Prototipado UI/UX                 [██████]
Modelado BD & API                     [██████]
Configuración Git/Infra                   [███]

[Fase 3: Desarrollo Core]
Auth & Middleware                             [██████]
Gastos & Dashboard                                [██████]
Misiones de Ahorro                                    [██████]
Hábitos & Gamificación                                    [██████]
Asesor Financiero                                             [██████]

[Fase 4: QA & Seguridad]
Pruebas Unitarias/Widgets                                         [███]
Auditoría API & Carga                                                 [██████]
Code Simplification                                                       [███]

[Fase 5: Despliegue]
Despliegue Cloud (Neon/API)                                                   [███]
Piloto con Universitarios                                                         [██████]
Informe Final & Cierre                                                                [███]
───────────────────────────────────────────────────────────────────────────────────────
```

---

## 4.2.- Presupuesto del Proyecto
El presupuesto se ha elaborado considerando los estándares de costeo para proyectos de software, categorizado en: Recursos Humanos, Infraestructura de Hardware, Software / Licencias / Servicios Cloud, y Gastos Operativos. Los valores están expresados en Soles Peruanos (S/) e incluyen su equivalente estimado en Dólares Estadounidenses (USD).

### 4.2.1. Recursos Humanos (Equipo de Ingeniería y Desarrollo)
*Nota: Para fines académicos, se calculan los honorarios basados en una dedicación de 10 horas semanales por integrante durante 4 meses (16 semanas).*

| Rol / Cargo | Integrante Asignado | Horas Totales | Costo por Hora (S/) | Subtotal (S/) | Subtotal (USD) |
| :--- | :--- | :---: | :---: | :---: | :---: |
| Líder de Proyecto & Fullstack Mobile Dev | Valentino Martin Marca Quedena | 160 hrs | S/ 25.00 | S/ 4,000.00 | $ 1,081.08 |
| Backend & Cloud Database Engineer | Flores Calderón, Eduardo José | 160 hrs | S/ 22.00 | S/ 3,520.00 | $ 951.35 |
| Frontend Flutter & QA Specialist | Astrid Milenka Coveñas Ipanaque | 160 hrs | S/ 20.00 | S/ 3,200.00 | $ 864.86 |
| UX Researcher & Product Documentation | Diani Abad Guerrero | 160 hrs | S/ 20.00 | S/ 3,200.00 | $ 864.86 |
| **TOTAL RECURSOS HUMANOS** | | **640 hrs** | | **S/ 13,920.00** | **$ 3,762.15** |

### 4.2.2. Recursos de Hardware y Equipamiento
| Ítem / Descripción | Cantidad | Especificaciones Técnicas | Costo Unitario (S/) | Subtotal (S/) | Subtotal (USD) |
| :--- | :---: | :--- | :---: | :---: | :---: |
| Laptops para Desarrollo | 4 unid. | Core i7/Ryzen 7, 16GB RAM, SSD 512GB (Depreciación 4 meses) | S/ 350.00 | S/ 1,400.00 | $ 378.38 |
| Dispositivos Móviles de Prueba | 2 unid. | Android 13/14, 6GB RAM (Test físico en vivo) | S/ 150.00 | S/ 300.00 | $ 81.08 |
| **TOTAL HARDWARE** | | | | **S/ 1,700.00** | **$ 459.46** |

### 4.2.3. Software, Licencias y Servicios Cloud
| Servicio / Herramienta | Proveedor / Tipo | Duración | Costo Mensual (S/) | Subtotal (S/) | Subtotal (USD) |
| :--- | :--- | :---: | :---: | :---: | :---: |
| Base de Datos PostgreSQL Serverless | Neon Tech (Cloud Database Tier) | 4 meses | S/ 0.00 (Free Dev Tier) | S/ 0.00 | $ 0.00 |
| Hosting de API Backend | Render / Railway (Starter Container) | 4 meses | S/ 26.00 ($ 7/mes) | S/ 104.00 | $ 28.00 |
| Cuenta de Desarrollador Google Play | Google Play Console (Pago único) | Vitalicio | S/ 95.00 ($ 25.00) | S/ 95.00 | $ 25.00 |
| Herramientas de Diseño y Prototipado | Figma for Education | 4 meses | S/ 0.00 (Licencia académica) | S/ 0.00 | $ 0.00 |
| Entorno de Desarrollo (VS Code, Git) | Open Source / GitHub Student Pack | 4 meses | S/ 0.00 | S/ 0.00 | $ 0.00 |
| **TOTAL SOFTWARE Y SERVICIOS** | | | | **S/ 199.00** | **$ 53.00** |

### 4.2.4. Gastos Operativos y Servicios Generales
| Rubro | Justificación | Periodo | Monto Mensual (S/) | Subtotal (S/) | Subtotal (USD) |
| :--- | :--- | :---: | :---: | :---: | :---: |
| Servicio de Internet de Alta Velocidad | Conectividad para videollamadas, repositorios y sync | 4 meses | S/ 120.00 | S/ 480.00 | $ 129.73 |
| Energía Eléctrica para Estaciones de Trabajo | Consumo de equipos de cómputo en sesiones de desarrollo | 4 meses | S/ 80.00 | S/ 320.00 | $ 86.49 |
| Materiales de Oficina y Documentación | Papelería, impresión de borradores e informes de prueba | - | Monto fijo | S/ 150.00 | $ 40.54 |
| **TOTAL GASTOS OPERATIVOS** | | | | **S/ 950.00** | **$ 256.76** |

---

### 4.2.5. Resumen General Consolidado del Presupuesto
| Categoría Presupuestaria | Monto en Soles (S/) | Monto en Dólares (USD) | Porcentaje (%) |
| :--- | :---: | :---: | :---: |
| 1. Recursos Humanos (Mano de Obra) | S/ 13,920.00 | $ 3,762.15 | 83.01% |
| 2. Recursos de Hardware (Depreciación de equipos) | S/ 1,700.00 | $ 459.46 | 10.14% |
| 3. Software, Licencias y Servicios Cloud | S/ 199.00 | $ 53.00 | 1.19% |
| 4. Gastos Operativos y Conectividad | S/ 950.00 | $ 256.76 | 5.66% |
| **SUBTOTAL** | **S/ 16,769.00** | **$ 4,531.37** | **100.00%** |
| **Reserva para Contingencias (5%)** | **S/ 838.45** | **$ 226.57** | - |
| **PRESUPUESTO TOTAL GENERAL** | **S/ 17,607.45** | **$ 4,757.94** | - |

*(Tipo de cambio referencial estimado: 1 USD = 3.70 PEN)*

---

## REFERENCIAS BIBLIOGRÁFICAS
- Banco Central de Reserva del Perú (BCRP). (2024). *Reporte de Inclusión Financiera y Métodos de Pago Digital en Jóvenes Peruanos*. Lima: BCRP.
- Chen, L., Huang, S., & Kumar, P. (2021). Algorithmic Financial Coaching: Assessing Nudge Theory in Personal Budgeting Apps. *Journal of Financial Behavioral Science*, 14(2), 89–104.
- Chou, Y. K. (2015). *Actionable Gamification: Beyond Points, Badges, and Leaderboards*. Octalysis Media.
- Clear, J. (2018). *Atomic Habits: An Easy & Proven Way to Build Good Habits & Break Bad Ones*. Avery.
- Mendoza, C., & Ticona, R. (2023). *Aplicación móvil basada en micro-hábitos para la mejora de la administración financiera en jóvenes trabajadores de Lima Metropolitana* [Tesis de pregrado, Pontificia Universidad Católica del Perú]. Repositorio Institucional PUCP.
- Rodríguez, A., & Morales, F. (2022). Gamificación aplicada al bienestar financiero de la Generación Z en aplicaciones móviles. *Revista Iberoamericana de Informática Educativa y Multimedia*, 18(1), 45–59.
- Superintendencia de Banca, Seguros y Administradoras Privadas de Fondos de Pensiones (SBS). (2023). *Encuesta Nacional de Capacidades Financieras en el Perú*. Lima: SBS.
- Vargas, D., & Zapata, M. (2023). *Desarrollo de un sistema móvil reactivo multiplataforma para el fomento de la cultura del ahorro en estudiantes de educación superior* [Trabajo de grado, Universidad de los Andes].
