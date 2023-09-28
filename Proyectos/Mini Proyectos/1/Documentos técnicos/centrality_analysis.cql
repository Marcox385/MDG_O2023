// Mini Proyecto 1 - Equipo 3
// Análisis de centralidad
// ICD745653 - López Arnaud, Luis Francisco
// IS727272 - Cordero Hernández, Marco Ricardo

// 1. ¿Qué personaje tiene el mayor número de interacciones con otras personas? [DEGREE]
// Creación de subgrafo (todo el grafo en este caso)
CALL gds.graph.project(
    'degree',
    'Person',
    {
        INTERACTS_WITH: {
            orientation: 'UNDIRECTED',
            properties: 'Weight'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.degree.write.estimate(
    'degree',
    {writeProperty: 'Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.degree.stream('degree')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.degree.write(
    'degree',
    {writeProperty: 'DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (n)
RETURN n.Label AS Personaje, toInteger(n.DEGREE) AS DEGREE
ORDER BY n.DEGREE DESC
LIMIT 1;

// Alternativa
MATCH ()-[r]-(n)
RETURN n.Label AS Personaje, COUNT(r) AS DEGREE
ORDER BY DEGREE DESC
LIMIT 10;


// 2. ¿Qué personaje tiene el mayor número de personas que se relacionan con el mismo? [IN_DEGREE]
// Creación de subgrafo (todo el grafo en este caso)
CALL gds.graph.project(
    'indegree',
    'Person',
    {
        INTERACTS_WITH: {
            orientation: 'REVERSE',
            properties: 'Weight'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.degree.write.estimate(
    'indegree',
    {writeProperty: 'Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.degree.stream('indegree')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.degree.write(
    'indegree',
    {writeProperty: 'IN_DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (n)
RETURN n.Label AS Personaje, toInteger(n.IN_DEGREE) AS IN_DEGREE
ORDER BY n.IN_DEGREE DESC
LIMIT 1;

// Alternativa
MATCH ()-[r]->(n)
RETURN n.Label AS Personaje, COUNT(r) AS IN_DEGREE
ORDER BY IN_DEGREE DESC
LIMIT 1;


// 3. ¿Qué personaje tiene el *menor* número de relaciones con otras personas? [OUT_DEGREE]
// Creación de subgrafo (todo el grafo en este caso)
CALL gds.graph.project(
    'outdegree',
    'Person',
    {
        INTERACTS_WITH: {
            orientation: 'NATURAL',
            properties: 'Weight'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.degree.write.estimate(
    'outdegree',
    {writeProperty: 'Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.degree.stream('outdegree')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.degree.write(
    'outdegree',
    {writeProperty: 'OUT_DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (n)
RETURN n.Label AS Personaje, toInteger(n.OUT_DEGREE) AS OUT_DEGREE
ORDER BY n.OUT_DEGREE
LIMIT 1;


// 4. Top 5 de personajes con más interacciones [DEGREE]
MATCH (n)
RETURN n.Label AS Personaje, toInteger(n.DEGREE) AS DEGREE
ORDER BY n.DEGREE DESC
LIMIT 5;

// Alternativa
MATCH ()-[r]-(n)
RETURN n.Label AS Personaje, COUNT(r) AS DEGREE
ORDER BY DEGREE DESC
LIMIT 5;


// 5. La línea de relación entre el personaje con la mayor cantidad de relaciones hacía otras personas [OUT] y el personaje con menos relaciones [DEG]
// Personaje con más relaciones hacía otras personas
MATCH (n)
RETURN n.Label AS Personaje
ORDER BY n.OUT_DEGREE DESC
LIMIT 1;

// Personaje con menos relaciones hacía otras personas
MATCH (n)
RETURN n.Label AS Personaje
ORDER BY n.DEGREE
LIMIT 1;

// Consulta completa
CALL {
    MATCH (n) RETURN n.Label AS Personaje
    ORDER BY n.OUT_DEGREE DESC LIMIT 1
} WITH Personaje AS PMR
CALL {
    MATCH (n) RETURN n.Label AS Personaje
    ORDER BY n.DEGREE LIMIT 1
} WITH Personaje AS PLR, PMR AS PMR
MATCH (m), (n)
WHERE m.Label = PMR
AND n.Label = PLR
RETURN shortestPath((m)-[*]-(n));


// 6. ¿Qué personaje tiene más influencia/popularidad en esta temporada? [PR]
// Creación de subgrafo (todo el grafo en este caso)
CALL gds.graph.project(
    'pagerank',
    'Person',
    'INTERACTS_WITH',
    {relationshipProperties: 'Weight'}
);

// Cálculo de memoria requerida
CALL gds.pageRank.write.estimate(
    'pagerank',
    {
        writeProperty: 'pageRank',
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.pageRank.stream('pagerank')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.pageRank.write(
    'pagerank',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'PageRank'
    }
)
YIELD nodePropertiesWritten, ranIterations;

// Resultado
MATCH (n)
RETURN n.Label AS Personaje, ROUND(n.PageRank) AS PageRank
ORDER BY PageRank DESC
LIMIT 1;


// 7. ¿Cuáles son los 5 personajes menos influyentes/populares? [PR]
// MATCH (n)
// RETURN n.Label AS Personaje, ROUND(n.PageRank) AS PageRank
// ORDER BY PageRank
// LIMIT 5;

// Mejor alternativa: ¿Cuáles son los 5 Starks más influyentes/populares?
MATCH (m)
WHERE m.Label IN ['Sansa', 'Robb', 'Jon', 'Arya', 'Ned', 'Catelyn', 'Rickon']
RETURN m.Label AS Personaje, ROUND(m.PageRank) AS PageRank
ORDER BY PageRank DESC
LIMIT 5;


// 8. ¿Qué personajes resultan más influyentes en el grafo al aplicar un damping factor de 0.6 y 30 iteraciones? [PR]
// Creación de atributo con resultado individual
CALL gds.pageRank.write(
    'pagerank',
    {
        maxIterations: 30,
        dampingFactor: 0.6,
        writeProperty: 'PageRank_MOD'
    }
)
YIELD nodePropertiesWritten, ranIterations;

// Resultado
MATCH (n)
RETURN n.Label AS Personaje, ROUND(n.PageRank_MOD) AS PageRank_MOD
ORDER BY PageRank_MOD DESC
LIMIT 5;


// 9. ¿Qué personajes se conectan entre varios grupos de personas? [BT]
// Creación de subgrafo (todo el grafo en este caso)
CALL gds.graph.project(
    'betweenness',
    'Person',
    {
        INTERACTS_WITH: {
            properties: 'Weight'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.betweenness.write.estimate(
    'betweenness',
    {writeProperty: 'betweenness'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.betweenness.stream('betweenness')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.betweenness.write(
    'betweenness',
    {writeProperty: 'Betweenness'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (n)
RETURN n.Label AS Nombre, ROUND(n.Betweenness, 4) AS Score
ORDER BY Score DESC
LIMIT 5;


// 10. ¿Qué personaje no tendría una eficacia óptima para hacer pactos entre otros grupos de personas? [BT]
// Con el mismo proyecto creado para la preguntar anterior...
MATCH (n)
WHERE n.Betweenness > 0
RETURN n.Label AS Nombre, ROUND(n.Betweenness, 4) AS Score
ORDER BY Score
LIMIT 5;
// Se revisan personajes que sí tienen al menos una baja posibilidad


// 11. ¿Qué personaje podría mandar mensajes de mejor manera? [CL]
// Creación de subgrafo (todo el grafo en este caso)
CALL gds.graph.project(
    'closeness',
    'Person',
    {
        INTERACTS_WITH: {
            properties: 'Weight'
        }
    }
);

// Se omite cálculo de memoria por calidad de algortimo (beta)

// Ejecución del algoritmo
CALL gds.beta.closeness.stream('closeness')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.beta.closeness.write(
    'closeness',
    {writeProperty: 'Closeness'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (n)
RETURN n.Label AS Personaje
ORDER BY n.Closeness DESC
LIMIT 1;


// 12. ¿Cuál es la línea de relación entre el personaje con menor posibilidad de comunicar mensajes y Arya (Stark)? [CL]
// Personaje con menor comunicación existente (!= 0)
MATCH (n)
WHERE n.Closeness <> 0
RETURN n.Label AS Personaje
ORDER BY n.Closeness
LIMIT 1;
// Resultado: Willem

// Consulta completa
CALL {
    MATCH (n)
    WHERE n.Closeness <> 0
    RETURN n.Label AS Personaje
    ORDER BY n.Closeness
    LIMIT 1
}
WITH Personaje AS LME
MATCH (n), (m)
WHERE n.Label = LME
AND m.Label = 'Arya'
RETURN shortestPath((n)-[*]-(m));


// 13. Tomando en cuenta su habilidad de relacionar grupos [BT] y comunicar mensajes [CL] ¿Cuáles son los 5 personajes más relevantes?
MATCH (n)
RETURN n.Label AS Personaje,
    ROUND(n.Betweenness, 4) AS Betweenness,
    ROUND(n.Closeness, 4) AS Closeness
ORDER BY Betweenness DESC, Closeness DESC
LIMIT 5;


// 14. Tomando en cuenta su influencia [PR] y sus relaciones [DEG] ¿Cuáles son los 5 personajes más relevantes?
MATCH (n)
RETURN n.Label AS Personaje,
    ROUND(n.PageRank, 4) AS PageRank,
    ROUND(n.DEGREE, 4) AS DEGREE
ORDER BY PageRank DESC, DEGREE DESC
LIMIT 5;


// 15. Tomando en cuenta todas las estadísticas anteriores ¿Cuáles son los 5 personajes más relevantes?
MATCH (n)
RETURN n.Label AS Personaje,
    ROUND(n.DEGREE, 4) AS DEGREE,
    ROUND(n.PageRank, 4) AS PageRank,
    ROUND(n.Betweenness, 4) AS Betweenness,
    ROUND(n.Closeness, 4) AS Closeness
ORDER BY DEGREE DESC, PageRank DESC,
    Betweenness DESC, Closeness DESC
LIMIT 5;
