// Mini Proyecto 3 - Equipo 1
// Requisitos previos y auxiliares para presentación interactiva
// IS727272 - Cordero Hernández, Marco Ricardo

// Dijkstra entre usuarios y artistas
CALL gds.graph.project(
    'Dijkstra-Dash',
    'Entity',
    {
        LISTENS_TO: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        }
    }
);

MATCH ()-[r:`DIJKSTRA-DASH`]->()
DETACH DELETE r;

MATCH (source:User {id: toInteger($neodash_user_id)}),
      (target:Artist {name: $neodash_artist_name})
CALL gds.shortestPath.dijkstra.write(
    'Dijkstra-Dash',
    {
        sourceNode: source,
        targetNode: target,
        relationshipWeightProperty: 'weight',
        writeRelationshipType: 'DIJKSTRA-DASH',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

MATCH (u:User)-[r:`DIJKSTRA-DASH`]->(a:Artist), (n:Entity)
WHERE ID(n) IN r.nodeIds
WITH u, r, a, n
WHERE u.id = toInteger($neodash_user_id)
AND a.name = $neodash_artist_name
RETURN u, r, a, n;

// DSSSSP para usuarios
CALL gds.graph.project(
    'DSSSSP-Dash',
    'User',
    {
        FRIEND_OF: {
            orientation: 'NATURAL',
            properties: 'weight'
        }
    }
);

MATCH ()-[r:`DSSSSP-DASH`]->()
DETACH DELETE r;

MATCH (source:User {id: toInteger($neodash_user_id_1)})
CALL gds.allShortestPaths.delta.write(
    'DSSSSP-Dash',
    {
        sourceNode: source,
        relationshipWeightProperty: 'weight',
        writeRelationshipType: 'DSSSSP-DASH',
        writeNodeIds: true,
        writeCosts: true
    }
)
YIELD relationshipsWritten
RETURN relationshipsWritten;

MATCH (u:User)-[r:`DSSSSP-DASH`]->(v:User)
WHERE u.id = toInteger($neodash_user_id_1)
RETURN u, r, v
LIMIT toInteger($neodash);

// Random Walk para mismos usuarios y artistas
CALL gds.graph.project(
    'RandomWalk-Dash',
    'Entity',
    {
        LISTENS_TO: {
            orientation: 'UNDIRECTED',
            Properties: 'weight'
        }
    }
);

MATCH (u:User), (a:Artist)
WHERE u.id = toInteger($neodash_user_id)
AND a.name = $neodash_artist_name
WITH COLLECT(a) AS sourceNodes
CALL gds.randomWalk.stream(
    'RandomWalk-Dash',
    {
        sourceNodes: sourceNodes,
        walkLength: toInteger($neodash_w_n),
        walksPerNode: 1,
        randomSeed: 727272,
        concurrency: 1
    }
)
YIELD nodeIds, path
RETURN nodeIds, path;
