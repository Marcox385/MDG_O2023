// IS727272 - Cordero Hernández, Marco Ricardo

// Comentario

// Limpiar consola
:clear

// Nodos
()
(variable:Label)

// Relaciones
-- -[]- --> <-- -[]-> <-[]-

// Propiedades
{}

// Creación de nodos
CREATE create CReate
Persona Persona PeRSONA

CREATE (n:Persona)

CREATE (n:Persona {nombre: 'Juan'})

// Relaciones
CREATE (n:Persona {nombre: 'Luis'}),
(m:Persona {nombre: 'José', auto: 'VW'}),
(n)-[:AMIGO {desde: 2023}]->(m);

MATCH (n:Persona)
WHERE n.nombre = 'Juan'
MATCH (m:Persona {nombre: 'Luis'})
CREATE (n)-[:AMIGO]->(m);

// Similitud con SQL
SELECT  RETURN
FROM    MATCH
WHERE   WHERE

// Historial de comandos
:history

// Detalles de comandos
:help [COMANDO]

// Regresar todos los nodos con sus ID
MATCH (n)
RETURN elementId(n) AS NodeID // AS para renombrar columnas

// Esquema del grafo
CALL db.schema.visualization

// Etiquetas del grafo
CALL db.labels

// Tipos de relaciones
CALL db.relationshipTypes

// Relaciones de los nodos
CALL db.schema.nodeTypeProperties

// Propiedades de las relaciones
CALL db.schema.relTypeProperties

// Información de la base de datos
CALL db.info                // Información de la instancia
CALL dbms...
CALL dbms.components        // Información de la versión
CALL dbms.showCurrentUser   // Ver usuario actual y sus roles (variante de SHOW CURRENT USER)
:sysinfo                    // Métricas de uso del sistema
SHOW DATABASES              // Muestra las bases actuales
SHOW SERVER                 // Información del espacio donde corre neo4j
SHOW USERS                  // Lista todos los usuarios de la base -> CREATE USER ...
SHOW ROLES                  // Lista los roles posibles que se le pueden asignar a los usuarios
SHOW PRIVILEGES             // Muestra los privileigios correspondientes a los usuarios

// Funciones de agregación
COUNT, MAX, MIN, AVG, SUM, COLLECT, ...
COLLECT // Transforma nodos resultantes (o sus etiquetas) a listas

// Combinación de merge para declarar nuevos atributos o cambiarlos
MERGE (n:NombreDeNodo)
ON MATCH // Cuando existe el nodo
    SET atributo = 'valor'
ON CREATE // Cuando no existe el nodo y va a crearse
    SET fechaDeCreacion = datetime()
SET atributoDefault = 'creado' // Atributo que se crea en cualquier caso
RETURN n; // Mostrar resultado
