// IS727272 - Cordero Hernández, Marco Ricardo
// Page Rank a través de GDS

// Propuesta de 4 pasos
//      1. Crear un subgrafo
//      2. Calcular la memoria (Si es en calidad de producción)
//      3. Ejecutar el algoritmo
//      4. Crear el atributo

// 1. Crear un subgrafo
CALL gds.graph.project(
    'pr_villians',
    'Villian',
    'COMPANION',
    {relationshipProperties: 'Weight'}
);

// 2. Calcular la memoria
CALL gds.pageRank.write.estimate(
    'pr_villians',
    {
        writeProperty: 'pageRank',  // Cuánto va a tardar en escribir la propiedad en todos los nodos
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecutar el algoritmo
CALL gds.pageRank.stream('pr_villians')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// 4. Crear el atributo
CALL gds.pageRank.write(
    'pr_villians',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'pageRank'
    }
)
YIELD nodePropertiesWritten, ranIterations;


// Mismo proceso con héroes
// 1. Crear un subgrafo
CALL gds.graph.project(
    'pr_heroes',
    'SuperHero',
    'FRIEND_OF',
    {relationshipProperties: 'Weight'}
);

// 2. Calcular la memoria
CALL gds.pageRank.write.estimate(
    'pr_heroes',
    {
        writeProperty: 'pageRank',
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecutar el algoritmo
CALL gds.pageRank.stream('pr_heroes')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// 4. Crear el atributo
CALL gds.pageRank.write(
    'pr_heroes',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'pageRank'
    }
)
YIELD nodePropertiesWritten, ranIterations;



// Reto: Implementar Betweeness Centrality por cuenta propia
// 1. Crear un subgrafo
CALL gds.graph.project(
    'bc_heroes',
    'SuperHero',
    {FRIEND_OF: {properties: 'Weight'}}
);

// 2. Calcular la memoria
CALL gds.betweenness.write.estimate(
    'bc_heroes',
    {writeProperty: 'betweenness'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecutar el algoritmo
CALL gds.betweenness.stream('bc_heroes')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// 4. Crear el atributo
CALL gds.betweenness.write(
    'bc_heroes',
    {writeProperty: 'Betweenness'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;
