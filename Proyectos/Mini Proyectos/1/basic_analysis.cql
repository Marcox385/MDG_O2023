// Mini Proyecto 1 - Equipo 3
// Análisis básico
// ICD745653 - López Arnaud, Luis Francisco
// IS727272 - Cordero Hernández, Marco Ricardo

// 1. ¿Cuál es el esquema del grafo?
CALL db.schema.visualization;

// 2. ¿Cómo se ve el grafo entero?
MATCH p=()-[]-() RETURN p;

// 3. ¿Cuáles nodos hay?
CALL db.labels() YIELD label RETURN COLLECT(label) AS NODOS;

// 4. ¿Cuántos nodos hay?
MATCH (n) RETURN COUNT(DISTINCT n) AS totalNodos;

// 5. ¿Cuáles atributos tienen los nodos?
CALL db.schema.nodeTypeProperties()
YIELD nodeType AS Nodo, propertyName AS Propiedad, propertyTypes AS Tipo;

// 6. ¿Cuáles son las relaciones?
MATCH ()-[r]->() RETURN DISTINCT TYPE(r) AS RELACIONES;

// 7. ¿Cuántas son las relaciones?
MATCH ()-[r]->() RETURN COUNT(r) as totalRelaciones;

// 8. ¿Cuáles atributos tienen las relaciones?
CALL db.schema.relTypeProperties()
YIELD relType AS Relacion, propertyName AS Propiedad, propertyTypes AS Tipo;

// 9. ¿Cuál es el diámetro del grafo?
MATCH path = shortestPath((n)-[:INTERACTS_WITH*]-(m))
WHERE n <> m
RETURN path, length(path) AS len
ORDER BY len DESC
LIMIT 5;

// 10. ¿Cuál es el diámetro del grafo? (con dirección)
MATCH path = shortestPath((n)-[:INTERACTS_WITH*]->(m))
WHERE n <> m
RETURN path, length(path) AS len
ORDER BY len DESC
LIMIT 5;

// 11. Comprobar si el grafo es completamente conexo
MATCH (n)
WITH COLLECT(n) AS NODES
UNWIND NODES AS startNode
UNWIND NODES AS endNode
WITH startNode, endNode
WHERE ID(startNode) <> ID(endNode)
OPTIONAL MATCH path = shortestPath((startNode)-[INTERACTS_WITH*]->(endNode))
WHERE path IS NULL
RETURN COUNT(*) = 0 AS GraphIsConnected
LIMIT 1;

// 12. ¿Cuántas personas se relacionan con Jon (Snow)?


// 13. ¿Qué relación tiene más peso?


// 14. ¿Qué relación tiene menos peso?


// 15. ¿El grafo es homogéneo o heterogéneo?

