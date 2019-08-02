<?PHP
    /*
        Que hace:
            Consultar un vale en la base de datos ejecutando una consulta a un procedimiento almacenado en la base de datos
        Procedimiento:
    */
    /* Intenta abrir una conexion con la base de datos y jecutar una consulta */
    try
    {
        include '../conexion.php';

        /* Prepara una llamada a un procedimiento almacenado preparandolo en la variable preparada */
        $preparada = $conexion->prepare( "CALL consultar_vale( :id, :b_id, :rfc_distribuidor, :b_rfc_distribuidor, :rfc_cliente, :b_rfc_cliente, :fecha, :b_fecha, :pagado, :b_pagado, :valor_inicial, :b_valor_inicial, :valor_actual, :b_valor_actual, :quincenas, :b_quincenas, :tasa, :b_tasa, :abono, :b_abono );" );
        /* Agrega los parametros a la consulta preparada */
        $preparada->bindValue( "id", $_POST[ "id" ] );
        $preparada->bindValue( "b_id", $_POST[ "b_id" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "rfc_distribuidor", $_POST[ "rfc_distribuidor" ] );
        $preparada->bindValue( "b_rfc_distribuidor", $_POST[ "b_rfc_distribuidor" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "rfc_cliente", $_POST[ "rfc_cliente" ] );
        $preparada->bindValue( "b_rfc_cliente", $_POST[ "b_rfc_cliente" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "fecha", $_POST[ "fecha" ] );
        $preparada->bindValue( "b_fecha", $_POST[ "b_fecha" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "pagado", $_POST[ "pagado" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "b_pagado", $_POST[ "b_pagado" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "valor_inicial", $_POST[ "valor_inicial" ] );
        $preparada->bindValue( "b_valor_inicial", $_POST[ "b_valor_inicial" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "valor_actual", $_POST[ "valor_actual" ] );
        $preparada->bindValue( "b_valor_actual", $_POST[ "b_valor_actual" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "quincenas", $_POST[ "quincenas" ] );
        $preparada->bindValue( "b_quincenas", $_POST[ "b_quincenas" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "tasa", $_POST[ "tasa" ] );
        $preparada->bindValue( "b_tasa", $_POST[ "b_tasa" ] == "true", PDO::PARAM_BOOL );
        $preparada->bindValue( "abono", $_POST[ "abono" ] );
        $preparada->bindValue( "b_abono", $_POST[ "b_abono" ] == "true", PDO::PARAM_BOOL );
        
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
