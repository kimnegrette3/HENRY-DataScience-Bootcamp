USE HENRY;

-- No se sabe con certeza el lanzamiento de las cohortes N° 1245 y N° 1246, se solicita que las elimine de la tabla.
SELECT * FROM cohorte;

DELETE FROM cohorte
WHERE cohorte_id = 1245 OR cohorte_id = 1246;  -- tambien puede ser WHERE cohorte_id IN (1245, 1246)

-- Se ha decidido retrasar el comienzo de la cohorte N°1243, por lo que la nueva fecha de inicio será el 16/05. Se le solicita modificar la fecha de inicio de esos alumnos
SELECT * FROM alumnnos;

UPDATE alumnos   -- Tal vez esto no era necesario, puede que sean fechas independientes. 
SET fecha_ingreso = '2022-05-16'
WHERE cohorte_id = 1243;


UPDATE cohorte 
SET fecha_inicio = '2022-05-16'
WHERE cohorte_id = 1243;

-- El alumno N° 165 solicito el cambio de su Apellido por “Ramirez”.

UPDATE alumnos
SET apellido = 'Ramirez'
WHERE alumno_id = 165;

-- El área de Learning le solicita un listado de alumnos de la Cohorte N°1243 que incluya la fecha de ingreso.

SELECT nombre, apellido, fecha_ingreso
FROM alumnos
WHERE cohorte_id = 1243;


-- Como parte de un programa de actualización, el área de People le solicita un listado de los instructores que dictan la carrera de Full Stack Developer.
SELECT * FROM instructores;
SELECT * FROM cohorte;


SELECT nombre, apellido, instructor_id
FROM instructores
WHERE instructor_id IN (
	SELECT instructor_id 
    FROM cohorte
    WHERE carrera_id = (  -- o simplemente poner carrera_id = 1
		SELECT carrera_id 
        FROM carrera
        WHERE nombre = 'Full Stack Developer'
		)
	)
    ;
    
	SELECT DISTINCT instructor_id 
    FROM cohorte
    WHERE carrera_id = 1;


-- Se desea saber que alumnos formaron parte de la cohorte N° 1235. Elabore un listado.
SELECT * FROM alumnos;

SELECT alumno_id, nombre, apellido 
FROM alumnos
WHERE cohorte_id = 1235;

-- Del listado anterior se desea saber quienes ingresaron en el año 2019.
SELECT alumno_id, nombre, apellido, YEAR(fecha_ingreso)
FROM alumnos
WHERE cohorte_id = 1235 AND YEAR(fecha_ingreso) = 2019;


/* En el M3 profudizaremos en el aprendizaje de SQL, pero aprovechemos lo que sabemos hasta aquí para entender como funcionan las relacionales. */


SELECT 
    *
FROM
    alumnos AS a
        JOIN
    cohorte AS c ON a.cohorte_id = c.cohorte_id
        JOIN
    carrera AS cr ON c.carrera_id = cr.carrera_id;








