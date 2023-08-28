// IS727272 - Cordero Hernández, Marco Ricardo

// Ejecutar ejemplo de películas
:play movies

// Análisis básico
//      1) Revisar tipos y cantidad de nodos
//      2) Revisar tipos y cantidad de relaciones
//      3) Revisar atributos de nodos y sus tipos
//      4) Revisar atributos de relaciones y sus tipos
//      5) Revisar propiedades de la base de datos
//      6) Revisar esquema general

// 1) Revisar tipos y cantidad de nodos
MATCH (n) RETURN DISTINCT LABELS(n); // Cuáles (CALL db.labels())
MATCH (n) RETURN COUNT(n); // Cuántos

// 2) Revisar tipos y cantidad de relaciones
CALL db.relationshipTypes(); // Cuáles
MATCH ()-[r]-() RETURN COUNT(r); // Cuántos

// 3) Revisar atributos de nodos y sus tipos
CALL db.schema.nodeTypeProperties(); // Cuáles
// De qué tipo

// 4) Revisar atributos de relaciones y sus tipos
CALL db.schema.relTypeProperties(); // Cuáles
// De qué tipo

// 5) Revisar propiedades de la base de datos
CALL db.info();

// 6) Revisar esquema general
CALL db.schema.visualization();

// Obtener los pares de actores que han trabajando en la misma película
MATCH (a1:Person)-[r1:ACTED_IN]->(m:Movie)<-[r2:ACTED_IN]-(a2:Person)
WHERE a1.name > a2.name // Se utiliza para evitar pares duplicados de personas (permutaciones != combinaciones)
RETURN DISTINCT a1.name AS FIRST, a2.name AS SECOND, COUNT(m) AS TOTAL, COLLECT(m.title) AS MOVIE
ORDER BY TOTAL DESC
LIMIT 3;

