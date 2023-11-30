// IS727272 - Cordero Hernández, Marco Ricardo
// Examen 2 - 30 de noviembre del 2023

// 0. Creación del grafo
// Importar nodos e índices
LOAD CSV WITH HEADERS FROM "file:///Persona.csv" AS row
CREATE (p:Persona)
SET p.id = toInteger(row.IdPersona),
    p.nombre = row.Persona,
    p.colonia = row.Colonia;

CREATE INDEX index_p_name FOR (p:Persona) ON (p.nombre);
CREATE INDEX index_p_neigh FOR (p:Persona) ON (p.colonia);

// Importar relaciones
LOAD CSV WITH HEADERS FROM "file:///Relaciones.csv" AS row
MATCH (pr1:Persona), (pr2:Persona)
WHERE pr1.id = toInteger(row.IdPersona1)
AND pr2.id = toInteger(row.IdPersona2)
MERGE (pr1)-[:VECINO_DE {weight: toInteger(row.Peso)}]->(pr2);

// Revisar esquema
CALL db.schema.visualization;

// 1. Preguntas
// 1.1 Realiza una consulta en cypher que muestre el nombre de las personas que
// viven en las colonias MODERNA y MONRAZ. Los datos para mostrar son la colonia,
// el total de personas y como lista el nombre de las personas
MATCH (p:Persona)
WHERE p.colonia = 'MODERNA' OR p.colonia = 'MONRAZ'
RETURN p.colonia AS Colonia,
       COUNT(DISTINCT p.nombre) AS TotalPersonas,
       COLLECT(DISTINCT p.nombre) AS Personas;

// 1.2 ¿Cuántos nodos alcanza GALA PERALTA a 3 saltos?
MATCH (p:Persona)
MATCH r=(p)-[*1..3]->()
WHERE p.nombre = 'GALA PERALTA'
RETURN COUNT(DISTINCT r) AS CantidadAlcanzables;

// 1.3 Usando el algoritmo de comunidad Louvain, modifica la estructura del grafo
// para que implementes un nuevo atributo de comunidad con el nombre del algoritmo
// Creación del subgrafo
CALL gds.graph.project(
    'LOUVAIN_DIR',
    'Persona',
    {
        VECINO_DE: {
            orientation: 'NATURAL'
        }
    }
);

// Ejecución del algoritmo
CALL gds.louvain.stream('LOUVAIN_DIR')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).nombre AS Persona, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// Escritura de los resultados
CALL gds.louvain.write(
    'LOUVAIN_DIR',
    { writeProperty: 'Louvain' }
)
YIELD communityCount, modularity, modularities;

// Agrupación (Miembros completos omitidos por brevedad)
MATCH (p:Persona)
RETURN p.Louvain AS Grupo, COLLECT(p.nombre)[1..4] AS Miembros;
 
// 1.4 Usando el algoritmo de centralidad PageRank, modifica la estructura del grafo
// para que implementes un atributo de centralidad con el nombre del algoritmo
// Creación del subgrafo
CALL gds.graph.project(
    'PageRank',
    'Persona',
    'VECINO_DE',
    {relationshipProperties: 'weight'}
);

// Ejecución del algoritmo
CALL gds.pageRank.stream('PageRank')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).nombre AS Persona, score
ORDER BY score DESC, Persona ASC;

// Escritura de los resultados (PageRank tradicional)
CALL gds.pageRank.write(
    'PageRank',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'pageRank'
    }
)
YIELD nodePropertiesWritten, ranIterations;

// Muestra de los resultados
MATCH (p:Persona)
RETURN p.nombre AS Persona, p.pageRank AS Influencia
ORDER BY Influencia DESC;

// 1.5 Usando el algoritmo de búsqueda de caminos Minimum Weight Spanning Tree,
// modifica la estructura del grafo para que muestre el camino desde la persona
// con mayor PageRank a las demás personas alcanzables.
// Creación del subgrafo
CALL gds.graph.project(
    'MWST',
    'Persona',
    {
        VECINO_DE: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        }
    }
);

// Escritura de los resultados
CALL {
    MATCH (p:Persona)
    RETURN p.nombre AS n, p.pageRank AS pageRank
    ORDER BY pageRank DESC
    LIMIT 1
} WITH n AS name
MATCH (source:Persona {nombre: name})
CALL gds.spanningTree.write(
    'MWST',
    {
        sourceNode: ID(source), 
        relationshipWeightProperty: 'weight',
        writeProperty: 'writeCost',
        writeRelationshipType: 'MWST'
    }
)
YIELD preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount
RETURN preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount;

// 1.7 Si elegimos a HUMBERTO PERA, ¿cuáles serían los tres amigos para recomendar
// (que actualmente no tengan la relación amigo) por similaridad?
// ((Se require algoritmo de similarity))
// Creación del subgrafo
CALL gds.graph.project(
    'Similarity',
    ['Persona', 'Persona'],
    {
        VECINO_DE: {
            properties: 'weight'
        }
    }
);

// Ejecución del algoritmo
CALL gds.nodeSimilarity.stream('Similarity')
YIELD node1, node2, similarity
RETURN
    gds.util.asNode(node1).nombre AS Persona1,
    gds.util.asNode(node2).nombre AS Persona2,
    similarity
ORDER BY similarity DESC, Persona1, Persona2;

// Escritura de los resultados
CALL gds.nodeSimilarity.write(
    'Similarity',
    {
        writeRelationshipType: 'SIMILAR',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;

// Sugerencia de amistad
MATCH (pr1:Persona)-[:VECINO_DE]->(pi:Persona)<-[s:SIMILAR]-(pr2:Persona)
WHERE pr1.nombre = 'HUMBERTO PERA'
AND s.score >= 0.75
AND pr1 <> pr2
AND pi <> pr2
RETURN pr1.nombre AS PersonaInicial,
       COLLECT(DISTINCT pr2.nombre)[0..3] AS Sugerencias;

// 1.8 Si elegimos a FLORENCIA ARMAS, ¿cuáles serían los tres amigos para recomendar
// (que actualmente no tengan la relación amigo) por comunidad?
MATCH (pr1:Persona)-[:VECINO_DE]->(pi:Persona)-[:VECINO_DE]-(pr2:Persona)
WHERE pr1.nombre = 'FLORENCIA ARMAS'
AND pr1.Louvain = pr2.Louvain
AND pr1 <> pr2
AND pi <> pr2
RETURN pr1.nombre AS PersonaInicial,
       COLLECT(DISTINCT pr2.nombre)[0..3] AS Sugerencias;
