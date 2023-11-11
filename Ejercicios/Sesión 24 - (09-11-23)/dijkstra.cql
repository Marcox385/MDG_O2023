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
MATCH (source:Villian {Name: 'Viper'}),
      (target:Villian {Name: 'Lex Luthor'})
CALL gds.shortestPath.dijkstra.write(
    'myUndirectedGraph',
    {
        sourceNode: source,
        targetNode: target,
        relationshipWeightProperty: 'Weight',
        writeRelationshipType: 'PATH_Viper_Lex_Luthor_Undirected',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Dirigido
MATCH (source:Villian {Name: 'Viper'}),
      (target:Villian {Name: 'Lex Luthor'})
CALL gds.shortestPath.dijkstra.write(
    'myDirectedGraph',
    {
        sourceNode: source,
        targetNode: target,
        relationshipWeightProperty: 'Weight',
        writeRelationshipType: 'PATH_Viper_Lex_Luthor_Directed',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Prueba con Siniestro y Grodd
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
MATCH (source:Villian {Name: 'Siniestro'}),
      (target:Villian {Name: 'Grodd'})
CALL gds.shortestPath.dijkstra.write(
    'myUndirectedGraph',
    {
        sourceNode: source,
        targetNode: target,
        relationshipWeightProperty: 'Weight',
        writeRelationshipType: 'PATH_Siniestro_Grodd_Undirected',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

// Dirigido
MATCH (source:Villian {Name: 'Siniestro'}),
      (target:Villian {Name: 'Grodd'})
CALL gds.shortestPath.dijkstra.write(
    'myDirectedGraph',
    {
        sourceNode: source,
        targetNode: target,
        relationshipWeightProperty: 'Weight',
        writeRelationshipType: 'PATH_Siniestro_Grodd_Directed',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;
