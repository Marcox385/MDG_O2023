// IS727272 - Cordero Hernández, Marco Ricardo
// Betweenness Centrality a través de GDS

// 1. Crear un subgrafo
CALL gds.graph.project(
    'btw',
    'Villian',
    {COMPANION: {properties: 'Weight'}}
);

// 2. Calcular la memoria
CALL gds.betweenness.write.estimate(
    'btw',
    {writeProperty: 'betweenness'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejectura el algorimto
CALL gds.betweenness.stream('btw')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// 4. Crear el atributo
CALL gds.betweenness.write(
    'btw',
    {writeProperty: 'Betweenness'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;
