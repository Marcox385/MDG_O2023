// Mini Proyecto 3 - Equipo 1
// Plantilla de algoritmos en GDS
// IS727272 - Cordero Hernández, Marco Ricardo

// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'nombre_del_proyecto',
    ['TIPOS_DE_NODOS'],
    {
        NOMBRE_DE_RELACION: {
            orientation: 'ORIENTACION_DE_LAS_RELACIONES [NATURAL | REVERSE | UNDIRECTED]',
            properties: 'PROPIEDAD(ES)_DE_LAS_RELACIONES' // Usualmente peso
        }
    }
);

// Cálculo de memoria requerida (Opcional y aplicable únicamente hacía algoritmos con calidad de producción)
CALL gds.ALGORITMO_A_APLICAR.write.estimate(
    'nombre_del_proyecto',
    {writeProperty: 'PROPIEDAD_A_CALCULAR'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.[CALIDAD_DEL_ALGORITMO.]ALGORITMO_A_APLICAR.stream('nombre_del_proyecto')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).PROPIEDAD_ORIGINAL_DEL_NODO As Name, score
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
