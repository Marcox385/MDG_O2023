// IS727272 - Cordero Hernández, Marco Ricardo

// Weakly Connected Components
// 1. Creación del subgrafo
CALL gds.graph.project(
    'WCC',
    'Villian',
    {
        COMPANION: {
            orientation: 'UNDIRECTED'
        }
    }
);

// (Opcional) 2. Cálculo de la memoria
CALL gds.wcc.write.estimate(
    'WCC',
    {
        writeProperty: 'component'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecución del algoritmo
CALL gds.wcc.stream('WCC')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).Name AS Villian, componentId
ORDER BY componentId, Villian;

// 4. Escritura de los resultados
CALL gds.wcc.write(
    'WCC',
    { writeProperty: 'WCC' })
YIELD nodePropertiesWritten, componentCount;

// Revisar grupos
MATCH (v:Villian)
RETURN v.WCC AS Group, COLLECT(v.Name) AS Villians;


// Strongly Connected Components
// 1. Creación del subgrafo
CALL gds.graph.project(
    'SCC',
    'Villian',
    'COMPANION'
);

// 2. OMITIDO POR CALIDAD DE PRODUCCIÓN DEL ALGORITMO (ALPHA)

// 3. Ejecución del algoritmo
CALL gds.alpha.scc.stream('SCC', {})
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).Name AS Villian, componentId AS Component
ORDER BY Component DESC;

// 4. Escritura de los resultados
CALL gds.alpha.scc.write(
    'SCC',
    { writeProperty: 'SCC' }
)
YIELD setCount, maxSetSize, minSetSize;

// Revisar grupos
MATCH (v:Villian)
RETURN v.SCC AS Group, COLLECT(v.Name) AS Villians;
