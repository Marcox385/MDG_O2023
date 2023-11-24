// Mini Proyecto 3 - Equipo 1
// Algoritmos de caminos y búsqueda
// IS727272 - Cordero Hernández, Marco Ricardo

// Modificación estructural previa
MATCH (n:Artist|User)
SET n:Entity;

MATCH (f:User)-[r:FRIEND_OF]->(g:User)
SET r.weight = 1;

MATCH (t:Tag)-[r:TAGS]->(a:Artist)
SET r.weight = 1;

// 1. ¿Cuál es el camino más corto desde un nodo hacía todos los demás?
// Frase en Bloom: Caminos cortos desde usuario $ID hacía $n usuarios
// Implementación dirigida
MATCH (u:User)-[r:PATH_DS_385]->(v:User)
WHERE u.id = $ID
RETURN u, r, v
LIMIT $n;

// 2. ¿Cuál es el camino más costoso de todos los caminos cortos generados?
MATCH (u:User)-[r:PATH_DS_385]->(v:User)
WHERE u.id = $ID
RETURN u.id AS Origen, v.id AS Destino, r.totalCost AS Costo
ORDER BY Costo DESC, Destino DESC
LIMIT 1;

// Frase en Bloom: Camino más costoso desde usuario $ID
MATCH (u:User)-[r:PATH_DS_385]->(v:User)
WHERE u.id = $ID
RETURN u, v, r
ORDER BY r.totalCost DESC, v.id DESC
LIMIT 1;

// 3. Suponiendo relaciones bidireccionales entre nodos
// ¿Cuál es una forma alterna de obtener el camino más
// corto desde un origen hacía otro nodo específico?
// Frase en Bloom: Dijkstra desde usuario $ID hacía artista $name
MATCH (u:User)-[r:PATH_1213_TO_YE]->(a:Artist), (n:Entity)
WHERE ID(n) IN r.nodeIds
WITH u, r, a, n
WHERE u.id = $ID
AND a.name = $name
RETURN u, r, a, n;

// 4. ¿Cuáles nodos se encuentran en común desde un
// origen hacía un destino del mismo tipo?
// Frase en Bloom: Dijkstra desde usuario $ID1 hacía usuario $ID2
MATCH (u1:User)-[r:PATH_1213_TO_1312]->(u2:User), (n:Entity)
WHERE ID(n) IN r.nodeIds
WITH u1, r, u2, n
WHERE u1.id = $ID1
AND u2.id = $ID2
RETURN u1, r, u2, n;

// 5.¿Qué nodos de un tipo específico se recolectan al
// realizar una caminata aleatoria partiendo desde un
// par de nodos definidos? Usando una distancia de 5 pasos
// Frase en Bloom: Caminata aleatoria de $n pasos usando a $a1 y $a2
MATCH (a:Artist)
WHERE a.name IN [$a1, $a2]
WITH COLLECT(a) AS sourceNodes
CALL gds.randomWalk.stream(
    'RandomWalk-U',
    {
        sourceNodes: sourceNodes,
        walkLength: $n,
        walksPerNode: 1,
        randomSeed: 385,
        concurrency: 1
    }
)
YIELD nodeIds, path
RETURN nodeIds, path;

// 6. ¿Qué otro tipo de caminatas aleatorias se pueden implementar?
// Frase de Bloom: Caminata aleatoria desde usuario $usr con $n pasos
MATCH (u:User)
WHERE u.id = $usr
WITH COLLECT(u) AS sourceNodes
CALL gds.randomWalk.stream(
    'RandomWalk-U-1',
    {
        sourceNodes: sourceNodes,
        walkLength: $n,
        walksPerNode: 1,
        randomSeed: 727272,
        concurrency: 1
    }
)
YIELD nodeIds, path
RETURN nodeIds, path;

// 7. ¿Cuál es el árbol mínimo para un nodo?
// Frase de Bloom: MWST de usuario $id
MATCH (source:User)-[r:USER-713-MINST]-(leaf:User)
WHERE source.id = $id
RETURN source, r, leaf;

// 8. ¿Cuál es el árbol mínimo de un nodo que cuente con al menos
// 3 niveles de profundidad? 
// Frase de Bloom: MWST extendido de entidad $id
MATCH (source:User)-[r:MINSTONES]-(leaf)
WHERE source.id = $id
RETURN source, r, leaf;

// 9. ¿Qué nodos resultan de una búsqueda a profundidad de 5 niveles?
// Frase de Bloom: DFS a $n niveles desde $id
MATCH (source:User {id: $id})
CALL gds.dfs.stream(
    'DFS-U',
    {
        sourceNode: source,
        maxDepth: $n
    }
)
YIELD path RETURN path;

// 10. ¿Qué nodos resultan de la exploración superficial de otro tipo de nodo?
// Frase de Bloom: Exploración inicial con DFS para $name
MATCH (source:Artist {name: $name})
CALL gds.dfs.stream(
    'DFS-D',
    {
        sourceNode: source,
        maxDepth: 1
    }
)
YIELD path RETURN path;
