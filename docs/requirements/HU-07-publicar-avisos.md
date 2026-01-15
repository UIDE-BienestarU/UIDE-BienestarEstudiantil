# HU-07 – Publicación de avisos institucionales

**Como** personal de Bienestar Universitario  
**Quiero** publicar avisos institucionales  
**Para** informar a la comunidad universitaria  

## Criterios de Aceptación (Gherkin)

Escenario: Publicación de un aviso  
Dado que ingreso al panel administrativo  
Cuando creo un nuevo aviso y lo publico  
Entonces el sistema guarda y muestra el aviso a los estudiantes  

Escenario: Validación de campos del aviso  
Dado que faltan datos obligatorios del aviso  
Cuando intento publicarlo  
Entonces el sistema muestra un mensaje de error  
