# HU-02 – Envío de solicitud de beca

**Como** estudiante UIDE  
**Quiero** enviar una solicitud de beca con documentos de respaldo  
**Para** aplicar al programa de apoyo económico institucional  

## Criterios de Aceptación (Gherkin)

Escenario: Visualización del formulario  
Dado que estoy autenticado  
Cuando selecciono "Nueva solicitud de beca"  
Entonces el sistema muestra el formulario correspondiente  

Escenario: Carga de documentos  
Dado que estoy llenando el formulario  
Cuando adjunto documentos en formato PDF  
Entonces el sistema muestra el nombre del archivo cargado  

Escenario: Envío exitoso de la solicitud  
Dado que he completado todos los campos obligatorios  
Cuando presiono "Enviar"  
Entonces el sistema registra la solicitud

Escenario: Validación de campos obligatorios  
Dado que faltan campos por completar  
Cuando intento enviar la solicitud  
Entonces el sistema indica los campos faltantes  
