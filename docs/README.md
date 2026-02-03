# Sistema de Bienestar Universitario UIDE

Sistema de gestión de bienestar estudiantil que permite a los estudiantes de la UIDE solicitar becas, consultar el estado de sus solicitudes y recibir atención personalizada, optimizando los procesos administrativos del departamento de bienestar.

##  Integrantes

| Nombre | Rol | GitHub |
|--------|-----|--------|
| Mateo Castillo | Backend | [@mateocp10](https://github.com/mateocp10) |
| Christian Salinas | Backend | [@ChrisSR247](https://github.com/ChrisSR247) |
| Juan Esteban Fuentes | Frontend | [@juanestebanf](https://github.com/juanestebanf) |
| Victor Montaño | Frontend | [@Victor12-ui](https://github.com/Victor12-ui) |
| Virginia Mora | Frontend | [@ginia18](https://github.com/ginia18) |

#…
[16:17, 3/2/2026] Juan Fuentes: docs/requirements/HU-10-mapa.md: # HU-10 – Visualización y filtrado del mapa del campus

*Como* estudiante  
*Quiero* acceder a un mapa interactivo del campus y filtrar por número de aula  
*Para* ubicar rápidamente mi salón de clases y orientarme dentro de la institución.

---

## Criterios de Aceptación (Gherkin)

Escenario: Acceso al mapa del campus
Dado que el estudiante se encuentra en el menú principal de la aplicación  
Cuando selecciona la opción de "Mapa guía"  
Entonces el sistema despliega una representación gráfica de las instalaciones del campus.

### Escenario: Búsqueda y filtrado de aula específica
Dado que el estudiante está visualizando el mapa  
Cuando ingresa un número de aula en el campo de búsqueda  
Entonces el sistema resalta la ubicación exacta con un marcador o punto visual.

### Escenario: Búsqueda sin resultados
Dado que el estudiante ingresa un término en el buscador  
Cuando el número de aula no coincide con ningún registro  
Entonces el sistema muestra un mensaje de "Ubicación no encontrada" y permite reintentar la búsqueda.
