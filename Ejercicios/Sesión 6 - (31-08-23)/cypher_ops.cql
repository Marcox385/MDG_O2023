// Encontrar todos los nodos alcanzables a N saltos desde una persona
MATCH (p:Person {name: ''})
MATCH (p)-[*1..N]-(n) // * Para indicar todos los saltos
RETURN p.name AS Persona, COUNT(DISTINCT n) as NodosAlcanzables

// ...
CALL {MATCH (p:Person {name: 'Kevin Bacon'})-[r]->()
MATCH rr = (p)-[*1..1]-(n)
RETURN p.name AS Name, COUNT(DISTINCT n) AS rr
UNION
MATCH (p:Person {name: 'Kevin Bacon'})-[r]->()
MATCH rr = (p)-[*1..2]-(n)
RETURN p.name AS Name, COUNT(DISTINCT n) AS rr
UNION
MATCH (p:Person {name: 'Kevin Bacon'})-[r]->()
MATCH rr = (p)-[*1..3]-(n)
RETURN p.name AS Name, COUNT(DISTINCT n) AS rr
UNION
MATCH (p:Person {name: 'Kevin Bacon'})-[r]->()
MATCH rr = (p)-[*1..4]-(n)
RETURN p.name AS Name, COUNT(DISTINCT n) AS rr
UNION
MATCH (p:Person {name: 'Kevin Bacon'})-[r]->()
MATCH rr = (p)-[*1..5]-(n)
RETURN p.name AS Name, COUNT(DISTINCT n) AS rr
UNION
MATCH (p:Person {name: 'Kevin Bacon'})-[r]->()
MATCH rr = (p)-[*1..6]-(n)
RETURN p.name AS Name, COUNT(DISTINCT n) AS rr}
RETURN Name, COLLECT(rr) as Degrees
