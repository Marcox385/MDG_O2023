// IS727272 - Cordero Hernández, Marco Ricardo
// Introducción a algoritmos de comunidad
// Louvain

// 1. Creación del subgrafo
CALL gds.graph.project(
    'Louvain_UND',
    'Villian',
    {
        COMPANION: {
            orientation: 'UNDIRECTED'
        }
    }
);

// (Opcional) 2. Cálculo de la memoria
CALL gds.louvain.write.estimate(
    'Louvain_UND',
    {
        writeProperty: 'Louvain'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecución del algoritmo
CALL gds.louvain.stream('Louvain_UND')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).Name AS Villian, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// 4. Escritura de los resultados
CALL gds.louvain.write(
    'Louvain_UND',
    { writeProperty: 'Louvain' }
)
YIELD communityCount, modularity, modularities;

// Revisar grupos
MATCH (v:Villian)
RETURN v.Louvain AS Group, COLLECT(v.Name) AS Villians;


// Con superhéroes
// 1. Creación del subgrafo
CALL gds.graph.project(
    'Louvain_UND_SH',
    'SuperHero',
    {
        FRIEND_OF: {
            orientation: 'UNDIRECTED'
        }
    }
);

// 3. Ejecución del algoritmo
CALL gds.louvain.stream('Louvain_UND_SH')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).Name AS SuperHero, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// 4. Escritura de los resultados
CALL gds.louvain.write(
    'Louvain_UND_SH',
    { writeProperty: 'Louvain' }
)
YIELD communityCount, modularity, modularities;

// Revisar grupos
MATCH (s:SuperHero)
RETURN s.Louvain AS Group, COLLECT(s.Name) AS Superheroes;


// Con villanos y relaciones dirigidas
// 1. Creación del subgrafo
CALL gds.graph.project(
    'Louvain_DIR_V',
    'Villian',
    {
        COMPANION: {
            orientation: 'NATURAL'
        }
    }
);

// 3. Ejecución del algoritmo
CALL gds.louvain.stream('Louvain_DIR_V')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).Name AS Villian, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// 4. Escritura de los resultados
CALL gds.louvain.write(
    'Louvain_DIR_V',
    { writeProperty: 'Louvain_DIR' }
)
YIELD communityCount, modularity, modularities;

// Revisar grupos
MATCH (v:Villian)
RETURN v.Louvain_DIR AS Group, COLLECT(v.Name) AS Villians;


// Con superhéroes y relaciones dirigidas
// 1. Creación del subgrafo
CALL gds.graph.project(
    'Louvain_DIR_SH',
    'SuperHero',
    {
        FRIEND_OF: {
            orientation: 'NATURAL'
        }
    }
);

// 3. Ejecución del algoritmo
CALL gds.louvain.stream('Louvain_DIR_SH')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).Name AS SuperHero, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// 4. Escritura de los resultados
CALL gds.louvain.write(
    'Louvain_DIR_SH',
    { writeProperty: 'Louvain_DIR' }
)
YIELD communityCount, modularity, modularities;

// Revisar grupos
MATCH (s:SuperHero)
RETURN s.Louvain_DIR AS Group, COLLECT(s.Name) AS Superheroes;


// Louvain sobre el grafo completo (Proceso previo requerido)
// Añadir etiqueta "persona" a todos los nodos
MATCH (n:SuperHero|Villian)
SET n:Persona
RETURN n;

// Fusionar relaciones de friend, companion y enemy (related) en un solo tipo
MATCH (s1:SuperHero)-[f:FRIEND_OF]->(s2:SuperHero)
CREATE (s1)-[r:RELATED_TO]->(s2)
SET r = f;

MATCH (v1:Villian)-[f:COMPANION]->(v2:Villian)
CREATE (v1)-[r:RELATED_TO]->(v2)
SET r = f;

MATCH (v:Villian)-[f:ENEMY_OF]->(s:SuperHero)
CREATE (v)-[r:RELATED_TO]->(s)
SET r = f;

// 1. Creación del subgrafo
CALL gds.graph.project(
    'Louvain_DIR',
    'Persona',
    {
        RELATED_TO: {
            orientation: 'NATURAL'
        }
    }
);

// 3. Ejecución del algoritmo
CALL gds.louvain.stream('Louvain_DIR')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).Name AS Person, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// 4. Escritura de los resultados
CALL gds.louvain.write(
    'Louvain_DIR',
    { writeProperty: 'Louvain_WHOLE' }
)
YIELD communityCount, modularity, modularities;

// Revisar grupos
MATCH (p:Persona)
RETURN p.Louvain_WHOLE AS Group, COLLECT(p.Name) AS Personas;


// Análisis adicional: PageRank sobre nuevo esquema
// 1. Crear un subgrafo
CALL gds.graph.project(
    'Whole_PR',
    'Persona',
    'RELATED_TO',
    {relationshipProperties: 'Weight'}
);

// 3. Ejecutar el algoritmo
CALL gds.pageRank.stream('Whole_PR')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).Name As Name, score
ORDER BY score DESC, Name ASC;

// 4. Crear el atributo
CALL gds.pageRank.write(
    'Whole_PR',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'pageRank_WHOLE'
    }
)
YIELD nodePropertiesWritten, ranIterations;

// Ver los nodos más importantes
MATCH (p:Persona)
RETURN p.Name AS Persona, p.pageRank_WHOLE AS Popularidad
ORDER BY Popularidad DESC
LIMIT 5;


// Sugerencias de análisis en bloom para Louvain
//  - Cambio de color de acuerdo a la comunidad
//  - Aplicar análisis adicional al cambiar el tamaño de los nodos a través de PageRank
