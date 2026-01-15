# HU-03 – Consulta de solicitudes enviadas

**Como** estudiante UIDE  
**Quiero** consultar el estado de mis solicitudes  
**Para** realizar seguimiento sin contactar al personal de Bienestar  

## Criterios de Aceptación (Gherkin)

Escenario: Listado de solicitudes  
Dado que estoy autenticado  
Cuando accedo a la opción "Historial"  
Entonces el sistema muestra todas mis solicitudes enviadas  

Escenario: Detalle de una solicitud  
Dado que selecciono una solicitud  
Cuando accedo a su detalle  
Entonces el sistema muestra la información completa y su estado  

Escenario: Uso de filtros  
Dado que existen múltiples solicitudes  
Cuando aplico filtros por estado o tipo  
Entonces el sistema muestra solo las solicitudes filtradas  

Escenario: Actualización automática del estado  
Dado que el estado de una solicitud cambia  
Cuando visualizo la lista de solicitudes  
Entonces el sistema refleja el cambio automáticamente  
