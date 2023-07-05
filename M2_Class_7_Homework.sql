USE HENRY;

-- cuántas carreras tiene HENRY?
SELECT COUNT(DISTINCT carrera_id) AS cantidad_carreras
FROM carrera;

-- Cuántos alumnos hay en total?
SELECT COUNT(*) AS cantidad_alumnos
FROM alumnos;

-- Cuántos alumnos tiene cada cohorte? 
SELECT cohorte_id, COUNT(*) AS cantidad_alumnos
FROM alumnos
GROUP BY cohorte_id;

-- Confecciona un listado de los alumnos ordenado por los últimos alumnos que ingresaron, con nombre y apellido en un solo campo.
SELECT CONCAT(nombre,' ',apellido) AS nombre_apellido, fecha_ingreso
FROM alumnos
ORDER BY fecha_ingreso DESC;

-- Cuál es el nombre del primer alumno que ingresó a Henry? 
SELECT nombre, apellido
FROM alumnos
ORDER BY fecha_ingreso ASC
LIMIT 1;

-- En qué fecha ingresó?
SELECT MIN(fecha_ingreso)
FROM alumnos;

-- Cuál es el nombre del último alumno que ingresó a Henry? 
SELECT nombre, apellido, fecha_ingreso
FROM alumnos
ORDER BY fecha_ingreso DESC
LIMIT 1;

-- La función YEAR le permite extraer el año de un campo date, utilice esta función y especifique cuantos alumnos ingresarona a Henry por año.
SELECT YEAR(fecha_ingreso) AS year, COUNT(*) AS count
FROM alumnos
GROUP BY year
ORDER BY year DESC; 

-- ¿Cuantos alumnos ingresaron por semana a henry?, indique también el año. WEEKOFYEAR()
SELECT YEAR(fecha_ingreso) AS year, WEEKOFYEAR(fecha_ingreso) AS week, COUNT(*) AS ingresados
FROM alumnos
GROUP BY year, week
ORDER BY year DESC;

-- En qué años ingresaron más de 20 alumnos?
SELECT YEAR(fecha_ingreso) AS year, COUNT(*) AS ingresados
FROM alumnos
GROUP BY year
HAVING ingresados > 20;

-- Investigue las funciones TIMESTAMPDIFF() y CURDATE(). ¿Podría utilizarlas para saber cual es la edad de los instructores?. 
-- ¿Como podrías verificar si la función calcula años completos? Utiliza DATE_ADD().
SELECT CONCAT(nombre, ' ', apellido) AS nombre_apellido, 
	TIMESTAMPDIFF(YEAR,fecha_nacimiento, CURDATE()) AS edad, 
    DATE_ADD(fecha_nacimiento, INTERVAL TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE()) YEAR) as verificacion
FROM instructores;

/*Cálcula:
- La edad de cada alumno.
- La edad promedio de los alumnos de henry.
- La edad promedio de los alumnos de cada cohorte.*/

SELECT alumno_id,
		CONCAT(nombre, ' ', apellido) AS nombre_apellido,
		TIMESTAMPDIFF(YEAR, fecha_nacimiento,CURDATE()) AS edad,
        fecha_nacimiento
FROM alumnos
WHERE TIMESTAMPDIFF(YEAR, fecha_nacimiento,CURDATE()) > 100; -- Para detectar el dato anómalo y corregirlo, es alumno con id 127 que tiene fecha_nacimiento '0202-01-02'

-- Corregir el dato anómalo por lo que probablemente es '2002-01-02'
UPDATE alumnos
SET fecha_nacimiento = '2002-01-02'
WHERE alumno_id = 127;

-- Ahora si la edad de los alumnos
SELECT alumno_id,
		CONCAT(nombre, ' ', apellido) AS nombre_apellido,
		TIMESTAMPDIFF(YEAR, fecha_nacimiento,CURDATE()) AS edad
FROM alumnos;

-- edad promedio
SELECT ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())),2) AS promedio_edad
FROM alumnos;

-- edad promedio de cada cohorte
SELECT cohorte_id, ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())),2) AS promedio_edad
FROM alumnos
GROUP BY cohorte_id;

-- Elabora un listado de los alumnos que superan la edad promedio de Henry.
SELECT nombre, apellido, TIMESTAMPDIFF(YEAR, fecha_nacimiento,CURDATE()) AS edad
FROM alumnos
WHERE TIMESTAMPDIFF(YEAR, fecha_nacimiento,CURDATE()) > (SELECT(ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())),2)) FROM alumnos);

-- Otra forma de hacerlo
SET @promedio := (SELECT avg(timestampdiff(YEAR, fecha_nacimiento, curdate())) from alumnos);

SELECT concat(nombre, ' ', apellido),TIMESTAMPDIFF(YEAR,fecha_nacimiento,curdate()) as edad,
@promedio as promedio_edad
FROM alumnos
where (TIMESTAMPDIFF(YEAR,fecha_nacimiento,curdate())) > @promedio
ORDER BY edad desc;
