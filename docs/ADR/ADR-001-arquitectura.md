# ADR-001: Arquitectura del Sistema

## Estado
Aceptado

## Contexto
El sistema de Bienestar Estudiantil UIDE es un proyecto académico que será
desarrollado por un equipo pequeño, con tiempo y alcance limitados.
El sistema incluye autenticación, gestión de solicitudes, notificaciones
y módulos informativos para estudiantes.

## Decisión
Se adopta una arquitectura monolítica en capas siguiendo el patrón MVC.

## Justificación
- Reduce la complejidad del desarrollo.
- Facilita el mantenimiento del código.
- Se adapta correctamente a aplicaciones Flutter con backend centralizado.
- Permite una clara separación entre interfaz, lógica de negocio y datos.

## Consecuencias
- La aplicación no está pensada para escalar como microservicios.
- En caso de crecimiento, será necesaria una refactorización futura.
