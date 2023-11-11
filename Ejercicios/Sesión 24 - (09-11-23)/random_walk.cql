// IS727272 - Cordero Hernández, Marco Ricardo
// Random Walk

// 1. Creación de subgrafos
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

// Ejecución del algoritmo
CALL gds.randomWalk.stream(
    'myDirectedGraph',
    {
        walkLength: 2,
        walksPerNode: 1,
        randomSeed: 42,
        concurrency: 1
    }
)
YIELD nodeIds, path
RETURN nodeIds, path;

// Variante del algoritmo
// con dirección, tipo de nodo Villian y forzando a pasar por dos nodos
MATCH (v:Villian)
WHERE v.Name IN ['Lex Luthor', 'Siniestro']
WITH COLLECT(v) AS sourceNodes
CALL gds.randomWalk.stream(
    'myDirectedGraph',
    {
        sourceNodes: sourceNodes,
        walkLength: 4,
        walksPerNode: 1,
        randomSeed: 42,
        concurrency: 1
    }
)
YIELD nodeIds, path
RETURN nodeIds, path;
