# Sistema de Bienestar Universitario UIDE

Sistema de gestión de bienestar estudiantil que permite a los estudiantes de la UIDE solicitar becas, consultar el estado de sus solicitudes y recibir atención personalizada, optimizando los procesos administrativos del departamento de bienestar.

## Integrantes

| Nombre | Rol | GitHub |
|--------|-----|--------|
| Mateo Castillo | Backend | [@mateocp10](https://github.com/mateocp10) |
| Christian Salinas | Backend | [@ChrisSR247](https://github.com/ChrisSR247) |
| Juan Esteban Fuentes | Frontend | [@juanestebanf](https://github.com/juanestebanf) |
| Victor Montaño | Frontend | [@Victor12-ui](https://github.com/Victor12-ui) |
| Virginia Mora | Frontend | [@ginia18](https://github.com/ginia18) |

## 🔗 Enlaces a GitHub Projects

* https://github.com/UIDE-BienestarU/UIDE-BienestarEstudiantil.git

## Descripción General

Este sistema permite:

* Registro e inicio de sesión para estudiantes y personal administrativo
* Envío de solicitudes de becas con datos y documentos adjuntos
* Seguimiento del estado de cada solicitud
* Panel administrativo para revisión, aprobación o rechazo
* Historial y trazabilidad de cambios por solicitud

El objetivo principal es digitalizar y centralizar el proceso de gestión de solicitudes de Bienestar Estudiantil en la UIDE.

## Requerimientos Funcionales

### RF-01: Autenticación de Usuarios
El sistema debe permitir que los estudiantes inicien sesión usando correo y contraseña.

### RF-02: Envío de Solicitudes con Documentos
El sistema debe permitir el envío de solicitudes (completando campos de Titulo, asunto y documentos).

### RF-03: Consulta de Estado de Solicitudes
El sistema debe permitir al usuario consultar el estado de sus solicitudes enviadas.

### RF-04: Gestión de Solicitudes Administrativas
El sistema debe permitir al personal de Bienestar gestionar solicitudes y aprobarlas o derivarlas a Becas.

### RF-05: Sistema de Notificaciones
El sistema debe permitir enviar notificaciones básicas cuando cambie el estado de una solicitud o información respecto al mismo.

### RF-06: Filtros y Visualización
El sistema debe permitir filtrar y visualizar solicitudes por estado, fecha o tipo de trámite.

### RF-07: Historial de Acciones
El sistema debe registrar las acciones realizadas para mantener un historial.

### RF-08: Gestión de Avisos Institucionales
El sistema debe permitir al personal de Bienestar publicar avisos generales dirigidos a la comunidad universitaria como noticias o eventos.

### RF-09: Contactos Directos
El sistema debe mostrar información de contacto directo del personal de Bienestar y asesores específicos según el tipo de solicitud.

### RF-10: Mapa guía
El sistema debe permitir a los estudiantes usar el mapa del campus para guiarse.

### RF-11: Avisos sencillos a estudiantes
El sistema debe notificar a estudiantes mediante ventanas de forma resumida.

### RF-12: Estadísticas sobre solicitudes
El sistema debe permitir al administrador visualizar estadísticas de solicitudes revisadas, por revisar y aprobadas.

### RF-13: Avisos sobre objetos perdidos
El sistema debe permitir al administrador generar avisos sobre objetos perdidos incluyendo imagenes.

### RF-14: Filtrar solicitudes por estado y por tipo
El sistema debe permitir al administrador filtrar solicitudes por tipo de estado y por tipo de solicitud.

## Requerimientos No Funcionales

### RNF-01: Rendimiento
La aplicación deberá responder en un tiempo menor a 2 segundos al cargar las solicitudes del usuario.

### RNF-02: Seguridad
La aplicación deberá proteger los documentos mediante almacenamiento seguro y uso de HTTPS.

### RNF-03: Compatibilidad
La aplicación deberá ser compatible con dispositivos Android a partir de la versión 8.0.

### RNF-04: Usabilidad
La interfaz deberá ser clara, usable y permitir completar una solicitud en menos de 5 minutos.

## Definition of Ready (DoR)

Una Historia de Usuario se considera lista cuando:

* Tiene criterios de aceptación en formato Gherkin
* Está estimada en Story Points
* Cuenta con prioridad (must / should / could / won't)
* No tiene dependencias bloqueantes
* Incluye mockups o diseños si aplica
* El equipo entiende claramente qué se debe implementar

## Definition of Done (DoD)

Una Historia de Usuario está terminada cuando:

* El código funciona correctamente
* Tests unitarios/integración pasan (coverage > 80%)
* Documentación técnica actualizada (README, API Docs)
* Todos los criterios de aceptación se cumplen
* No existen bugs críticos
* Commits asociados al issue correspondiente
* Estado actualizado en GitHub Projects

## Capacidad del Equipo

* **Integrantes**: 5 personas
* **Disponibilidad**: 12 horas por persona
* **Velocidad estimada**: 3.5 SP por persona
* **Capacidad total por sprint**: 17.5 Story Points
* **Duración del sprint**: 2 semanas

### Uso de GitFlow básico:

* `main` → versión estable
* `develop` → desarrollo continuo
* `feature/` → nuevas funcionalidades
* `fix/` → correcciones

### Convención de commits:

* `feat:` descripción
* `fix:` descripción
* `docs:` descripción
* `refactor:` descripción

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
