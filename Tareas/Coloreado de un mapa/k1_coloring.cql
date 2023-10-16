// IS727272 - Cordero Hernández, Marco Ricardo
// K-1 Coloring

// 1. Subgraph creation
CALL gds.graph.project(
    'k1_coloring',
    'Region',
    {
        NEIGHBOR_OF: {
            orientation: 'UNDIRECTED' // Suggested by documentation
        }
    }
);

// 2. Memory calculation - OMITTED (Algorithm is beta tier)

// 3. Algorithm execution
CALL gds.beta.k1coloring.stream('k1_coloring')
YIELD nodeId, color
RETURN gds.util.asNode(nodeId).region_name AS Region, color
ORDER BY Region;

// 4. Write results
CALL gds.beta.k1coloring.write(
    'k1_coloring',
    { writeProperty: 'color' }
)
YIELD nodeCount, colorCount, ranIterations, didConverge;

// Review results
MATCH (r:Region)
RETURN r.color AS Color, COLLECT(r.region_name) AS Regions
ORDER BY Color;
