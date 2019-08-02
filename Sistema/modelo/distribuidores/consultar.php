<?PHP
    /*
        Que hace:
            Consultar un distribuidor en la base de datos ejecutando una consulta a un procedimiento almacenado en la base de datos
        Procedimiento:
    */
    /* Intenta abrir una conexion con la base de datos y jecutar una consulta */
    try
    {
        include '../conexion.php';

        /* Prepara una llamada a un procedimiento almacenado preparandolo en la variable preparada */
        $preparada = $conexion->prepare( "CALL consultar_distribuidor( :rfc, :b_rfc, :nombres, :b_nombres, :apellido_paterno, :b_apellido_paterno, :apellido_materno, :b_apellido_materno, :telefono, :b_telefono, :correo_electronico, :b_correo_electronico, :numero_casa, :b_numero_casa, :calle, :b_calle, :colonia, :b_colonia, :ciudad, :b_ciudad, :estado, :b_estado, :limite_credito, :b_limite_credito, :monto_credito, :b_monto_credito );" );
        /* Agrega los parametros a la consulta preparada */
        $preparada->bindValue( ":rfc", $_POST[ "rfc" ] );
        $preparada->bindValue( ":b_rfc", $_POST[ "b_rfc" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":nombres", $_POST[ "nombres" ] );
        $preparada->bindValue( ":b_nombres", $_POST[ "b_nombres" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":apellido_paterno", $_POST[ "apellido_paterno" ] );
        $preparada->bindValue( ":b_apellido_paterno", $_POST[ "b_apellido_paterno" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":apellido_materno", $_POST[ "apellido_materno" ] );
        $preparada->bindValue( ":b_apellido_materno", $_POST[ "b_apellido_materno" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":telefono", $_POST[ "telefono" ] );
        $preparada->bindValue( ":b_telefono", $_POST[ "b_telefono" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":correo_electronico", $_POST[ "correo_electronico" ] );
        $preparada->bindValue( ":b_correo_electronico", $_POST[ "b_correo_electronico" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":numero_casa", $_POST[ "numero_casa" ] );
        $preparada->bindValue( ":b_numero_casa", $_POST[ "b_numero_casa" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":calle", $_POST[ "calle" ] );
        $preparada->bindValue( ":b_calle", $_POST[ "b_calle" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":colonia", $_POST[ "colonia" ] );
        $preparada->bindValue( ":b_colonia", $_POST[ "b_colonia" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":ciudad", $_POST[ "ciudad" ] );
        $preparada->bindValue( ":b_ciudad", $_POST[ "b_ciudad" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":estado", $_POST[ "estado" ] );
        $preparada->bindValue( ":b_estado", $_POST[ "b_estado" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":limite_credito", $_POST[ "limite_credito" ] );
        $preparada->bindValue( ":b_limite_credito", $_POST[ "b_limite_credito" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( ":monto_credito", $_POST[ "monto_credito" ] );
        $preparada->bindValue( ":b_monto_credito", $_POST[ "b_monto_credito" ] == "true", PDO::PARAM_BOOL );
        
        /*
            Ejecuta la consulta preparada, si regresa false significa que algo salio mal,
            y entra al if mandando un erro con el mensaje del error ocurrido
        */
        if( !$preparada->execute() )
        {
            throw new PDOException( $preparada->errorInfo()[2] );
        }
        
        /* Si todo salio bien regresa la informacion debida */
        echo json_encode( $preparada->fetchAll( PDO::FETCH_ASSOC ) );
    }
    /* Si ocurre algun error al conectar o realizar una consulta a la base de datos retorna el mensaje de error */
    catch( PDOException $error )
    {
        echo $error->getMessage();
    }
?>
