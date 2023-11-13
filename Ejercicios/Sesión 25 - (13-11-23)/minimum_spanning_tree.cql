// IS727272 - Cordero Hernández, Marco Ricardo
// Minimum Weight Spanning Tree
// Hecho en la versión 2.5.3

// 1. Creación de subgrafo
// Subgrafo no dirigido (el algoritmo ignora las direcciones de las relaciones)
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

// 2. Creación de las relaciones
MATCH (source:Villian {Name: 'Catwoman'})
CALL gds.spanningTree.write(
    'myUndirectedGraph',
    {
        sourceNode: ID(source), 
        relationshipWeightProperty: 'Weight',
        writeProperty: 'writeCost',
        writeRelationshipType: 'MINST'
    }
)
YIELD preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount
RETURN preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount;


// Ejercicio adicional
// Probar con Grodd y guardar el camino resultante
MATCH (source:Villian {Name: 'Grodd'})
CALL gds.spanningTree.write(
    'myUndirectedGraph',
    {
        sourceNode: ID(source), 
        relationshipWeightProperty: 'Weight',
        writeProperty: 'writeCost',
        writeRelationshipType: 'MINST_G'
    }
)
YIELD preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount
RETURN preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount;

// En Bloom, haz lo necesario para que reciba el nombre del villano como parámetro (omitido)
// y prueba con Bizarro y guarda el camino resultante
// Frase: MWST para $villianName
// (Se intuye la presencia de un subgrafo existente con nombre 'myUndirectedGraph')
MATCH (source:Villian {Name: $villianName})
CALL gds.spanningTree.write(
    'myUndirectedGraph',
    {
        sourceNode: ID(source), 
        relationshipWeightProperty: 'Weight',
        writeProperty: 'writeCost',
        writeRelationshipType: 'MINST_$villianName'
    }
);

MATCH (source:Villian {Name: $villianName})-[r:MINST_$villianName]-(d:Villian)
MATCH (v:Villian)
RETURN source, r, d, v;

// Probar con Bizarro y guardar el camino resultante
MATCH (source:Villian {Name: 'Bizarro'})
CALL gds.spanningTree.write(
    'myUndirectedGraph',
    {
        sourceNode: ID(source), 
        relationshipWeightProperty: 'Weight',
        writeProperty: 'writeCost',
        writeRelationshipType: 'MINST_B'
    }
)
YIELD preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount
RETURN preProcessingMillis, computeMillis, writeMillis, effectiveNodeCount;
