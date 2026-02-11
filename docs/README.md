# Sistema de Bienestar Universitario UIDE

Sistema de gestión de bienestar estudiantil que permite a los estudiantes de la UIDE solicitar becas, consultar el estado de sus solicitudes y recibir atención personalizada, optimizando los procesos administrativos del departamento de bienestar.

## Integrantes

| Nombre              | Rol      | GitHub                                    |
|---------------------|----------|-------------------------------------------|
| Mateo Castillo      | Backend  | [@mateocp10](https://github.com/mateocp10)      |
| Christian Salinas   | Backend  | [@ChrisSR247](https://github.com/ChrisSR247)    |
| Juan Esteban Fuentes| Frontend | [@juanestebanf](https://github.com/juanestebanf) |
| Victor Montaño      | Frontend | [@Victor12-ui](https://github.com/Victor12-ui)  |
| Virginia Mora       | Frontend | [@ginia18](https://github.com/ginia18)          |

## 🔗 Enlaces a GitHub Projects

- https://github.com/UIDE-BienestarU/UIDE-BienestarEstudiantil.git

## Descripción General

Este sistema permite:

- Registro e inicio de sesión para estudiantes y personal administrativo
- Envío de solicitudes de becas con datos y documentos adjuntos
- Seguimiento del estado de cada solicitud
- Panel administrativo para revisión, aprobación o rechazo
- Historial y trazabilidad de cambios por solicitud
- Envío de sugerencias al departamento de Bienestar
- Gestión de objetos perdidos con comentarios y reclamos
- Guardado de borradores de solicitudes
- Notificaciones en tiempo real y push
- Publicación de avisos institucionales y estadísticas

El objetivo principal es digitalizar y centralizar el proceso de gestión de solicitudes de Bienestar Estudiantil en la UIDE.

## Requerimientos Funcionales

### RF-01: 
Inicio de sesión de estudiantes con correo y contraseña.

### RF-02: 
Envío de solicitudes con título, asunto y documentos.

### RF-03: 
Consulta del estado de solicitudes.

### RF-04: 
Gestión administrativa de solicitudes (aprobar, rechazar o derivar).

### RF-05: 
Notificaciones por cambios en solicitudes.

### RF-06: 
Filtros y visualización de solicitudes.

### RF-07: 
Historial de acciones por solicitud.

### -08: 
Publicación de avisos institucionales.

### -09: 
Visualización de contactos de bienestar.

### RF-10: 
Avisos resumidos para estudiantes.

### RF-11: 
Estadísticas administrativas de solicitudes.

### -12: 
Publicación de objetos perdidos con imágenes.

### RF-13: 
Filtros administrativos por estado y tipo.

### -14: 
Envío de sugerencias al departamento de bienestar.

### RF-15: 
Comentarios y reclamos en objetos perdidos.

### RF-16: 
Guardado de solicitudes como borrador.

### RF-17: 
Registro de dispositivos para notificaciones push.

## Requerimientos No Funcionales

### RNF-01: Rendimiento
La aplicación deberá responder en un tiempo menor a 2 segundos al cargar las solicitudes del usuario.

### RNF-02: Seguridad
La aplicación deberá proteger los documentos mediante almacenamiento seguro y uso de HTTPS.

### RNF-03: Compatibilidad
La aplicación deberá ser compatible con dispositivos Android a partir de la versión 8.0.

### RNF-04: Usabilidad
La interfaz deberá ser clara, usable y permitir completar una solicitud en menos de 5 minutos.

### RNF-05: Tiempo Real
El sistema debe soportar comunicación en tiempo real para funcionalidades como comentarios en objetos perdidos mediante Socket.IO.

## Definition of Ready (DoR)

Una Historia de Usuario se considera lista cuando:

- Tiene criterios de aceptación en formato Gherkin
- Está estimada en Story Points
- Cuenta con prioridad (must / should / could / won't)
- No tiene dependencias bloqueantes
- Incluye mockups o diseños si aplica
- El equipo entiende claramente qué se debe implementar

## Definition of Done (DoD)

Una Historia de Usuario está terminada cuando:

- El código funciona correctamente
- Tests unitarios/integración pasan (coverage > 80%)
- Documentación técnica actualizada (README, API Docs)
- Todos los criterios de aceptación se cumplen
- No existen bugs críticos
- Commits asociados al issue correspondiente
- Estado actualizado en GitHub Projects

## Capacidad del Equipo

- **Integrantes**: 5 personas
- **Disponibilidad**: 12 horas por persona
- **Velocidad estimada**: 3.5 SP por persona
- **Capacidad total por sprint**: 17.5 Story Points
- **Duración del sprint**: 2 semanas

### Uso de GitFlow básico:

- `main` → versión estable
- `develop` → desarrollo continuo
- `feature/` → nuevas funcionalidades
- `fix/` → correcciones

### Convención de commits:

- `feat:` descripción
- `fix:` descripción
- `docs:` descripción
- `refactor:` descripción

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
