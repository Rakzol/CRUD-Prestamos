<?PHP
    /*
        Que hace:
            Agrega un cliente en la base de datos ejecutando una consulta a un procedimiento almacenado en la base de datos
        Procedimiento:
    */
    /* Intenta abrir una conexion con la base de datos y jecutar una consulta */
    try
    {
        include '../conexion.php';

        /* Prepara una llamada a un procedimiento almacenado preparandolo en la variable preparada */
        $preparada = $conexion->prepare( "CALL agregar_cliente( :rfc, :nombres, :apellido_paterno, :apellido_materno, :telefono, :correo_electronico, :numero_casa, :calle, :colonia, :ciudad, :estado, :sexo, :fecha_nacimiento, :nombre_referencia, :telefono_referencia, :direccion_referencia );" );
        /* Agrega los parametros a la consulta preparada */
        $preparada->bindValue( ":rfc", $_POST[ "rfc" ] );
        $preparada->bindValue( ":nombres", $_POST[ "nombres" ] );
        $preparada->bindValue( ":apellido_paterno", $_POST[ "apellido_paterno" ] );
        $preparada->bindValue( ":apellido_materno", $_POST[ "apellido_materno" ] );
        $preparada->bindValue( ":telefono", $_POST[ "telefono" ] );
        $preparada->bindValue( ":correo_electronico", $_POST[ "correo_electronico" ] );
        $preparada->bindValue( ":numero_casa", $_POST[ "numero_casa" ] );
        $preparada->bindValue( ":calle", $_POST[ "calle" ] );
        $preparada->bindValue( ":colonia", $_POST[ "colonia" ] );
        $preparada->bindValue( ":ciudad", $_POST[ "ciudad" ] );
        $preparada->bindValue( ":estado", $_POST[ "estado" ] );
        $preparada->bindValue( ":sexo", $_POST[ "sexo" ] );
        $preparada->bindValue( ":fecha_nacimiento", $_POST[ "fecha_nacimiento" ] );
        $preparada->bindValue( ":nombre_referencia", $_POST[ "nombre_referencia" ] );
        $preparada->bindValue( ":telefono_referencia", $_POST[ "telefono_referencia" ] );
        $preparada->bindValue( ":direccion_referencia", $_POST[ "direccion_referencia" ] );
        
        /*
            Ejecuta la consulta preparada, si regresa false significa que algo salio mal,
            y entra al if mandando un erro con el mensaje del error ocurrido
        */
        if( !$preparada->execute() )
        {
            throw new PDOException( $preparada->errorInfo()[2] );
        }
        
        /* Si todo salio bien regresa la informacion debida */
        echo "Cliente agregado";
    }
    /* Si ocurre algun error al conectar o realizar una consulta a la base de datos retorna el mensaje de error */
    catch( PDOException $error )
    {
        echo $error->getMessage();
    }
?>
