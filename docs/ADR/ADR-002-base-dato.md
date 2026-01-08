# ADR-002: Persistencia de Datos y Notificaciones con Firebase

## Estado
Aceptado

## Contexto
El sistema de Bienestar Estudiantil UIDE es una aplicación móvil que gestiona
solicitudes, documentos, avisos institucionales, objetos perdidos y notificaciones.
El tamaño de la aplicación y la necesidad de notificaciones en tiempo real
influyen en la decisión tecnológica.

## Decisión
Se utilizará Firebase como plataforma de backend, específicamente:
- Firebase Authentication
- Firebase Firestore / Realtime Database
- Firebase Storage para archivos
- Firebase Cloud Messaging para notificaciones

## Justificación
- Escalabilidad automática sin necesidad de administrar servidores.
- Almacenamiento eficiente de documentos y archivos mediante Firebase Storage.
- Integración directa con notificaciones push.
- Adecuado para aplicaciones móviles desarrolladas en Flutter.
- Reduce la complejidad de infraestructura para un proyecto académico.

## Consecuencias
- Dependencia del ecosistema Firebase.
- Limitaciones en consultas complejas.
- Costos potenciales si el uso escala fuera del plan gratuito.
