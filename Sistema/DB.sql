/* Creacion de la base de datos modelo y entramos en su espacio de nombres */
DROP DATABASE IF EXISTS modelo;
CREATE DATABASE modelo;
USE modelo;

DELIMITER $$

/*
	Que hace:
		Funcion para la ip de la conexion actual
	Funcionamiento:
*/
CREATE FUNCTION IP_CONEXION()
RETURNS VARCHAR(15)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
	/* Variable para almacenar la ip de la conexion actual */
    DECLARE ip_conexion VARCHAR(15) DEFAULT "";
    /* Consultamos la conexion actual y la guardamos en la variable ip_conexion */
    SELECT HOST INTO ip_conexion FROM information_schema.processlist WHERE id = CONNECTION_ID();
    /* retornamos la varaible ip_conexion que contiene la ip de la conexion actual */
    RETURN ip_conexion;
END;$$

DELIMITER ;

/* Tablas, procedimientos almacenados y triggers de dsitribuidores */

/* Tabla para almacenar a los distribuidores */
CREATE TABLE distribuidores
(
	rfc VARCHAR(13) PRIMARY KEY,
	nombres VARCHAR(50),
	apellido_paterno VARCHAR(50),
	apellido_materno VARCHAR(50),
	telefono VARCHAR(10),
	correo_electronico VARCHAR(50),
	numero_casa VARCHAR(5),
	calle VARCHAR(50),
	colonia VARCHAR(50),
	ciudad VARCHAR(50),
	estado VARCHAR(50),
	limite_credito FLOAT,
	monto_credito FLOAT
);

/* Tabla de respaldo para almacenar a los distribuidores eliminados */
CREATE TABLE distribuidores_borrados
(
    fecha DATETIME,
    usuario VARCHAR(50),
    ip VARCHAR(15),
     
	rfc VARCHAR(13),
	nombres VARCHAR(50),
	apellido_paterno VARCHAR(50),
	apellido_materno VARCHAR(50),
	telefono VARCHAR(10),
	correo_electronico VARCHAR(50),
	numero_casa VARCHAR(5),
	calle VARCHAR(50),
	colonia VARCHAR(50),
	ciudad VARCHAR(50),
	estado VARCHAR(50),
	limite_credito FLOAT,
	monto_credito FLOAT
);

/* Tabla de respaldo para almacenar a los distribuidores cambiados */
CREATE TABLE distribuidores_cambiados
(
    fecha DATETIME,
    usuario VARCHAR(50),
    ip VARCHAR(15),
    
    rfc_old VARCHAR(13),
    nombres_old VARCHAR(50),
    apellido_paterno_old VARCHAR(50),
    apellido_materno_old VARCHAR(50),
    telefono_old VARCHAR(10),
    correo_electronico_old VARCHAR(50),
    numero_casa_old VARCHAR(5),
    calle_old VARCHAR(50),
    colonia_old VARCHAR(50),
    ciudad_old VARCHAR(50),
    estado_old VARCHAR(50),
    limite_credito_old FLOAT,
    monto_credito_old FLOAT,
    
    rfc_new VARCHAR(13),
    nombres_new VARCHAR(50),
    apellido_paterno_new VARCHAR(50),
    apellido_materno_new VARCHAR(50),
    telefono_new VARCHAR(10),
    correo_electronico_new VARCHAR(50),
    numero_casa_new VARCHAR(5),
    calle_new VARCHAR(50),
    colonia_new VARCHAR(50),
    ciudad_new VARCHAR(50),
    estado_new VARCHAR(50),
    limite_credito_new FLOAT,
	monto_credito_new FLOAT
);

DELIMITER $$

/*
	Que hace:
		Procedimiento almacenado para agregar un distribuidor
    Parametros:
		rfc de tipo VARCHAR(13) es el rfc del dsitribuidor a gregar,
		nombres de tipo VARCHAR(50) es el nombre del dsitribuidor a gregar,
		apellido_paterno de tipo VARCHAR(50) es el apellido paterno del dsitribuidor a gregar,
		apellido_materno de tipo VARCHAR(50) es el apellido materno de distribuidor a gregar,
		telefono de tipo VARCHAR(10) es el telefono del dsitribuidor a gregar,
		correo_electronico de tipo VARCHAR(50) es el correo electronico del dsitribuidor a gregar,
		numero_casa de tipo VARCHAR(5) es el numero de casa donde vive el distribuidor a gregar,
		calle de tipo VARCHAR(50) es la calle donde vive el distribuidor a gregar,
		colonia de tipo VARCHAR(50) es la colonia donde vive el distribuidor a gregar,
		ciudad de tipo VARCHAR(50) es la ciudad donde vive el distribuidor a gregar,
		estado de tipo VARCHAR(50) es el estado donde vive el distribuidor a gregar,
		limite_credito de tipo FLOAT es el limite de credito que tiene el distribuidor a gregar
	Funcionamiento:
*/
CREATE PROCEDURE agregar_distribuidor
(
	rfc VARCHAR(13),
	nombres VARCHAR(50),
	apellido_paterno VARCHAR(50),
	apellido_materno VARCHAR(50),
	telefono VARCHAR(10),
	correo_electronico VARCHAR(50),
	numero_casa VARCHAR(5),
	calle VARCHAR(50),
	colonia VARCHAR(50),
	ciudad VARCHAR(50),
	estado VARCHAR(50),
	limite_credito FLOAT
)
BEGIN
	/*
		Se realiza una conteo de las coincidencias de la consulta a la tabla distribuidores con la condicion de que
        el rfc sea igual al rfc del dsitribuidor a agregar,
        en caso de encontrar una concidencia entra al if y eso quiere decir que el rfc que se quiere agregar es duplicado
	*/
	IF ( ( SELECT COUNT(*) FROM distribuidores WHERE distribuidores.rfc = rfc ) = 1 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "RFC de distribuidor duplicado" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "RFC de distribuidor duplicado";
	END IF;

	/*
		Se insertar una nuevo distribuidor con las variables pasadas por parametro
	*/
	INSERT INTO distribuidores VALUES
	(
		rfc,
		nombres,
		apellido_paterno,
		apellido_materno,
		telefono,
		correo_electronico,
		numero_casa,
		calle,
		colonia,
		ciudad,
		estado,
        /* Cuando se crea un distribuidor la primera vez el limite de credito es igual al monto de credito */
		limite_credito,
		limite_credito
	);

END;$$

/*
	Que hace:
		Procedimiento almacenado para borrar un distribuidor
	Parametros:
		rfc de tipo VARCHAR(13) es el rfc del distribuidor a borrar
	Funcionamiento:
*/
CREATE PROCEDURE borrar_distribuidor
(
	rfc VARCHAR(13)
)
BEGIN
	/*
		Se realiza un conteo de las coincidencias de la consulta a la tabla distribuidores con las condiciones de que
        el rfc sea igual al rfc del distribuidor que se quiere borrar,
        en caso de no encontrar coincidencias entrara al if eso quiere decir que no existe un distribuidor con ese rfc
    */
	IF( ( SELECT COUNT(*) FROM distribuidores WHERE distribuidores.rfc = rfc ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "El distribuidor no existe" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El distribuidor no existe";
	END IF;

	/*
		Se realiza un conteo de los resultados de la consulta a la tabla vales con la condicion de que el
        rfc_distribuidor sea igual al rfc de distribuidor que se quiere borrar y que el vale no este pagado,
        si se encontraron mas de una concidencia quiere decir que el distribuidor tiene deudas
    */
	IF( ( SELECT COUNT(*) FROM vales WHERE rfc_distribuidor = rfc AND pagado = false ) > 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "El distribuidor tiene deudas" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El distribuidor tiene deudas";
	END IF;

	/* Sino ocurrio ningun error entonces se borra el distribuidor que concida con el rfc */
	DELETE FROM distribuidores WHERE distribuidores.rfc = rfc;

END;$$

/*
	Que hace:
		Procedimiento almacenado para cambiar un distribuidor
	Parametros:
		rfc de tipo VARCHAR(13) es el rfc del distribuidor al que se le realizaran cambios,
		nombres de tipo VARCHAR(50) es el nuevo nombre del dsitribuidor,
		b_nombres de tipo BOOLEAN bandera para saber si se cambiara nombre del dsitribuidor,
		apellido_paterno de tipo VARCHAR(50) es el nuevo apellido paterno del dsitribuidor,
		b_apellido_paterno de tipo BOOLEAN bandera para saber si se cambiara apellido paterno del dsitribuidor,
		apellido_materno de tipo VARCHAR(50) es el nuevo apellido materno de distribuidor,
		b_apellido_materno de tipo BOOLEAN bandera para saber si se cambiara apellido materno de distribuidor,
		telefono de tipo VARCHAR(10) es el nuevo telefono del dsitribuidor,
		b_telefono de tipo BOOLEAN bandera para saber si se cambiara telefono del dsitribuidor,
		correo_electronico de tipo VARCHAR(50) es el nuevo correo electronico del dsitribuidor,
		b_correo_electronico de tipo BOOLEAN bandera para saber si se cambiara correo electronico del dsitribuidor,
		numero_casa de tipo VARCHAR(5) es el nuevo numero de casa donde vive el distribuidor,
		b_numero_casa de tipo BOOLEAN bandera para saber si se cambiara numero de casa donde vive el distribuidor,
		calle de tipo VARCHAR(50) es la nueva calle donde vive el distribuidor,
		b_calle de tipo BOOLEAN bandera para saber si se cambiara calle donde vive el distribuidor,
		colonia de tipo VARCHAR(50) es la nueva colonia donde vive el distribuidor,
		b_colonia de tipo BOOLEAN bandera para saber si se cambiara colonia donde vive el distribuidor,
		ciudad de tipo VARCHAR(50) es la nueva ciudad donde vive el distribuidor,
		b_ciudad de tipo BOOLEAN bandera para saber si se cambiara ciudad donde vive el distribuidor,
		estado de tipo VARCHAR(50) es el nuevo estado donde vive el distribuidor,
		b_estado de tipo BOOLEAN bandera para saber si se cambiara estado donde vive el distribuidor,
		limite_credito de tipo FLOAT es el nuevo limite de credito que tiene el distribuidor,
		b_limite_credito de tipo BOOLEAN bandera para saber si se cambiara limite de credito que tiene el distribuidor,
		monto_credito de tipo FLOAT es el nuevo monto de credito que tiene el distribuidor,
		b_monto_credito de tipo BOOLEAN bandera para saber si se cambiara monto de credito que tiene el distribuidor
	Funcionamiento:
*/
CREATE PROCEDURE cambiar_distribuidor
(
	rfc VARCHAR(13),
	nombres VARCHAR(50),
	b_nombres BOOLEAN,
	apellido_paterno VARCHAR(50),
	b_apellido_paterno BOOLEAN,
	apellido_materno VARCHAR(50),
	b_apellido_materno BOOLEAN,
	telefono VARCHAR(10),
	b_telefono BOOLEAN,
	correo_electronico VARCHAR(50),
	b_correo_electronico BOOLEAN,
	numero_casa VARCHAR(5),
	b_numero_casa BOOLEAN,
	calle VARCHAR(50),
	b_calle BOOLEAN,
	colonia VARCHAR(50),
	b_colonia BOOLEAN,
	ciudad VARCHAR(50),
	b_ciudad BOOLEAN,
	estado VARCHAR(50),
	b_estado BOOLEAN,
	limite_credito FLOAT,
	b_limite_credito BOOLEAN,
	monto_credito FLOAT,
	b_monto_credito BOOLEAN
)
BEGIN
	/* Varaible para armar la consulta update con los campos que si se van a cambiar */
	SET @consulta = "";

	/*
		Se realiza un conteo de las coincidencias de la consulta a la tabla distribuidores con las condiciones de que
        el rfc sea igual al rfc del distribuidor que se quiere cambiar,
        en caso de no encontrar coincidencias entrara al if eso quiere decir que no existe un distribuidor con ese rfc
    */
	IF( ( SELECT COUNT(*) FROM distribuidores WHERE distribuidores.rfc = rfc ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "El distribuidor no existe" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El distribuidor no existe";
	END IF;

	/*
		Se hace una consulta a la tabla distribuidores para almacenar el
        limite de credito en la varaible @limite_credito y el
        monto de credito en la variable @monto_credito con las condiciones de que
        el rfc sea igual al rfc del distribuidor que se quiere cambiar
    */
	SELECT distribuidores.limite_credito, distribuidores.monto_credito INTO @limite_credito, @monto_credito FROM distribuidores WHERE distribuidores.rfc = rfc;
    /*
		El if verifica si el monto de credito es mayor al limite de credito para los casos en los que
        se pone un nuevo limite de credito y el monto de credito se mantiene,
        se mantiene el limite de credito y se pone un nuevo monto de credito,
        se pone un nuevo limite de credito y se pone un nuevo monto de cerdito,
        en caso de ocurrir esto entra al if y quiere decir que esta mal ya que el monto de credito no puede ser mayor al limite de credito
    */
	IF(
		( b_limite_credito AND ( NOT b_monto_credito ) AND @monto_credito > limite_credito ) OR
		( ( NOT b_limite_credito ) AND b_monto_credito AND monto_credito > @limite_credito ) OR
		( b_limite_credito AND b_monto_credito AND monto_credito > limite_credito )
	)THEN
		/* Se cancela el procedimiento almacenando lanzando un error con el mensaje "El monto no puede ser mayor al limite de credito" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El monto no puede ser mayor al limite de credito";
	END IF;

	/* Se comienza a armar la consulta update guardandola en la varaible @consulta agregando los parametros si se activo su bandera en true */
	IF ( b_nombres ) THEN
		SET @consulta = CONCAT( @consulta,'nombres="',nombres,'",' );
	END IF;
	IF ( b_apellido_paterno ) THEN
		SET @consulta = CONCAT( @consulta,'apellido_paterno="',apellido_paterno,'",' );
	END IF;
	IF ( b_apellido_materno ) THEN
		SET @consulta = CONCAT( @consulta,'apellido_materno="',apellido_materno,'",' );
	END IF;
	IF ( b_telefono ) THEN
		SET @consulta = CONCAT( @consulta,'telefono="',telefono,'",' );
	END IF;
	IF ( b_correo_electronico ) THEN
		SET @consulta = CONCAT( @consulta,'correo_electronico="',correo_electronico,'",' );
	END IF;
	IF ( b_numero_casa ) THEN
		SET @consulta = CONCAT( @consulta,'numero_casa="',numero_casa,'",' );
	END IF;
	IF ( b_calle ) THEN
		SET @consulta = CONCAT( @consulta,'calle="',calle,'",' );
	END IF;
	IF ( b_colonia ) THEN
		SET @consulta = CONCAT( @consulta,'colonia="',colonia,'",' );
	END IF;
	IF ( b_ciudad ) THEN
		SET @consulta = CONCAT( @consulta,'ciudad="',ciudad,'",' );
	END IF;
	IF ( b_estado ) THEN
		SET @consulta = CONCAT( @consulta,'estado="',estado,'",' );
	END IF;
	IF ( b_limite_credito ) THEN
		SET @consulta = CONCAT( @consulta,'limite_credito=',limite_credito,',' );
	END IF;
	IF ( b_monto_credito ) THEN
		SET @consulta = CONCAT( @consulta,'monto_credito=',monto_credito,',' );
	END IF;
	SET @consulta = LEFT( @consulta, CHAR_LENGTH( @consulta ) - 1 );

	/* Sino se almaceno nada en la variable @consulta eso quiere decir que no se marco ninguna bandera para cambiar */
	IF( CHAR_LENGTH( @consulta ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "No selecciono ningun campo para actualizar" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "No selecciono ningun campo para actualizar";
    END IF;

	/* Se termina de armar la consulta update en la variable @consulta para el rfc del dsitribuidor a cambiar */
	SET @consulta = CONCAT( "UPDATE distribuidores SET ",@consulta,' WHERE rfc="',rfc,'";' );
	
    /* Se prepara la consulta update */
	PREPARE sentencia FROM @consulta;
    /* Se ejecuta la consulta update */
	EXECUTE sentencia;
    /* Se verifica si se afectaron filas por la consulta update en caso de no hacerlo quiere decir que no se agregaron datos distinto a los almacenados */
	IF( ROW_COUNT() = 0 ) THEN
		/* Se cancela el procedimiento almacenado con lanzando un error con el mensaje "No se agregaron datos diferentes a los actuales" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "No se agregaron datos diferentes a los actuales";
	END IF;

END;$$

/*
	Que hace:
		Consulta distribuidores que concidan con los valores de los parametros
	Parametros:
		rfc de tipo VARCHAR(13) es el rfc del distribuidor,
		b_rfc de tipo BOOLEAN bandera para saber si se consultara por el rfc del distribuidor,
		nombres de tipo VARCHAR(50) es el nombre del distribuidor,
		b_nombres de tipo BOOLEAN bandera para saber si se consultara por el nombre del distribuidor,
		apellido_paterno de tipo VARCHAR(50) es el apellido paterno del distribuidor,
		b_apellido_paterno de tipo BOOLEAN bandera para saber si se consultara por el apellido paterno del distribuidor,
		apellido_materno de tipo VARCHAR(50) es el apellido materno de distribuidor,
		b_apellido_materno de tipo BOOLEAN bandera para saber si se consultara por el apellido materno de distribuidor,
		telefono de tipo VARCHAR(10) es el telefono del distribuidor,
		b_telefono de tipo BOOLEAN bandera para saber si se consultara por el telefono del distribuidor,
		correo_electronico de tipo VARCHAR(50) es el correo electronico del distribuidor,
		b_correo_electronico de tipo BOOLEAN bandera para saber si se consultara por el correo electronico del distribuidor,
		numero_casa de tipo VARCHAR(5) es el numero de casa donde vive el distribuidor,
		b_numero_casa de tipo BOOLEAN bandera para saber si se consultara por el numero de casa donde vive el distribuidor,
		calle de tipo VARCHAR(50) es la calle donde vive el distribuidor,
		b_calle de tipo BOOLEAN bandera para saber si se consultara por la calle donde vive el distribuidor,
		colonia de tipo VARCHAR(50) es la colonia donde vive el distribuidor,
		b_colonia de tipo BOOLEAN bandera para saber si se consultara por la colonia donde vive el distribuidor,
		ciudad de tipo VARCHAR(50) es la ciudad donde vive el distribuidor,
		b_ciudad de tipo BOOLEAN bandera para saber si se consultara por la ciudad donde vive el distribuidor,
		estado de tipo VARCHAR(50) es el estado donde vive el distribuidor,
		b_estado de tipo BOOLEAN bandera para saber si se consultara por el estado donde vive el distribuidor,
		limite_credito de tipo FLOAT es el limite de credito que tiene el distribuidor,
		b_limite_credito de tipo BOOLEAN bandera para saber si se consultara por el limite de credito que tiene el distribuidor,
		monto_credito de tipo FLOAT es el monto de credito que tiene el distribuidor,
		b_monto_credito de tipo BOOLEAN bandera para saber si se consultara por el monto de credito que tiene el distribuidor
	Funcionamiento:
*/
CREATE PROCEDURE consultar_distribuidor
(
	rfc VARCHAR(13),
	b_rfc BOOLEAN,
	nombres VARCHAR(50),
	b_nombres BOOLEAN,
	apellido_paterno VARCHAR(50),
	b_apellido_paterno BOOLEAN,
	apellido_materno VARCHAR(50),
	b_apellido_materno BOOLEAN,
	telefono VARCHAR(10),
	b_telefono BOOLEAN,
	correo_electronico VARCHAR(50),
	b_correo_electronico BOOLEAN,
	numero_casa VARCHAR(5),
	b_numero_casa BOOLEAN,
	calle VARCHAR(50),
	b_calle BOOLEAN,
	colonia VARCHAR(50),
	b_colonia BOOLEAN,
	ciudad VARCHAR(50),
	b_ciudad BOOLEAN,
	estado VARCHAR(50),
	b_estado BOOLEAN,
	limite_credito FLOAT,
	b_limite_credito BOOLEAN,
	monto_credito FLOAT,
	b_monto_credito BOOLEAN
)
BEGIN
	/* Varaible para armar la consulta select con los campos que si se van a usar en la consulta */
	SET @consulta = "";

	/* Armamos la consulta select en la variable @consulta agregando los parametros si se activo su bandera en true */
	IF ( b_rfc ) THEN
		SET @consulta = CONCAT( @consulta,'rfc LIKE "',rfc,'%" AND ' );
	END IF;
	IF ( b_nombres ) THEN
		SET @consulta = CONCAT( @consulta,'nombres LIKE "',nombres,'%" AND ' );
	END IF;
	IF ( b_apellido_paterno ) THEN
		SET @consulta = CONCAT( @consulta,'apellido_paterno LIKE "',apellido_paterno,'%" AND ' );
	END IF;
	IF ( b_apellido_materno ) THEN
		SET @consulta = CONCAT( @consulta,'apellido_materno LIKE "',apellido_materno,'%" AND ' );
	END IF;
	IF ( b_telefono ) THEN
		SET @consulta = CONCAT( @consulta,'telefono LIKE "',telefono,'%" AND ' );
	END IF;
	IF ( b_correo_electronico ) THEN
		SET @consulta = CONCAT( @consulta,'correo_electronico LIKE "',correo_electronico,'%" AND ' );
	END IF;
	IF ( b_numero_casa ) THEN
		SET @consulta = CONCAT( @consulta,'numero_casa LIKE "',numero_casa,'%" AND ' );
	END IF;
	IF ( b_calle ) THEN
		SET @consulta = CONCAT( @consulta,'calle LIKE "',calle,'%" AND ' );
	END IF;
	IF ( b_colonia ) THEN
		SET @consulta = CONCAT( @consulta,'colonia LIKE "',colonia,'%" AND ' );
	END IF;
	IF ( b_ciudad ) THEN
		SET @consulta = CONCAT( @consulta,'ciudad LIKE "',ciudad,'%" AND ' );
	END IF;
	IF ( b_estado ) THEN
		SET @consulta = CONCAT( @consulta,'estado LIKE "',estado,'%" AND ' );
	END IF;
	IF ( b_limite_credito ) THEN
		SET @consulta = CONCAT( @consulta,'limite_credito LIKE "',limite_credito,'%" AND ' );
	END IF;
	IF ( b_monto_credito ) THEN
		SET @consulta = CONCAT( @consulta,'monto_credito LIKE "',monto_credito,'%" AND ' );
	END IF;
	SET @consulta = LEFT( @consulta, CHAR_LENGTH( @consulta ) - 5 );

	/* Si se seleccionaron campos con bandera en true se terminar de concatenar la consulta select en la variable @consulta */
	IF( CHAR_LENGTH( @consulta ) > 0 ) THEN
		SET @consulta = CONCAT( "SELECT * FROM distribuidores WHERE ", @consulta , ";" );
	/* Si no selecciono ninguna bandera en true para la consulta, se guarda la consulta de toda la tabla en la variable @consulta */
    ELSE
		SET @consulta = "SELECT * FROM distribuidores;";
	END IF;

	/* Preparamos la consulta */
	PREPARE sentencia FROM @consulta;
    /* Ejecutamos la consulta */
	EXECUTE sentencia;

END;$$

/* Tigger que se dispara cuando un distribuidor es borrado */
CREATE TRIGGER respaldo_distribuidores_borrados BEFORE DELETE ON distribuidores
FOR EACH ROW
BEGIN
	/* Inserta los datos del dsitribuidor eliminado comorespaldo en la tabla distribuidores_eliminados */
    INSERT INTO distribuidores_borrados VALUES
    (
		NOW(),
        USER(),
        IP_CONEXION(),
        
		OLD.rfc,
		OLD.nombres,
		OLD.apellido_paterno,
		OLD.apellido_materno,
		OLD.telefono,
		OLD.correo_electronico,
		OLD.numero_casa,
		OLD.calle,
		OLD.colonia,
		OLD.ciudad,
		OLD.estado,
		OLD.limite_credito,
		OLD.monto_credito
	);
END;$$

/* Trigger que se dispara cuando un distribuidor es cambiado */
CREATE TRIGGER respaldo_distribuidores_cambiados BEFORE UPDATE ON distribuidores
FOR EACH ROW
BEGIN
	/*
		Si hay diferencia entre alguno de los valores anteriores con los nuevo entra al if
        y le hace una copia de seguridad en la tabla distribuidores_cambiados
	*/
	IF
    (
		OLD.rfc != NEW.rfc OR
		OLD.nombres != NEW.nombres OR
		OLD.apellido_paterno != NEW.apellido_paterno OR
		OLD.apellido_materno != NEW.apellido_materno OR
		OLD.telefono != NEW.telefono OR
		OLD.correo_electronico != NEW.correo_electronico OR
		OLD.numero_casa != NEW.numero_casa OR
		OLD.calle != NEW.calle OR
		OLD.colonia != NEW.colonia OR
		OLD.ciudad != NEW.ciudad OR
		OLD.estado != NEW.estado OR
		OLD.limite_credito != NEW.limite_credito OR
		OLD.monto_credito != NEW.monto_credito
	)
    THEN
		INSERT INTO distribuidores_cambiados VALUES
		(
			NOW(),
			USER(),
			IP_CONEXION(),
			
			OLD.rfc,
			OLD.nombres,
			OLD.apellido_paterno,
			OLD.apellido_materno,
			OLD.telefono,
			OLD.correo_electronico,
			OLD.numero_casa,
			OLD.calle,
			OLD.colonia,
			OLD.ciudad,
			OLD.estado,
			OLD.limite_credito,
			OLD.monto_credito,
			
			NEW.rfc,
			NEW.nombres,
			NEW.apellido_paterno,
			NEW.apellido_materno,
			NEW.telefono,
			NEW.correo_electronico,
			NEW.numero_casa,
			NEW.calle,
			NEW.colonia,
			NEW.ciudad,
			NEW.estado,
			NEW.limite_credito,
			NEW.monto_credito
		);
    END IF;
END;$$

DELIMITER ;

/* Tablas, procedimientos almacenados y triggers de clientes */

/* Tabla para guardar a los clientes */
CREATE TABLE clientes
(
	rfc VARCHAR(13) PRIMARY KEY,
	nombres VARCHAR(50),
	apellido_paterno VARCHAR(50),
	apellido_materno VARCHAR(50),
	telefono VARCHAR(10),
	correo_electronico VARCHAR(50),
	numero_casa VARCHAR(5),
	calle VARCHAR(50),
	colonia VARCHAR(50),
	ciudad VARCHAR(50),
	estado VARCHAR(50),
	sexo VARCHAR(9),
	fecha_nacimiento DATE,
	moroso BOOLEAN,
	nombre_referencia VARCHAR(50),
	telefono_referencia VARCHAR(50),
	direccion_referencia VARCHAR(50)
);

/* Tabla para guardar a los clientes borrados */
CREATE TABLE clientes_borrados
(
    fecha DATETIME,
    usuario VARCHAR(50),
    ip VARCHAR(15),
     
	rfc VARCHAR(13),
	nombres VARCHAR(50),
	apellido_paterno VARCHAR(50),
	apellido_materno VARCHAR(50),
	telefono VARCHAR(10),
	correo_electronico VARCHAR(50),
	numero_casa VARCHAR(5),
	calle VARCHAR(50),
	colonia VARCHAR(50),
	ciudad VARCHAR(50),
	estado VARCHAR(50),
	sexo VARCHAR(9),
	fecha_nacimiento DATE,
	moroso BOOLEAN,
	nombre_referencia VARCHAR(50),
	telefono_referencia VARCHAR(50),
	direccion_referencia VARCHAR(50)
);

/* Tabla para guardar a los clientes cambiados */
CREATE TABLE clientes_cambiados
(
    fecha DATETIME,
    usuario VARCHAR(50),
    ip VARCHAR(15),
    
    rfc_old VARCHAR(13),
    nombres_old VARCHAR(50),
    apellido_paterno_old VARCHAR(50),
    apellido_materno_old VARCHAR(50),
    telefono_old VARCHAR(10),
    correo_electronico_old VARCHAR(50),
    numero_casa_old VARCHAR(5),
    calle_old VARCHAR(50),
    colonia_old VARCHAR(50),
    ciudad_old VARCHAR(50),
    estado_old VARCHAR(50),
	sexo_old VARCHAR(9),
	fecha_nacimiento_old DATE,
	moroso_old BOOLEAN,
	nombre_referencia_old VARCHAR(50),
	telefono_referencia_old VARCHAR(50),
	direccion_referencia_old VARCHAR(50),
    
    rfc_new VARCHAR(13),
    nombres_new VARCHAR(50),
    apellido_paterno_new VARCHAR(50),
    apellido_materno_new VARCHAR(50),
    telefono_new VARCHAR(10),
    correo_electronico_new VARCHAR(50),
    numero_casa_new VARCHAR(5),
    calle_new VARCHAR(50),
    colonia_new VARCHAR(50),
    ciudad_new VARCHAR(50),
    estado_new VARCHAR(50),
	sexo_new VARCHAR(9),
	fecha_nacimiento_new DATE,
	moroso_new BOOLEAN,
	nombre_referencia_new VARCHAR(50),
	telefono_referencia_new VARCHAR(50),
	direccion_referencia_new VARCHAR(50)
);

DELIMITER $$

/*
	Que hace:
		Procedimiento almacenado para agregar un cliente
    Parametros:
		rfc de tipo VARCHAR(13) es el rfc del cliente a gregar,
		nombres de tipo VARCHAR(50) es el nombre del cliente a gregar,
		apellido_paterno de tipo VARCHAR(50) es el apellido paterno del cliente a gregar,
		apellido_materno de tipo VARCHAR(50) es el apellido materno de cliente a gregar,
		telefono de tipo VARCHAR(10) es el telefono del cliente a gregar,
		correo_electronico de tipo VARCHAR(50) es el correo electronico del cliente a gregar,
		numero_casa de tipo VARCHAR(5) es el numero de casa donde vive el cliente a gregar,
		calle de tipo VARCHAR(50) es la calle donde vive el cliente a gregar,
		colonia de tipo VARCHAR(50) es la colonia donde vive el cliente a gregar,
		ciudad de tipo VARCHAR(50) es la ciudad donde vive el cliente a gregar,
		estado de tipo VARCHAR(50) es el estado donde vive el cliente a gregar,
        sexo de tipo VARCHAR(9) es el sexo al que pertenece el cliente a agregar,
        fecha_nacimiento de tipo DATE es la fecha en la que nacio el cliente a agregar,
        nombre_referencia de tipo VARCHAR(50) es el nombre de un contacto del cliente a agregar,
        telefono_referencia de tipo VARCHAR(50) es el telefono de un contacto del cliente a agregar,
        direccion_referencia de tipo VARCHAR(50) es la direccion de un contacto del cliente a agregar
	Funcionamiento:
*/
CREATE PROCEDURE agregar_cliente
(
	rfc VARCHAR(13),
	nombres VARCHAR(50),
	apellido_paterno VARCHAR(50),
	apellido_materno VARCHAR(50),
	telefono VARCHAR(10),
	correo_electronico VARCHAR(50),
	numero_casa VARCHAR(5),
	calle VARCHAR(50),
	colonia VARCHAR(50),
	ciudad VARCHAR(50),
	estado VARCHAR(50),
	sexo VARCHAR(9),
	fecha_nacimiento DATE,
	nombre_referencia VARCHAR(50),
	telefono_referencia VARCHAR(50),
	direccion_referencia VARCHAR(50)
)
BEGIN

	/*
		Se realiza un conteo de los resultados de la consulta a la tabla clientes con las condiciones de que
        el rfc sea igual al rfc del cliente a agregar, si encuentra un resultado entra al if y eso quiere decir
        que el rfc del cliente esta duplicado
    */
	IF ( ( SELECT COUNT(*) FROM clientes WHERE clientes.rfc = rfc ) = 1 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje de "RFC de cliente duplicado" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "RFC de cliente duplicado";
	END IF;

	/* Inserta el cliente en la tabla clientes */
	INSERT INTO clientes VALUES
	(
		rfc,
		nombres,
		apellido_paterno,
		apellido_materno,
		telefono,
		correo_electronico,
		numero_casa,
		calle,
		colonia,
		ciudad,
		estado,
		sexo,
		fecha_nacimiento,
        /* Por defecto un nuevo cliente no es moroso */
		false,
		nombre_referencia,
		telefono_referencia,
		direccion_referencia
	);

END;$$

/*
	Que hace:
		Procedimiento almacenado para borrar un cliente
    Parametros:
		rfc de tipo VARCHAR(13) es el rfc del cliente a borrar
	Funcionamiento:
*/
CREATE PROCEDURE borrar_cliente
(
	rfc VARCHAR(13)
)
BEGIN

	/*
		Se realiza un conteo de los resultados de la consulta a la tabla clientes con las condiciones de que
        el rfc sea igual al rfc del cliente a agregar, si no encuentra un resultado entra al if y eso quiere decir
        que el rfc del cliente no existe
    */
	IF( ( SELECT COUNT(*) FROM clientes WHERE clientes.rfc = rfc ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje de "El cliente no existe" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El cliente no existe";
	END IF;

	/*
		Se realiza un conteo de los resultados de la consulta a la vales clientes con las condiciones de que
        el rfc_cliente sea igual al rfc del cliente a agregar y pagado sea falso, si no encuentra un resultado entra al if
        y eso quiere decir que el cliente tiene deudas
    */
	IF( ( SELECT COUNT(*) FROM vales WHERE rfc_cliente = rfc AND pagado = false ) = 1 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje de "El cliente tiene deudas" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El cliente tiene deudas";
	END IF;

	/* Se elimina el cliente de la tabla clientes */
	DELETE FROM clientes WHERE clientes.rfc = rfc;

END;$$

/*
	Que hace:
		Procedimiento almacenado para cambiar un cliente
	Parametros:
		rfc de tipo VARCHAR(13) es el rfc del cliente al que se le realizaran cambios,
		nombres de tipo VARCHAR(50) es el nuevo nombre del cliente,
		b_nombres de tipo BOOLEAN bandera para saber si se cambiara nombre del cliente,
		apellido_paterno de tipo VARCHAR(50) es el nuevo apellido paterno del cliente,
		b_apellido_paterno de tipo BOOLEAN bandera para saber si se cambiara apellido paterno del cliente,
		apellido_materno de tipo VARCHAR(50) es el nuevo apellido materno de cliente,
		b_apellido_materno de tipo BOOLEAN bandera para saber si se cambiara apellido materno de cliente,
		telefono de tipo VARCHAR(10) es el nuevo telefono del cliente,
		b_telefono de tipo BOOLEAN bandera para saber si se cambiara telefono del cliente,
		correo_electronico de tipo VARCHAR(50) es el nuevo correo electronico del cliente,
		b_correo_electronico de tipo BOOLEAN bandera para saber si se cambiara correo electronico del cliente,
		numero_casa de tipo VARCHAR(5) es el nuevo numero de casa donde vive el cliente,
		b_numero_casa de tipo BOOLEAN bandera para saber si se cambiara numero de casa donde vive el cliente,
		calle de tipo VARCHAR(50) es la nueva calle donde vive el cliente,
		b_calle de tipo BOOLEAN bandera para saber si se cambiara calle donde vive el cliente,
		colonia de tipo VARCHAR(50) es la nueva colonia donde vive el cliente,
		b_colonia de tipo BOOLEAN bandera para saber si se cambiara colonia donde vive el cliente,
		ciudad de tipo VARCHAR(50) es la nueva ciudad donde vive el cliente,
		b_ciudad de tipo BOOLEAN bandera para saber si se cambiara ciudad donde vive el cliente,
		estado de tipo VARCHAR(50) es el nuevo estado donde vive el cliente,
		b_estado de tipo BOOLEAN bandera para saber si se cambiara estado donde vive el cliente,
        sexo de tipo VARCHAR(9) es el nuevo sexo al que pertenece el cliente,
        b_sexo de tipo BOOLEAN bandera para saber si se cambiara el sexo del cliente,
        fecha_nacimiento de tipo DATE es la nueva fecha en la que nacio el cliente,
        b_fecha_nacimiento de tipo BOOLEAN bandera para saber si se cambiara la fecha de nacimiento del cliente,
        moroso de tipo BOOLEAN es el nuevo estado de moroso del cliente,
        b_moroso de tipo BOOLEAN bandera para saber si se cambiara el estado moroso del cliente,
        nombre_referencia de tipo VARCHAR(50) es el nuevo nombre de un contacto del cliente,
        b_nombre_referencia de tipo BOOLEAN bandera para saber si se cambiara el nombre de referencia del cliente,
        telefono_referencia de tipo VARCHAR(50) es el nuevo telefono de un contacto del cliente,
        b_telefono_referencia de tipo BOOLEAN bandera para saber si se cambiara el telefono de referencia del cliente,
        direccion_referencia de tipo VARCHAR(50) es la nueva direccion de un contacto del cliente,
        b_direccion_referencia de tipo BOOLEAN bandera para saber si se cambiara la direccion de referencia del cliente
	Funcionamiento:
*/
CREATE PROCEDURE cambiar_cliente
(
	rfc VARCHAR(13),
	nombres VARCHAR(50),
	b_nombres BOOLEAN,
	apellido_paterno VARCHAR(50),
	b_apellido_paterno BOOLEAN,
	apellido_materno VARCHAR(50),
	b_apellido_materno BOOLEAN,
	telefono VARCHAR(10),
	b_telefono BOOLEAN,
	correo_electronico VARCHAR(50),
	b_correo_electronico BOOLEAN,
	numero_casa VARCHAR(5),
	b_numero_casa BOOLEAN,
	calle VARCHAR(50),
	b_calle BOOLEAN,
	colonia VARCHAR(50),
	b_colonia BOOLEAN,
	ciudad VARCHAR(50),
	b_ciudad BOOLEAN,
	estado VARCHAR(50),
	b_estado BOOLEAN,
	sexo VARCHAR(9),
	b_sexo BOOLEAN,
	fecha_nacimiento DATE,
	b_fecha_nacimiento BOOLEAN,
	moroso BOOLEAN,
	b_moroso BOOLEAN,
	nombre_referencia VARCHAR(50),
	b_nombre_referencia BOOLEAN,
	telefono_referencia VARCHAR(50),
	b_telefono_referencia BOOLEAN,
	direccion_referencia VARCHAR(50),
	b_direccion_referencia BOOLEAN
)
BEGIN
	/* Varaible para armar la consulta update con los campos que si se van a cambiar */
	SET @consulta = "";

	/*
		Se realiza un conteo de los resultados de la consulta a la tabla clientes con las condiciones de que
        el rfc sea igual al rfc del cliente a cambiar, si no encuentra un resultado entra al if y eso quiere decir
        que el rfc del cliente no existe
    */
	IF( ( SELECT COUNT(*) FROM clientes WHERE clientes.rfc = rfc ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje de "El cliente no existe" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El cliente no existe";
	END IF;

	/* Se comienza a armar la consulta update guardandola en la varaible @consulta agregando los parametros si se activo su bandera en true */
	IF ( b_nombres ) THEN
		SET @consulta = CONCAT( @consulta,'nombres="',nombres,'",' );
	END IF;
	IF ( b_apellido_paterno ) THEN
		SET @consulta = CONCAT( @consulta,'apellido_paterno="',apellido_paterno,'",' );
	END IF;
	IF ( b_apellido_materno ) THEN
		SET @consulta = CONCAT( @consulta,'apellido_materno="',apellido_materno,'",' );
	END IF;
	IF ( b_telefono ) THEN
		SET @consulta = CONCAT( @consulta,'telefono="',telefono,'",' );
	END IF;
	IF ( b_correo_electronico ) THEN
		SET @consulta = CONCAT( @consulta,'correo_electronico="',correo_electronico,'",' );
	END IF;
	IF ( b_numero_casa ) THEN
		SET @consulta = CONCAT( @consulta,'numero_casa="',numero_casa,'",' );
	END IF;
	IF ( b_calle ) THEN
		SET @consulta = CONCAT( @consulta,'calle="',calle,'",' );
	END IF;
	IF ( b_colonia ) THEN
		SET @consulta = CONCAT( @consulta,'colonia="',colonia,'",' );
	END IF;
	IF ( b_ciudad ) THEN
		SET @consulta = CONCAT( @consulta,'ciudad="',ciudad,'",' );
	END IF;
	IF ( b_estado ) THEN
		SET @consulta = CONCAT( @consulta,'estado="',estado,'",' );
	END IF;
	IF ( b_sexo ) THEN
		SET @consulta = CONCAT( @consulta,'sexo="',sexo,'",' );
	END IF;
	IF ( b_fecha_nacimiento ) THEN
		SET @consulta = CONCAT( @consulta,'fecha_nacimiento="',fecha_nacimiento,'",' );
	END IF;
	IF ( b_moroso ) THEN
		SET @consulta = CONCAT( @consulta,'moroso=',moroso,',' );
	END IF;
	IF ( b_nombre_referencia ) THEN
		SET @consulta = CONCAT( @consulta,'nombre_referencia="',nombre_referencia,'",' );
	END IF;
	IF ( b_telefono_referencia ) THEN
		SET @consulta = CONCAT( @consulta,'telefono_referencia="',telefono_referencia,'",' );
	END IF;
	IF ( b_direccion_referencia ) THEN
		SET @consulta = CONCAT( @consulta,'direccion_referencia="',direccion_referencia,'",' );
	END IF;
	SET @consulta = LEFT( @consulta, CHAR_LENGTH( @consulta ) - 1 );

	/* Sino se almaceno nada en la variable @consulta eso quiere decir que no se marco ninguna bandera para cambiar */
	IF( CHAR_LENGTH( @consulta ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "No selecciono ningun campo para actualizar" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "No selecciono ningun campo para actualizar";
    END IF;
    
	/* Se termina de armar la consulta update en la variable @consulta para el rfc del cliente a cambiar */
	SET @consulta = CONCAT( "UPDATE clientes SET ",@consulta,' WHERE rfc="',rfc,'";' );

	/* Se prepara la consulta update */
	PREPARE sentencia FROM @consulta;
    /* Se ejecuta la consulta update */
	EXECUTE sentencia;
    /* Se verifica si se afectaron filas por la consulta update en caso de no hacerlo quiere decir que no se agregaron datos distinto a los almacenados */
	IF( ROW_COUNT() = 0 ) THEN
		/* Se cancela el procedimiento almacenado con lanzando un error con el mensaje "No se agregaron datos diferentes a los actuales" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "No se agregaron datos diferentes a los actuales";
	END IF;

END;$$

/*
	Que hace:
		Consulta clientes que concidan con los valores de los parametros
	Parametros:
		rfc de tipo VARCHAR(13) es el rfc del distribuidor,
		b_rfc de tipo BOOLEAN bandera para saber si se consultara por el rfc del distribuidor,
		nombres de tipo VARCHAR(50) es el nombre del distribuidor,
		b_nombres de tipo BOOLEAN bandera para saber si se consultara por el nombre del distribuidor,
		apellido_paterno de tipo VARCHAR(50) es el apellido paterno del distribuidor,
		b_apellido_paterno de tipo BOOLEAN bandera para saber si se consultara por el apellido paterno del distribuidor,
		apellido_materno de tipo VARCHAR(50) es el apellido materno de distribuidor,
		b_apellido_materno de tipo BOOLEAN bandera para saber si se consultara por el apellido materno de distribuidor,
		telefono de tipo VARCHAR(10) es el telefono del distribuidor,
		b_telefono de tipo BOOLEAN bandera para saber si se consultara por el telefono del distribuidor,
		correo_electronico de tipo VARCHAR(50) es el correo electronico del distribuidor,
		b_correo_electronico de tipo BOOLEAN bandera para saber si se consultara por el correo electronico del distribuidor,
		numero_casa de tipo VARCHAR(5) es el numero de casa donde vive el distribuidor,
		b_numero_casa de tipo BOOLEAN bandera para saber si se consultara por el numero de casa donde vive el distribuidor,
		calle de tipo VARCHAR(50) es la calle donde vive el distribuidor,
		b_calle de tipo BOOLEAN bandera para saber si se consultara por la calle donde vive el distribuidor,
		colonia de tipo VARCHAR(50) es la colonia donde vive el distribuidor,
		b_colonia de tipo BOOLEAN bandera para saber si se consultara por la colonia donde vive el distribuidor,
		ciudad de tipo VARCHAR(50) es la ciudad donde vive el distribuidor,
		b_ciudad de tipo BOOLEAN bandera para saber si se consultara por la ciudad donde vive el distribuidor,
		estado de tipo VARCHAR(50) es el estado donde vive el distribuidor,
		b_estado de tipo BOOLEAN bandera para saber si se consultara por el estado donde vive el distribuidor,
        sexo de tipo VARCHAR(9) es el sexo al que pertenece el cliente,
        b_sexo de tipo BOOLEAN bandera para saber si se consultara por el sexo del cliente,
        fecha_nacimiento de tipo DATE es la fecha en la que nacio el cliente,
        b_fecha_nacimiento de tipo BOOLEAN bandera para saber si se consultara por la fecha de nacimiento del cliente,
        moroso de tipo BOOLEAN es el estado de moroso del cliente,
        b_moroso de tipo BOOLEAN bandera para saber si se consultara por el estado moroso del cliente,
        nombre_referencia de tipo VARCHAR(50) es el nombre de un contacto del cliente,
        b_nombre_referencia de tipo BOOLEAN bandera para saber si se consultara por el nombre de referencia del cliente,
        telefono_referencia de tipo VARCHAR(50) es el telefono de un contacto del cliente,
        b_telefono_referencia de tipo BOOLEAN bandera para saber si se consultara por el telefono de referencia del cliente,
        direccion_referencia de tipo VARCHAR(50) es la direccion de un contacto del cliente,
        b_direccion_referencia de tipo BOOLEAN bandera para saber si se consultara por la direccion de referencia del cliente
	Funcionamiento:
*/
CREATE PROCEDURE consultar_cliente
(
	rfc VARCHAR(13),
	b_rfc BOOLEAN,
	nombres VARCHAR(50),
	b_nombres BOOLEAN,
	apellido_paterno VARCHAR(50),
	b_apellido_paterno BOOLEAN,
	apellido_materno VARCHAR(50),
	b_apellido_materno BOOLEAN,
	telefono VARCHAR(10),
	b_telefono BOOLEAN,
	correo_electronico VARCHAR(50),
	b_correo_electronico BOOLEAN,
	numero_casa VARCHAR(5),
	b_numero_casa BOOLEAN,
	calle VARCHAR(50),
	b_calle BOOLEAN,
	colonia VARCHAR(50),
	b_colonia BOOLEAN,
	ciudad VARCHAR(50),
	b_ciudad BOOLEAN,
	estado VARCHAR(50),
	b_estado BOOLEAN,
	sexo VARCHAR(9),
	b_sexo BOOLEAN,
	fecha_nacimiento DATE,
	b_fecha_nacimiento BOOLEAN,
	moroso BOOLEAN,
	b_moroso BOOLEAN,
	nombre_referencia VARCHAR(50),
	b_nombre_referencia BOOLEAN,
	telefono_referencia VARCHAR(50),
	b_telefono_referencia BOOLEAN,
	direccion_referencia VARCHAR(50),
	b_direccion_referencia BOOLEAN
)
BEGIN
	/* Varaible para armar la consulta select con los campos que si se van a usar en la consulta */
	SET @consulta = "";

	/* Armamos la consulta select en la variable @consulta agregando los parametros si se activo su bandera en true */
	IF ( b_rfc ) THEN
		SET @consulta = CONCAT( @consulta,'rfc LIKE "',rfc,'%" AND ' );
	END IF;
	IF ( b_nombres ) THEN
		SET @consulta = CONCAT( @consulta,'nombres LIKE "',nombres,'%" AND ' );
	END IF;
	IF ( b_apellido_paterno ) THEN
		SET @consulta = CONCAT( @consulta,'apellido_paterno LIKE "',apellido_paterno,'%" AND ' );
	END IF;
	IF ( b_apellido_materno ) THEN
		SET @consulta = CONCAT( @consulta,'apellido_materno LIKE "',apellido_materno,'%" AND ' );
	END IF;
	IF ( b_telefono ) THEN
		SET @consulta = CONCAT( @consulta,'telefono LIKE "',telefono,'%" AND ' );
	END IF;
	IF ( b_correo_electronico ) THEN
		SET @consulta = CONCAT( @consulta,'correo_electronico LIKE "',correo_electronico,'%" AND ' );
	END IF;
	IF ( b_numero_casa ) THEN
		SET @consulta = CONCAT( @consulta,'numero_casa LIKE "',numero_casa,'%" AND ' );
	END IF;
	IF ( b_calle ) THEN
		SET @consulta = CONCAT( @consulta,'calle LIKE "',calle,'%" AND ' );
	END IF;
	IF ( b_colonia ) THEN
		SET @consulta = CONCAT( @consulta,'colonia LIKE "',colonia,'%" AND ' );
	END IF;
	IF ( b_ciudad ) THEN
		SET @consulta = CONCAT( @consulta,'ciudad LIKE "',ciudad,'%" AND ' );
	END IF;
	IF ( b_estado ) THEN
		SET @consulta = CONCAT( @consulta,'estado LIKE "',estado,'%" AND ' );
	END IF;
	IF ( b_sexo ) THEN
		SET @consulta = CONCAT( @consulta,'sexo LIKE "',sexo,'%" AND ' );
	END IF;
	IF ( b_fecha_nacimiento ) THEN
		SET @consulta = CONCAT( @consulta,'fecha_nacimiento LIKE "',fecha_nacimiento,'%" AND ' );
	END IF;
	IF ( b_moroso ) THEN
		SET @consulta = CONCAT( @consulta,'moroso LIKE "',moroso,'%" AND ' );
	END IF;
	IF ( b_nombre_referencia ) THEN
		SET @consulta = CONCAT( @consulta,'nombre_referencia LIKE "',nombre_referencia,'%" AND ' );
	END IF;
	IF ( b_telefono_referencia ) THEN
		SET @consulta = CONCAT( @consulta,'telefono_referencia LIKE "',telefono_referencia,'%" AND ' );
	END IF;
	IF ( b_direccion_referencia ) THEN
		SET @consulta = CONCAT( @consulta,'direccion_referencia LIKE "',direccion_referencia,'%" AND ' );
	END IF;
	SET @consulta = LEFT( @consulta, CHAR_LENGTH( @consulta ) - 5 );

	/* Si se seleccionaron campos con bandera en true se terminar de concatenar la consulta select en la variable @consulta */
	IF( CHAR_LENGTH( @consulta ) > 0 ) THEN
		SET @consulta = CONCAT( "SELECT * FROM clientes WHERE ", @consulta , ";" );
	/* Si no selecciono ninguna bandera en true para la consulta, se guarda la consulta de toda la tabla en la variable @consulta */
	ELSE
		SET @consulta = "SELECT * FROM clientes;";
	END IF;

	/* Preparamos la consulta */
	PREPARE sentencia FROM @consulta;
    /* Ejecutamos la consulta */
	EXECUTE sentencia;

END;$$

/* Tigger que se dispara cuando un cliente es borrado */
CREATE TRIGGER respaldo_clientes_borrados BEFORE DELETE ON clientes
FOR EACH ROW
BEGIN
	/* Inserta los datos del cliente eliminado como respaldo en la tabla clientes_eliminados */
    INSERT INTO clientes_borrados VALUES
    (
		NOW(),
        USER(),
        IP_CONEXION(),
        
		OLD.rfc,
		OLD.nombres,
		OLD.apellido_paterno,
		OLD.apellido_materno,
		OLD.telefono,
		OLD.correo_electronico,
		OLD.numero_casa,
		OLD.calle,
		OLD.colonia,
		OLD.ciudad,
		OLD.estado,
        OLD.sexo,
        OLD.fecha_nacimiento,
        OLD.moroso,
        OLD.nombre_referencia,
        OLD.telefono_referencia,
        OLD.direccion_referencia
	);
END;$$

/* Tigger que se dispara cuando un cliente es cambiado */
CREATE TRIGGER respaldo_clientes_cambiados BEFORE UPDATE ON clientes
FOR EACH ROW
BEGIN
	/*
		Si hay diferencia entre alguno de los valores anteriores con los nuevo entra al if
        y le hace una copia de seguridad en la tabla distribuidores_cambiados
	*/
	IF
    (
		OLD.rfc != NEW.rfc OR
		OLD.nombres != NEW.nombres OR
		OLD.apellido_paterno != NEW.apellido_paterno OR
		OLD.apellido_materno != NEW.apellido_materno OR
		OLD.telefono != NEW.telefono OR
		OLD.correo_electronico != NEW.correo_electronico OR
		OLD.numero_casa != NEW.numero_casa OR
		OLD.calle != NEW.calle OR
		OLD.colonia != NEW.colonia OR
		OLD.ciudad != NEW.ciudad OR
		OLD.estado != NEW.estado OR
		OLD.sexo != NEW.sexo OR
		OLD.fecha_nacimiento != NEW.fecha_nacimiento OR
		OLD.moroso != NEW.moroso OR
		OLD.nombre_referencia != NEW.nombre_referencia OR
		OLD.telefono_referencia != NEW.telefono_referencia OR
		OLD.direccion_referencia != NEW.direccion_referencia
    )
    THEN
		INSERT INTO clientes_cambiados VALUES
		(
			NOW(),
			USER(),
			IP_CONEXION(),
			
			OLD.rfc,
			OLD.nombres,
			OLD.apellido_paterno,
			OLD.apellido_materno,
			OLD.telefono,
			OLD.correo_electronico,
			OLD.numero_casa,
			OLD.calle,
			OLD.colonia,
			OLD.ciudad,
			OLD.estado,
			OLD.sexo,
			OLD.fecha_nacimiento,
			OLD.moroso,
			OLD.nombre_referencia,
			OLD.telefono_referencia,
			OLD.direccion_referencia,
			
			NEW.rfc,
			NEW.nombres,
			NEW.apellido_paterno,
			NEW.apellido_materno,
			NEW.telefono,
			NEW.correo_electronico,
			NEW.numero_casa,
			NEW.calle,
			NEW.colonia,
			NEW.ciudad,
			NEW.estado,
			NEW.sexo,
			NEW.fecha_nacimiento,
			NEW.moroso,
			NEW.nombre_referencia,
			NEW.telefono_referencia,
			NEW.direccion_referencia
		);
    END IF;
END;$$

DELIMITER ;

/* Tabla y procedimientos almacenados de tasas */

/* Tabla para guardar las tasas */
CREATE TABLE tasas
(
	quincenas INTEGER PRIMARY KEY,
	tasa FLOAT
);

DELIMITER $$

/*
	Que hace:
		Cambia la tasa de interes del numero de quincenas pasado por parametro
	Parametros:
		quincenas de tipo INTEGER es la quincena a la que se le cambiara la tasa de interes,
		tasa de tipo FLOAT la nueva tasa de interes a asignar
	Funcionamiento:
*/
CREATE PROCEDURE cambiar_tasa
(
	quincenas INTEGER,
	tasa FLOAT
)
BEGIN
	/* Se cambia la tasa de interes del numero de quincenas pasado por parametro */
	UPDATE tasas SET tasas.tasa = tasa WHERE tasas.quincenas = quincenas;
    /* Si no se afecto ninguna fula quiere decir que no se agregaron datos distinto a los anteriores */
	IF( ROW_COUNT() = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "No se agregaron datos diferentes a los actuales" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "No se agregaron datos diferentes a los actuales";
	END IF;
END;$$

/*
	Que hace:
		Consulta tasas que concidan con los valores de los parametros
	Parametros:
		quincenas de tipo INTEGER se el numero de quincenas,
		b_quincenas de tipo BOOLEAN bandera para saber si se consultara por quincenas,
		tasa de tipo FLOAT es la tasa de interes,
		b_tasa de tipo BOOLEAN bandera para saber si se consultara por tasa
	Funcionamiento:
*/
CREATE PROCEDURE consultar_tasa
(
	quincenas INTEGER,
	b_quincenas BOOLEAN,
	tasa FLOAT,
	b_tasa BOOLEAN
)
BEGIN

	/* Variable para almacenar la consulta select */
	SET @consulta = "";

	/* Armamos la consulta select en la variable @consulta agregando los parametros si se activo su bandera en true */
	IF ( b_quincenas ) THEN
		SET @consulta = CONCAT( @consulta,'quincenas LIKE "',quincenas,'%" AND ' );
	END IF;
	IF ( b_tasa ) THEN
		SET @consulta = CONCAT( @consulta,'tasa LIKE "',tasa,'%" AND ' );
	END IF;
	SET @consulta = LEFT( @consulta, CHAR_LENGTH( @consulta ) - 5 );

	/* Si se seleccionaron campos con bandera en true se terminar de concatenar la consulta select en la variable @consulta */
	IF( CHAR_LENGTH( @consulta ) > 0 ) THEN
		SET @consulta = CONCAT( "SELECT * FROM tasas WHERE ", @consulta , ";" );
	/* Si no selecciono ninguna bandera en true para la consulta, se guarda la consulta de toda la tabla en la variable @consulta */
	ELSE
		SET @consulta = "SELECT * FROM tasas;";
	END IF;

	/* Ejecutamos la consulta */
	PREPARE sentencia FROM @consulta;
	EXECUTE sentencia;

END;$$

DELIMITER ;

/* Insertamos las tasas con su interes por defecto */
INSERT INTO tasas VALUES ( 4, 10 ), ( 6, 20 ), ( 8, 30 ), ( 10, 40 ), ( 12, 50 );

/* Tablas y procedimientos almacenados de vales */

/* Tabla para almacenar los vales */
CREATE TABLE vales
(
    id VARCHAR(50) PRIMARY KEY,
	rfc_distribuidor VARCHAR(13),
	rfc_cliente VARCHAR(13),
	fecha DATE,
	pagado BOOLEAN,
    
	valor_inicial FLOAT,
    valor_actual FLOAT,
	quincenas INTEGER,
	tasa FLOAT,
    abono FLOAT,

    /* Llaves foraneas */
    INDEX fk_rfc_distribuidor ( rfc_distribuidor ),
    FOREIGN KEY ( rfc_distribuidor ) REFERENCES distribuidores( rfc ),
	INDEX fk_rfc_cliente ( rfc_cliente ),
    FOREIGN KEY ( rfc_cliente ) REFERENCES clientes( rfc ),
	INDEX fk_quincenas ( quincenas ),
    FOREIGN KEY ( quincenas ) REFERENCES tasas( quincenas )
);

DELIMITER $$

/*
	Que hace:
		Procedimiento almacenado que permite agregar otorgar un vale de un distribuidor a un cliente
	Parametros:
		id de tipo VARCHAR(50) es el id que le asigna el distribuidor al vale,
		rfc_distribuidor de tipo VARCHAR(13) es el rfc del distribuidor que otorga el vale,
		rfc_cliente de tipo VARCHAR(13) es el rfc del cliente que obtiene el vale,
		valor_inicial de tipo FLOAT es el valor con el que el cliente obtiene el vale,
		quincenas de tipo INTEGER es el numero de quincenas a las que se pagara la deuda del vale,
		tasa de tipo FLOAT es la tasa de interes asignada al vale,
		abono de tipo FLOAT es la cantidad de dinero que se tiene que pagar cada quincena
    Funcionamiento:
*/
CREATE PROCEDURE agregar_vale
(
	id VARCHAR(50),
	rfc_distribuidor VARCHAR(13),
	rfc_cliente VARCHAR(13),
	valor_inicial FLOAT,
	quincenas INTEGER,
    tasa FLOAT,
    abono FLOAT
)
BEGIN

	/*
		Realizamos un conteo de las coincidencia de la consulta a la tabla vales con la condiciones de que
        la id sea igual la id del vale que asigna el distribuidor, endado caso de que se encuentre una concidencia
        entra al if y eso quiere decir que la id de vale esta duplicada
    */
	IF( ( SELECT COUNT(*) FROM vales WHERE vales.id = id ) = 1 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "El id de vale es duplicado" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El id de vale es duplicado";
	END IF;

	/*
		Realizamos una conteo de las coincidencias de la consulta a la tabal distribuidores con la condicion de que
		el rfc sea igual al rfc del distribuidor que otorga el vale, en dado caso de no encontrar concidencias entra al if
        y eso quiere decir que el distribuidor no existe
    */
	IF( ( SELECT COUNT(*) FROM distribuidores WHERE rfc = rfc_distribuidor ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "El distribuidor no existe" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El distribuidor no existe";
	END IF;

	/*
		Se realiza una consulta a la tabla distribuidores para almacenar el monto de credito del distribuidor que otorga el vale
        en la variable @monto_credito
    */
	SELECT monto_credito INTO @monto_credito FROM distribuidores WHERE rfc = rfc_distribuidor;
	/*
		Se verifica que el monto de credito del distribuidor sea suficiente para cubrir el valor con el que se otorga el vale,
        en caso de no serlo entra en el if y eso quiere decir que el distribuidor no tiene suficiente monto de credito
    */
    IF( @monto_credito <= valor_inicial ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "El distribuidor no tiene suficiente monto de credito" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El distribuidor no tiene suficiente monto de credito";
	END IF;

	/*
		Se realiza un conteo de las coincidencias de la consulta a la tabla clientes con la condicion de que
        el rfc sea igual al rfc del cliente que esta solicitando el vale, en dado caso de no encontrar coincidencias
        entra al if y eso quiere decir que el cliente no existe
    */
	IF( ( SELECT COUNT(*) FROM clientes WHERE rfc = rfc_cliente ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un erro con el mensaje "El cliente no existe" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El cliente no existe";
	END IF;

	/*
		Se realiza un conteo de las coincidencias de la consulta a la tabla vales con la condicion de que
        el rfc_cliente sea igual al rfc del cliente que solicita el vale y pagado igual a false osea que no este pagado,
        en dado caso de encontrar una coincidencia entra al if y eso quiere decir que el cliente tiene deudas
    */
	IF( ( SELECT COUNT(*) FROM vales WHERE vales.rfc_cliente = rfc_cliente AND pagado = false ) = 1 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un erro con el mensaje "El cliente tiene deudas" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El cliente tiene deudas";
	END IF;

	/*
		Se realiza una conteo de las coincidencia de la consulta a la tabla clientes con las condiciones de que
		el rfc sea igual al rfc del cliente que solicita el vale y moroso sea igual a true osea que sea un cliente malo,
        encaso de encontrar una coincidencia entra al if y eso quiere decir que el cliente es moroso
    */
	IF( ( SELECT COUNT(*) FROM clientes WHERE rfc = rfc_cliente AND moroso = true ) = 1 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "El cliente es moroso" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El cliente es moroso";
	END IF;

	/*
		Se realiza un conteo de las coincidencias de la consulta a la tabla tasas con las condiciones de que
        quincenas sea igual a las quincenas que se pagara el vale y la tasa igual a la tasa de interes del vale,
        en caso de no encontrar coincidencias entra al if y eso quiere decir que la tasa de interes esta desactualizada
    */
	IF( ( SELECT COUNT(*) FROM tasas WHERE tasas.tasa = tasa AND tasas.quincenas = quincenas ) = 0 ) THEN
		/* Se cancela el procedimiento almacenado lanzando un error con el mensaje "Tasa de interes inexistente" */
		SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "Tasa de interes inexistente";
	END IF;

	/* Se reliza la insercion del vale en la tabla vales con los parametros */
	INSERT INTO vales VALUES ( id, rfc_distribuidor, rfc_cliente, NOW(), false, valor_inicial, valor_inicial, quincenas, tasa, abono );
	/* Se le descuenta al distribuidor del monto de credito el valor inicial con el que se otorgo el vale */
    UPDATE distribuidores SET monto_credito = @monto_credito - valor_inicial WHERE rfc = rfc_distribuidor;

END;$$

/*
	Que hace:
		Consulta vales que coincidan con lo valores pasados por parametros
	Parametros:
		id de tipo VARCHAR(50) es el id del vale,
		b_id de tipo BOOLEAN es la bandera para consultar por id de vale,
		rfc_distribuidor de tipo VARCHAR(13) es el rfc de distribuidor del vale,
		b_rfc_distribuidor de tipo BOOLEAN es la bandera para consultar por rfc de distribuidor,
		rfc_cliente de tipo VARCHAR(13) es el rfc de cliente del vale,
		b_rfc_cliente de tipo BOOLEAN es la bandera para consultar por rfc de cliente,
		fecha de tipo DATE es la fecha en la que se otorgo el vale,
		b_fecha de tipo BOOLEAN es la bandera para consultar por fecha de vale,
		pagado de tipo BOOLEAN es la bandera para saber si el vale esta pagado,
		b_pagado de tipo BOOLEAN es la bandera para consultar por pagado,
		valor_inicial de tipo FLOAT es el valor inicial del vale,
		b_valor_inicial de tipo BOOLEAN es la bandera para consultar por valor inicial del vale,
		valor_actual de tipo FLOAT es el valor actual del vale,
		b_valor_actual de tipo BOOLEAN es la bandera para consultar por valor actual del vale,
		quincenas de tipo INTEGER es el numero de quincenas en las que otorgo el vale,
		b_quincenas de tipo BOOLEAN es la bandera para consultar por quincenas,
		tasa de tipo FLOAT es la tasa de interes que se le asigno al vale,
		b_tasa de tipo BOOLEAN es la bandera para consultar por tasa,
        abono de tipo FLOAT es la cantidad de dinero que se tiene que pagar cada quincena,
        b_abono de tipo BOOLEAN es la bandera para consultar por abono
    Funcionamiento:
*/
CREATE PROCEDURE consultar_vale
(
	id VARCHAR(50),
	b_id BOOLEAN,
	rfc_distribuidor VARCHAR(13),
	b_rfc_distribuidor BOOLEAN,
	rfc_cliente VARCHAR(13),
	b_rfc_cliente BOOLEAN,
	fecha DATE,
	b_fecha BOOLEAN,
	pagado BOOLEAN,
	b_pagado BOOLEAN,
	valor_inicial FLOAT,
	b_valor_inicial BOOLEAN,
	valor_actual FLOAT,
	b_valor_actual BOOLEAN,
	quincenas INTEGER,
	b_quincenas BOOLEAN,
	tasa FLOAT,
	b_tasa BOOLEAN,
    abono FLOAT,
    b_abono BOOLEAN
)
BEGIN
	/* Variable para armar la consulta select */
	SET @consulta = "";
	/* Armamos la consulta select en la variable @consulta agregando los parametros si se activo su bandera */
	IF ( b_id ) THEN
		SET @consulta = CONCAT( @consulta,'id LIKE "',id,'%" AND ' );
	END IF;
	IF ( b_rfc_distribuidor ) THEN
		SET @consulta = CONCAT( @consulta,'rfc_distribuidor LIKE "',rfc_distribuidor,'%" AND ' );
	END IF;
	IF ( b_rfc_cliente ) THEN
		SET @consulta = CONCAT( @consulta,'rfc_cliente LIKE "',rfc_cliente,'%" AND ' );
	END IF;
	IF ( b_fecha ) THEN
		SET @consulta = CONCAT( @consulta,'fecha LIKE "',fecha,'%" AND ' );
	END IF;
	IF ( b_pagado ) THEN
		SET @consulta = CONCAT( @consulta,'pagado LIKE "',pagado,'%" AND ' );
	END IF;
	IF ( b_valor_inicial ) THEN
		SET @consulta = CONCAT( @consulta,'valor_inicial LIKE "',valor_inicial,'%" AND ' );
	END IF;
	IF ( b_valor_actual ) THEN
		SET @consulta = CONCAT( @consulta,'valor_actual LIKE "',valor_actual,'%" AND ' );
	END IF;
	IF ( b_quincenas ) THEN
		SET @consulta = CONCAT( @consulta,'quincenas LIKE "',quincenas,'%" AND ' );
	END IF;
	IF ( b_tasa ) THEN
		SET @consulta = CONCAT( @consulta,'tasa LIKE "',tasa,'%" AND ' );
	END IF;
	IF ( b_abono ) THEN
		SET @consulta = CONCAT( @consulta,'abono LIKE "',abono,'%" AND ' );
	END IF;
	SET @consulta = LEFT( @consulta, CHAR_LENGTH( @consulta ) - 5 );

	/* Si se selecciono por lo menos una bandera en true, podemos terminar de armar la consulta dentro del if */
	IF( CHAR_LENGTH( @consulta ) > 0 ) THEN
		/* Terminamos de armar la consulta */
		SET @consulta = CONCAT( "SELECT * FROM vales WHERE ", @consulta , ";" );
	/* Sino se selecciono ninguna bandera para consultar, guardamos una consulta de toda la tabla en la variable @consulta */
	ELSE
		SET @consulta = "SELECT * FROM vales;";
	END IF;

	/* Preparamos la consulta */
	PREPARE sentencia FROM @consulta;
    /* Ejecutamos la consulta */
	EXECUTE sentencia;

END;$$

DELIMITER ;

/* Tablas y procedimientos de abonos */

/* Tabla para guardar los abonos */
CREATE TABLE abonos
(
	/* id INTEGER AUTO_INCREMENT PRIMARY KEY, */
    id_vale VARCHAR(50),
    fecha DATE,
    /* llaves */
	INDEX fk_id_vale ( id_vale ),
    FOREIGN KEY ( id_vale ) REFERENCES vales( id )
);

DELIMITER $$

/*
	Que hace:
		Procedimiento almacenado para agregar abonos
	Parametros:
		id_vale de tipo VARCHAR(50) es el id del vale al que se le abonara
*/
CREATE PROCEDURE agregar_abono
(
	id_vale VARCHAR(50)
)
BEGIN
    
    /*
		Realiza un conteo de las coincidencias de la consulta a la tabla vales con las condiciones de que
		el id sea igual al id de vale a abonar si no encuentra coincidencias entra al if,
        eso quiere decir que el vale no existe
    */
	IF( ( SELECT COUNT(*) FROM vales WHERE id = id_vale ) = 0 ) THEN
		/* Cancela el procedimiento almacenando lanzando un error con el mensaje "El vale no existe" */
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El vale no existe";
	END IF;

	/*
		Se realiza una select a la tabla vales seleccionado quincenas y guardandolas en la variable @quincenas
		con la condicion de que el id sea igual al id del vale a abonar, esta variable representa
        las quincenas totales a pagar
    */
	SELECT quincenas INTO @quincenas FROM vales WHERE id = id_vale;
    /*
		Se realiza un conteo de las condiciones de la consulta a la tabla abonos con las condiciones de que
        id_vale sea igual a la id del del vale a abonar guardandolo en @quincenas_pagadas, esta variable
        representa las quincenas pagadas del vale a pagar
    */
    SELECT COUNT(*) INTO @quincenas_pagadas FROM abonos WHERE abonos.id_vale = id_vale;
    /* Si las quinceanas a pagar es igual a las quincenas pagadas entra al if y quiere decir que el vale ya esta pagado */
	IF( @quincenas = @quincenas_pagadas ) THEN
		/* Cancela el procedimiento almacenando lanzando un error con el mensaje "El vale ya esta pagado" */
        SIGNAL SQLSTATE "45000" SET MESSAGE_TEXT = "El vale ya esta pagado";
	END IF;

	/* Se inserta el abono en la tabla abonos */
	INSERT INTO abonos /*( abonos.id_vale, fecha )*/ VALUES ( id_vale, NOW() );
        
	/* Si la quincenas por pagar es igual a las quincenas pagadas actualmente entra al if y esto quiere decir que el vale ya esta pagado */
	IF( @quincenas = @quincenas_pagadas + 1 ) THEN
		/* Marcamos el vale como pagado */
		UPDATE vales SET pagado = true WHERE id = id_vale;
	END IF;

END;$$

/*
	Que hace:
		Consulta abonos que coincidan con los valores pasados por parametro
	Parametros:
		id_vale de tipo VARCHAR(50) es el id de vale a consultar,
		b_id_vale de tipo BOOLEAN bandera para saber si es consultara por el id de vale,
		fecha de tipo DATE es la fecha en la que se realizo el vale a consultar,
		b_fecha de tipo BOOLEAN bandera para saber si se consultara por la fecha del vale
    Funcionamiento:
*/
CREATE PROCEDURE consultar_abono
(
	id_vale VARCHAR(50),
	b_id_vale BOOLEAN,
	fecha DATE,
	b_fecha BOOLEAN
)
BEGIN

	/* Variable para armar la consulta select */
	SET @consulta = "";
    
	/* Armamos la consulta select en la variable @consulta agregando los parametros si se activo su bandera */
	IF ( b_id_vale ) THEN
		SET @consulta = CONCAT( @consulta,'id_vale LIKE "',id_vale,'%" AND ' );
	END IF;
	IF ( b_fecha ) THEN
		SET @consulta = CONCAT( @consulta,'fecha LIKE "',fecha,'%" AND ' );
	END IF;
	SET @consulta = LEFT( @consulta, CHAR_LENGTH( @consulta ) - 5 );

	/* Si se selecciono por lo menos una bandera en true, podemos terminar de armar la consulta dentro del if */
	IF( CHAR_LENGTH( @consulta ) > 0 ) THEN
		/* Terminamos de armar la consulta */
		SET @consulta = CONCAT( "SELECT * FROM abonos WHERE ", @consulta , ";" );
	/* Sino se selecciono ninguna bandera para consultar, guardamos una consulta de toda la tabla en la variable @consulta */
	ELSE
		SET @consulta = "SELECT * FROM abonos;";
	END IF;

	/* Preparamos la consulta */
	PREPARE sentencia FROM @consulta;
    /* Ejecutamos la consulta */
	EXECUTE sentencia;

END;$$

DELIMITER ;

/* Vistas de reportes */

/* Muestra cuanto tetienen que pagar los distribuidores */
CREATE VIEW vista_reporte_cobranza AS
SELECT
distribuidores.rfc,
distribuidores.nombres,
distribuidores.telefono,
FORMAT ( SUM( vales.abono ) , 2 )
FROM
distribuidores,
vales
WHERE
distribuidores.rfc = vales.rfc_distribuidor
AND
vales.pagado = false
GROUP BY
vales.rfc_distribuidor;

/* Muestra todos los clientes que faltan por pagar */
CREATE VIEW vista_reporte_clientes AS
SELECT
clientes.rfc,
clientes.nombres,
clientes.telefono,
FORMAT ( SUM( vales.abono ) , 2 )
FROM
clientes,
vales
WHERE
clientes.rfc = vales.rfc_cliente
AND
vales.pagado = false
GROUP BY
vales.rfc_cliente;

/* Muestra todos los ditribuidores */
CREATE VIEW vista_reporte_distribuidores AS
SELECT
distribuidores.rfc,
distribuidores.nombres,
distribuidores.limite_credito,
distribuidores.monto_credito
FROM
distribuidores;

/* Muestra todos los clientes morosos */
CREATE VIEW vista_reporte_morosos AS
SELECT
clientes.rfc,
clientes.nombres,
clientes.telefono,
clientes.correo_electronico
FROM
clientes
WHERE
clientes.moroso = true;

/* Creacion de usuarios */

/*
	Creamos un usario que solo tiene permiso de ejecutar:
		Todos los procedimientos almacenados y las vistas
*/

DROP USER IF EXISTS 'usuario_abcc'@'%';
CREATE USER 'usuario_abcc'@'%' IDENTIFIED BY 'C5GJ6t6vG6Ta5cD5';

/*GRANT INSERT, DELETE, UPDATE, SELECT ON distribuidores TO 'usuario_abcc'@'%';*/
GRANT EXECUTE ON PROCEDURE agregar_distribuidor TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE borrar_distribuidor TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE cambiar_distribuidor TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE consultar_distribuidor TO 'usuario_abcc'@'%';

/*GRANT INSERT, DELETE, UPDATE, SELECT ON clientes TO 'usuario_abcc'@'%';*/
GRANT EXECUTE ON PROCEDURE agregar_cliente TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE borrar_cliente TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE cambiar_cliente TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE consultar_cliente TO 'usuario_abcc'@'%';

/*GRANT INSERT, DELETE, UPDATE, SELECT ON vales TO 'usuario_abcc'@'%';*/
GRANT EXECUTE ON PROCEDURE agregar_vale TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE consultar_vale TO 'usuario_abcc'@'%';

/*GRANT INSERT, DELETE, UPDATE, SELECT ON abonos TO 'usuario_abcc'@'%';*/
GRANT EXECUTE ON PROCEDURE agregar_abono TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE consultar_abono TO 'usuario_abcc'@'%';

/*GRANT INSERT, DELETE, UPDATE, SELECT ON tasas TO 'usuario_abcc'@'%';*/
GRANT EXECUTE ON PROCEDURE cambiar_tasa TO 'usuario_abcc'@'%';
GRANT EXECUTE ON PROCEDURE consultar_tasa TO 'usuario_abcc'@'%';

GRANT SELECT ON vista_reporte_cobranza TO 'usuario_abcc'@'%';
GRANT SELECT ON vista_reporte_clientes TO 'usuario_abcc'@'%';
GRANT SELECT ON vista_reporte_distribuidores TO 'usuario_abcc'@'%';
GRANT SELECT ON vista_reporte_morosos TO 'usuario_abcc'@'%';
