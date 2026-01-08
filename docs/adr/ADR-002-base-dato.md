# ADR-002: Base de Datos

## Estado
Aceptado

## Contexto
El sistema requiere almacenar información estructurada relacionada con
usuarios, solicitudes, documentos, notificaciones y registros históricos.

## Decisión
Se utilizará una base de datos relacional para la persistencia de datos.

## Justificación
- Permite manejar relaciones claras entre entidades.
- Garantiza integridad referencial.
- Facilita la generación de reportes y estadísticas.
- Es adecuada para sistemas administrativos.

## Consecuencias
- Menor flexibilidad frente a bases NoSQL.
- Cambios en el esquema requieren migraciones.
