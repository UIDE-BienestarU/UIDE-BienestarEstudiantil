# Sistema de Bienestar Estudiantil UIDE

Sistema integral de gestión de bienestar estudiantil que permite a los estudiantes de la UIDE solicitar becas, consultar el estado de sus solicitudes y recibir atención personalizada, optimizando los procesos administrativos del departamento de bienestar.

## Integrantes

- **Mateo Castillo** - Backend - @mateocp10
- **Christian Salinas** - Backend - @ChrisSR247
- **Juan Esteban Fuentes** - Fronted - @juanestebanf
- **Victor Montaño** - Fronted - @Victor12-ui
- **Vriginia Mora ** - Fronted - @ginia18

## Enlaces a GitHub Projects

- https://github.com/UIDE-BienestarU/UIDE-BienestarEstudiantil.git

## Descripción General

Este sistema permite:

- Registro e inicio de sesión para estudiantes y personal administrativo.  
- Envío de solicitudes de becas con datos y documentos adjuntos.  
- Seguimiento del estado de cada solicitud.  
- Panel administrativo para revisión, aprobación o rechazo.  
- Historial y trazabilidad de cambios por solicitud.

El objetivo principal es **digitalizar y centralizar** el proceso de gestión de solicitudes de Bienestar Estudiantil en la UIDE.

---

## Definition of Ready (DoR)

Una Historia de Usuario se considera lista cuando:

- Tiene criterios de aceptación en formato **Gherkin**.  
- Está estimada en **Story Points**.  
- Cuenta con prioridad (must / should / could / won’t).  
- No tiene dependencias bloqueantes.  
- Incluye mockups o diseños si aplica.  
- El equipo entiende claramente qué se debe implementar.

---

## Definition of Done (DoD)

Una Historia de Usuario está terminada cuando:

- El código funciona correctamente.  
- Tests unitarios/integración pasan (coverage > **80%**).  
- Documentación técnica actualizada (README, API Docs).  
- Todos los criterios de aceptación se cumplen.  
- No existen bugs críticos.  
- Commits asociados al issue correspondiente.  
- Estado actualizado en GitHub Projects.

---

## Capacidad del Equipo

- **Integrantes:** 5 personas  
- **Disponibilidad:** 12 horas por persona  
- **Velocidad estimada:** 3.5 SP por persona  
- **Capacidad total por sprint:** **17.5 Story Points**  
- **Duración del sprint:** 2 semanas  

---

## Convenciones del Proyecto

- Uso de GitFlow básico:
  - `main` → versión estable  
  - `develop` → desarrollo continuo  
  - `feature/` → nuevas funcionalidades  
  - `fix/` → correcciones  
- Convención de commits:
  - `feat: descripción`
  - `fix: descripción`
  - `docs: descripción`
  - `refactor: descripción`

---

## Instalación
```bash
# Clonar repositorio
git clone https://github.com/UIDE-BienestarU/UIDE-BienestarEstudiantil
cd bienestar-estudiantil-uide

# Instalar dependencias de Flutter
flutter pub get

# Verificar instalación de Flutter
flutter doctor

# Ejecutar en modo desarrollo
flutter run

# Ejecutar tests
flutter test
```
