// IS727272 - Cordero Hernández, Marco Ricardo
// Label propagation

// 1. Creación del subgrafo
CALL gds.graph.project(
    'LP_UND',
    'Villian',
    {
        COMPANION: {
            orientation: 'UNDIRECTED'
        }
    }
);

// (Opcional) 2. Cálculo de la memoria
CALL gds.labelPropagation.write.estimate(
    'LP_UND',
    {
        writeProperty: 'labelPropagation'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecución del algoritmo
CALL gds.labelPropagation.stream('LP_UND')
YIELD nodeId, communityId AS labelPropagation
RETURN gds.util.asNode(nodeId).Name AS Villian, labelPropagation
ORDER BY labelPropagation, Villian;

// 4. Escribir los resultados
CALL gds.labelPropagation.write(
    'LP_UND',
    { writeProperty: 'LabelPropagation' }
)
YIELD communityCount, ranIterations, didConverge;

// Revisar grupos
MATCH (v:Villian)
RETURN v.LabelPropagation AS Group, COLLECT (v.Name) AS Villians;


// Con superhéroes
// 1. Creación del subgrafo
CALL gds.graph.project(
    'LP_UND_SH',
    'SuperHero',
    {
        FRIEND_OF: {
            orientation: 'UNDIRECTED'
        }
    }
);

// (Opcional) 2. Cálculo de la memoria
CALL gds.labelPropagation.write.estimate(
    'LP_UND_SH',
    {
        writeProperty: 'labelPropagation'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecución del algoritmo
CALL gds.labelPropagation.stream('LP_UND_SH')
YIELD nodeId, communityId AS labelPropagation
RETURN gds.util.asNode(nodeId).Name AS SuperHero, labelPropagation
ORDER BY labelPropagation, SuperHero;

// 4. Escritura de los resultados
CALL gds.labelPropagation.write(
    'LP_UND_SH',
    { writeProperty: 'LabelPropagation' }
)
YIELD communityCount, ranIterations, didConverge;

// Revisar grupos
MATCH (s:SuperHero)
RETURN s.LabelPropagation AS Group, COLLECT (s.Name) AS SuperHero;
