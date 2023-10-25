// IS727272 - Cordero Hernández, Marco Ricardo
// Práctica 2: Aplicando algoritmos de centralidad y comunidades para analizar un grafo
// Plantilla para aplicación de algoritmos a través de GDS

// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'nombre_del_proyecto',
    'TIPO_DE_NODO',
    {
        NOMBRE_DE_RELACION: {
            orientation: 'ORIENTACION_DE_LAS_RELACIONES [NATURAL | REVERSE | UNDIRECTED]',
            properties: 'PROPIEDAD(ES)_DE_LAS_RELACIONES'
        }
    }
);

// Cálculo de memoria requerida (Posible únicamente para algoritmos con calidad de producción)
CALL gds.ALGORITMO_A_APLICAR.write.estimate(
    'nombre_del_proyecto',
    {writeProperty: 'PROPIEDAD_A_CALCULAR'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.[CALIDAD_DEL_ALGORITMO.]ALGORITMO_A_APLICAR.stream('nombre_del_proyecto')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).PROPIEDAD_DEL_NODO As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.[CALIDAD_DEL_ALGORITMO.]ALGORITMO_A_APLICAR.write(
    'nombre_del_proyecto',
    {writeProperty: 'PROPIEDAD_A_ESCRIBIR'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (n:TIPO_DE_NODO)
RETURN n.PROPIEDAD_DEL_NODO AS NODO_X, PROPIEDAD_A_ESCRIBIR AS ALGORITMO_A_APLICAR
ORDER BY n.ALGORITMO_A_APLICAR DESC
LIMIT X;
