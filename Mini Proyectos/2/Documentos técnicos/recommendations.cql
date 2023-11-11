// Mini Proyecto 2 - Equipo 3
// Recomendaciones
// IS727272 - Cordero Hernández, Marco Ricardo

// 2. Recomendaciones nativas
// 2.1 Recomendar películas basadas en el mismo director
MATCH (m:Movie)<-[:DIRECTED]-(p:Person)-[:DIRECTED]->(om:Movie)
WHERE m.title = ''
AND m <> om
RETURN m.title as peliculaInicial,
       om.title as peliculasRecomendada
ORDER BY peliculasRecomendada
LIMIT 5;

// 2.2 Recomendar películas basadas en la misma categoría
MATCH (m:Movie)-[:LISTED_IN]->(c:Category)<-[:LISTED_IN]-(om:Movie)
WHERE m.title = ''
AND m <> om
RETURN m.title as peliculaInicial,
       om.title as peliculasRecomendada,
       c.name as categoria
ORDER BY peliculasRecomendada
LIMIT 5;

// 2.3 Recomendar películas de un actor
CALL {
    MATCH (a:Person)-[:ACTED_IN]->(m:Movie)
    WHERE a.name = ''
    RETURN a.name AS Actor, m.title AS movie
    LIMIT 5
} WITH Actor, movie
RETURN Actor, COLLECT(movie) AS Películas;

// 2.4 Recomendar películas “extranjeras”
MATCH (a:Person)-[act:ACTED_IN]->(m:Movie)-[:FROM]->(c:Country)
WITH a, act, m, c
MATCH (m)-[:LISTED_IN]->(ct:Category)
WHERE c.name <> '' AND TRIM(c.name) <> 'United States'
RETURN DISTINCT m.title AS Película, COLLECT(DISTINCT c.name) AS Países,
       COLLECT(DISTINCT ct.name) AS Categorías, COUNT(DISTINCT a.name) AS totalActores
ORDER BY totalActores DESC
LIMIT 10;

// 2.5 Recomendar directores prominentes dentro de la industria
MATCH (c:Country)<-[:IS_CITIZEN_OF]-(d:Person)-[dr:DIRECTED]->(:Movie)
RETURN d.name AS Director, COLLECT(DISTINCT c.name) AS Nacionalidades,
       COUNT(dr) AS Películas
ORDER BY Películas DESC
LIMIT 5;

// 2.6 Recomendar películas en base a la nacionalidad de su director
MATCH (c:Country)<-[:IS_CITIZEN_OF]-(d:Person)-[dr:DIRECTED]->(m:Movie)
MATCH (m)-[:FROM]->(mc:Country)<-[:FROM]-(om:Movie)
WHERE d.name = '' AND c.name = mc.name AND m <> om
RETURN d.name AS Director, c.name AS País,
       COLLECT(DISTINCT om.title)[..10] AS peliculasNacionales;

// 2.7 Recomendaciones aleatorias dado un año específico
MATCH (m:Movie)
WITH m.title AS Película, m.releaseYear AS ry, RAND() AS r
WHERE ry = 0
RETURN Película
ORDER BY r
LIMIT 10;

// 2.8 Recomendar otros directores del mismo género
MATCH (d:Person)-[:DIRECTED]->(m:Movie)-[:LISTED_IN]->(c:Category)
MATCH (c)<-[:LISTED_IN]-(om:Movie)<-[:DIRECTED]-(od:Person)
WHERE m <> om AND d <> od
AND d.name = 'Quentin Tarantino'
RETURN d.name AS Director,
       COLLECT(DISTINCT od.name)[..5] AS otrosDirectores;

// 2.9 Recomendar películas de un país
MATCH (m:Movie)-[:FROM]->(c:Country)
WHERE c.name = ''
RETURN c.name AS País, COLLECT(DISTINCT m.title)[..10] AS Películas;

// 2.10 Recomendar actores que también han sido directores
MATCH (p:Person)-[:DIRECTED]->(m:Movie)<-[:ACTED_IN]-(p)
RETURN COLLECT(DISTINCT p.name) AS actores_directores,
       m.title AS Pelicula
LIMIT 10;


// 3. Recomendaciones con sustento (apoyadas a través de GDS)
// 3.1 Node Similarity entre películas a través de categorías
MATCH (m:Movie)-[s:SIMILAR]->(om:Movie)
WHERE m.title = ''
AND m <> om
AND s.score >= 0.75
RETURN m.title as películaOriginal,
       COLLECT(DISTINCT om.title)[0..5] as películasRecomendadas;

// 3.2 K-Nearest Neighbors entre películas
MATCH (m:Movie)-[ks:KSIMILAR]->(om:Movie)
WHERE m.title = ''
AND m <> om
AND ks.score >= 0.75
RETURN m.title as películaOriginal,
       COLLECT(DISTINCT om.title)[0..5] as películasRecomendadas;

// 3.3 Node Similarity entre actores y directores a través de nacionalidad
MATCH (d:Person)-[s:SIMILAR]->(p:Person)
WHERE d.name = ''
AND d <> p
AND s.score >= 0.33
RETURN d.name as personaInicial,
       COLLECT(DISTINCT p.name)[0..5] as personasRecomendadas;

// 3.4 Weakly Connected Components para películas
MATCH (m:Movie)
RETURN m.WCC AS Categoría, COLLECT(m.title)[1..5] AS Películas;

// 3.5 Strongly Connected Components para directores y actores
MATCH (p:Person)
RETURN p.SCC AS Gremio, COLLECT(p.name)[1..8] AS Colaboradores
ORDER BY Colaboradores DESC;

// 3.6 Lovain para películas usando K-Nearest Neigbors como relación
MATCH (m:Movie)
RETURN m.louvain AS Grupo, COLLECT(m.title)[1..5] AS Películas;

// 3.7 Label Propagation para personas
MATCH (p:Person)
RETURN p.labelPropagation AS Grupo, COLLECT(p.name)[3..8] AS Personas
ORDER BY Personas DESC;

// 3.8 Node Similarity entre películas a través de directores
MATCH (m:Movie)-[sd:SIMILAR_MD]->(om:Movie)
WHERE m.title = ''
AND m <> om
AND sd.score >= 0.75
RETURN m.title as películaOriginal,
       COLLECT(DISTINCT om.title)[0..5] as películasRecomendadas;

// 3.9 Node Similarity entre películas a través de actores
MATCH (m:Movie)-[sa:SIMILAR_MA]->(om:Movie)
WHERE m.title = ''
AND m <> om
AND sa.score >= 0.75
RETURN m.title as películaOriginal,
       COLLECT(DISTINCT om.title)[0..5] as películasRecomendadas;

// 3.10 Node Similarity entre películas a través de país
MATCH (m:Movie)-[sc:SIMILAR_MC]->(om:Movie)
WHERE m.title = ''
AND m <> om
AND sc.score >= 0.75
RETURN m.title as películaOriginal,
       COLLECT(DISTINCT om.title)[0..5] as películasRecomendadas;
