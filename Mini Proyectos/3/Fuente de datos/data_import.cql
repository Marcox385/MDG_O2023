// Mini Proyecto 3 - Equipo 1
// Transformación e importe de datos
// IS727272 - Cordero Hernández, Marco Ricardo

// Los datos tienen extensión .dat con columnas separadas por tabulador (\t)
// Este formato puede interpretarse como .csv dentro de Neo4j

// El set de datos cuenta con distintos tipos de entidades:
//  - Artistas (artists.dat)
//  - Etiquetas (tags.dat)
//  - Usuarios (embebidos en varios archivos)
//  - Usuarios <-> Artistas (user_artists.dat)
//  - Usuarios <-> Amigos (user_friends.dat)
//  - Usuarios <-> Etiquetas de artistas (user_taggedartists.dat)
//  - Timestamp de etiquetas de artistas (user_taggedartists-timestamps.dat)

//// Debido a la extensión de los datos, los dos últimos archivos serán omitidos

// Artistas (≈ 14 segundos)
LOAD CSV WITH HEADERS FROM 'file:///dat_files/artists.dat' AS row
FIELDTERMINATOR '\t'
MERGE (a:Artist {name: row.name})
ON CREATE SET a.id = toInteger(row.id);

// Índice para artistas
CREATE INDEX index_artist_name FOR (a:Artist) ON (a.name);

// Usuarios a través de user_artists (≈ 6.3 minutos)
LOAD CSV WITH HEADERS FROM 'file:///dat_files/user_artists.dat' AS row
FIELDTERMINATOR '\t'
MERGE (u:User {id: toInteger(row.userID)})
WITH u, row
MATCH (a:Artist)
WHERE a.id = toInteger(row.artistID)
MERGE (u)-[:LISTENS_TO {weight: toInteger(row.weight)}]->(a);

// Índice para usuarios
CREATE INDEX index_user_id FOR (u:User) ON (u.id);

// Relación de amistad entre usuarios (≈ 1.3 segundos)
LOAD CSV WITH HEADERS FROM 'file:///dat_files/user_friends.dat' AS row
FIELDTERMINATOR '\t'
MATCH (u1:User), (u2:User)
WHERE u1.id = toInteger(row.userID)
AND u2.id = toInteger(row.friendID)
MERGE (u1)-[:FRIEND_OF]->(u2);

// Etiquetas (≈ 30 segundos)
LOAD CSV WITH HEADERS FROM 'file:///dat_files/tags.dat' AS row
FIELDTERMINATOR '\t'
MERGE (t:Tag {id: toInteger(row.tagID)})
ON CREATE SET t.tagValue = row.tagValue;

// Índice para etiquetas
CREATE INDEX index_tag_value FOR (t:Tag) ON (t.tagValue);

// Relación de etiquetado entre usuarios y artistas (≈ 31 minutos)
LOAD CSV WITH HEADERS FROM 'file:///dat_files/user_taggedartists.dat' AS row
FIELDTERMINATOR '\t'
MATCH (u:User), (t:Tag), (a:Artist)
WHERE u.id = toInteger(row.userID)
AND t.id = toInteger(row.tagID)
AND a.id = toInteger(row.artistID)
MERGE (u)-[:USES {id: toInteger(row.tagID),
    date: date(row.year + '-' + row.month + '-' + row.day)}]->(t)
MERGE (t)-[:TAGS]->(a);

// Complemento de relación de etiquetado con timestamps (≈ 6 segundos)
LOAD CSV WITH HEADERS FROM 'file:///dat_files/user_taggedartists-timestamps.dat' AS row
FIELDTERMINATOR '\t'
MATCH (u:User)-[l:LISTENS_TO]->(a:Artist)
WHERE u.id = toInteger(row.userID)
AND a.id = toInteger(row.artistID)
WITH u, l, a, datetime({epochMillis: toInteger(row.timestamp)}) AS tstamp
SET l.tagged_at = COALESCE(l.tagged_at, []) + tstamp;
