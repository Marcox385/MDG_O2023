// IS727272 - Cordero Hernández, Marco Ricardo
// Práctica 2: Aplicando algoritmos de centralidad y comunidades para analizar un grafo
// Procedimientos generales

// 0. Fuente de datos - Creación del grafo
// 0.1. Importar datos
LOAD CSV WITH HEADERS FROM 'file:///nodos.csv' AS row
MERGE (c:Country {name: row.country})
CREATE (a:Airport)
SET a.id = toInteger(row.Id),
    a.name = row.Label,
    a.latitude = toFloat(row.latitude),
    a.longitude = toFloat(row.longitude)
MERGE (a)-[:LOCATED_IN]->(c);

// 0.2. Índices
// Índice de identificador
CREATE INDEX index_airId FOR (a:Airport) ON (a.id);

// Índice de búsqueda
CREATE INDEX index_airName FOR (a:Airport) ON (a.name);

// 0.3. Relaciones
LOAD CSV WITH HEADERS FROM 'file:///enlaces.csv' AS row
MATCH (a1:Airport), (a2:Airport)
WHERE a1.id = toInteger(row.Source)
AND a2.id = toInteger(row.Target)
MERGE (a1)-[:CONNECTS_WITH]->(a2);


// 2. Análisis básico
// 2.1. Una imagen del esquema general del grafo
CALL db.schema.visualization;

// 2.2. Una imagen del grafo completo
// Hecho en Gephi

// 2.3. Número de nodos y atributos
MATCH (n) RETURN COUNT(n) AS totalNodos; // Número de nodos
// Atributos de nodos
CALL db.schema.nodeTypeProperties()
YIELD nodeType AS Nodo, propertyName AS Propiedad, propertyTypes AS Tipo;

// 2.4. Número de relaciones y atributos
MATCH ()-[r]->() RETURN COUNT(r) AS totalRelaciones; // Número de relaciones
// Atributos de relaciones
CALL db.schema.relTypeProperties()
YIELD relType AS Relacion, propertyName AS Propiedad, propertyTypes AS Tipo;

// 2.5. Diámetro del grafo e interpretación
// Hecho en Gephi (el grafo es demasiado grande para ser analizado con Neo4j)

// 2.6. Densidad del grafo e interpretación
// Hecho en Gephi

// 2.7. Una consulta con cypher que muestre el número aeropuertos por cada país y una la lista de ellos
MATCH (a:Airport)-[:LOCATED_IN]->(c:Country)
RETURN c.name AS Country, COUNT(a) AS totalAirports, COLLECT(a.name) AS Airports
ORDER BY totalAirports DESC;

// 2.8. Una consulta con cypher que muestre el número de conexiones que cada país tiene con otros países
MATCH (c1:Country)<-[:LOCATED_IN]-(a:Airport)-[:CONNECTS_WITH]->(b:Airport)-[:LOCATED_IN]->(c2:Country)
WHERE c1.name <> c2.name
RETURN c1.name AS Origin, COUNT(DISTINCT c2) AS totalLinks
ORDER BY totalLinks DESC, Origin;

// 2.9. Una frase de búsqueda en Bloom que reciba el nombre del aeropuerto como parámetro y te regrese su grafo a un salto. Prueba con un aeropuerto de tu elección de Europa
// Frase: Graph of airport $AIRPORT at one hop
// Parámetro de entrada: AIRPORT := Nombre del aeropuerto
MATCH (a:Airport {name: $AIRPORT})
MATCH p=(a)-[*1..1]-(n)
RETURN p;

// 2.10. Una frase de búsqueda en Bloom que reciba el nombre del país como parámetro y te regrese su grafo a dos saltos. Prueba con México.
// Frase: Graph of country $COUNTRY at two hops
// Parámetro de entrada: COUNTRY := Nombre del país
MATCH (c:Country {name: $COUNTRY})
MATCH p=(c)-[*1..2]-(n)
RETURN p;


// 3. Preguntas guía (Ejecutar código de sección 4 antes)
// Centralidad
// ¿Qué nodos tienen la mayor cantidad de relaciones con otros nodos?
MATCH (a:Airport)
RETURN a.name AS Airport, a.Degree AS Conexiones
ORDER BY Conexiones DESC
LIMIT 5;

// ¿Qué nodos tienen la mayor cantidad de relaciones hacía otros nodos?
MATCH (a:Airport)
RETURN a.name AS Airport, a.Out_Degree AS Salidas
ORDER BY Salidas DESC
LIMIT 5;

// ¿Qué nodos tienen la menor cantidad de relaciones desde otros nodos?
MATCH (a:Airport)
RETURN a.name AS Airport, a.In_Degree AS Entradas
ORDER BY Entradas
LIMIT 5;

// ¿Cuál es el tercer nodo con la mayor cantidad de relaciones?
CALL {
    MATCH (a:Airport)
    RETURN a.name AS Airport, a.Degree AS Conexiones
    ORDER BY Conexiones DESC
    LIMIT 3
} WITH Airport, Conexiones
RETURN Airport, Conexiones
ORDER BY Conexiones
LIMIT 1;

// El camino más corto entre el nodo con mayor cantidad de relaciones salientes
// y el nodo con la menor cantidad de relaciones entrantes.
CALL {
    MATCH (n:Airport) RETURN n.name AS Airport
    ORDER BY n.Out_Degree DESC LIMIT 1
} WITH Airport AS a1
CALL {
    MATCH (n:Airport) RETURN n.name AS Airport
    ORDER BY n.In_Degree LIMIT 1
} WITH Airport AS a2, a1 AS a1
MATCH (a:Airport), (b:Airport)
WHERE a.name = a1
AND b.name = a2
RETURN shortestPath((a)-[*]-(b));

// ¿Cuál nodo es el más popular dentro del grafo?
CALL {
    MATCH (a:Airport)
    RETURN a.PageRank AS PR
    ORDER BY PR DESC LIMIT 1
} WITH toFloat(PR) AS PR
MATCH (a:Airport)
WITH a, toFloat(a.PageRank) AS pr, PR
RETURN
    a.name AS Airport,
    toString(ROUND(pr/PR, 2)*100) + '%' AS Popularidad
ORDER BY a.PageRank DESC
LIMIT 1;

// ¿Cuáles nodos no resultan tan relevantes dentro del grafo?
CALL {
    MATCH (a:Airport)
    RETURN a.PageRank AS PR
    ORDER BY PR DESC LIMIT 1
} WITH toFloat(PR) AS PR
MATCH (a:Airport)
WITH a, toFloat(a.PageRank) AS pr, PR
RETURN
    a.name AS Airport,
    toString(ROUND(pr/PR, 2)) + '%' AS Popularidad
ORDER BY a.PageRank
LIMIT 5;

// ¿Qué nodos conectan a distintas partes del grafo?
CALL {
    MATCH (a:Airport)
    RETURN a.BetweennessCentrality AS BT
    ORDER BY BT DESC LIMIT 1
} WITH toFloat(BT) AS BT
MATCH (a:Airport)
WITH a, toFloat(a.BetweennessCentrality) AS bt, BT
RETURN
    a.name AS Airport,
    toString(ROUND(bt/BT, 2)*100) + '%' AS Conecta
ORDER BY a.BetweennessCentrality DESC
LIMIT 5;

// ¿Qué nodos tienen la mejor capacidad para distribuir información a través del grafo?
CALL {
    MATCH (a:Airport)
    RETURN a.ClosenessCentrality AS CT
    ORDER BY CT DESC LIMIT 1
} WITH toFloat(CT) AS CT
MATCH (a:Airport)
WITH a, toFloat(a.ClosenessCentrality) AS ct, CT
RETURN
    a.name AS Airport,
    toString(ROUND(ct/CT, 2)*100) + '%' AS Distribuye
ORDER BY a.ClosenessCentrality
LIMIT 5;

// Si se combinaran las mediciones de Betweennesss y Closeness ¿Cuáles nodos
// resultan ser mejores para distribuir información a través de distintas partes del grafo?
CALL {
    MATCH (a:Airport)
    RETURN a.BetweennessCentrality AS BT
    ORDER BY BT DESC LIMIT 1
} WITH toFloat(BT) AS BT
CALL {
    MATCH (a:Airport)
    RETURN a.ClosenessCentrality AS CT
    ORDER BY CT DESC LIMIT 1
} WITH toFloat(CT) AS CT, BT
MATCH (a:Airport)
WITH a,
    toFloat(a.BetweennessCentrality) AS bt,
    toFloat(a.ClosenessCentrality) AS ct,
    BT, CT
RETURN
    a.name AS Airport,
    toString(ROUND(bt/BT, 2)*100) + '%' AS Conecta,
    toString(ROUND(ct/CT, 2)*100) + '%' AS Distribuye
ORDER BY
    a.BetweennessCentrality DESC,
    a.ClosenessCentrality DESC,
    Airport
LIMIT 5;

// Comunidad
// ¿Cuáles comunidades de nodos relacionados existen dentro del grafo?
MATCH (a:Airport)
RETURN
    a.louvain AS grupoAeroportuario,
    COLLECT(a.name) AS Aeropuertos
ORDER BY grupoAeroportuario;

// ¿Cuáles nodos demuestran conexiones estrechas entre sí?
MATCH (a:Airport)
RETURN a.name AS Aeropuerto, a.triangleCount AS conjuntosDeAeropuertos
ORDER BY conjuntosDeAeropuertos DESC
LIMIT 5;

// ¿Cuántos triángulos conforman al nodo con mayor cantidad de triadas?
MATCH (a:Airport)
RETURN a.name AS Aeropuerto, a.triangleCount AS conjuntosDeAeropuertos
ORDER BY conjuntosDeAeropuertos DESC
LIMIT 1;

// ¿Cuántas comunidades se encuentran dentro del grafo al etiquetar todos sus nodos?
MATCH (a:Airport)
RETURN a.labelPropagation AS Agrupación, COLLECT(a.name) AS Aeropuertos
ORDER BY Agrupación;

// ¿Cuál sería una forma alterna de revisar los nodos fuertemente conectados dentro del grafo
// después de aplicar los algoritmos anteriores?
MATCH (a:Airport)
RETURN
    a.labelPropagation AS Agrupación,
    SUM(a.triangleCount) AS conjuntosDeAeropuertos,
    COLLECT(a.name) AS Aeropuertos
ORDER BY conjuntosDeAeropuertos DESC, Agrupación;

// ¿Cuáles nodos cuentan con relaciones débiles indistintas?
MATCH (a:Airport)
RETURN a.weaklyConnected AS Agrupación, COLLECT(a.name) AS Aeropuertos
ORDER BY Agrupación;

// Suponiendo relaciones con baja relevancia ¿Cuántas comunidades pueden ser encontradas en todo el grafo?
MATCH (a:Airport)
RETURN COUNT(DISTINCT a.weaklyConnected) AS Agrupaciones;

// ¿Cuáles nodos cuentan con caminos bidireccionales?
MATCH (a:Airport)
RETURN a.stronglyConnected AS Agrupación, COLLECT(a.name) AS Aeropuertos
ORDER BY Agrupación;

// ¿Cuáles nodos cuentan con las mejores relaciones entre ellos?
MATCH (a:Airport)
RETURN a.stronglyConnected AS Agrupación, COLLECT(a.name) AS Aeropuertos
ORDER BY Agrupación, SIZE(Aeropuertos)
LIMIT 3;

// ¿Cuántos colores serían necesarios para colorear el grafo entero con la menor cantidad posible de colores?
MATCH (a:Airport)
RETURN COUNT(DISTINCT a.color) AS totalColores;


// 4. Modificación de la estructura del grafo
// 4.1. Añade un atributo Degree con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'Degree',
    'Airport',
    {
        CONNECTS_WITH: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.degree.write.estimate(
    'Degree',
    {writeProperty: 'Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.degree.stream('Degree')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.degree.write(
    'Degree',
    {writeProperty: 'Degree'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (a:Airport)
RETURN a.name AS Airport, toInteger(a.Degree) AS Degree
ORDER BY Degree DESC
LIMIT 5;

// 4.2. Añade un atributo In_Degree con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'In_Degree',
    'Airport',
    {
        CONNECTS_WITH: {
            orientation: 'REVERSE'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.degree.write.estimate(
    'In_Degree',
    {writeProperty: 'In_Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.degree.stream('In_Degree')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.degree.write(
    'In_Degree',
    {writeProperty: 'In_Degree'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (a:Airport)
RETURN a.name AS Airport, toInteger(a.In_Degree) AS In_Degree
ORDER BY In_Degree DESC
LIMIT 5;

// 4.3. Añade un atributo Out_Degree con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'Out_Degree',
    'Airport',
    {
        CONNECTS_WITH: {
            orientation: 'NATURAL'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.degree.write.estimate(
    'Out_Degree',
    {writeProperty: 'Out_Degree'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.degree.stream('Out_Degree')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.degree.write(
    'Out_Degree',
    {writeProperty: 'Out_Degree'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (a:Airport)
RETURN a.name AS Airport, toInteger(a.Out_Degree) AS Out_Degree
ORDER BY Out_Degree DESC
LIMIT 5;

// 4.4. Añade un atributo PageRank con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'PageRank',
    'Airport',
    'CONNECTS_WITH'
);

// Cálculo de memoria requerida
CALL gds.pageRank.write.estimate(
    'PageRank',
    {
        writeProperty: 'pageRank',
        maxIterations: 20,
        dampingFactor: 0.85
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.pageRank.stream('PageRank')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.pageRank.write(
    'PageRank',
    {
        maxIterations: 20,
        dampingFactor: 0.85,
        writeProperty: 'PageRank'
    }
)
YIELD nodePropertiesWritten, ranIterations;

// Resultado
MATCH (a:Airport)
RETURN a.name AS Airport, ROUND(a.PageRank) AS PageRank
ORDER BY PageRank DESC
LIMIT 5;

// 4.5. Añade un atributo Betweenness Centrality con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'Betweenness_Centrality',
    'Airport',
    'CONNECTS_WITH'
);

// Cálculo de memoria requerida
CALL gds.betweenness.write.estimate(
    'Betweenness_Centrality',
    {writeProperty: 'BetweennessCentrality'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.betweenness.stream('Betweenness_Centrality')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.betweenness.write(
    'Betweenness_Centrality',
    {writeProperty: 'BetweennessCentrality'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (a:Airport)
RETURN a.name AS Airport, ROUND(a.BetweennessCentrality, 4) AS BetweennessCentrality
ORDER BY BetweennessCentrality DESC
LIMIT 5;

// 4.6. Añade un atributo Closeness Centrality con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'Closeness_Centrality',
    'Airport',
    'CONNECTS_WITH'
);

// Se omite cálculo de memoria por calidad de algortimo (beta)

// Ejecución del algoritmo
CALL gds.beta.closeness.stream('Closeness_Centrality')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).name As Name, score
ORDER BY score DESC, Name ASC;

// Creación de atributo con resultado individual
CALL gds.beta.closeness.write(
    'Closeness_Centrality',
    {writeProperty: 'ClosenessCentrality'}
)
YIELD centralityDistribution, nodePropertiesWritten
RETURN
    centralityDistribution.min AS MinScore,
    centralityDistribution.max AS MaxScore,
    centralityDistribution.mean AS MeanScore,
    nodePropertiesWritten;

// Resultado
MATCH (a:Airport)
RETURN a.name AS Airport, ROUND(a.ClosenessCentrality, 4) AS ClosenessCentrality
ORDER BY ClosenessCentrality DESC
LIMIT 5;

//4.7. Añade un atributo louvain con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'louvain',
    'Airport',
    {
        CONNECTS_WITH: {
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
RETURN gds.util.asNode(nodeId).name AS Name, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// Creación de atributo con resultado individual
CALL gds.louvain.write(
    'louvain',
    { writeProperty: 'louvain' }
)
YIELD communityCount, modularity, modularities;

// Resultado
MATCH (a:Airport)
RETURN a.louvain AS Group, COLLECT(a.name) AS Airport;

// 4.8. Añade un atributo triangle count con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'triangle_count',
    'Airport',
    {
        CONNECTS_WITH: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Cálculo de memoria requerida
CALL gds.triangleCount.write.estimate(
    'triangle_count',
    {writeProperty: 'triangleCount'}
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.triangleCount.stream('triangle_count')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).name AS name, triangleCount
ORDER BY triangleCount DESC;

// Creación de atributo con resultado individual
CALL gds.triangleCount.write(
    'triangle_count',
    { writeProperty: 'triangleCount' }
)
YIELD globalTriangleCount, nodeCount;

// Resultado
MATCH (a:Airport)
RETURN a.name AS Airport, a.triangleCount as triangleCount
ORDER BY triangleCount DESC
LIMIT 5;

// 4.9. Añade un atributo label propagation con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'label_propagation',
    'Airport',
    {
        CONNECTS_WITH: {
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
RETURN gds.util.asNode(nodeId).name AS Name, labelPropagation
ORDER BY labelPropagation, Name;

// Creación de atributo con resultado individual
CALL gds.labelPropagation.write(
    'label_propagation',
    { writeProperty: 'labelPropagation' }
)
YIELD communityCount, ranIterations, didConverge;

// Resultado
MATCH (a:Airport)
RETURN a.labelPropagation AS Group, COLLECT (a.name) AS Airports;

// 4.10. Añade un atributo weakly connected components con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'weakly_connected',
    'Airport',
    {
        CONNECTS_WITH: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Cálculo de la memoria requerida
CALL gds.wcc.write.estimate(
    'weakly_connected',
    {
        writeProperty: 'weaklyConnected'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// Ejecución del algoritmo
CALL gds.wcc.stream('weakly_connected')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).name AS Name, componentId
ORDER BY componentId, Name;

// Creación de atributo con resultado individual
CALL gds.wcc.write(
    'weakly_connected',
    { writeProperty: 'weaklyConnected' })
YIELD nodePropertiesWritten, componentCount;

// Resultados
MATCH (a:Airport)
RETURN a.weaklyConnected AS Group, COLLECT(a.name) AS Airports;

// 4.11. Añade un atributo strongly connected components con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'strongly_connected',
    'Airport',
    {
        CONNECTS_WITH: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Se omite cálculo de memoria por calidad de algortimo (alpha)

// Ejecución del algoritmo
CALL gds.alpha.scc.stream('strongly_connected')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).name AS Name, componentId
ORDER BY componentId, Name;

// Creación de atributo con resultado individual
CALL gds.alpha.scc.write(
    'strongly_connected',
    { writeProperty: 'stronglyConnected' }
)
YIELD setCount, maxSetSize, minSetSize;

// Resultados
MATCH (a:Airport)
RETURN a.stronglyConnected AS Group, COLLECT(a.name) AS Airports;

// Creación de subgrafo
CALL gds.graph.project(
    'label_propagation',
    'Airport',
    {
        CONNECTS_WITH: {
            orientation: 'UNDIRECTED'
        }
    }
);

// 4.12. Añade un atributo coloreado con su valor correspondiente a cada nodo Airport
// Creación de subgrafo
CALL gds.graph.project(
    'k-1_coloring',
    'Airport',
    {
        CONNECTS_WITH: {
            orientation: 'UNDIRECTED'
        }
    }
);

// Se omite cálculo de memoria por falta calidad del algoritmo (beta)

// Ejecución del algoritmo
CALL gds.beta.k1coloring.stream('k-1_coloring')
YIELD nodeId, color
RETURN gds.util.asNode(nodeId).name AS Name, color
ORDER BY Name, color;

// Creación de atributo con resultado individual
CALL gds.beta.k1coloring.write(
    'k-1_coloring',
    { writeProperty: 'color' }
)
YIELD nodeCount, colorCount, ranIterations, didConverge;

// Resultado
MATCH (a:Airport)
RETURN a.color AS Color, COLLECT(a.name) AS Airports
ORDER BY Color;
