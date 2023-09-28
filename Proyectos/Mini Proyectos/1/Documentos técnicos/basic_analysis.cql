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
MATCH (start), (end)
WHERE start <> end
WITH shortestPath((start)-[*]-(end)) AS path
WITH length(path) AS distance
WHERE distance IS NOT NULL
RETURN distance AS Diámetro
ORDER BY distance DESC 
LIMIT 1;

// 10. ¿Cuál es el diámetro del grafo? (con dirección)
MATCH (start), (end)
WHERE start <> end
WITH shortestPath((start)-[*]->(end)) AS path
WITH length(path) AS distance
WHERE distance IS NOT NULL
RETURN distance AS DiámetroDirigido
ORDER BY distance DESC 
LIMIT 1;

// 11. Comprobar si el grafo es completamente conexo
MATCH (n), (m)
WHERE id(n) <> id(m)
OPTIONAL MATCH p = shortestPath((n)-[*]-(m))
WITH n, m, p
WHERE p IS NULL
RETURN DISTINCT FALSE AS totallyConnected
LIMIT 1;
// Si el resultado es nulo, el grafo es conexo

// 12. ¿Cuántas personas se relacionan con Jon (Snow)?
MATCH (m)-[:INTERACTS_WITH]->(n)
WHERE n.Label = 'Jon'
RETURN COUNT(m) AS totalRelaciones;

// Frase de búsqueda en Bloom
MATCH (m)-[r:INTERACTS_WITH]->(n)
WHERE n.Label = $PERSONAJE
RETURN m, r, n;

// 13. ¿Qué relación tiene más peso?
MATCH (n)-[r:INTERACTS_WITH]->(m)
WHERE n <> m
RETURN n.Label, m.Label, r.Weight AS Peso
ORDER BY r.Weight DESC
LIMIT 1;

// 14. ¿Qué relación tiene menos peso?
MATCH (n)-[r:INTERACTS_WITH]->(m)
WHERE n <> m
RETURN n.Label, m.Label, r.Weight AS Peso
ORDER BY r.Weight
LIMIT 1;

// 15. ¿El grafo es homogéneo o heterogéneo?
MATCH (n)
WITH COLLECT(DISTINCT LABELS(n)) AS NodeTypes
RETURN NodeTypes, COUNT(NodeTypes) AS TOTAL;

MATCH ()-[r]->()
WITH COLLECT(DISTINCT TYPE(r)) AS RelantionshipTypes
RETURN RelantionshipTypes, COUNT(RelantionshipTypes) AS TOTAL;
// Sí es homogéneo, ya que todos los nodos y relaciones tienen las mismas propiedades
