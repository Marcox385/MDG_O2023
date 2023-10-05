// IS727272 - Cordero Hernández, Marco Ricardo
// Examen 1 - 02 de octubre del 2023

// 1. Creación del grafo
// Importar nodos
LOAD CSV WITH HEADERS FROM "file:///Country-nodes.csv" AS row
CREATE (p:Pais)
SET p = row;

// Índice para identificador de nodos
CREATE INDEX index_cnt FOR (p:Pais) ON (p.Id);

// Índice de búsqueda
CREATE INDEX index_cnt_label FOR (p:Pais) ON (p.Label);

// Importar relaciones y pesos
LOAD CSV FROM "file:///Country-edges.csv" AS row
MATCH (p:Pais), (q:Pais)
WHERE p.Id = row[0] and q.Id = row[1]
MERGE (p)-[:RELACION_CON {Weight: toInteger(row[2])}]->(q);


// 2. Descripción del grafo
// 2.1 Esquema general
CALL db.schema.visualization();

// 2.2 Grafo completo
MATCH p=()-[]-() RETURN p;

// 2.3 Total de nodos y sus atributos
MATCH (p:Pais) RETURN COUNT(p) AS totalNodos;
CALL db.schema.nodeTypeProperties()
YIELD nodeType AS Nodo, propertyName AS Propiedad, propertyTypes AS Tipo;

// 2.4 Total de relaciones y sus atributos
MATCH ()-[r]->() RETURN COUNT(r) as totalRelaciones;
CALL db.schema.relTypeProperties()
YIELD relType AS Relacion, propertyName AS Propiedad, propertyTypes AS Tipo;

// 2.5 Diámetro
// Suponiendo un diámetro dirigido...
MATCH (start), (end)
WHERE start <> end
WITH shortestPath((start)-[*]->(end)) AS p
WITH LENGTH(p) AS d
WHERE d IS NOT NULL
RETURN d AS diametroDirigido
ORDER BY d DESC 
LIMIT 1;

// 3. Tablero (Procedimientos y consultas previas de soporte)
// Degree's
// DEGREE
CALL gds.graph.project('degree', 'Pais',
    { RELACION_CON: { orientation: 'UNDIRECTED', properties: 'Weight' } }
);
CALL gds.degree.stream('degree');
CALL gds.degree.write('degree', {writeProperty: 'DEGREE'});

// IN_DEGREE
CALL gds.graph.project('indegree', 'Pais',
    { RELACION_CON: { orientation: 'REVERSE', properties: 'Weight' } }
);
CALL gds.degree.stream('indegree');
CALL gds.degree.write('indegree', {writeProperty: 'IN_DEGREE'});

// OUT_DEGREE
CALL gds.graph.project('outdegree', 'Pais',
    { RELACION_CON: { orientation: 'NATURAL', properties: 'Weight'} }
);
CALL gds.degree.stream('outdegree');
CALL gds.degree.write('outdegree', {writeProperty: 'OUT_DEGREE'});

// Closeness
CALL gds.graph.project('closeness', 'Pais',
    { RELACION_CON: { properties: 'Weight' } }
);
CALL gds.beta.closeness.stream('closeness');
CALL gds.beta.closeness.write('closeness', { writeProperty: 'Closeness' });

// PageRank
CALL gds.graph.project('pagerank', 'Pais',
    'RELACION_CON', { relationshipProperties: 'Weight' }
);
CALL gds.pageRank.stream('pagerank');
CALL gds.pageRank.write(
    'pagerank',
    { maxIterations: 20, dampingFactor: 0.85, writeProperty: 'PageRank' }
);

// Betweenness
CALL gds.graph.project('betweenness', 'Pais',
    { RELACION_CON: { properties: 'Weight' } }
);
CALL gds.betweenness.stream('betweenness');
CALL gds.betweenness.write('betweenness',
    {writeProperty: 'Betweenness'}
);

// Top 3 de todos los algoritmos
MATCH (p:Pais)
RETURN p.Label AS Pais, p.DEGREE AS DEGREE
ORDER BY DEGREE DESC
LIMIT 3;

MATCH (p:Pais)
RETURN p.Label AS Pais, p.IN_DEGREE AS IN_DEGREE
ORDER BY IN_DEGREE DESC
LIMIT 3;

MATCH (p:Pais)
RETURN p.Label AS Pais, p.OUT_DEGREE AS OUT_DEGREE
ORDER BY OUT_DEGREE DESC
LIMIT 3;

MATCH (p:Pais)
RETURN p.Label AS Pais, p.Closeness AS Closeness
ORDER BY Closeness DESC
LIMIT 3;

MATCH (p:Pais)
RETURN p.Label AS Pais, p.PageRank AS PageRank
ORDER BY PageRank DESC
LIMIT 3;

MATCH (p:Pais)
RETURN p.Label AS Pais, p.Betweenness AS Betweenness
ORDER BY Betweenness DESC
LIMIT 3;

// 4. Bloom
// Consulta: Países alcanzable a 2 saltos desde $PAIS
MATCH (p:Pais)
MATCH r=(p)-[*1..2]->()
WHERE p.Label = $PAIS
RETURN r;

// 5. Centralidad
// 5.1 nodo con mayor out_dregee, el número de relaciones que tiene a un salto y como una colección todos los nodos que están conectados a él
MATCH (m)-[r]->(n)
RETURN m.Label AS Nodo,
    COUNT(r) AS OUT_DEGREE,
    COLLECT(n.Label) AS vecinos1Salto
ORDER BY OUT_DEGREE DESC
LIMIT 1;

// 5.2 ¿Cuáles serían los 5 principales nodos que tienen más calidad conexiones con otros y de qué te servirían?
// PageRank
MATCH (p:Pais)
RETURN p.Label AS Pais
ORDER BY p.PageRank DESC
LIMIT 5;
// Por medio de estos países, tratados internacionales serían posibles y las relaciones políticas serían fructíferas

// 5.3.	¿Cuáles serían los 5 principales nodos que sirven como puente esencial para que continúe el flujo de información en el grafo y por qué?
// Betweenness
MATCH (p:Pais)
RETURN p.Label AS Pais
ORDER BY p.Betweenness DESC
LIMIT 5;
// La posición geopolítica planeada estratégicamente para este ejercicio provee un panorama en donde los países mostrados conectan varias naciones, contando con varios de los idiomas principales del mundo, impacto cultural y social

// 5.4.	¿Cuáles serían los 5 principales nodos que propondrías para distribuir un mensaje y por qué?
// Closeness
MATCH (p:Pais)
RETURN p.Label AS Pais
ORDER BY p.Closeness DESC
LIMIT 5;
// La densidad de las poblaciones mostradas, así como su espacio geográfico indica, hacen posible una rápida distribución de mensajes/sucesos a través del mundo. De igual manera, esta información podría resultar relevante en el contexto de las telecomunicaciones.
