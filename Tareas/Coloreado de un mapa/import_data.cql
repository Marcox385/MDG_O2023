// IS727272 - Cordero Hernández, Marco Ricardo
// K-1 Coloring
// Data import

// Nodes
LOAD CSV WITH HEADERS FROM "file:///regions.csv" AS row
CREATE (r:Region)
SET r = row;

// Node index
CREATE INDEX index_Region FOR (r:Region) ON (r.id);

// Relationships
LOAD CSV FROM "file:///neighbors.csv" AS row
MATCH (r1:Region), (r2:Region)
WHERE r1.id = row[0] AND r2.id = row[1]
MERGE (r1)<-[:NEIGHBOR_OF]->(r2);