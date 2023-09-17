// IS727272 - Cordero Hernández, Marco Ricardo
// Closeness Centrality a través de GDS

// 1. Crear un subgrafo
CALL gds.graph.project(
    'ctl',
    'Villian',
    {COMPANION: {properties: 'Weight'}}
);

// 2. Calcular la memoria
// [[OMITIDO POR CALIDAD DE ALGORITMO BETA]]

// 3. Ejecutar el algoritmo
CALL gds.beta.closeness.stream('ctl')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// 4. Crear el atributo
CALL gds.beta.closeness.write(
    'ctl',
    {writeProperty: 'Closeness'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;
