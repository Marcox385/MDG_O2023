// Mini Proyecto 3 - Equipo 1
// Llamadas a GDS y modificación estructural
// IS727272 - Cordero Hernández, Marco Ricardo

// (1), (2)
// Implementación dirigida
// Subgrafo dirigido sin peso
CALL gds.graph.project(
    'DSSSSP-D',
    'User',
    {
        FRIEND_OF: {
            orientation: 'NATURAL',
            properties: 'weight'
        }
    }
);

// Relaciones
MATCH (source:User {id: 385})
CALL gds.allShortestPaths.delta.write(
    'DSSSSP-D',
    {
        sourceNode: source,
        relationshipWeightProperty: 'weight',
        writeRelationshipType: 'PATH_DS_385',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// (3)
// Subgrafo no dirigido
CALL gds.graph.project(
    'Dijkstra-U',
    'Entity',
    {
        LISTENS_TO: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        }
    }
);

// Relaciones
MATCH (source:User {id: 1213}),
      (target:Artist {name: 'Kanye West'})
CALL gds.shortestPath.dijkstra.write(
    'Dijkstra-U',
    {
        sourceNode: source,
        targetNode: target,
        relationshipWeightProperty: 'weight',
        writeRelationshipType: 'PATH_1213_TO_YE',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// (4)
// Subgrafo no dirigido
CALL gds.graph.project(
    'Dijkstra-U',
    'Entity',
    {
        LISTENS_TO: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        }
    }
);

// Relaciones
MATCH (source:User {id: 1213}),
      (target:User {id: 1312})
CALL gds.shortestPath.dijkstra.write(
    'Dijkstra-U',
    {
        sourceNode: source,
        targetNode: target,
        relationshipWeightProperty: 'weight',
        writeRelationshipType: 'PATH_1213_TO_1312',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// (5)
// Subgrafo no dirigido
CALL gds.graph.project(
    'RandomWalk-U',
    'Entity',
    {
        LISTENS_TO: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        }
    }
);

// Ejecución del algoritmo
MATCH (a:Artist)
WHERE a.name IN [$a1, $a2]
WITH COLLECT(a) AS sourceNodes
CALL gds.randomWalk.stream(
    'RandomWalk-U',
    {
        sourceNodes: sourceNodes,
        walkLength: $n,
        walksPerNode: 1,
        randomSeed: 385,
        concurrency: 1
    }
)
YIELD nodeIds, path
RETURN nodeIds, path;

// (6)
// Subgrafo dirigido
CALL gds.graph.project(
    'RandomWalk-U-1',
    'User',
    {
        FRIEND_OF: {
            orientation: 'NATURAL',
            Properties: 'weight'
        }
    }
);

// Ejecución del algoritmo
MATCH (u:User)
WHERE a.name IN [$usr]
WITH COLLECT(a) AS sourceNodes
CALL gds.randomWalk.stream(
    'RandomWalk-U-1',
    {
        sourceNodes: sourceNodes,
        walkLength: $n,
        walksPerNode: 1,
        randomSeed: 727272,
        concurrency: 1
    }
)
YIELD nodeIds, path
RETURN nodeIds, path;


// (7)
// Subgrafo
CALL gds.graph.project(
    'MWST',
    'User',
    {
        FRIEND_OF: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        }
    }
);

// Relaciones
MATCH (source:User {id: 713})
CALL gds.spanningTree.write(
    'MWST',
    {
        sourceNode: ID(source), 
        relationshipWeightProperty: 'weight',
        writeProperty: 'writeCost',
        writeRelationshipType: 'USER-713-MINST'
    }
)
YIELD preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount
RETURN preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount;

// (8)
// Subgrafo
CALL gds.graph.project(
    'MWST-1',
    'Entity',
    {
        LISTENS_TO: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        },
        FRIEND_OF: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        },
        TAGS: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        }
    }
);

// Relaciones
MATCH (source:User {id: 284})
CALL gds.spanningTree.write(
    'MWST-1',
    {
        sourceNode: ID(source), 
        relationshipWeightProperty: 'weight',
        writeProperty: 'writeCost',
        writeRelationshipType: 'MINSTONES',
        relationshipTypes: ['LISTENS_TO', 'FRIEND_OF', 'TAGS']
    }
)
YIELD preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount
RETURN preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount;

// (9)
// Subgrafo dirigido
CALL gds.graph.project(
    'DFS-U',
    'User',
    {
        FRIEND_OF: {
            orientation: 'NATURAL',
            Properties: 'weight'
        }
    }
);

// Ejecución del algoritmo
MATCH (source:User {id: 24})
CALL gds.dfs.stream(
    'DFS-U',
    {
        sourceNode: source,
        maxDepth: 5
    }
)
YIELD path RETURN path;

// (10)
// Subgrafo no dirigido
CALL gds.graph.project(
    'DFS-D',
    'Entity',
    {
        LISTENS_TO: {
            orientation: 'REVERSE',
            Properties: 'weight'
        }
    }
);

// Ejecución del algoritmo
MATCH (source:Artist {name: $name})
CALL gds.dfs.stream(
    'DFS-D',
    {
        sourceNode: source,
        maxDepth: 1
    }
)
YIELD path RETURN path;
