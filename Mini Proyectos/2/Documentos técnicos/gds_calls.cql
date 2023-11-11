// Mini Proyecto 2 - Equipo 3
// Modificación estructural y plantilla de algoritmos en GDS
// IS727272 - Cordero Hernández, Marco Ricardo

// Modificación estructural propuesta (no funcional; NO EJECUTAR)
// Personas
MATCH (pa:Person)-[:DIRECTED | ACTED_IN | IS_CITIZEN_OF]-(:Movie | Country)-[:IS_CITIZEN_OF | ACTED_IN | DIRECTED]-(pb:Person)
WHERE pa <> pb
MERGE (pa)-[:COLLEAGUE_OF]->(pb);

MATCH (a)-[b:COLLEAGUE_OF]-(c)
RETURN COUNT(DISTINCT b);

// Películas
MATCH (ma:Movie)-[:FROM | LISTED_IN | DIRECTED]-(:Country | Category | Person)-[:DIRECTED | LISTED_IN | FROM]-(mb:Movie)
WHERE ma <> mb
MERGE (ma)-[:RELATIVE_TO]->(mb);

MATCH (a)-[b:RELATIVE_TO]-(c)
RETURN COUNT(DISTINCT b);


// Estructura básica
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

// Resultado
MATCH (n:TIPO_DE_NODO)
RETURN n.PROPIEDAD_DEL_NODO AS NODO_X, PROPIEDAD_A_ESCRIBIR AS ALGORITMO_A_APLICAR
ORDER BY n.ALGORITMO_A_APLICAR DESC
LIMIT X;


// 1. Node Similarity para películas y categorías
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'NS_Movies_Categories',
    ['Movie', 'Category'],
    'LISTED_IN'
);

// Cálculo de memoria requerida
CALL gds.nodeSimilarity.write.estimate(
    'NS_Movies_Categories',
    {
        writeRelationshipType: 'SIMILAR',
        writeProperty: 'score'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.nodeSimilarity.stream('NS_Movies_Categories')
YIELD node1, node2, similarity
RETURN
    gds.util.asNode(node1).title AS Movie1,
    gds.util.asNode(node2).title AS Movie2,
    similarity
ORDER BY similarity DESC, Movie1, Movie2;

// Creación de relación con resultado individual
CALL gds.nodeSimilarity.write(
    'NS_Movies_Categories',
    {
        writeRelationshipType: 'SIMILAR',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;

// 2. K-Nearest Neighbors con películas
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'KN_Movie',
    {
        Movie: {
            properties: ['releaseYear']
        }
    },
    '*'
);

// Cálculo de memoria requerida
CALL gds.knn.write.estimate(
    'KN_Movie',
    {
        nodeProperties: ['releaseYear'],
        writeRelationshipType: 'KSIMILAR',
        writeProperty: 'score',
        topK: 1
    }
)
YIELD nodeCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.knn.stream(
    'KN_Movie',
    {
        topK: 1,
        nodeProperties: ['releaseYear'],
        randomSeed: 727272,
        concurrency: 1,
        sampleRate: 1.0,
        deltaThreshold: 0.0
    }
)
YIELD node1, node2, similarity
RETURN gds.util.asNode(node1).title AS Movie1, gds.util.asNode(node2).title AS Movie2, similarity
ORDER BY similarity DESC, Movie1, Movie2;

// Creación de relación con resultado individual
CALL gds.knn.write(
    'KN_Movie',
    {
        writeRelationshipType: 'KSIMILAR',
        writeProperty: 'score',
        topK: 1,
        randomSeed: 42,
        concurrency: 1,
        nodeProperties: ['releaseYear']
    }
)
YIELD nodesCompared, relationshipsWritten;

// 3. Node Similarity para directores o actores y países
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'NS_Person_Country',
    ['Person', 'Country'],
    'IS_CITIZEN_OF'
);

// Cálculo de memoria requerida
CALL gds.nodeSimilarity.write.estimate(
    'NS_Person_Country',
    {
        writeRelationshipType: 'SIMILAR',
        writeProperty: 'score'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.nodeSimilarity.stream('NS_Person_Country')
YIELD node1, node2, similarity
RETURN
    gds.util.asNode(node1).name AS Director1,
    gds.util.asNode(node2).name AS Director2,
    similarity
ORDER BY similarity DESC, Director1, Director2;

// Creación de relación con resultado individual
CALL gds.nodeSimilarity.write(
    'NS_Person_Country',
    {
        writeRelationshipType: 'SIMILAR',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;

// 4. Weakly Connected Components para películas
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'WCC_Movie',
    'Movie',
    {
        SIMILAR: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.wcc.write.estimate(
    'WCC_Movie',
    {
        writeProperty: 'WCC'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.wcc.stream('WCC_Movie')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).title AS Película, componentId
ORDER BY componentId, Película;

// Creación de atributo con resultado individual
CALL gds.wcc.write(
    'WCC_Movie',
    { writeProperty: 'WCC' })
YIELD nodePropertiesWritten, componentCount;

// 5. Strongly Connected Components para directores y actores
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'SCC',
    'Person',
    {
        SIMILAR: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Se omite cálculo de memoria por calidad de algortimo (alpha)

// Ejecución del algoritmo
CALL gds.alpha.scc.stream('SCC')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).name AS Name, componentId
ORDER BY componentId, Name;

// Creación de atributo con resultado individual
CALL gds.alpha.scc.write(
    'SCC',
    { writeProperty: 'SCC' }
)
YIELD setCount, maxSetSize, minSetSize;

// 6. Lovain para películas usando K-Nearest Neigbors como relación
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'louvain',
    'Movie',
    {
        KSIMILAR: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.louvain.write.estimate(
    'louvain',
    {writeProperty: 'louvain'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.louvain.stream('louvain')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).title AS Película, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// Creación de atributo con resultado individual
CALL gds.louvain.write(
    'louvain',
    { writeProperty: 'louvain' }
)
YIELD communityCount, modularity, modularities;

// 7. Label Propagation para personas
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'label_propagation',
    'Person',
    {
        SIMILAR: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.labelPropagation.write.estimate(
    'label_propagation',
    {
        writeProperty: 'labelPropagation'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.labelPropagation.stream('label_propagation')
YIELD nodeId, communityId AS labelPropagation
RETURN gds.util.asNode(nodeId).name AS Persona, labelPropagation
ORDER BY labelPropagation, Persona;

// Creación de atributo con resultado individual
CALL gds.labelPropagation.write(
    'label_propagation',
    { writeProperty: 'labelPropagation' }
)
YIELD communityCount, ranIterations, didConverge;

// 8. Node Similarity para películas y directores
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'NS_Movies_Directors',
    ['Person', 'Movie'],
    {
        DIRECTED: {
            orientation: 'REVERSE'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.nodeSimilarity.write.estimate(
    'NS_Movies_Directors',
    {
        writeRelationshipType: 'SIMILAR_MD',
        writeProperty: 'score'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.nodeSimilarity.stream('NS_Movies_Directors')
YIELD node1, node2, similarity
RETURN
    gds.util.asNode(node1).title AS Movie1,
    gds.util.asNode(node2).title AS Movie2,
    similarity
ORDER BY similarity DESC, Movie1, Movie2;

// Creación de relación con resultado individual
CALL gds.nodeSimilarity.write(
    'NS_Movies_Directors',
    {
        writeRelationshipType: 'SIMILAR_MD',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;

// 9. Node Similarity para películas y actores
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'NS_Movies_Actors',
    ['Person', 'Movie'],
    {
        ACTED_IN: {
            orientation: 'REVERSE'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.nodeSimilarity.write.estimate(
    'NS_Movies_Actors',
    {
        writeRelationshipType: 'SIMILAR_MA',
        writeProperty: 'score'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.nodeSimilarity.stream('NS_Movies_Actors')
YIELD node1, node2, similarity
RETURN
    gds.util.asNode(node1).title AS Movie1,
    gds.util.asNode(node2).title AS Movie2,
    similarity
ORDER BY similarity DESC, Movie1, Movie2;

// Creación de relación con resultado individual
CALL gds.nodeSimilarity.write(
    'NS_Movies_Actors',
    {
        writeRelationshipType: 'SIMILAR_MA',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;

// 10. Node Similarity para películas y países
// Creación de subgrafo/proyecto
CALL gds.graph.project(
    'NS_Movies_Countries',
    ['Movie', 'Country'],
    {
        FROM: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.nodeSimilarity.write.estimate(
    'NS_Movies_Countries',
    {
        writeRelationshipType: 'SIMILAR_MC',
        writeProperty: 'score'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.nodeSimilarity.stream('NS_Movies_Countries')
YIELD node1, node2, similarity
RETURN
    gds.util.asNode(node1).title AS Movie1,
    gds.util.asNode(node2).title AS Movie2,
    similarity
ORDER BY similarity DESC, Movie1, Movie2;

// Creación de relación con resultado individual
CALL gds.nodeSimilarity.write(
    'NS_Movies_Countries',
    {
        writeRelationshipType: 'SIMILAR_MC',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;
