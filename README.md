# Sistema de Bienestar Estudiantil UIDE

Sistema integral de gestión de bienestar estudiantil que permite a los estudiantes de la UIDE solicitar becas, consultar el estado de sus solicitudes y recibir atención personalizada, optimizando los procesos administrativos del departamento de bienestar.

## Integrantes

- **Mateo [Apellido]** - Full Stack Developer - @mateocp10
- **Chris [Apellido]** - Full Stack Developer - @ChrisSR247
- **Juan Esteban [Apellido]** - Full Stack Developer - @juanestebanf
- **Victor [Apellido]** - Full Stack Developer - @Victor12-ui
- **Ginia [Apellido]** - Full Stack Developer - @ginia18

## Enlaces a GitHub Projects

- https://github.com/UIDE-BienestarU/UIDE-BienestarEstudiantil.git

## Definition of Ready (DoR)

Una Historia de Usuario está lista para ser trabajada cuando:
- Tiene criterios de aceptación claros en formato Gherkin
- Está estimada con story points
- Tiene prioridad asignada (must/should/could/wont-have)
- No tiene dependencias bloqueantes con otras HU
- Los diseños/mockups están disponibles (si aplica)
- El equipo entiende completamente lo que se debe hacer

## Definition of Done (DoD)

Una Historia de Usuario está completa cuando:
- El código está implementado y funciona correctamente
- Los tests unitarios y de integración pasan exitosamente (coverage > 70%)
- La documentación técnica está actualizada (README, API docs)
- La HU cumple todos los criterios de aceptación en formato Gherkin
- No hay bugs críticos o bloqueantes
- Los commits están vinculados al issue (#número)
- El estado del issue está actualizado en GitHub Projects

## Capacidad del Equipo

- **Integrantes:** 5 personas
- **Disponibilidad:** 10-12 horas por persona por sprint (2 semanas)
- **Velocidad estimada:** 2.5 SP por persona = 12-13 SP total por sprint
- **Sprint duration:** 2 semanas

## Convenciones

### Convenciones de Ramas
- `main`: Rama principal de producción
- `develop`: Rama de desarrollo
- `feature/[nombre-funcionalidad]`: Ramas para nuevas funcionalidades (ej: `feature/crear-solicitud-beca`)
- `fix/[nombre-bug]`: Ramas para correcciones de bugs

### Convenciones de Commits
- `feat:` - Nueva funcionalidad
- `fix:` - Corrección de bugs
- `docs:` - Cambios en documentación
- `test:` - Agregar o modificar tests
- `chore:` - Tareas de mantenimiento
- `refactor:` - Refactorización de código

**Importante:** Siempre vincular commits a issues usando `#número`

### Labels
- **Tipo:** `feature`, `user-story`, `bug`, `documentation`
- **Prioridad:** `priority:must-have`, `priority:should-have`, `priority:could-have`, `priority:wont-have`
- **Story Points:** `sp:1`, `sp:2`, `sp:3`, `sp:5`, `sp:8`

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
```
