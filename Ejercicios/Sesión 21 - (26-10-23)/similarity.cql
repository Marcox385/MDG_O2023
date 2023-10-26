// IS727272 - Cordero Hernández, Marco Ricardo
// Recomendaciones utilizando una BDG
// Continuación de sesión anterior con algoritmos de similaridad

// Node Similarity
// 1. Creación del subgrafo
CALL gds.graph.project(
    'similarity',
    ['Product', 'Order'],
    {
        ORDERS: {
            properties: 'quantity'
        }
    }
);

// 2. Cálculo de la memoria requerida
CALL gds.nodeSimilarity.write.estimate(
    'similarity',
    {
        writeRelationshipType: 'SIMILAR',
        writeProperty: 'score'
    }
)
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory;

// 3. Ejecución del algoritmo
// NOTA: Los nodos que regresa la ejecución son los que apuntan a nodo A (Order en este caso)
CALL gds.nodeSimilarity.stream('similarity')
YIELD node1, node2, similarity
RETURN
    gds.util.asNode(node1).orderID AS Order1,
    gds.util.asNode(node2).orderID AS Order2,
    similarity
ORDER BY similarity DESC, Order1, Order2;
// Los resultados de esta similaridad estarán en función de la similaridad entre Product <- Order1
// con Product <- Order2 (en este caso, compara quantity)

// 4. Creación de atributo con resultado individual
CALL gds.nodeSimilarity.write(
    'similarity',
    {
        writeRelationshipType: 'SIMILAR',
        writeProperty: 'score'
    }
)
YIELD nodesCompared, relationshipsWritten;

// Recomendación de productos usando similarity
MATCH (pr1:Product)<-[:ORDERS]-(o1:Order)-[:SIMILAR]-(o2:Order)-[:ORDERS]->(pr2:Product)
WHERE o1.orderID = '10937' AND o2.orderID = '11008'
RETURN COLLECT(pr1), COLLECT(pr2);

// Combinación de recomendaciones anterior y similarity para mejores resultados
// Recomendación anterior
MATCH (p:Product)<-[:ORDERS]-(o:Order)-[:ORDERS]->(op:Product)
WHERE p.productName = 'Chai'
AND p <> op
RETURN p.productName as originalProduct,
       op.productName as recommendedProduct,
       COUNT(o.orderID) as numOrders
ORDER BY numOrders DESC
LIMIT 5;

// Recomendación nueva
MATCH (p:Product)<-[:ORDERS]-(o1:Order)-[s:SIMILAR]->(o2:Order)-[:ORDERS]->(op:Product)
WHERE p.productName = 'Chai'
AND s.score < 1
AND s.score >= 0.6
AND p <> op
AND o1 <> o2
RETURN p.productName as originalProduct,
       COLLECT(DISTINCT op.productName)[0..5] as recommendedProducts;

// Recomendaciones con comunidad (Lovain)
// Creación de subgrafo
CALL gds.graph.project(
    'louvain',
    ['Product', 'Order'],
    {
        ORDERS: {
            properties: 'quantity'
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
CALL gds.louvain.stream(
    'louvain',
    {
        nodeLabels: ['Order']
    }
)
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).orderID AS Order, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

// Creación de atributo con resultado individual
CALL gds.louvain.write(
    'louvain',
    {
        nodeLabels: 'Order',
        writeProperty: 'louvain'
    }
)
YIELD communityCount, modularity, modularities;
// Corrección pendiente (no funciona la implementación)
