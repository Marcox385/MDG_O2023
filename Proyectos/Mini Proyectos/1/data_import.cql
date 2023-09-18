// Equipo 3
// ICD745653 - López Arnaud, Luis Francisco
// IS727272 - Cordero Hernández, Marco Ricardo

// Importar nodos
LOAD CSV WITH HEADERS FROM "file:///got-s3-nodes.csv" AS row
CREATE (n:Person)
SET n = row;

// Crear índice para los nodos
CREATE INDEX index_person FOR (n:Person) ON (n.id);

// Crear índice de búsqueda (útil para bloom) => Label
CREATE INDEX index_Person_First_Name FOR (n:Person) ON (n.Label);

// Cargar relaciones entre nodos
LOAD CSV FROM "file:///got-s3-edges.csv" AS row
MATCH (n:Person), (m:Person)
WHERE n.Id = row[0] and m.Id = row[1]
MERGE (n)-[:INTERACTS_WITH {Weight: row[2]}]->(m);
