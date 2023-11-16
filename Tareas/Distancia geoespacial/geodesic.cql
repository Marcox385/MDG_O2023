// IS727272 - Cordero Hernández, Marco Ricardo
// Distancia geoespacial

// Formato para POINT
point({
    latitude: 0.0,
    longitude: 0.0,
    crs: 'WGS-84',  // Opcional
    srid: 4326      // Opcional
})

// Función para distancia geoespacial
point.distance(point(), point())

// 1. Crea la distancia geodésica desde el aeropuerto de Guadalajara
// hacia el aeropuerto de Puerto Vallarta
MATCH (a1:Airport {name: 'Guadalajara'}),
      (a2:Airport {name: 'Puerto Vallarta'})
WITH point({longitude: a1.longitude, latitude: a1.latitude}) as pt1,
     point({longitude: a2.longitude, latitude: a2.latitude}) as pt2
RETURN point.distance(pt1, pt2) AS Distancia;
// RETURN point.distance(pt1, pt2) / 1000 AS Distancia;

// 2. Crea la distancia geodésica desde el aeropuerto de Guadalajara
// hacia otro aeropuerto de tu elección
MATCH (a1:Airport {name: 'Guadalajara'}),
      (a2:Airport {name: 'Tuxtla Gutierrez'})
WITH point({longitude: a1.longitude, latitude: a1.latitude}) as pt1,
     point({longitude: a2.longitude, latitude: a2.latitude}) as pt2
RETURN point.distance(pt1, pt2) AS Distancia;
// RETURN point.distance(pt1, pt2) / 1000 AS Distancia;

// 3. Muestra el resultado en un mapa utilizando NeoDash
// Mapa de aeropuertos de México
MATCH (a:Airport)-[:LOCATED_IN]->(c:Country)
WHERE c.name = 'Mexico'
RETURN a;

// Modificación de relaciones entre aeropuertos previos
// para incluir la distancia
MATCH (a1:Airport {name: 'Guadalajara'}),
      (a2:Airport {name: 'Puerto Vallarta'})
MERGE (a1)-[r:CONNECTS_WITH]->(a2)
ON MATCH
    SET
        r.distance = point.distance(
            point({longitude: a1.longitude, latitude: a1.latitude}),
            point({longitude: a2.longitude, latitude: a2.latitude})
        ) / 1000 + 'KM'
ON CREATE
    SET
        r.distance = point.distance(
            point({longitude: a1.longitude, latitude: a1.latitude}),
            point({longitude: a2.longitude, latitude: a2.latitude})
        ) / 1000 + 'KM';

// Mapa de aeropuertos de México con distancias
MATCH (a1:Airport)-[r:CONNECTS_WITH]->(a2:Airport)
WHERE a1.name = 'Guadalajara'
AND a2.name IN ['Puerto Vallarta', 'Tuxtla Gutierrez']
RETURN a1, r, a2;
