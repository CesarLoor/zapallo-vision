# Dataset para rechazo de imágenes que no son hojas

El nuevo modelo requiere la clase `not_leaf`. Coloca sus imágenes en
`model/data/raw/not_leaf/`; se permiten subcarpetas.

## Contenido recomendado

- 2.000–3.000 imágenes originales para entrenamiento, validación y prueba.
- Personas, rostros, manos, ropa, herramientas, celulares, mesas, paredes,
  suelo, cielo, vehículos, frutos, tallos y hojas de otras especies.
- Escenas capturadas con los mismos teléfonos, distancias, luz y fondos que se
  usarán en campo.
- Un conjunto externo adicional de 300–500 negativos que no entre al pipeline,
  para medir el rechazo antes de desplegar.

No mezcles en distintos splits copias, ráfagas ni transformaciones de una misma
foto. Para las cinco clases foliares prioriza fotos originales de campo. En
especial, agrega 500–1.000 imágenes nuevas de mildiu velloso provenientes de
plantas, parcelas, fechas y cámaras distintas; no más aumentos artificiales del
mismo conjunto.

El modelo existente se conserva. Un entrenamiento nuevo usa el run
`zapallo_yolov11n_v2` y exporta en `model/exports/zapallo_yolov11n_v2/`. Solo
`python model/scripts/train.py --deploy` copia el resultado a Flutter.
