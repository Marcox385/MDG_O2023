// IS727272 - Cordero Hernández, Marco Ricardo
// Degree Centrality a través de GDS

// Escribir IN_DEGREE
// 1) Crear un subgrafo (temporal)
//      Relación NATURAL (default)  == OUT_DEGREE
//      Relación REVERSE            == IN_DEGREE
//      Relación UNDIRECTED         == DEGREE
CALL gds.graph.project(
    'myGraphID',                        // Nombre del subgrafo
    'Villian',                          // Tipo de nodo
    {                                   // Propiedades
        COMPANION: {
            orientation: 'REVERSE',
            properties: 'Weight'
        }
    }
);

// 2) Calcular memoria requerida
CALL gds.degree.write.estimate(
    'myGraphID',
    {writeProperty: 'Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3) Ejecutar el algoritmo de centralidad
CALL gds.degree.stream('myGraphID')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS name, score AS IN_DEGREE
ORDER BY IN_DEGREE DESC, name DESC;

// 4) Crear el atributo IN_DEGREE en los nodos
CALL gds.degree.write(
    'myGraphID',
    {writeProperty: 'IN_DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;


// Escribir OUT_DEGREE
// 1) Crear un subgrafo (temporal)
CALL gds.graph.project(
    'myGraphID_OUT',                    // Nombre del subgrafo
    'Villian',                          // Tipo de nodo
    {                                   // Propiedades
        COMPANION: {
            orientation: 'NATURAL',
            properties: 'Weight'
        }
    }
);

// 2) Calcular memoria requerida
CALL gds.degree.write.estimate(
    'myGraphID_OUT',
    {writeProperty: 'Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3) Ejecutar el algoritmo de centralidad
CALL gds.degree.stream('myGraphID_OUT')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS name, score AS OUT_DEGREE
ORDER BY OUT_DEGREE DESC, name DESC;

// 4) Crear el atributo IN_DEGREE en los nodos
CALL gds.degree.write(
    'myGraphID_OUT',
    {writeProperty: 'OUT_DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;


// Escribir DEGREE
// 1) Crear un subgrafo (temporal)
CALL gds.graph.project(
    'myGraphID_D',                      // Nombre del subgrafo
    'Villian',                          // Tipo de nodo
    {                                   // Propiedades
        COMPANION: {
            orientation: 'UNDIRECTED',
            properties: 'Weight'
        }
    }
);

// 2) Calcular memoria requerida
CALL gds.degree.write.estimate(
    'myGraphID_D',
    {writeProperty: 'Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3) Ejecutar el algoritmo de centralidad
CALL gds.degree.stream('myGraphID_D')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS name, score AS DEGREE
ORDER BY DEGREE DESC, name DESC;

// 4) Crear el atributo IN_DEGREE en los nodos
CALL gds.degree.write(
    'myGraphID_D',
    {writeProperty: 'DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;


// DEGREE, IN_DEGREE y OUT_DEGREE para héroes
// DEGREE
CALL gds.graph.project(
    'hero_DG',
    'SuperHero',
    {                                   
        FRIEND_OF: {
            orientation: 'UNDIRECTED',
            properties: 'Weight'
        }
    }
);

CALL gds.degree.stream('hero_DG')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS name, score AS DEGREE
ORDER BY DEGREE DESC, name DESC;

CALL gds.degree.write(
    'hero_DG',
    {writeProperty: 'DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// IN_DEGREE
CALL gds.graph.project(
    'hero_IN',
    'SuperHero',
    {                                   
        FRIEND_OF: {
            orientation: 'REVERSE',
            properties: 'Weight'
        }
    }
);

CALL gds.degree.stream('hero_IN')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS name, score AS IN_DEGREE
ORDER BY IN_DEGREE DESC, name DESC;

CALL gds.degree.write(
    'hero_IN',
    {writeProperty: 'IN_DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// OUT_DEGREE
CALL gds.graph.project(
    'hero_OUT',
    'SuperHero',
    {                                   
        FRIEND_OF: {
            orientation: 'NATURAL',
            properties: 'Weight'
        }
    }
);

CALL gds.degree.stream('hero_OUT')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name AS name, score AS OUT_DEGREE
ORDER BY OUT_DEGREE DESC, name DESC;

CALL gds.degree.write(
    'hero_OUT',
    {writeProperty: 'OUT_DEGREE'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;
