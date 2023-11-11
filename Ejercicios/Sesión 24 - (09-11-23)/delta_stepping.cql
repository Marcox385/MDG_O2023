// IS727272 - Cordero Hernández, Marco Ricardo
// Delta-Stepping Single-Source Shorterst path

// 1. Creación de subgrafos
// Subgrafo no dirigido
CALL gds.graph.project(
    'myUndirectedGraph',
    'Villian',
    {
        COMPANION: {
            orientation: 'UNDIRECTED',
            Properties: 'Weight'
        }
    }
);

// Subgrafo dirigido
CALL gds.graph.project(
    'myDirectedGraph',
    'Villian',
    {
        COMPANION: {
            orientation: 'NATURAL',
            Properties: 'Weight'
        }
    }
);

// 2. Creación de relaciones
// No dirigido
MATCH (source:Villian {Name: 'Lex Luthor'})
CALL gds.allShortestPaths.delta.write(
    'myUndirectedGraph',
    {
        sourceNode: source,
        relationshipWeightProperty: 'Weight',
        writeRelationshipType: 'PATH_Lex_Luthor_Undirected',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Dirigido
MATCH (source:Villian {Name: 'Lex Luthor'})
CALL gds.allShortestPaths.delta.write(
    'myDirectedGraph',
    {
        sourceNode: source,
        relationshipWeightProperty: 'Weight',
        writeRelationshipType: 'PATH_Lex_Luthor',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Prueba con Siniestro
// 1. Creación de subgrafos
// Subgrafo no dirigido
CALL gds.graph.project(
    'myUndirectedGraph_Sin',
    'Villian',
    {
        COMPANION: {
            orientation: 'UNDIRECTED',
            Properties: 'Weight'
        }
    }
);

// Subgrafo dirigido
CALL gds.graph.project(
    'myDirectedGraph_Sin',
    'Villian',
    {
        COMPANION: {
            orientation: 'NATURAL',
            Properties: 'Weight'
        }
    }
);

// 2. Creación de relaciones
// No dirigido
MATCH (source:Villian {Name: 'Siniestro'})
CALL gds.allShortestPaths.delta.write(
    'myUndirectedGraph_Sin',
    {
        sourceNode: source,
        relationshipWeightProperty: 'Weight',
        writeRelationshipType: 'PATH_Siniestro_Undirected',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Dirigido
MATCH (source:Villian {Name: 'Siniestro'})
CALL gds.allShortestPaths.delta.write(
    'myDirectedGraph_Sin',
    {
        sourceNode: source,
        relationshipWeightProperty: 'Weight',
        writeRelationshipType: 'PATH_Siniestro',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;
