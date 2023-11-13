// IS727272 - Cordero Hernández, Marco Ricardo
// Depth First Search

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

// 2. Ejecución del algoritmo como frase de búsqueda en bloom
// Las siguientes frases asumen la ejecución del paso anterior
// 2.1 Frase: DFS desde $villian a $n nivel(es)
//        $villian: String (label-key Villian:Name)
//        $n: Integer
MATCH (source:Villian {Name: $villian})
CALL gds.dfs.stream(
    'myUndirectedGraph',
    {
        sourceNode: source,
        maxDepth: $n
    }
)
YIELD path RETURN path;

// 2.2 Frase: DFS dirigido desde $villian a $n nivel(es)
//        $villian: String (label-key Villian:Name)
//        $n: Integer
MATCH (source:Villian {Name: $villian})
CALL gds.dfs.stream(
    'myDirectedGraph',
    {
        sourceNode: source,
        maxDepth: $n
    }
)
YIELD path RETURN path;

// Ejercicios adicionales
// DFS dirigido para Viper a 2 y 3 niveles
MATCH (source:Villian {Name: 'Viper'})
CALL gds.dfs.stream(
    'myDirectedGraph',
    {
        sourceNode: source,
        maxDepth: 2 // y 3
    }
)
YIELD path RETURN path;

// Probar con Braniac
//      - n = 1
//      - n = 2
//      - n = 2 ND
//      - n = 3
MATCH (source:Villian {Name: 'Braniac'})
CALL gds.dfs.stream(
    'my{Un}DirectedGraph',
    {
        sourceNode: source,
        maxDepth: n
    }
)
YIELD path RETURN path;

// En Bloom, haz lo necesario para que reciba el nombre del villano como parámetro
// y prueba con Joker a 1 y 2 niveles de profundidad
// (Misma frase de búsqueda ya creada)
