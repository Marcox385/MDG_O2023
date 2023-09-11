// Diametro del grafo (dirigido)
MATCH (start), (end)
WHERE start <> end
WITH shortestPath((start)-[*]->(end)) AS path
WITH length(path) AS distance
WHERE distance IS NOT NULL
RETURN distance
ORDER BY distance DESC 
LIMIT 1

// Diametro del grafo (no dirigido)
MATCH (start), (end)
WHERE start <> end
WITH shortestPath((start)-[*]-(end)) AS path
WITH length(path) AS distance
WHERE distance IS NOT NULL
RETURN distance
ORDER BY distance DESC 
LIMIT 1
