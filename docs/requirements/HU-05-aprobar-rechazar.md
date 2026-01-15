# HU-05 – Aprobación o postergación de solicitudes

**Como** personal de Bienestar Universitario  
**Quiero** aprobar o rechazar solicitudes con un comentario  
**Para** dar una respuesta formal al estudiante  

## Criterios de Aceptación (Gherkin)

Escenario: Aprobación de solicitud  
Dado que he revisado una solicitud  
Cuando presiono la opción "Aprobar"  
Entonces el sistema cambia el estado y notifica al estudiante  

Escenario: Postergo de solicitud con motivo  
Dado que deseo postergar una solicitud  
Cuando ingreso el motivo y confirmo la acción  
Entonces el sistema registra la postergación y notifica al estudiante  

Escenario: Validación de motivo obligatorio  
Dado que intento postergar una solicitud sin ingresar un motivo  
Cuando confirmo la acción  
Entonces el sistema muestra un mensaje de error  

Escenario: Actualización de solicitudes pendientes  
Dado que una solicitud fue aprobada o postergada  
Cuando regreso al listado  
Entonces la solicitud ya no aparece como pendiente  
